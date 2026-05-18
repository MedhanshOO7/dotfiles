local function detect_image_backend()
    -- User explicitly uses Kitty, force backend
    return "kitty"
end

local image_backend = detect_image_backend()
local image_enabled = image_backend ~= "none"

local function jupytext_bin()
    local local_bin = vim.fn.expand("~/.venvs/neovim/bin/jupytext")
    if vim.fn.executable(local_bin) == 1 then
        return local_bin
    end

    return "jupytext"
end

local function sync_notebook(ipynb_path)
    local jupytext = jupytext_bin()
    if vim.fn.executable(jupytext) ~= 1 then
        vim.notify("jupytext is not installed in ~/.venvs/neovim yet", vim.log.levels.WARN)
        return false
    end

    local result = vim.system({
        jupytext,
        "--set-formats",
        "ipynb,py:percent",
        "--sync",
        ipynb_path,
    }, { text = true }):wait()

    if result.code ~= 0 then
        vim.notify(
            ("jupytext sync failed for %s:\n%s"):format(ipynb_path, result.stderr or result.stdout or ""),
            vim.log.levels.ERROR
        )
        return false
    end

    return true
end

local function percent_path(ipynb_path)
    return ipynb_path:gsub("%.ipynb$", ".py")
end

local function ensure_jupyter_dirs()
    local config_dir = vim.fn.expand("~/.jupyter")
    local runtime_dir = vim.fn.expand("~/.local/share/jupyter/runtime")

    vim.fn.mkdir(config_dir, "p")
    vim.fn.mkdir(runtime_dir, "p")

    vim.env.JUPYTER_CONFIG_DIR = config_dir
    vim.env.JUPYTER_RUNTIME_DIR = runtime_dir
end

local function open_notebook_buffer(args)
    local ipynb_path = vim.fn.fnamemodify(args.file, ":p")
    if ipynb_path == "" or vim.bo[args.buf].buftype ~= "" then
        return
    end

    if vim.b[args.buf].molten_notebook_redirecting then
        return
    end

    if not sync_notebook(ipynb_path) then
        return
    end

    local py_path = percent_path(ipynb_path)
    vim.g.__molten_ipynb_pairs = vim.g.__molten_ipynb_pairs or {}
    vim.g.__molten_ipynb_pairs[py_path] = ipynb_path

    vim.b[args.buf].molten_notebook_redirecting = true
    vim.bo[args.buf].bufhidden = "wipe"

    vim.cmd("keepalt edit " .. vim.fn.fnameescape(py_path))
    vim.b.molten_ipynb_source = ipynb_path
end

return {
    {
        "3rd/image.nvim",
        enabled = image_enabled,
        opts = function()
            return {
                backend = image_backend,
                processor = "magick_cli",
                integrations = {
                    markdown = {
                        enabled = false,
                    },
                    html = {
                        enabled = false,
                    },
                    css = {
                        enabled = false,
                    },
                },
            }
        end,
    },
    {
        "benlubas/molten-nvim",
        build = ":UpdateRemotePlugins",
        event = { "BufReadPost", "BufNewFile" },
        cmd = {
            "MoltenInit",
            "MoltenEvaluateOperator",
            "MoltenEvaluateLine",
            "MoltenEvaluateVisual",
            "MoltenDelete",
            "MoltenHideOutput",
            "MoltenShowOutput",
            "MoltenRestart",
            "MoltenOpenInBrowser",
        },
        dependencies = image_enabled and { "3rd/image.nvim" } or {},
        init = function()
            ensure_jupyter_dirs()

            vim.g.molten_image_provider = image_enabled and "image.nvim" or "none"
            vim.g.molten_output_win_style = "minimal"
            vim.g.molten_virt_text_output = true
            vim.g.molten_auto_open_output = false
            vim.g.molten_wrap_output = true
            vim.g.molten_enter_output_behavior = "open_then_enter"

            if not image_enabled then
                vim.schedule(function()
                    vim.notify(
                        "Molten image rendering disabled: neither kitty graphics nor ueberzug were detected",
                        vim.log.levels.WARN
                    )
                end)
            end

            local jupytext_group = vim.api.nvim_create_augroup("molten_jupytext", { clear = true })

            vim.api.nvim_create_autocmd("BufEnter", {
                group = jupytext_group,
                pattern = "*.ipynb",
                callback = open_notebook_buffer,
            })

            vim.api.nvim_create_autocmd("BufEnter", {
                group = jupytext_group,
                pattern = "*.py",
                callback = function(args)
                    local py_path = vim.fn.fnamemodify(args.file, ":p")
                    local pairs = vim.g.__molten_ipynb_pairs or {}
                    local ipynb_path = pairs[py_path]
                    if ipynb_path then
                        vim.b[args.buf].molten_ipynb_source = ipynb_path
                    end
                end,
            })

            vim.api.nvim_create_autocmd("BufWritePost", {
                group = jupytext_group,
                pattern = "*.py",
                callback = function(args)
                    local ipynb_path = vim.b[args.buf].molten_ipynb_source
                    if not ipynb_path then
                        return
                    end

                    local jupytext = jupytext_bin()
                    if vim.fn.executable(jupytext) ~= 1 then
                        vim.notify("jupytext is not installed in ~/.venvs/neovim yet", vim.log.levels.WARN)
                        return
                    end

                    local result = vim.system({
                        jupytext,
                        "--sync",
                        vim.fn.fnamemodify(args.file, ":p"),
                    }, { text = true }):wait()

                    if result.code ~= 0 then
                        vim.notify(
                            ("jupytext write-back failed for %s:\n%s"):format(
                                ipynb_path,
                                result.stderr or result.stdout or ""
                            ),
                            vim.log.levels.ERROR
                        )
                    end
                end,
            })
        end,
    },
}

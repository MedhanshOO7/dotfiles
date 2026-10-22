return {
    "linux-cultist/venv-selector.nvim",

    ft = "python",

    cmd = {
        "VenvSelect",
        "VenvSelectLog",
    },

    dependencies = {
        "neovim/nvim-lspconfig",
        "mfussenegger/nvim-dap-python",
    },

    opts = {
        options = {
            notify_user_on_venv_activation = true,

            -- Keep the selected environment synchronized with Python LSP.
            on_venv_activate_callback = function()
                local venv = vim.env.VIRTUAL_ENV

                if not venv or venv == "" then
                    return
                end

                venv = vim.fs.normalize(venv)

                local python = vim.fs.joinpath(venv, "bin", "python")

                if vim.fn.executable(python) ~= 1 then
                    vim.notify(
                        "Python interpreter not found: " .. python,
                        vim.log.levels.ERROR,
                        { title = "Python" }
                    )
                    return
                end

                -- Store it so other Python tooling can use the same interpreter.
                vim.g.python_venv = venv
                vim.g.python_venv_python = python

                -- Restart basedpyright so it reads the newly selected interpreter.
                -- (:LspStart is not defined by nvim-lspconfig on Nvim 0.12+.)
                if #vim.lsp.get_clients({ name = "basedpyright" }) > 0 then
                    vim.schedule(function()
                        vim.cmd(vim.fn.exists(":lsp") == 2 and "lsp restart basedpyright" or "LspRestart basedpyright")
                    end)
                end

                vim.notify(
                    "Python environment: " .. vim.fn.fnamemodify(venv, ":t"),
                    vim.log.levels.INFO,
                    { title = "Python" }
                )
            end,
        },
    },

    keys = {
        {
            "<leader>Pv",
            "<cmd>VenvSelect<cr>",
            desc = "Python: Select VirtualEnv",
            ft = "python",
        },

        {
            "<leader>Pm",
            function()
                local file = vim.api.nvim_buf_get_name(0)
                local file_dir = (file ~= "" and vim.fs.dirname(file)) or vim.fn.getcwd()

                local project_root = vim.fs.root(file_dir, {
                    "pyproject.toml",
                    "requirements.txt",
                    "Pipfile",
                    ".git",
                }) or file_dir

                project_root = vim.fs.normalize(project_root)

                vim.ui.input({
                    prompt = string.format(
                        "Create venv in %s: ",
                        vim.fn.fnamemodify(project_root, ":~")
                    ),
                    default = ".venv",
                }, function(venv_name)
                    if not venv_name or vim.trim(venv_name) == "" then
                        return
                    end

                    venv_name = vim.trim(venv_name)

                    if venv_name:match("[/\\]") then
                        vim.notify(
                            "Please enter a venv name only, such as .venv",
                            vim.log.levels.ERROR,
                            { title = "Python" }
                        )
                        return
                    end

                    local venv_path =
                        vim.fs.normalize(vim.fs.joinpath(project_root, venv_name))

                    if vim.fn.isdirectory(venv_path) == 1 then
                        vim.notify(
                            "Virtual environment already exists: "
                                .. vim.fn.fnamemodify(venv_path, ":~"),
                            vim.log.levels.WARN,
                            { title = "Python" }
                        )
                        return
                    end

                    vim.notify(
                        "Creating virtual environment at "
                            .. vim.fn.fnamemodify(venv_path, ":~")
                            .. " ...",
                        vim.log.levels.INFO,
                        { title = "Python" }
                    )

                    local function finish(result)
                        if result.code == 0
                            and vim.fn.isdirectory(venv_path) == 1
                        then
                            vim.notify(
                                "Virtual environment created: "
                                    .. vim.fn.fnamemodify(venv_path, ":~")
                                    .. " ✓",
                                vim.log.levels.INFO,
                                { title = "Python" }
                            )

                            vim.schedule(function()
                                vim.cmd("VenvSelect")
                            end)
                        else
                            local output = vim.trim(
                                (result.stdout or "") .. (result.stderr or "")
                            )

                            vim.notify(
                                "Failed to create virtual environment"
                                    .. (output ~= "" and ":\n" .. output or ""),
                                vim.log.levels.ERROR,
                                { title = "Python" }
                            )
                        end
                    end

                    if vim.fn.executable("uv") == 1 then
                        vim.system(
                            { "uv", "venv", venv_path },
                            { text = true },
                            finish
                        )
                    elseif vim.fn.executable("python3") == 1 then
                        vim.system(
                            { "python3", "-m", "venv", venv_path },
                            { text = true },
                            finish
                        )
                    else
                        vim.notify(
                            "Neither 'uv' nor 'python3' is available",
                            vim.log.levels.ERROR,
                            { title = "Python" }
                        )
                    end
                end)
            end,
            desc = "Python: Make VirtualEnv",
            ft = "python",
        },

        {
            "<leader>Pi",
            function()
                local package = vim.trim(
                    vim.fn.input("Install Python package: ")
                )

                if package == "" then
                    return
                end

                local python = vim.fn.exepath("python3")

                if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
                    local venv_python = vim.fs.joinpath(
                        vim.env.VIRTUAL_ENV,
                        "bin",
                        "python"
                    )

                    if vim.fn.executable(venv_python) == 1 then
                        python = venv_python
                    end
                end

                if python == "" then
                    vim.notify(
                        "No Python interpreter found",
                        vim.log.levels.ERROR,
                        { title = "Python" }
                    )
                    return
                end

                vim.notify(
                    "Installing " .. package .. " ...",
                    vim.log.levels.INFO,
                    { title = "Python" }
                )

                local command

                if vim.fn.executable("uv") == 1 then
                    command = {
                        "uv",
                        "pip",
                        "install",
                        "--python",
                        python,
                        package,
                    }
                else
                    command = {
                        python,
                        "-m",
                        "pip",
                        "install",
                        package,
                    }
                end

                vim.system(command, { text = true }, function(result)
                    vim.schedule(function()
                        if result.code == 0 then
                            vim.notify(
                                "Successfully installed: "
                                    .. package
                                    .. " ✓",
                                vim.log.levels.INFO,
                                { title = "Python" }
                            )
                        else
                            local output = vim.trim(
                                (result.stdout or "")
                                    .. (result.stderr or "")
                            )

                            vim.notify(
                                "Failed to install "
                                    .. package
                                    .. (output ~= "" and ":\n" .. output or ""),
                                vim.log.levels.ERROR,
                                { title = "Python" }
                            )
                        end
                    end)
                end)
            end,
            desc = "Python: Install package",
            ft = "python",
        },

        {
            "<leader>PR",
            function()
                local req_file = vim.fs.find("requirements.txt", {
                    upward = true,
                    path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
                })[1]

                if not req_file then
                    vim.notify(
                        "No requirements.txt found in project",
                        vim.log.levels.WARN,
                        { title = "Python" }
                    )
                    return
                end

                local python = vim.fn.exepath("python3")

                if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
                    local venv_python = vim.fs.joinpath(
                        vim.env.VIRTUAL_ENV,
                        "bin",
                        "python"
                    )

                    if vim.fn.executable(venv_python) == 1 then
                        python = venv_python
                    end
                end

                if python == "" then
                    vim.notify(
                        "No Python interpreter found",
                        vim.log.levels.ERROR,
                        { title = "Python" }
                    )
                    return
                end

                vim.notify(
                    "Installing dependencies from "
                        .. vim.fn.fnamemodify(req_file, ":~")
                        .. " ...",
                    vim.log.levels.INFO,
                    { title = "Python" }
                )

                local command

                if vim.fn.executable("uv") == 1 then
                    command = {
                        "uv",
                        "pip",
                        "install",
                        "--python",
                        python,
                        "-r",
                        req_file,
                    }
                else
                    command = {
                        python,
                        "-m",
                        "pip",
                        "install",
                        "-r",
                        req_file,
                    }
                end

                vim.system(command, { text = true }, function(result)
                    vim.schedule(function()
                        if result.code == 0 then
                            vim.notify(
                                "Successfully installed requirements ✓",
                                vim.log.levels.INFO,
                                { title = "Python" }
                            )
                        else
                            local output = vim.trim(
                                (result.stdout or "")
                                    .. (result.stderr or "")
                            )

                            vim.notify(
                                "Failed to install requirements"
                                    .. (output ~= "" and ":\n" .. output or ""),
                                vim.log.levels.ERROR,
                                { title = "Python" }
                            )
                        end
                    end)
                end)
            end,
            desc = "Python: Install requirements.txt",
            ft = "python",
        },

        {
            "<leader>Pr",
            function()
                local file = vim.api.nvim_buf_get_name(0)

                if file == "" then
                    vim.notify(
                        "Current buffer has no file",
                        vim.log.levels.WARN,
                        { title = "Python" }
                    )
                    return
                end

                local python = vim.fn.exepath("python3")

                if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
                    local venv_python = vim.fs.joinpath(
                        vim.env.VIRTUAL_ENV,
                        "bin",
                        "python"
                    )

                    if vim.fn.executable(venv_python) == 1 then
                        python = venv_python
                    end
                end

                if python == "" then
                    vim.notify(
                        "No Python interpreter found",
                        vim.log.levels.ERROR,
                        { title = "Python" }
                    )
                    return
                end

                vim.notify(
                    "Running "
                        .. vim.fn.fnamemodify(file, ":t")
                        .. " ...",
                    vim.log.levels.INFO,
                    { title = "Python" }
                )

                vim.system(
                    { python, file },
                    {
                        text = true,
                        cwd = vim.fs.dirname(file),
                    },
                    function(result)
                        vim.schedule(function()
                            if result.code == 0 then
                                vim.notify(
                                    "Python process finished ✓",
                                    vim.log.levels.INFO,
                                    { title = "Python" }
                                )
                            else
                                local output = vim.trim(
                                    (result.stdout or "")
                                        .. (result.stderr or "")
                                )

                                vim.notify(
                                    "Python process exited with code "
                                        .. result.code
                                        .. (
                                            output ~= ""
                                                and ":\n" .. output
                                            or ""
                                        ),
                                    vim.log.levels.ERROR,
                                    { title = "Python" }
                                )
                            end
                        end)
                    end
                )
            end,
            desc = "Python: Run current file",
            ft = "python",
        },
    },
}

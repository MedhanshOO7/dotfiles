return {
    "stevearc/overseer.nvim",
    cmd = { "OverseerToggle", "OverseerOpen", "OverseerClose", "OverseerRun", "OverseerShell", "OverseerTaskAction" },
    keys = {
        { "<leader>tt", "<cmd>OverseerToggle<cr>", desc = "Open or close the task list" },
        { "<leader>tr", "<cmd>OverseerRun<cr>", desc = "Choose and run a project task" },
        { "<leader>ta", "<cmd>OverseerTaskAction<cr>", desc = "Run a task action on the current item" },
    },
    opts = {
        task_list = {
            direction = "bottom",
            min_height = 10,
            max_height = 16,
        },
        component_aliases = {
            -- overseer v2 defaults, plus diagnostics parsed from task results
            default = {
                "on_exit_set_status",
                "on_complete_notify",
                { "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
                "on_result_diagnostics",
            },
        },
        -- Template definitions contributed by other specs (lua/plugins/zephyr.lua).
        -- Not an overseer option: registered after setup() below.
        extra_templates = {},
    },
    config = function(_, opts)
        local extra_templates = opts.extra_templates or {}
        opts.extra_templates = nil
        require("overseer").setup(opts)

        local overseer = require("overseer")
        for _, template in ipairs(extra_templates) do
            overseer.register_template(template)
        end

        overseer.register_template({
            name = "cpp_run_current",
            builder = function()
                if vim.bo.filetype ~= "cpp" and vim.bo.filetype ~= "c" then
                    return nil
                end

                pcall(vim.cmd, "silent! write")

                local file = vim.fn.expand("%:p")
                local dir = vim.fn.expand("%:p:h")
                local exe = vim.fn.expand("%:p:r")
                local compiler = vim.bo.filetype == "c" and "gcc" or "g++"
                local standard = vim.bo.filetype == "c" and "-std=c11" or "-std=c++20"
                local command = string.format(
                    "%s %s -Wall -Wextra %s -o %s && %s",
                    compiler,
                    standard,
                    vim.fn.shellescape(file),
                    vim.fn.shellescape(exe),
                    vim.fn.shellescape(exe)
                )

                return {
                    cmd = { "sh", "-c", command },
                    cwd = dir,
                    components = {
                        { "default" },
                        { "open_output", direction = "float", focus = true, on_start = "always", on_complete = "always" },
                    },
                }
            end,
            condition = {
                filetype = { "c", "cpp" },
            },
        })

        overseer.register_template({
            name = "python_run_current",
            builder = function()
                if vim.bo.filetype ~= "python" then
                    return nil
                end

                pcall(vim.cmd, "silent! write")

                return {
                    cmd = { "python3", vim.fn.expand("%:p") },
                    cwd = vim.fn.expand("%:p:h"),
                    components = {
                        { "default" },
                        { "open_output", direction = "float", focus = true, on_start = "always", on_complete = "always" },
                    },
                }
            end,
            condition = {
                filetype = { "python" },
            },
        })

        overseer.register_template({
            name = "shell_run_current",
            builder = function()
                if not vim.tbl_contains({ "sh", "bash", "zsh" }, vim.bo.filetype) then
                    return nil
                end

                pcall(vim.cmd, "silent! write")
                local shell = vim.bo.filetype == "zsh" and "zsh" or "bash"

                return {
                    cmd = { shell, vim.fn.expand("%:p") },
                    cwd = vim.fn.expand("%:p:h"),
                    components = {
                        { "default" },
                        { "open_output", direction = "float", focus = true, on_start = "always", on_complete = "always" },
                    },
                }
            end,
            condition = {
                filetype = { "sh", "bash", "zsh" },
            },
        })

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("OverseerBufferKeymaps", { clear = true }),
            pattern = { "OverseerList", "OverseerOutput", "overseer" },
            callback = function(event)
                vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = event.buf, silent = true, desc = "Close Overseer window" })
                vim.keymap.set("n", "<Esc>", "<Cmd>close<CR>", { buffer = event.buf, silent = true, desc = "Close Overseer window" })
            end,
        })
    end,
}

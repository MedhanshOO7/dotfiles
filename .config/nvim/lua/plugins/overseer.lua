return {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerQuickAction", "OverseerLoadBundle" },
    config = function()
        require("overseer").setup({
            strategy = "toggleterm",
            task_list = {
                direction = "bottom",
                min_height = 10,
                max_height = 16,
                default_detail = 1,
            },
            component_aliases = {
                default = {
                    { "display_duration", detail_level = 2 },
                    "on_output_summarize",
                    "on_result_diagnostics",
                    "on_complete_notify",
                    "default",
                },
            },
        })

        local overseer = require("overseer")

        overseer.register_template({
            name = "cpp_run_current",
            builder = function()
                if vim.bo.filetype ~= "cpp" and vim.bo.filetype ~= "c" then
                    return nil
                end

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
                    cmd = vim.o.shell,
                    args = { vim.o.shellcmdflag, command },
                    cwd = dir,
                    components = {
                        { "default" },
                        { "open_output", direction = "float", focus = true, on_start = "always", on_complete = "failure" },
                    },
                }
            end,
            condition = {
                filetype = { "c", "cpp" },
            },
        })
    end,
}

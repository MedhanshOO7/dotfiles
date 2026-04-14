return {
    "okuuva/auto-save.nvim",
    event = { "InsertEnter", "TextChanged", "TextChangedI", "BufLeave", "FocusLost" },
    config = function()
        local autosave = require("auto-save")

        vim.g.auto_save_enabled = true

        autosave.setup({
            enabled = true,
            debounce_delay = 1000,
            trigger_events = {
                immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" },
                defer_save = { "TextChanged", "TextChangedI" },
                cancel_deferred_save = { "InsertEnter" },
            },
            condition = function(buf)
                local ignored_filetypes = {
                    "gitcommit",
                    "neo-tree",
                    "oil",
                    "toggleterm",
                }

                return vim.g.auto_save_enabled
                    and vim.b[buf].auto_save ~= false
                    and vim.fn.getbufvar(buf, "&modifiable") == 1
                    and vim.bo[buf].readonly == false
                    and vim.bo[buf].buftype == ""
                    and vim.api.nvim_buf_get_name(buf) ~= ""
                    and not vim.tbl_contains(ignored_filetypes, vim.bo[buf].filetype)
            end,
        })

        vim.api.nvim_create_user_command("AutoSaveToggle", function()
            vim.g.auto_save_enabled = not vim.g.auto_save_enabled
            vim.notify(vim.g.auto_save_enabled and "Autosave is on" or "Autosave is off")
        end, { desc = "Turn autosave on or off" })

        vim.api.nvim_create_user_command("AutoSaveBufferToggle", function()
            vim.b.auto_save = vim.b.auto_save == false
            vim.notify(vim.b.auto_save and "Autosave is on for this buffer" or "Autosave is off for this buffer")
        end, { desc = "Turn autosave on or off for the current buffer" })
    end,
}

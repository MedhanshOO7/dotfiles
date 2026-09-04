return {
    "okuuva/auto-save.nvim",
    event = "VeryLazy",
    config = function()
        local autosave = require("auto-save")

        vim.g.auto_save_enabled = true

        autosave.setup({
            enabled = true,
            debounce_delay = 1000,
            trigger_events = {
                immediate_save = { "BufLeave", "FocusLost" },
                defer_save = { "InsertLeave", "TextChanged" },
                cancel_deferred_save = { "InsertEnter" },
            },
            condition = function(buf)
                if not vim.api.nvim_buf_is_valid(buf) then
                    return false
                end

                local ignored_filetypes = {
                    "gitcommit",
                    "oil",
                    "toggleterm",
                    "dbui",
                    "dbout",
                    "dadbod",
                    "TelescopePrompt",
                    "snacks_picker_input",
                }

                local ft = vim.bo[buf].filetype
                local bt = vim.bo[buf].buftype

                return vim.g.auto_save_enabled
                    and vim.b[buf].auto_save ~= false
                    and vim.bo[buf].modifiable
                    and not vim.bo[buf].readonly
                    and bt == ""
                    and vim.api.nvim_buf_get_name(buf) ~= ""
                    and not vim.tbl_contains(ignored_filetypes, ft)
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

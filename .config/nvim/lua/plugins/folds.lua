return {
    {
        "kevinhwang91/promise-async",
        lazy = true,
    },
    {
        "kevinhwang91/nvim-ufo",
        event = "VeryLazy",
        dependencies = {
            "kevinhwang91/promise-async",
        },
        config = function()
            -- Show fold column with better visibility for UX
            vim.o.foldcolumn = "1" -- Show fold column with width 1
            vim.o.foldlevel = 99 -- Start with folds open (can be closed with zm/zM)
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true

            -- Enhanced fold text handler with better UX
            local handler = function(virtText, lnum, endLnum, width, truncate)
                local newVirtText = {}
                local lineCount = endLnum - lnum
                local suffix = ("  %d lines "):format(lineCount)
                local targetWidth = width - vim.fn.strdisplaywidth(suffix)
                local curWidth = 0
                for _, chunk in ipairs(virtText) do
                    local chunkText = chunk[1]
                    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if targetWidth > curWidth + chunkWidth then
                        table.insert(newVirtText, chunk)
                    else
                        chunkText = truncate(chunkText, targetWidth - curWidth)
                        local hlGroup = chunk[2]
                        table.insert(newVirtText, { chunkText, hlGroup })
                        chunkWidth = vim.fn.strdisplaywidth(chunkText)
                        if curWidth + chunkWidth < targetWidth then
                            suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
                        end
                        break
                    end
                    curWidth = curWidth + chunkWidth
                end
                table.insert(newVirtText, { suffix, "Comment" })
                return newVirtText
            end

            require("ufo").setup({
                open_fold_hl_timeout = 150,
                fold_virt_text_handler = handler,
                close_fold_kinds_for_ft = {
                    default = {},
                    json = { "array" },
                    c = { "comment" },
                    cpp = { "comment" },
                },
                preview = {
                    win_config = {
                        border = "rounded",
                        winblend = 0,
                        maxheight = 20,
                    },
                    mappings = {
                        scrollB = "<C-b>",
                        scrollF = "<C-f>",
                        scrollU = "<C-u>",
                        scrollD = "<C-d>",
                    },
                },
                provider_selector = function(_, filetype, _)
                    if filetype == "markdown" or filetype == "text" or filetype == "gitcommit" then
                        return { "indent" }
                    end
                    return { "treesitter", "indent" }
                end,
            })

            -- Create commands for easier fold management (no keybind changes)
            vim.api.nvim_create_user_command("FoldOpenAll", function()
                require("ufo").openAllFolds()
                vim.notify("All folds opened", vim.log.levels.INFO)
            end, { desc = "Open all folds" })

            vim.api.nvim_create_user_command("FoldCloseAll", function()
                require("ufo").closeAllFolds()
                vim.notify("All folds closed", vim.log.levels.INFO)
            end, { desc = "Close all folds" })

            vim.api.nvim_create_user_command("FoldToggle", function()
                local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
                if wininfo and wininfo.foldlevel > 0 then
                    require("ufo").closeAllFolds()
                    vim.notify("Folds closed", vim.log.levels.INFO)
                else
                    require("ufo").openAllFolds()
                    vim.notify("Folds opened", vim.log.levels.INFO)
                end
            end, { desc = "Toggle folds open/closed" })
        end,
    },
}

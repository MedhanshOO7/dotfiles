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
            vim.o.foldcolumn = "0"
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true

            local handler = function(virtText, lnum, endLnum, width, truncate)
                local newVirtText = {}
                local suffix = (" 󰁂 %d lines "):format(endLnum - lnum)
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
                table.insert(newVirtText, { suffix, "MoreMsg" })
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
        end,
    },
}

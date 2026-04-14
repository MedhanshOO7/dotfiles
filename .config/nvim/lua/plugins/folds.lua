return {
    {
        "kevinhwang91/promise-async",
        lazy = true,
    },
    {
        "kevinhwang91/nvim-ufo",
        event = "BufReadPost",
        dependencies = {
            "kevinhwang91/promise-async",
        },
        config = function()
            -- Keep folds available without starting files collapsed. This gives structure
            -- on demand instead of making every buffer feel closed-off on entry.
            vim.o.foldcolumn = "1"
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true

            require("ufo").setup({
                open_fold_hl_timeout = 150,
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
                    -- Markdown and prose files read better with indent folds only; code gets
                    -- structural folds from treesitter with indent as a safe fallback.
                    if filetype == "markdown" or filetype == "text" or filetype == "gitcommit" then
                        return { "indent" }
                    end

                    return { "treesitter", "indent" }
                end,
            })
        end,
    },
}

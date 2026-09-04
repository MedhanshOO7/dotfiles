return {
    "Bekaboo/dropbar.nvim",
    event = "LspAttach",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    opts = function()
        local sources = require("dropbar.sources")
        local utils = require("dropbar.utils")

        return {
            bar = {
                enable = function(buf, _)
                    return vim.fn.buflisted(buf) == 1
                        and vim.api.nvim_buf_get_name(buf) ~= ""
                        and not vim.tbl_contains({
                            "help",
                            "snacks_dashboard",
                            "snacks_picker_input",
                            "snacks_explorer",
                            "alpha",
                            "dashboard",
                            "lazy",
                            "mason",
                            "trouble",
                            "toggleterm",
                            "notify",
                            "noice",
                        }, vim.bo[buf].filetype)
                end,
                separator = "  ",
                sources = function(buf, _)
                    if vim.bo[buf].ft == "markdown" then
                        return {
                            sources.path,
                            sources.markdown,
                        }
                    end
                    if vim.bo[buf].buftype == "terminal" then
                        return {
                            sources.terminal,
                        }
                    end
                    return {
                        sources.path,
                        utils.source.fallback({
                            sources.lsp,
                            sources.treesitter,
                        }),
                    }
                end,
            },
            sources = {
                path = {
                    relative_to = function(buf, _)
                        local root = vim.fs.root(buf, { ".git", "package.json", "Makefile", "CMakeLists.txt" })
                        return root or vim.fn.getcwd()
                    end,
                },
            },
        }
    end,
    keys = {
        {
            "<leader>;",
            function()
                require("dropbar.api").pick()
            end,
            desc = "Pick symbols in breadcrumb dropbar",
        },
        {
            "[;",
            function()
                require("dropbar.api").goto_context_start()
            end,
            desc = "Go to start of current context",
        },
        {
            "];",
            function()
                require("dropbar.api").select_next_context()
            end,
            desc = "Select next context",
        },
    },
}

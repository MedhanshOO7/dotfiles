return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = {
            "windwp/nvim-ts-autotag",
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        config = function()
            require("nvim-treesitter").setup({
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                    disable = function(lang, buf)
                        if vim.b[buf] and (vim.b[buf].large_file or vim.b[buf].bigfile) then
                            return true
                        end
                        return vim.api.nvim_buf_line_count(buf) > 5000
                    end,
                },
                indent = {
                    enable = true,
                    disable = function(lang, buf)
                        if vim.b[buf] and (vim.b[buf].large_file or vim.b[buf].bigfile) then
                            return true
                        end
                        return vim.api.nvim_buf_line_count(buf) > 5000
                    end,
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn",
                        node_incremental = "grn",
                        scope_incremental = "grc",
                        node_decremental = "grm",
                    },
                },
                ensure_installed = {
                    "bash",
                    "c",
                    "cmake",
                    "comment",
                    "cpp",
                    "css",
                    "devicetree",
                    "diff",
                    "dockerfile",
                    "go",
                    "html",
                    "hyprlang",
                    "javascript",
                    "json",
                    "jsonc",
                    "latex",
                    "lua",
                    "luadoc",
                    "markdown",
                    "markdown_inline",
                    "mermaid",
                    "norg",
                    "python",
                    "qml",
                    "query",
                    "regex",
                    "ruby",
                    "rust",
                    "scss",
                    "sql",
                    "svelte",
                    "toml",
                    "tsx",
                    "typescript",
                    "typst",
                    "vim",
                    "vimdoc",
                    "vue",
                    "yaml",
                },
                auto_install = false,
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                            ["aa"] = "@parameter.outer",
                            ["ia"] = "@parameter.inner",
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start = {
                            ["]m"] = "@function.outer",
                            ["]]"] = "@class.outer",
                        },
                        goto_previous_start = {
                            ["[m"] = "@function.outer",
                            ["[["] = "@class.outer",
                        },
                    },
                },
            })

            require("nvim-ts-autotag").setup()
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        enabled = false,
    },
}

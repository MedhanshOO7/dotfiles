return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            -- Apply Dracula colorscheme
            vim.cmd("colorscheme dracula")

            require("neo-tree").setup({
                close_if_last_window = true,
                popup_border_style = "rounded",
                enable_git_status = true,
                enable_diagnostics = true,

                filesystem = {
                    filtered_items = {
                        visible = false,
                        hide_gitignored = true,
                    },
                    follow_current_file = {
                        enabled = true,
                    },
                    hijack_netrw_behavior = "disabled",
                },

                window = {
                    width = 30,
                    mappings = {
                        ["<space>"] = "toggle_node",
                        ["<cr>"] = "open",
                        ["l"] = "open",
                        ["h"] = "close_node",
                    },
                },

                default_component_configs = {
                    indent = {
                        padding = 1,
                    },
                    icon = {
                        folder_closed = "",
                        folder_open = "",
                    },
                    git_status = {
                        symbols = {
                            added     = "✚",
                            modified  = "",
                            deleted   = "✖",
                            renamed   = "➜",
                            untracked = "★",
                        },
                    },
                },
            })

            -- Toggle key
            vim.keymap.set("n", "<leader>b", ":Neotree toggle<CR>", { silent = true })
        end,
    },

    -- Dracula colorscheme
    {
        "Mofiqul/dracula.nvim",
        lazy = false,
        priority = 1000,
    },
    -- Better contrast for Neo-tree
}

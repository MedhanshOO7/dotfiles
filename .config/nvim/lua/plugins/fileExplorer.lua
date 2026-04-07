return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
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
                hijack_netrw_behavior = "open_default",
                use_libuv_file_watcher = true,
            },

            window = {
                position = "left",
                width = 34,
                mappings = {
                    ["<cr>"] = "open",
                    ["l"] = "open",
                    ["h"] = "close_node",
                    ["-"] = "navigate_up",
                    ["z"] = "toggle_node",
                    ["%"] = {
                        "add",
                        config = {
                            show_path = "none",
                        },
                    },
                    ["d"] = "add_directory",
                    ["D"] = "delete",
                    ["r"] = "rename",
                    ["R"] = "refresh",
                    ["?"] = "show_help",
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
                        added = "✚",
                        modified = "",
                        deleted = "✖",
                        renamed = "➜",
                        untracked = "★",
                    },
                },
            },
        })
    end,
}

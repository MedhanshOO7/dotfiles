return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local function explorer_width()
            return math.max(20, math.floor(vim.o.columns * 0.15))
        end

        require("neo-tree").setup({
            close_if_last_window = false,
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
                width = explorer_width(),
                mappings = {
                    ["<cr>"] = "open",
                    ["<space>"] = "none",
                    ["l"] = "open",
                    ["h"] = "close_node",
                    ["-"] = "navigate_up",
                    ["o"] = "none",
                    ["z"] = "none",
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
                    with_markers = false,
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
            source_selector = {
                winbar = false,
                statusline = false,
            },
        })

        vim.api.nvim_create_autocmd("VimResized", {
            group = vim.api.nvim_create_augroup("neo_tree_dynamic_width", { clear = true }),
            callback = function()
                local width = explorer_width()
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    if vim.bo[buf].filetype == "neo-tree" then
                        pcall(vim.api.nvim_win_set_width, win, width)
                    end
                end
            end,
        })
    end,
}

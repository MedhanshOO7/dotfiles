return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local function explorer_width()
            return math.max(26, math.floor(vim.o.columns * 0.18))
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
                    ["s"] = "open_vsplit",
                    ["S"] = "open_split",
                    ["P"] = { "toggle_preview", config = { use_float = true } },
                    ["H"] = "toggle_hidden",
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
                    folder_closed = "󰉋",
                    folder_open = "󰝰",
                    folder_empty = "󰉖",
                    default = "󰈔",
                },
                git_status = {
                    align = "right",
                    symbols = {
                        added = "✚",
                        modified = "",
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

        -- Sync neo-tree background with current theme on every colorscheme change
        local function sync_neotree_hl()
            vim.api.nvim_set_hl(0, "NeoTreeNormal",         { link = "Normal" })
            vim.api.nvim_set_hl(0, "NeoTreeNormalNC",       { link = "NormalNC" })
            vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer",    { link = "EndOfBuffer" })
            vim.api.nvim_set_hl(0, "NeoTreeWinSeparator",   { link = "WinSeparator" })
            vim.api.nvim_set_hl(0, "NeoTreeStatusLine",     { link = "StatusLine" })
            vim.api.nvim_set_hl(0, "NeoTreeStatusLineNC",   { link = "StatusLineNC" })
            vim.api.nvim_set_hl(0, "NeoTreeVertSplit",      { link = "VertSplit" })
            vim.api.nvim_set_hl(0, "NeoTreeFloatBorder",    { link = "FloatBorder" })
            vim.api.nvim_set_hl(0, "NeoTreeFloatTitle",     { link = "FloatTitle" })
        end

        sync_neotree_hl()

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("neo_tree_theme_sync", { clear = true }),
            pattern = "*",
            callback = sync_neotree_hl,
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

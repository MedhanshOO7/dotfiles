return {
    -- 1. Smooth Cursor Animation
    -- Makes cursor movement incredibly smooth and fluid by rendering a "smear" trail.
    {
        "sphamba/smear-cursor.nvim",
        event = "VeryLazy",
        opts = {
            stiffness = 0.8,
            trailing_stiffness = 0.5,
            distance_stop_animating = 0.5,
            hide_target_hack = false,
        },
    },

    -- 2. Multi-Action Micro-Glimmer Animations
    -- Smooth fade/pulse feedback on yank, paste, undo/redo, and search jumps.
    {
        "rachartier/tiny-glimmer.nvim",
        event = "VeryLazy",
        opts = {
            disable_warnings = true,
            default_animation = "fade",
            animations = {
                fade = {
                    max_duration = 300,
                    min_duration = 150,
                    easing = "outQuad",
                    chars_for_max_duration = 10,
                },
                pulse = {
                    max_duration = 300,
                    min_duration = 150,
                    chars_for_max_duration = 15,
                    pulse_count = 1,
                    intensity = 1.2,
                },
            },
            commands = {
                yank = {
                    enabled = true,
                    default_animation = "fade",
                },
                paste = {
                    enabled = false,
                },
                undo = {
                    enabled = false,
                },
                redo = {
                    enabled = false,
                },
                search = {
                    enabled = true,
                    default_animation = "pulse",
                    next_mapping = "n",
                    prev_mapping = "N",
                },
            },
        },
    },

    -- 3. Glowing Active Window Split Separators
    -- Highlights the active split border so you immediately know which window has focus.
    {
        "nvim-zh/colorful-winsep.nvim",
        event = { "WinLeave" },
        opts = {
            highlight = "#89b4fa",
            interval = 30,
            no_exec_files = {
                "packer",
                "TelescopePrompt",
                "mason",
                "snacks_dashboard",
                "snacks_picker_input",
                "snacks_explorer",
                "lazy",
                "alpha",
            },
            symbols = { "─", "│", "┌", "┐", "└", "┘" },
            smooth = true,
        },
    },

    -- 4. Translucent Decorative Satellite Scrollbar
    -- Displays glanceable diagnostic errors, git changes, and search matches on the right rail.
    {
        "lewis6991/satellite.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            current_only = true,
            winblend = 50,
            zindex = 40,
            excluded_filetypes = {
                "snacks_dashboard",
                "snacks_picker_input",
                "snacks_explorer",
                "lazy",
                "mason",
                "help",
                "alpha",
                "Trouble",
                "toggleterm",
            },
            handlers = {
                cursor = {
                    enable = true,
                    overlap = true,
                    priority = 100,
                },
                search = {
                    enable = true,
                },
                diagnostic = {
                    enable = true,
                    signs = { "", "", "", "" },
                    min_severity = vim.diagnostic.severity.HINT,
                },
                gitsigns = {
                    enable = true,
                    signs = {
                        add = "▎",
                        change = "▎",
                        delete = "󰐊",
                    },
                },
                marks = {
                    enable = false,
                },
            },
        },
    },

    -- 5. Rainbow Delimiters
    -- Uses Treesitter to color-code matching parentheses, brackets, and braces.
    {
        "HiPhish/rainbow-delimiters.nvim",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            vim.g.rainbow_delimiters = {
                highlight = {
                    "RainbowDelimiterRed",
                    "RainbowDelimiterYellow",
                    "RainbowDelimiterBlue",
                    "RainbowDelimiterOrange",
                    "RainbowDelimiterGreen",
                    "RainbowDelimiterViolet",
                    "RainbowDelimiterCyan",
                },
            }
        end,
    },
}

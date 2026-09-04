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
            legacy_computing_symbols_support = true,
        },
    },

    -- 2. Smooth Scrolling & Physics Transitions
    -- Makes viewport jumps, <C-d>/<C-u>, and search jumps smooth as butter.
    {
        "declancm/cinnamon.nvim",
        version = "*",
        event = "VeryLazy",
        opts = {
            keymaps = {
                basic = false,
                extra = false,
            },
            options = {
                mode = "window",
                delay = 6,
                max_delta = {
                    time = 150,
                },
                step_size = {
                    vertical = 1,
                    horizontal = 2,
                },
            },
        },
    },

    -- 3. Multi-Action Micro-Glimmer Animations (Colorful Flash Flares)
    -- Smooth fade/pulse feedback with custom vibrant colors on yank, paste, undo/redo, and search.
    {
        "rachartier/tiny-glimmer.nvim",
        event = "VeryLazy",
        opts = {
            disable_warnings = true,
            default_animation = "fade",
            animations = {
                fade = {
                    max_duration = 250,
                    min_duration = 120,
                    easing = "outQuad",
                    chars_for_max_duration = 10,
                },
                pulse = {
                    max_duration = 250,
                    min_duration = 120,
                    chars_for_max_duration = 15,
                    pulse_count = 1,
                    intensity = 1.3,
                },
            },
            commands = {
                yank = {
                    enabled = true,
                    default_animation = "fade",
                    highlight = "IncSearch",
                },
                paste = {
                    enabled = false,
                },
                undo = {
                    enabled = true,
                    default_animation = "pulse",
                    highlight = "DiagnosticInfo",
                },
                redo = {
                    enabled = true,
                    default_animation = "pulse",
                    highlight = "DiagnosticHint",
                },
                search = {
                    enabled = true,
                    default_animation = "pulse",
                    highlight = "CurSearch",
                    next_mapping = "n",
                    prev_mapping = "N",
                },
            },
        },
    },

    -- 4. Glowing Active Window Split Separators
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

    -- 5. Translucent Decorative Satellite Scrollbar
    -- Displays glanceable diagnostic errors, git changes, and search matches on the right rail.
    {
        "lewis6991/satellite.nvim",
        event = "VeryLazy",
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

    -- 6. Vivid Rainbow Delimiters
    -- Uses Treesitter to color-code matching parentheses, brackets, and braces with vibrant saturated colors.
    {
        "HiPhish/rainbow-delimiters.nvim",
        event = "VeryLazy",
        config = function()
            local function apply_rainbow_colors()
                vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = "#f38ba8", bold = true })
                vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = "#f9e2af", bold = true })
                vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = "#89b4fa", bold = true })
                vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = "#fab387", bold = true })
                vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { fg = "#a6e3a1", bold = true })
                vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = "#cba6f7", bold = true })
                vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = "#89dceb", bold = true })
            end

            apply_rainbow_colors()

            vim.api.nvim_create_autocmd("ColorScheme", {
                group = vim.api.nvim_create_augroup("rainbow_delimiters_vivid_colors", { clear = true }),
                pattern = "*",
                callback = apply_rainbow_colors,
            })

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

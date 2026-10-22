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

    -- 3. Multi-Action Micro-Glimmer Animations (Colorful Flash Flares)
    -- Smooth fade/pulse feedback with custom vibrant colors on yank, paste, undo/redo, and search.
    {
        "rachartier/tiny-glimmer.nvim",
        event = "VeryLazy",
        config = function(_, opts)
            local glimmer = require("tiny-glimmer")
            glimmer.setup(opts)
            -- auto_map is off (it defers past the dashboard and clobbers maps), so
            -- wire the motions here: arm the animation, then run the real key.
            local function animated(animate, keys, after)
                return function()
                    animate()
                    local ok, err = pcall(vim.cmd.normal, { vim.v.count1 .. keys, bang = true })
                    if not ok then
                        vim.api.nvim_echo({ { (err:gsub("^.-:%s*(E%d+)", "%1")), "ErrorMsg" } }, false, {})
                    elseif after then
                        vim.cmd.normal({ after, bang = true })
                    end
                end
            end
            local map = vim.keymap.set
            map("n", "n", animated(glimmer.search_next, "n", "zzzv"), { desc = "Next search match (centred)" })
            map("n", "N", animated(glimmer.search_prev, "N", "zzzv"), { desc = "Previous search match (centred)" })
            map("n", "*", animated(glimmer.search_under_cursor, "*", "zzzv"), { desc = "Search word under cursor" })
            map("n", "#", animated(glimmer.search_under_cursor, "#", "zzzv"), { desc = "Search word under cursor backwards" })
            map("n", "u", animated(glimmer.undo, "u"), { desc = "Undo" })
            map("n", "<C-r>", animated(glimmer.redo, "\18"), { desc = "Redo" })
        end,
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
            -- tiny-glimmer reads these from `overwrite` (a `commands` table is ignored)
            overwrite = {
                auto_map = false,
                yank = {
                    enabled = true,
                    default_animation = { name = "fade", settings = { from_color = "IncSearch" } },
                },
                paste = { enabled = false }, -- yanky owns p/P (and highlights puts)
                undo = {
                    enabled = true,
                    default_animation = { name = "pulse", settings = { from_color = "DiagnosticInfo" } },
                },
                redo = {
                    enabled = true,
                    default_animation = { name = "pulse", settings = { from_color = "DiagnosticHint" } },
                },
                search = {
                    enabled = true,
                    default_animation = { name = "pulse", settings = { to_color = "CurSearch" } },
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
            border = "rounded",
            -- Re-run by the plugin on every ColorScheme, so the glow tracks the theme accent
            highlight = function()
                local c = require("utils.palette").colors()
                vim.api.nvim_set_hl(0, "ColorfulWinSep", { fg = c.blue, bg = "NONE" })
            end,
            animate = { enabled = false }, -- smear-cursor already animates focus changes
            excluded_ft = {
                "mason",
                "lazy",
                "snacks_dashboard",
                "snacks_picker_input",
                "snacks_picker_list",
                "snacks_layout_box",
                "snacks_explorer",
            },
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
            -- Bracket colours come from the active theme so they stay readable on any palette
            local function apply_rainbow_colors()
                local c = require("utils.palette").colors()
                vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = c.red })
                vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = c.yellow })
                vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = c.blue })
                vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = c.orange })
                vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { fg = c.green })
                vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = c.violet })
                vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = c.cyan })
            end

            apply_rainbow_colors()

            vim.api.nvim_create_autocmd("ColorScheme", {
                group = vim.api.nvim_create_augroup("rainbow_delimiters_vivid_colors", { clear = true }),
                pattern = "*",
                -- schedule: run after utils.theme finishes its own ColorScheme pass
                callback = function()
                    vim.schedule(apply_rainbow_colors)
                end,
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

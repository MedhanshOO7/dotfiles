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
        },
    },

    -- 2. Highlight Undo/Redo
    -- Visually highlights the text that was just changed when you press 'u' or '<C-r>'.
    -- Huge quality-of-life improvement for tracking changes.
    {
        "tzachar/highlight-undo.nvim",
        event = "VeryLazy",
        opts = {
            -- Uses default highlight groups and settings
        },
    },

    -- 3. Rainbow Delimiters
    -- Uses Treesitter to color-code matching parentheses, brackets, and braces.
    -- Essential for reading deeply nested code (JSON, Lisp, heavily nested JS/TS).
    {
        "HiPhish/rainbow-delimiters.nvim",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            -- This plugin uses a global variable for configuration rather than setup()
            vim.g.rainbow_delimiters = {
                highlight = {
                    'RainbowDelimiterRed',
                    'RainbowDelimiterYellow',
                    'RainbowDelimiterBlue',
                    'RainbowDelimiterOrange',
                    'RainbowDelimiterGreen',
                    'RainbowDelimiterViolet',
                    'RainbowDelimiterCyan',
                },
            }
        end,
    },
}

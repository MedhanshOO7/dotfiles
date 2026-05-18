return {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        filetypes = { "*", "!lazy" },
        user_default_options = {
            RGB = true,
            RRGGBB = true,
            names = false,
            RRGGBBAA = true,
            AARRGGBB = true,
            rgb_fn = true,
            hsl_fn = true,
            css = true,
            css_fn = true,
            mode = "background",
            tailwind = true,
            sass = { enable = true, parsers = { css = true } },
            virtualtext = "■",
            -- Enable ANSI color codes (important for terminal output as a pager)
            names = true,
            RGB = true,
            RRGGBB = true,
            always_update = true,
        },
    },
}

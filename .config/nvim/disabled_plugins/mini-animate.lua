return {
    "echasnovski/mini.animate",
    event = "VeryLazy",
    opts = function()
        local animate = require("mini.animate")
        return {
            cursor = { enable = false },
            scroll = { enable = false },
            resize = {
                enable = true,
                timing = animate.gen_timing.linear({ duration = 80, unit = "total" }),
            },
            open = {
                enable = true,
                timing = animate.gen_timing.linear({ duration = 80, unit = "total" }),
            },
            close = {
                enable = true,
                timing = animate.gen_timing.linear({ duration = 80, unit = "total" }),
            },
        }
    end,
}

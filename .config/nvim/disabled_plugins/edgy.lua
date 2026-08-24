return {
    "folke/edgy.nvim",
    event = "VeryLazy",
    opts = {
        bottom = {
            { ft = "toggleterm", title = "Terminal", size = { height = 0.25 } },
            { ft = "trouble", title = "Diagnostics", size = { height = 0.25 } },
            { ft = "qf", title = "QuickFix", size = { height = 0.25 } },
            { ft = "help", title = "Help", size = { height = 0.25 } },
        },
        left = {
            { title = "Explorer", ft = "snacks_picker_list", size = { width = 0.25 } },
            { title = "Outline", ft = "aerial", size = { width = 0.25 } },
        },
        right = {
            { title = "Database", ft = "dbui", size = { width = 0.25 } },
            { title = "Tasks", ft = "OverseerList", size = { width = 0.25 } },
            { title = "Git", ft = "NeogitStatus", size = { width = 0.3 } },
        },
        animate = { enabled = true, fps = 100, cps = 120 },
    },
}

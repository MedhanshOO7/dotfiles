return {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
        {
            "<leader>/",
            "gcc",
            remap = true,
            desc = "Toggle line comment",
        },
        {
            "<leader>/",
            "gc",
            mode = "v",
            remap = true,
            desc = "Toggle line comment",
        },
    },
}

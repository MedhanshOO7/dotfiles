return {
    "folke/todo-comments.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        require("todo-comments").setup({
            signs = true,
            highlight = {
                keyword = "wide",
            },
        })
    end,
}

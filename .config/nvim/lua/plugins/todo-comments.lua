return {
    "folke/todo-comments.nvim",
    cmd = { "TodoTelescope", "TodoTrouble", "TodoLocList", "TodoQuickFix" },
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

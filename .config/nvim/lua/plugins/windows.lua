return {
    "anuvyklack/windows.nvim",
    dependencies = { "anuvyklack/middleclass", "anuvyklack/animation.nvim" },
    event = "WinNew",
    config = function()
        vim.o.winwidth = 10
        vim.o.winminwidth = 5
        vim.o.equalalways = false
        require("windows").setup({
            animation = { duration = 150, fps = 60 },
            autowidth = { enable = false },
        })
    end,
    keys = {
        { "<C-w>z", "<cmd>WindowsMaximize<cr>", desc = "Maximize Window" },
        { "<C-w>=", "<cmd>WindowsEqualize<cr>", desc = "Equalize Windows" },
    },
}

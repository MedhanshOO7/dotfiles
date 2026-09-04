return {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    keys = {
        { "<leader>gg", "<cmd>Neogit<cr>", desc = "Open Neogit status tab" },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "sindrets/diffview.nvim",
    },
    config = function()
        require("neogit").setup({
            kind = "tab",
            integrations = {
                diffview = true,
            },
            signs = {
                section = { "󰁕", "󰁅" },
                item = { "󰄴", "󰄲" },
                hunk = { "", "" },
            },
        })
    end,
}

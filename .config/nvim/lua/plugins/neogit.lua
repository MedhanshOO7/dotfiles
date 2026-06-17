return {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        require("neogit").setup({
            kind = "tab",
            integrations = {
                telescope = true,
            },
            signs = {
                section = { "󰁕", "󰁅" },
                item = { "󰄴", "󰄲" },
                hunk = { "", "" },
            },
        })
    end,
}

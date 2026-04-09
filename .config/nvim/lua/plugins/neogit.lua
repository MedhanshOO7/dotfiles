return {
    "NeogitOrg/neogit",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        require("neogit").setup({
            kind = "tab",
            disable_commit_confirmation = true,
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

return {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" },
    config = function()
        require("grug-far").setup({
            headerMaxWidth = 80,
            transient = true,
        })
    end,
}

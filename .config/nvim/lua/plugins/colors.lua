local function Etrans()
    -- Core UI
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })

    -- Neo-tree
    vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "none" })
    vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "none" })
end

return {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
        vim.cmd("colorscheme catppuccin-mocha")
        Etrans()

        -- Reapply after any colorscheme change
        vim.api.nvim_create_autocmd("ColorScheme", {
            pattern = "*",
            callback = function()
                Etrans()
            end,
        })
    end,
}

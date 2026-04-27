return {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    lazy = true,
    config = function()
        local mc = require("multicursor-nvim")

        -- Keep multi-cursor behavior in one plugin only. The previous config
        -- also loaded vim-visual-multi, which caused overlapping Ctrl-based
        -- triggers and unpredictable cursor state.
        mc.setup()

        -- When multiple cursors are active, these maps take priority so the
        -- editor stays predictable instead of leaking into unrelated mappings.
        mc.addKeymapLayer(function(layer_set)
            layer_set({ "n", "x" }, "<Left>", mc.prevCursor)
            layer_set({ "n", "x" }, "<Right>", mc.nextCursor)
            layer_set({ "n", "x" }, "<leader>Mt", mc.toggleCursor)
            layer_set({ "n", "x" }, "<leader>Mx", mc.deleteCursor)

            layer_set("n", "<Esc>", function()
                if not mc.cursorsEnabled() then
                    mc.enableCursors()
                else
                    mc.clearCursors()
                end
            end)
        end)

        local function apply_highlights()
            vim.api.nvim_set_hl(0, "MultiCursorCursor", { reverse = true })
            vim.api.nvim_set_hl(0, "MultiCursorVisual", { link = "Visual" })
            vim.api.nvim_set_hl(0, "MultiCursorSign", { link = "SignColumn" })
            vim.api.nvim_set_hl(0, "MultiCursorMatchPreview", { link = "Search" })
            vim.api.nvim_set_hl(0, "MultiCursorDisabledCursor", { reverse = true })
            vim.api.nvim_set_hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
            vim.api.nvim_set_hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
        end

        apply_highlights()

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("multicursor_theme_sync_user", { clear = true }),
            pattern = "*",
            callback = apply_highlights,
        })
    end,
}

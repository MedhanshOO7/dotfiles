return {
    "gorbit99/codewindow.nvim",
    event = "VeryLazy",
    config = function()
        local ok, codewindow = pcall(require, "codewindow")
        if not ok then return end

        codewindow.setup({
            active_in_terminals = false,
            auto_enable = false,
            exclude_filetypes = { "help", "dashboard", "snacks_dashboard", "nofile", "prompt" },
            minimap_width = 10,
            use_lsp = true,
            use_treesitter = false,
            use_git = true,
            width_multiplier = 4,
            z_index = 1,
            show_cursor = true,
            window_border = "none",
            relative = "win",
        })
        vim.keymap.set("n", "<leader>mm", function() codewindow.toggle_minimap() end,
            { desc = "Toggle Minimap" })
    end,
}

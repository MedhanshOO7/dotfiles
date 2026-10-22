return {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp" },
    opts = {
        inlay_hints = {
            inline = true,
        },
    },
    keys = {
        -- Buffer-local: <leader>ch is Obsidian's checkbox toggle in markdown notes
        { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "C/C++: Switch Source/Header", ft = { "c", "cpp" } },
        { "<leader>cT", "<cmd>ClangdTypeHierarchy<cr>", desc = "C/C++: Type Hierarchy", ft = { "c", "cpp" } },
    },
}

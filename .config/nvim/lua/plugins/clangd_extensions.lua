return {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    opts = {
        inlay_hints = {
            inline = vim.fn.has("nvim-0.10") == 1,
        },
    },
    keys = {
        { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "C/C++: Switch Source/Header" },
        { "<leader>cT", "<cmd>ClangdTypeHierarchy<cr>", desc = "C/C++: Type Hierarchy" },
    },
}

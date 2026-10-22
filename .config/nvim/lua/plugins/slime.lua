return {
    "jpalardy/vim-slime",
    ft = { "python", "javascript", "typescript", "sh", "bash", "zsh", "c", "cpp" },
    init = function()
        vim.g.slime_target = "neovim"
        vim.g.slime_no_mappings = 1
        vim.g.slime_python_ipython = 1
    end,
    -- <leader>rp / <leader>rc belong to code_runner (run project / close runner)
    keys = {
        { "<leader>rs", "<Plug>SlimeRegionSend", mode = "x", desc = "Send selection to REPL" },
        { "<leader>rs", "<Plug>SlimeParagraphSend", desc = "Send paragraph to REPL" },
        { "<leader>rl", "<Plug>SlimeLineSend", desc = "Send line to REPL" },
        { "<leader>rC", "<Plug>SlimeConfig", desc = "Configure REPL target" },
    },
}

return {
    "dkarter/bullets.vim",
    ft = { "markdown", "text", "gitcommit" },
    init = function()
        vim.g.bullets_enabled_file_types = {
            "markdown",
            "text",
            "gitcommit",
        }
        -- Disable default mappings to avoid conflict with autolist.nvim
        vim.g.bullets_set_mappings = 0
        vim.g.bullets_mapping_leader = ""
    end,
}

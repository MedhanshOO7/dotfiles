return {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    cmd = {
        "MarkdownPreview",
        "MarkdownPreviewStop",
        "MarkdownPreviewToggle",
    },
    build = function()
        vim.fn["mkdp#util#install"]()
    end,
    init = function()
        vim.g.mkdp_filetypes = { "markdown" }
        vim.g.mkdp_auto_start = 0
        vim.g.mkdp_auto_close = 1
        vim.g.mkdp_refresh_slow = 0
        vim.g.mkdp_theme = "dark"
        vim.g.mkdp_preview_options = {
            disable_sync_scroll = 0,
            hide_yaml_meta = 1,
            sync_scroll_type = "middle",
        }
    end,
}

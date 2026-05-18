return {
    {
        "RRethy/vim-illuminate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("illuminate").configure({
                delay = 150,
                large_file_cutoff = 3000,
                large_file_overrides = {
                    providers = { "lsp", "treesitter" },
                },
                filetypes_denylist = {
                    "alpha",
                    "dashboard",
                    "help",
                    "lazy",
                    "mason",
                    "neo-tree",
                    "notify",
                    "snacks_dashboard",
                    "TelescopePrompt",
                    "toggleterm",
                },
                modes_denylist = { "i", "ic", "ix" },
            })
        end,
    },
    {
        "b0o/incline.nvim",
        event = "VeryLazy",
        config = function()
            local devicons = require("nvim-web-devicons")

            require("incline").setup({
                debounce_threshold = {
                    falling = 40,
                    rising = 10,
                },
                hide = {
                    cursorline = false,
                    focused_win = false,
                    only_win = false,
                },
                highlight = {
                    groups = {
                        InclineNormal = "InclineNormal",
                        InclineNormalNC = "InclineNormalNC",
                    },
                },
                render = function(props)
                    local buf = props.buf
                    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
                    local modified = vim.bo[buf].modified
                    local icon, icon_hl = devicons.get_icon_color(filename)
                    local diagnostics = vim.diagnostic.count(buf)
                    local parts = {}

                    if icon then
                        table.insert(parts, { icon .. " ", guifg = icon_hl })
                    end

                    table.insert(parts, filename ~= "" and filename or "[No Name]")

                    if diagnostics[vim.diagnostic.severity.ERROR] and diagnostics[vim.diagnostic.severity.ERROR] > 0 then
                        table.insert(parts, { "  " .. diagnostics[vim.diagnostic.severity.ERROR], group = "DiagnosticError" })
                    elseif diagnostics[vim.diagnostic.severity.WARN] and diagnostics[vim.diagnostic.severity.WARN] > 0 then
                        table.insert(parts, { "  " .. diagnostics[vim.diagnostic.severity.WARN], group = "DiagnosticWarn" })
                    end

                    if modified then
                        table.insert(parts, { " ●", group = "DiagnosticWarn" })
                    end

                    return parts
                end,
                window = {
                    margin = { horizontal = 1, vertical = 0 },
                    padding = 1,
                    placement = { horizontal = "right", vertical = "top" },
                },
            })
        end,
    },
    {
        "kevinhwang91/nvim-bqf",
        ft = "qf",
        opts = {
            auto_enable = true,
            auto_resize_height = true,
            preview = {
                border = "rounded",
                show_title = true,
                should_preview_cb = function(bufnr)
                    local filename = vim.api.nvim_buf_get_name(bufnr)
                    return filename ~= "" and vim.fn.getfsize(filename) < 1024 * 1024
                end,
            },
        },
    },
}

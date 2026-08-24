return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "onsails/lspkind.nvim",
        {
            "xzbdmw/colorful-menu.nvim",
            opts = {},
        },
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")
        local colorful_menu = require("colorful-menu")
        local compare = require("cmp.config.compare")

        local function hl_fg(group)
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
            return (ok and hl.fg) and string.format("#%06x", hl.fg) or nil
        end

        local function apply_highlights()
            vim.api.nvim_set_hl(0, "CmpDocBorder", {
                fg = hl_fg("FloatBorder") or hl_fg("WinSeparator") or hl_fg("NormalFloat"),
                bg = "NONE",
            })
            vim.api.nvim_set_hl(0, "CmpDocNormal", { bg = "NONE" })
        end

        apply_highlights()

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("nvim_cmp_theme_sync", { clear = true }),
            pattern = "*",
            callback = apply_highlights,
        })

        cmp.setup({
            completion = {
                completeopt = "menu,menuone,noinsert",
            },
            preselect = cmp.PreselectMode.None,
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({ select = false }),
                ["<C-d>"] = cmp.mapping(function()
                    if cmp.visible_docs() then
                        cmp.close_docs()
                    else
                        cmp.open_docs()
                    end
                end, { "i", "s" }),
                ["<C-n>"] = cmp.mapping(function()
                    if cmp.visible() then
                        cmp.select_next_item()
                    else
                        cmp.complete()
                    end
                end, { "i", "s" }),
                ["<C-p>"] = cmp.mapping(function()
                    if cmp.visible() then
                        cmp.select_prev_item()
                    else
                        cmp.complete()
                    end
                end, { "i", "s" }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    local copilot_ok, copilot_suggestion = pcall(require, "copilot.suggestion")
                    if copilot_ok and copilot_suggestion.is_visible() then
                        copilot_suggestion.accept()
                    elseif cmp.visible() then
                        cmp.confirm({ select = true })
                    elseif luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if luasnip.locally_jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            sources = {
                { name = "obsidian", priority = 10 },
                { name = "obsidian_new", priority = 9 },
                { name = "nvim_lsp" },
                { name = "nvim_lua" },
                { name = "luasnip" },
                { name = "path" },
                { name = "buffer" },
            },
            sorting = {
                priority_weight = 2,
                comparators = {
                    compare.exact,
                    compare.score,
                    compare.recently_used,
                    compare.locality,
                    compare.kind,
                    compare.sort_text,
                    compare.length,
                    compare.order,
                },
            },
            formatting = {
                fields = { "kind", "abbr", "menu" },
                format = function(entry, vim_item)
                    local _ = lspkind.cmp_format({
                        mode = "symbol_text",
                        maxwidth = 50,
                        ellipsis_char = "...",
                        menu = {
                            nvim_lsp = "[LSP]",
                            luasnip = "[Snip]",
                            buffer = "[Buf]",
                            path = "[Path]",
                            obsidian = "[Obs]",
                            obsidian_new = "[Obs+]",
                        },
                    })(entry, vim_item)

                    local ok, highlights_info = pcall(colorful_menu.cmp_highlights, entry)
                    if ok and highlights_info ~= nil then
                        vim_item.abbr_hl_group = highlights_info.highlights
                        vim_item.abbr = highlights_info.text
                    end

                    return vim_item
                end,
            },
            view = {
                docs = {
                    auto_open = false,
                },
            },
            experimental = {
                ghost_text = false,
            },
            window = {
                completion = cmp.config.window.bordered({
                    border = "rounded",
                    winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                    col_offset = -3,
                    side_padding = 1,
                }),
                documentation = cmp.config.window.bordered({
                    border = "rounded",
                    winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
                }),
            },
        })

        cmp.setup.filetype({ "sql", "mysql", "plsql" }, {
            sources = cmp.config.sources({
                { name = "vim-dadbod-completion" },
                { name = "buffer" },
            }),
        })
    end,
}

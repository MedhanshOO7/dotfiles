return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",
        "onsails/lspkind.nvim",
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")

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

        -- LOAD SNIPPETS (IMPORTANT)
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_lua").load({
            paths = "~/.config/nvim/lua/snippets"
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
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
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
                    -- Keep <Tab> predictable for indentation. Completion
                    -- navigation moves to <C-n>/<C-p> so Tab can insert spaces.
                    if luasnip.expand_or_locally_jumpable() then
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
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "path" },
                { name = "buffer" },
            },

            formatting = {
                format = lspkind.cmp_format({
                    mode = "symbol_text",
                    maxwidth = 50,
                }),
            },

            view = {
                docs = {
                    auto_open = false,
                },
            },

            window = {
                completion = {
                    border = "rounded",
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
                },
                documentation = {
                    border = "rounded",
                    max_width = math.floor(vim.o.columns * 0.35),
                    max_height = math.floor(vim.o.lines * 0.25),
                    winhighlight = "NormalFloat:CmpDocNormal,FloatBorder:CmpDocBorder",
                    winblend = 5,
                    col_offset = 1,
                    zindex = 50,
                },
            },
        })
    end,
}

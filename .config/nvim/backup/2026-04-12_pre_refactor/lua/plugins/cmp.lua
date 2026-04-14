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

        vim.api.nvim_set_hl(0, "CmpDocBorder", { fg = "#ffffff", bg = "NONE" })
        vim.api.nvim_set_hl(0, "CmpDocNormal", { bg = "NONE" })

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
                ["<C-k>"] = cmp.mapping(function()
                    if cmp.visible_docs() then
                        cmp.close_docs()
                    else
                        cmp.open_docs()
                    end
                end, { "i", "s" }),

                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
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

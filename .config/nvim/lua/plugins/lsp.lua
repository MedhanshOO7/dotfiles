return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "folke/lazydev.nvim",
    },
    config = function()
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        local float_border = {
            { "╭", "LspFloatBorder" },
            { "─", "LspFloatBorder" },
            { "╮", "LspFloatBorder" },
            { "│", "LspFloatBorder" },
            { "╯", "LspFloatBorder" },
            { "─", "LspFloatBorder" },
            { "╰", "LspFloatBorder" },
            { "│", "LspFloatBorder" },
        }

        vim.api.nvim_set_hl(0, "LspFloatBorder", { fg = "#ffffff", bg = "NONE" })

        require("lazydev").setup({
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        })

        vim.diagnostic.config({
            virtual_text = {
                prefix = "●",
                spacing = 2,
            },
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = "✘",
                    [vim.diagnostic.severity.WARN] = "▲",
                    [vim.diagnostic.severity.HINT] = "⚑",
                    [vim.diagnostic.severity.INFO] = "»",
                },
            },
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = {
                border = "rounded",
                source = "always",
            },
        })

        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
            border = float_border,
            focusable = false,
            max_width = math.floor(vim.o.columns * 0.40),
            max_height = math.floor(vim.o.lines * 0.25),
        })

        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
            border = float_border,
            focusable = false,
            max_width = math.floor(vim.o.columns * 0.35),
            max_height = math.floor(vim.o.lines * 0.20),
        })

        local servers = {
            bashls = {},
            clangd = {},
            cssls = {},
            html = {},
            jsonls = {},
            lua_ls = {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = {
                            globals = { "vim" },
                        },
                        workspace = {
                            checkThirdParty = false,
                            library = vim.api.nvim_get_runtime_file("", true),
                        },
                        telemetry = { enable = false },
                    },
                },
            },
            pylsp = {},
            ts_ls = {},
        }

        for server, config in pairs(servers) do
            config.capabilities = capabilities
            vim.lsp.config(server, config)
            vim.lsp.enable(server)
        end

        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(event)
                local opts = { buffer = event.buf }

                vim.keymap.set("n", "<leader>ds", vim.diagnostic.open_float,
                    vim.tbl_extend("force", opts, { desc = "Explain the problem on this line" }))
                vim.keymap.set("n", "[d", vim.diagnostic.goto_prev,
                    vim.tbl_extend("force", opts, { desc = "Go to the previous problem" }))
                vim.keymap.set("n", "]d", vim.diagnostic.goto_next,
                    vim.tbl_extend("force", opts, { desc = "Go to the next problem" }))
            end,
        })
    end,
}

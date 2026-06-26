return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "folke/lazydev.nvim",
        "b0o/schemastore.nvim",
        "mason-org/mason.nvim",
        "mason-org/mason-lspconfig.nvim",
    },
    config = function()
        local function cmd(command)
            return "<cmd>" .. command .. "<CR>"
        end

        local function smart_code_action()
            local ok, tiny = pcall(require, "tiny-code-action")
            if ok then
                tiny.code_action()
                return
            end

            vim.lsp.buf.code_action()
        end

        local function smart_rename()
            if vim.fn.exists(":IncRename") == 2 then
                vim.cmd("IncRename " .. vim.fn.expand("<cword>"))
                return
            end

            vim.lsp.buf.rename()
        end

        local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
        local capabilities = cmp_lsp_ok and cmp_nvim_lsp.default_capabilities() or vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
        }

        local float_border = {
            { "╭", "FloatBorder" },
            { "─", "FloatBorder" },
            { "╮", "FloatBorder" },
            { "│", "FloatBorder" },
            { "╯", "FloatBorder" },
            { "─", "FloatBorder" },
            { "╰", "FloatBorder" },
            { "│", "FloatBorder" },
        }

        local function bordered(config)
            return vim.tbl_deep_extend("force", config or {}, {
                border = float_border,
                focusable = false,
                max_width = math.floor(vim.o.columns * 0.40),
                max_height = math.floor(vim.o.lines * 0.25),
            })
        end

        local function toggle_inlay_hints(bufnr)
            if not vim.lsp.inlay_hint then
                vim.notify("Inlay hints are not supported in this Neovim build", vim.log.levels.WARN)
                return
            end

            local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
            vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
            vim.notify(not enabled and "Inlay hints are on" or "Inlay hints are off")
        end

        local lazydev_ok, lazydev = pcall(require, "lazydev")
        if lazydev_ok then
            lazydev.setup({
                library = {
                    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                },
            })
        end

        vim.diagnostic.config({
            virtual_text = {
                prefix = "●",
                spacing = 2,
                source = "if_many",
                severity = {
                    min = vim.diagnostic.severity.WARN,
                },
            },
            virtual_lines = false,
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = "",
                    [vim.diagnostic.severity.WARN] = "",
                    [vim.diagnostic.severity.HINT] = "",
                    [vim.diagnostic.severity.INFO] = "",
                },
            },
            underline = {
                severity = vim.diagnostic.severity.ERROR,
            },
            update_in_insert = false,
            severity_sort = true,
            float = {
                border = float_border,
                source = "if_many",
                scope = "cursor",
            },
        })





        local servers_ok, servers = pcall(require, "lsp.servers")
        if not servers_ok then
            vim.notify("Failed to load LSP servers config", vim.log.levels.ERROR)
            servers = {}
        end

        -- Ensure lspconfig is loaded so it registers default configs with vim.lsp.config
        pcall(require, "lspconfig")

        -- Global LSP commands and keybinds


        vim.keymap.set("n", "<leader>lR", "<cmd>LspRestart<cr>", { desc = "Restart language servers" })

        local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
        if mason_lspconfig_ok then
            mason_lspconfig.setup({
                ensure_installed = {
                    "bashls",
                    "clangd",
                    "cssls",
                    "html",
                    "jsonls",
                    "lua_ls",
                    "marksman",
                    "pylsp",
                    "qmlls",
                    "vtsls",
                    "yamlls",
                },
                automatic_installation = true,
            })
        end

        for server, server_config in pairs(servers) do
            local merged_config = vim.tbl_deep_extend("force", {
                capabilities = capabilities,
            }, server_config)
            
            -- Use the modern Neovim 0.11+ native API
            vim.lsp.config(server, merged_config)
            vim.lsp.enable(server)
        end

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
            callback = function(event)
                local client = vim.lsp.get_client_by_id(event.data.client_id)

                local function map_lsp(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, {
                        buffer = event.buf,
                        desc = desc,
                    })
                end

                vim.bo[event.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

                map_lsp("n", "<leader>le", function()
                    vim.diagnostic.open_float(bordered({
                        scope = "cursor",
                        source = "if_many",
                    }))
                end, "Explain the problem on this line")
                map_lsp("n", "<leader>ld", function()
                    vim.diagnostic.open_float(bordered({
                        scope = "cursor",
                        source = "if_many",
                    }))
                end, "Explain the problem on this line")
                map_lsp("n", "<leader>lD", vim.lsp.buf.declaration, "Jump to where this symbol is declared")
                map_lsp("n", "<leader>li", vim.lsp.buf.implementation, "Jump to the implementation")
                map_lsp("n", "<leader>lo", cmd("Telescope lsp_document_symbols"), "Search symbols in this file")
                map_lsp("n", "<leader>ls", cmd("Telescope lsp_workspace_symbols"), "Search workspace symbols")
                map_lsp("n", "<leader>lt", vim.lsp.buf.type_definition, "Jump to the type definition")
                map_lsp("n", "gd", vim.lsp.buf.definition, "Jump to where this symbol is defined")
                map_lsp("n", "gD", vim.lsp.buf.declaration, "Jump to where this symbol is declared")
                map_lsp("n", "gr", vim.lsp.buf.references, "Show every place this symbol is used")
                map_lsp("n", "gi", vim.lsp.buf.implementation, "Jump to the implementation")
                map_lsp("n", "K", vim.lsp.buf.hover, "Show documentation for the symbol under the cursor")
                map_lsp("i", "<C-k>", vim.lsp.buf.signature_help, "Show function signature help")
                map_lsp("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Go to the previous diagnostic")
                map_lsp("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Go to the next diagnostic")
                map_lsp("n", "<leader>lk", vim.lsp.buf.signature_help, "Show function signature help")
                map_lsp("n", "<leader>rn", smart_rename, "Rename this symbol everywhere")
                map_lsp({ "n", "v" }, "<leader>ca", smart_code_action, "Show suggested code fixes and actions")

                local navic_ok, navic = pcall(require, "nvim-navic")
                if client and navic_ok and client:supports_method("textDocument/documentSymbol") then
                    if not vim.b[event.buf].navic_attached then
                        navic.attach(client, event.buf)
                        vim.b[event.buf].navic_attached = true
                    end
                end



                if client and client:supports_method("textDocument/inlayHint") and vim.lsp.inlay_hint then
                    vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
                    map_lsp("n", "<leader>lI", function()
                        toggle_inlay_hints(event.buf)
                    end, "Turn inlay hints on or off")
                end
            end,
        })

        vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("user_lsp_detach", { clear = true }),
            callback = function()
                pcall(vim.lsp.buf.clear_references)
            end,
        })
    end,
}

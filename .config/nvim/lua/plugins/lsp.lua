return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "folke/lazydev.nvim",
        "mason-org/mason.nvim",
        "mason-org/mason-lspconfig.nvim",
    },
    config = function()
        local function cmd(command)
            return "<cmd>" .. command .. "<CR>"
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

        vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
            return vim.lsp.handlers.hover(err, result, ctx, bordered(config))
        end

        vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
            return vim.lsp.handlers.signature_help(err, result, ctx, bordered(config))
        end

        vim.api.nvim_create_autocmd("CursorHold", {
            group = vim.api.nvim_create_augroup("lsp_diagnostic_hover", { clear = true }),
            callback = function()
                if vim.api.nvim_get_mode().mode ~= "n" then
                    return
                end

                local diagnostics = vim.diagnostic.get(0, {
                    lnum = vim.api.nvim_win_get_cursor(0)[1] - 1,
                })

                if #diagnostics == 0 then
                    return
                end

                vim.diagnostic.open_float(nil, bordered({
                    scope = "cursor",
                    source = "if_many",
                    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                }))
            end,
        })

        local servers_ok, servers = pcall(require, "lsp.servers")
        if not servers_ok then
            vim.notify("Failed to load LSP servers config", vim.log.levels.ERROR)
            servers = {}
        end

        -- Ensure lspconfig is loaded so it registers default configs with vim.lsp.config
        pcall(require, "lspconfig")

        for server, server_config in pairs(servers) do
            local merged_config = vim.tbl_deep_extend("force", {
                capabilities = capabilities,
                flags = {
                    debounce_text_changes = 150,
                },
            }, server_config)
            
            -- Use the modern Neovim 0.11+ native API
            vim.lsp.config(server, merged_config)
            vim.lsp.enable(server)
        end

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
                    "ts_ls",
                    "yamlls",
                },
                automatic_installation = true,
            })
        end

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
            callback = function(event)
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                local highlight_group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. event.buf, { clear = true })

                local function map_lsp(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, {
                        buffer = event.buf,
                        desc = desc,
                    })
                end

                vim.bo[event.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

                map_lsp("n", "<leader>le", function()
                    vim.diagnostic.open_float(nil, bordered({
                        scope = "cursor",
                        source = "if_many",
                    }))
                end, "Explain the problem on this line")
                map_lsp("n", "<leader>ld", function()
                    vim.diagnostic.open_float(nil, bordered({
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
                map_lsp("n", "[d", vim.diagnostic.goto_prev, "Go to the previous diagnostic")
                map_lsp("n", "]d", vim.diagnostic.goto_next, "Go to the next diagnostic")
                map_lsp("n", "<leader>lk", vim.lsp.buf.signature_help, "Show function signature help")
                map_lsp("n", "<leader>lR", cmd("LspRestart"), "Restart language servers for this file")
                map_lsp("n", "<leader>rn", vim.lsp.buf.rename, "Rename this symbol everywhere")
                map_lsp({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Show suggested code fixes and actions")

                local navic_ok, navic = pcall(require, "nvim-navic")
                if client and navic_ok and client:supports_method("textDocument/documentSymbol") then
                    navic.attach(client, event.buf)
                end

                if client and client:supports_method("textDocument/documentHighlight") then
                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        group = highlight_group,
                        buffer = event.buf,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
                        group = highlight_group,
                        buffer = event.buf,
                        callback = vim.lsp.buf.clear_references,
                    })
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
            callback = function(event)
                pcall(vim.lsp.buf.clear_references)
                pcall(vim.api.nvim_del_augroup_by_name, "lsp_document_highlight_" .. event.buf)
            end,
        })
    end,
}

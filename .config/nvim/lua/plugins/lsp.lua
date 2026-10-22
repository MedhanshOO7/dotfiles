return {
    "neovim/nvim-lspconfig",

    event = { "BufReadPre", "BufNewFile" },

    dependencies = {
        "saghen/blink.cmp",
        "folke/lazydev.nvim",
        "b0o/schemastore.nvim",
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
            vim.lsp.buf.rename()
        end

        -- ============================================================
        -- LSP CAPABILITIES
        -- ============================================================

        local capabilities = vim.lsp.protocol.make_client_capabilities()

        local blink_ok, blink = pcall(require, "blink.cmp")

        if blink_ok then
            capabilities = blink.get_lsp_capabilities(capabilities)
        end

        capabilities.textDocument.foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
        }

        -- ============================================================
        -- UI
        -- ============================================================

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

        -- ============================================================
        -- INLAY HINTS
        -- ============================================================

        local function toggle_inlay_hints(bufnr)
            if not vim.lsp.inlay_hint then
                vim.notify("Inlay hints are not supported in this Neovim build", vim.log.levels.WARN)
                return
            end

            local enabled = vim.lsp.inlay_hint.is_enabled({
                bufnr = bufnr,
            })

            vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })

            vim.notify(not enabled and "Inlay hints are on" or "Inlay hints are off")
        end

        -- ============================================================
        -- LAZYDEV
        -- ============================================================

        local lazydev_ok, lazydev = pcall(require, "lazydev")

        if lazydev_ok then
            lazydev.setup({
                library = {
                    {
                        path = "${3rd}/luv/library",
                        words = { "vim%.uv" },
                    },
                },
            })
        end

        -- ============================================================
        -- DIAGNOSTICS
        -- ============================================================

        vim.diagnostic.config({
            virtual_text = false,
            virtual_lines = false,

            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = "",
                    [vim.diagnostic.severity.WARN] = "",
                    [vim.diagnostic.severity.HINT] = "",
                    [vim.diagnostic.severity.INFO] = "",
                },

                numhl = {},
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

                max_width = math.floor(vim.o.columns * 0.6),
                max_height = math.floor(vim.o.lines * 0.4),
            },
        })

        -- LSP progress, hover and signature help are rendered by noice.nvim
        -- (lua/plugins/noice.lua). Don't override those handlers here: a
        -- handler installed after noice loads silently replaces noice's.

        -- ============================================================
        -- SERVER CONFIGURATION
        -- ============================================================

        local servers_ok, servers = pcall(require, "lsp.servers")

        if not servers_ok then
            vim.notify("Failed to load LSP servers config", vim.log.levels.ERROR)

            servers = {}
        end

        vim.keymap.set("n", "<leader>lR", function()
            -- `:lsp` is built in from 0.12; nvim-lspconfig provides :LspRestart on 0.11
            vim.cmd(vim.fn.exists(":lsp") == 2 and "lsp restart" or "LspRestart")
        end, {
            desc = "Restart language servers",
        })

        -- ============================================================
        -- ENABLE LSP SERVERS
        -- ============================================================

        for server, server_config in pairs(servers) do
            vim.lsp.config(server, vim.tbl_deep_extend("force", {
                capabilities = capabilities,
            }, server_config))
            vim.lsp.enable(server)
        end

        -- ============================================================
        -- LSP ATTACH
        -- ============================================================

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),

            callback = function(event)
                -- Disable LSP for very large files.
                if vim.b[event.buf].large_file or vim.b[event.buf].bigfile then
                    vim.schedule(function()
                        pcall(vim.lsp.buf_detach_client, event.buf, event.data.client_id)
                    end)

                    return
                end

                local client = vim.lsp.get_client_by_id(event.data.client_id)

                local function map_lsp(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, {
                        buffer = event.buf,
                        desc = desc,
                    })
                end

                vim.bo[event.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

                -- Diagnostics.
                map_lsp("n", "<leader>le", function()
                    vim.diagnostic.open_float(bordered({
                        scope = "cursor",
                        source = "if_many",
                    }))
                end, "Explain the problem on this line")

                -- Navigation.
                map_lsp("n", "<leader>ld", vim.lsp.buf.definition, "Jump to where this symbol is defined")

                map_lsp("n", "<leader>lD", vim.lsp.buf.declaration, "Jump to where this symbol is declared")

                map_lsp("n", "<leader>li", vim.lsp.buf.implementation, "Jump to the implementation")

                map_lsp("n", "<leader>lo", function()
                    require("snacks").picker.lsp_symbols()
                end, "Search symbols in this file")

                map_lsp("n", "<leader>ls", function()
                    require("snacks").picker.lsp_workspace_symbols()
                end, "Search workspace symbols")

                map_lsp("n", "<leader>lt", vim.lsp.buf.type_definition, "Jump to the type definition")

                map_lsp("n", "gd", vim.lsp.buf.definition, "Jump to where this symbol is defined")

                map_lsp("n", "gD", vim.lsp.buf.declaration, "Jump to where this symbol is declared")

                map_lsp("n", "gr", vim.lsp.buf.references, "Show every place this symbol is used")

                map_lsp("n", "gi", vim.lsp.buf.implementation, "Jump to the implementation")

                map_lsp("n", "K", vim.lsp.buf.hover, "Show documentation for the symbol under the cursor")

                -- Diagnostics navigation.
                map_lsp("n", "[d", function()
                    vim.diagnostic.jump({
                        count = -1,
                        float = true,
                    })
                end, "Go to the previous diagnostic")

                map_lsp("n", "]d", function()
                    vim.diagnostic.jump({
                        count = 1,
                        float = true,
                    })
                end, "Go to the next diagnostic")

                -- Signature help.
                map_lsp("n", "<leader>lk", vim.lsp.buf.signature_help, "Show function signature help")

                -- Rename.
                map_lsp("n", "<leader>rn", smart_rename, "Rename this symbol everywhere")

                -- Code actions.
                map_lsp({ "n", "v" }, "<leader>ca", smart_code_action, "Show suggested code fixes and actions")

                -- Inlay hints.
                if client and client:supports_method("textDocument/inlayHint") and vim.lsp.inlay_hint then
                    map_lsp("n", "<leader>lI", function()
                        toggle_inlay_hints(event.buf)
                    end, "Turn inlay hints on or off")
                end
            end,
        })

        -- ============================================================
        -- LSP DETACH
        -- ============================================================

        vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("user_lsp_detach", { clear = true }),

            callback = function()
                pcall(vim.lsp.buf.clear_references)
            end,
        })
    end,
}

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "folke/lazydev.nvim",
    },
    config = function()
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        capabilities.textDocument.foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
        }

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

        local function hl_fg(group)
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
            return (ok and hl.fg) and string.format("#%06x", hl.fg) or nil
        end

        local function apply_highlights()
            vim.api.nvim_set_hl(0, "LspFloatBorder", {
                fg = hl_fg("FloatBorder") or hl_fg("WinSeparator") or hl_fg("NormalFloat"),
                bg = "NONE",
            })
        end

        apply_highlights()

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("nvim_lsp_theme_sync", { clear = true }),
            pattern = "*",
            callback = apply_highlights,
        })

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

        require("lazydev").setup({
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        })

        -- Keep diagnostics informative without turning every line into a warning wall.
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
                    [vim.diagnostic.severity.ERROR] = "✘",
                    [vim.diagnostic.severity.WARN] = "▲",
                    [vim.diagnostic.severity.HINT] = "⚑",
                    [vim.diagnostic.severity.INFO] = "»",
                },
            },
            underline = {
                severity = vim.diagnostic.severity.ERROR,
            },
            update_in_insert = false,
            severity_sort = true,
            jump = {
                float = true,
            },
            float = {
                border = "rounded",
                source = "if_many",
                scope = "line",
            },
        })

        vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
            config = bordered(config)
            return vim.lsp.handlers.hover(err, result, ctx, config)
        end

        vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
            config = bordered(config)
            return vim.lsp.handlers.signature_help(err, result, ctx, config)
        end

        local servers = {
            bashls = {
                filetypes = { "bash", "sh", "zsh" },
            },
            clangd = {
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--completion-style=detailed",
                    "--header-insertion=iwyu",
                },
                init_options = {
                    clangdFileStatus = true,
                    completeUnimported = true,
                    usePlaceholders = true,
                },
            },
            cssls = {
                settings = {
                    css = { validate = true },
                    scss = { validate = true },
                    less = { validate = true },
                },
            },
            html = {},
            jsonls = {
                settings = {
                    json = {
                        validate = { enable = true },
                        format = { enable = true },
                    },
                },
            },
            lua_ls = {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        completion = {
                            callSnippet = "Replace",
                        },
                        diagnostics = {
                            globals = { "vim" },
                        },
                        hint = {
                            enable = true,
                            arrayIndex = "Disable",
                            paramName = "Disable",
                            paramType = true,
                            setType = true,
                        },
                        workspace = {
                            checkThirdParty = false,
                            library = vim.api.nvim_get_runtime_file("", true),
                        },
                        telemetry = { enable = false },
                    },
                },
            },
            pylsp = {
                settings = {
                    pylsp = {
                        plugins = {
                            autopep8 = { enabled = false },
                            mccabe = { enabled = false },
                            pycodestyle = { enabled = false },
                            pyflakes = { enabled = true },
                            yapf = { enabled = false },
                            jedi_completion = {
                                fuzzy = true,
                                include_params = true,
                            },
                            jedi_hover = { enabled = true },
                            jedi_references = { enabled = true },
                            jedi_signature_help = { enabled = true },
                            preload = { enabled = true },
                        },
                    },
                },
            },
            ts_ls = {
                settings = {
                    typescript = {
                        inlayHints = {
                            includeInlayEnumMemberValueHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayParameterNameHints = "all",
                            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayVariableTypeHints = false,
                        },
                    },
                    javascript = {
                        inlayHints = {
                            includeInlayEnumMemberValueHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayParameterNameHints = "all",
                            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayVariableTypeHints = false,
                        },
                    },
                },
            },
        }

        -- Use one baseline capability set, then layer server-specific behavior only where
        -- it improves the daily workflow for that language.
        for server, config in pairs(servers) do
            config.capabilities = capabilities
            vim.lsp.config(server, config)
            vim.lsp.enable(server)
        end

        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(event)
                local opts = { buffer = event.buf }
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                local highlight_group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. event.buf, { clear = true })

                vim.bo[event.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

                vim.keymap.set("n", "<leader>ds", vim.diagnostic.open_float,
                    vim.tbl_extend("force", opts, { desc = "Explain the problem on this line" }))
                vim.keymap.set("n", "[d", vim.diagnostic.goto_prev,
                    vim.tbl_extend("force", opts, { desc = "Go to the previous problem" }))
                vim.keymap.set("n", "]d", vim.diagnostic.goto_next,
                    vim.tbl_extend("force", opts, { desc = "Go to the next problem" }))
                vim.keymap.set("n", "<leader>le", vim.diagnostic.open_float,
                    vim.tbl_extend("force", opts, { desc = "Explain the problem on this line" }))
                vim.keymap.set("n", "<leader>lk", vim.lsp.buf.signature_help,
                    vim.tbl_extend("force", opts, { desc = "Show function signature help" }))
                vim.keymap.set("n", "<leader>lo", "<cmd>Telescope lsp_document_symbols<CR>",
                    vim.tbl_extend("force", opts, { desc = "Search symbols in this file" }))
                vim.keymap.set("n", "<leader>lR", "<cmd>LspRestart<CR>",
                    vim.tbl_extend("force", opts, { desc = "Restart language servers for this file" }))

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

                if client and client:supports_method("textDocument/inlayHint") then
                    if vim.lsp.inlay_hint then
                        vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
                        vim.keymap.set("n", "<leader>lI", function()
                            toggle_inlay_hints(event.buf)
                        end, vim.tbl_extend("force", opts, { desc = "Turn inlay hints on or off" }))
                    end
                end
            end,
        })

        vim.api.nvim_create_autocmd("LspDetach", {
            callback = function(event)
                pcall(vim.lsp.buf.clear_references)
                pcall(vim.api.nvim_del_augroup_by_name, "lsp_document_highlight_" .. event.buf)
            end,
        })
    end,
}

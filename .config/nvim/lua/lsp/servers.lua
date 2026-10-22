return {
    -- ============================================================
    -- BASH
    -- ============================================================

    bashls = {
        filetypes = { "bash", "sh", "zsh" },

        settings = {
            bashIde = {
                globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.bash|.zsh|.env|.envrc|.ksh|PKGBUILD)",

                shellcheckPath = "shellcheck",
            },
        },
    },

    -- ============================================================
    -- CLANGD
    -- ============================================================

    clangd = {
        cmd = {
            "clangd",
            "--background-index",
            "--all-scopes-completion",
            "--clang-tidy",
            "--completion-style=detailed",
            "--function-arg-placeholders=0",
            "--header-insertion=iwyu",
            "--fallback-style=WebKit",
            "--log=error",

            "--query-driver=/usr/bin/arm-none-eabi-*,"
                .. "/opt/homebrew/bin/*,"
                .. "/usr/local/bin/*,"
                .. "/usr/bin/*gcc*,"
                .. "/usr/bin/*g++,"
                .. "/usr/bin/clang*,"
                .. "/Library/Developer/CommandLineTools/usr/bin/*",
        },

        filetypes = {
            "c",
            "cpp",
            "objc",
            "objcpp",
        },

        before_init = function(_, config)
            local root = config.root_dir or vim.fn.getcwd()

            local platformio_ini = vim.fn.glob(root .. "/platformio.ini")

            local opts = vim.deepcopy(config.init_options or {})

            if platformio_ini ~= "" then
                local compile_commands = root .. "/compile_commands.json"

                local already_exists = vim.fn.filereadable(compile_commands) == 1

                if not already_exists then
                    vim.system({
                        "pio",
                        "run",
                        "--target",
                        "compiledb",
                    }, {
                        cwd = root,
                    }, function(obj)
                        vim.schedule(function()
                            if obj.code ~= 0 then
                                vim.notify(
                                    "PlatformIO: Failed to generate compile_commands.json\n" .. (obj.stderr or ""),
                                    vim.log.levels.WARN,
                                    {
                                        title = "clangd/PlatformIO",
                                    }
                                )

                                return
                            end

                            vim.notify(
                                "PlatformIO: compile_commands.json generated, restarting clangd",
                                vim.log.levels.INFO,
                                {
                                    title = "clangd/PlatformIO",
                                }
                            )

                            -- :LspStart is not defined by nvim-lspconfig on Nvim 0.12+
                            vim.cmd(vim.fn.exists(":lsp") == 2 and "lsp restart clangd" or "LspRestart clangd")
                        end)
                    end)
                end

                opts.compilationDatabasePath = root
            end

            config.init_options = opts
        end,
    },

    -- ============================================================
    -- CSS
    -- ============================================================

    cssls = {
        settings = {
            css = {
                validate = true,

                lint = {
                    unknownAtRules = "ignore",
                },
            },

            scss = {
                validate = true,
            },

            less = {
                validate = true,
            },
        },
    },

    -- ============================================================
    -- TAILWIND
    -- ============================================================

    tailwindcss = {
        filetypes = {
            "html",
            "css",
            "scss",
            "less",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "vue",
            "svelte",
            "astro",
        },
    },

    -- ============================================================
    -- EMMET
    -- ============================================================

    emmet_language_server = {
        filetypes = {
            "css",
            "eruby",
            "html",
            "javascript",
            "javascriptreact",
            "less",
            "pug",
            "sass",
            "scss",
            "typescriptreact",
        },
    },

    -- ============================================================
    -- HTML
    -- ============================================================

    html = {
        filetypes = {
            "html",
            "templ",
        },
    },

    -- ============================================================
    -- JSON
    -- ============================================================

    jsonls = {
        settings = {
            json = {
                validate = {
                    enable = true,
                },

                format = {
                    enable = true,
                },
            },
        },

        -- on_new_config is an old lspconfig hook that vim.lsp.config never calls;
        -- before_init runs before the settings are sent to the server.
        before_init = function(_, config)
            local ok, schemastore = pcall(require, "schemastore")

            if ok then
                config.settings = config.settings or {}
                config.settings.json = config.settings.json or {}
                config.settings.json.schemas = schemastore.json.schemas()
            end
        end,
    },

    -- ============================================================
    -- LUA
    -- ============================================================

    lua_ls = {
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                },

                completion = {
                    autoRequire = true,
                    callSnippet = "Replace",
                },

                diagnostics = {
                    globals = {
                        "vim",
                    },
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
                },

                telemetry = {
                    enable = false,
                },
            },
        },
    },

    -- ============================================================
    -- PYTHON / BASEDPYRIGHT
    -- ============================================================

    basedpyright = {
        settings = {
            basedpyright = {
                analysis = {
                    -- Only diagnose files you currently have open.
                    diagnosticMode = "openFilesOnly",

                    -- Good balance between useful checking and noise.
                    typeCheckingMode = "standard",

                    -- Let basedpyright discover normal Python paths.
                    autoSearchPaths = true,

                    -- Use installed package source/type information.
                    useLibraryCodeForTypes = true,

                    -- Enable automatic import suggestions.
                    autoImportCompletions = true,

                    -- Useful Python type information in the editor.
                    inlayHints = {
                        variableTypes = true,
                        functionReturnTypes = true,
                        callArgumentNames = true,
                    },
                },
            },
        },
    },

    -- ============================================================
    -- MARKDOWN
    -- ============================================================

    marksman = {
        filetypes = {
            "markdown",
            "markdown.mdx",
        },
    },

    -- ============================================================
    -- QML
    -- ============================================================

    qmlls = {
        filetypes = {
            "qml",
        },
    },

    -- ============================================================
    -- TYPESCRIPT / JAVASCRIPT
    -- ============================================================

    vtsls = {
        filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
        },

        settings = {
            typescript = {
                suggest = {
                    completeFunctionCalls = true,
                },

                inlayHints = {
                    includeInlayEnumMemberValueHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayVariableTypeHints = false,
                },

                preferences = {
                    includePackageJsonAutoImports = "auto",
                    importModuleSpecifier = "shortest",
                    quoteStyle = "auto",
                },
            },

            javascript = {
                suggest = {
                    completeFunctionCalls = true,
                },

                inlayHints = {
                    includeInlayEnumMemberValueHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayVariableTypeHints = false,
                },

                preferences = {
                    includePackageJsonAutoImports = "auto",
                    importModuleSpecifier = "shortest",
                    quoteStyle = "auto",
                },
            },
        },
    },

    -- ============================================================
    -- YAML
    -- ============================================================

    yamlls = {
        settings = {
            yaml = {
                keyOrdering = false,

                format = {
                    enable = true,
                },

                validate = true,
            },
        },

        before_init = function(_, config)
            local ok, schemastore = pcall(require, "schemastore")

            if ok then
                config.settings = config.settings or {}
                config.settings.yaml = config.settings.yaml or {}
                -- Use SchemaStore.nvim's catalogue instead of yamlls' built-in download
                config.settings.yaml.schemaStore = { enable = false, url = "" }
                config.settings.yaml.schemas = schemastore.yaml.schemas()
            end
        end,
    },
}

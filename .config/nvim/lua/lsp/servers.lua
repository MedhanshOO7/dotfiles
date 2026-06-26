return {
    bashls = {
        filetypes = { "bash", "sh", "zsh" },
        settings = {
            bashIde = {
                globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.bash|.zsh|.env|.envrc|.ksh|PKGBUILD)",
                shellcheckPath = "shellcheck",
            },
        },
    },
    clangd = {
        cmd = {
            "clangd",
            "--background-index",
            "--all-scopes-completion",
            "--clang-tidy",
            "--completion-style=detailed",
            "--function-arg-placeholders=0",
            "--header-insertion=iwyu",
            "--fallback-style={BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Never}",
            "--log=error",
        },
        init_options = {
            clangdFileStatus = false,
            completeUnimported = true,
            usePlaceholders = true,
        },
    },
    cssls = {
        settings = {
            css = {
                validate = true,
                lint = {
                    unknownAtRules = "ignore",
                },
            },
            scss = { validate = true },
            less = { validate = true },
        },
    },
    html = {
        filetypes = { "html", "templ" },
    },
    jsonls = {
        settings = {
            json = {
                validate = { enable = true },
                format = { enable = true },
            },
        },
        on_new_config = function(new_config)
            local ok, schemastore = pcall(require, "schemastore")
            if ok then
                new_config.settings = new_config.settings or {}
                new_config.settings.json = new_config.settings.json or {}
                new_config.settings.json.schemas = schemastore.json.schemas()
            end
        end,
    },
    lua_ls = {
        settings = {
            Lua = {
                runtime = { version = "LuaJIT" },
                completion = {
                    autoRequire = true,
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
                    library = vim.list_extend(vim.api.nvim_get_runtime_file("", true), {
                        vim.fn.stdpath("config"),
                        vim.fn.stdpath("data") .. "/lazy",
                    }),
                },
                telemetry = { enable = false },
            },
        },
    },
    marksman = {},
    pylsp = {
        settings = {
            pylsp = {
                plugins = {
                    autopep8 = { enabled = false },
                    mccabe = { enabled = false },
                    pycodestyle = { enabled = false },
                    pyflakes = { enabled = true },
                    yapf = { enabled = false },
                    pylsp_mypy = { enabled = false },
                    pylint = { enabled = false },
                    rope_autoimport = { enabled = true },
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
    qmlls = {},
    vtsls = {
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
    yamlls = {
        settings = {
            yaml = {
                keyOrdering = false,
                format = { enable = true },
                validate = true,
            },
        },
        on_new_config = function(new_config)
            local ok, schemastore = pcall(require, "schemastore")
            if ok then
                new_config.settings = new_config.settings or {}
                new_config.settings.yaml = new_config.settings.yaml or {}
                new_config.settings.yaml.schemas = schemastore.yaml.schemas()
            end
        end,
    },
}

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
            "--fallback-style=WebKit",
            "--log=error",
            "--query-driver=**/*arm-none-eabi*,/usr/bin/arm-none-eabi-*,/usr/bin/*gcc*,/usr/bin/*g++*,/usr/bin/clang*,/opt/homebrew/bin/*,/usr/local/bin/*,/Library/Developer/CommandLineTools/usr/bin/*",
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
                },
                telemetry = { enable = false },
            },
        },
    },
    basedpyright = {
        before_init = function(_, config)
            local root = config.root_dir or vim.fn.getcwd()
            local venv = vim.env.VIRTUAL_ENV
            if not venv or venv == "" then
                local file_path = vim.api.nvim_buf_get_name(0)
                local start_dir = (file_path ~= "" and vim.fs.dirname(file_path)) or root
                local found = vim.fs.find({ ".venv", "venv" }, { upward = true, path = start_dir })[1]
                if found then
                    venv = vim.fn.fnamemodify(found, ":p"):gsub("/$", "")
                end
            end
            if venv and venv ~= "" then
                local python_bin = venv .. "/bin/python"
                if vim.fn.executable(python_bin) == 1 then
                    config.settings = config.settings or {}
                    config.settings.python = config.settings.python or {}
                    config.settings.python.pythonPath = python_bin

                    local site_packages = vim.fn.glob(venv .. "/lib/python*/site-packages", false, true)
                    if #site_packages > 0 then
                        config.settings.basedpyright = config.settings.basedpyright or {}
                        config.settings.basedpyright.analysis = config.settings.basedpyright.analysis or {}
                        config.settings.basedpyright.analysis.extraPaths = site_packages
                    end
                end
            end
        end,
        settings = {
            python = {},
            basedpyright = {
                analysis = {
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    diagnosticMode = "openFilesOnly",
                    typeCheckingMode = "standard",
                    autoImportCompletions = true,
                    inlayHints = {
                        variableTypes = true,
                        functionReturnTypes = true,
                        callArgumentNames = true,
                    },
                },
            },
        },
    },
    marksman = {},
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

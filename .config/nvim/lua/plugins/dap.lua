return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "nvim-neotest/nvim-nio",
            "mxsdev/nvim-dap-vscode-js",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            local mason_path = vim.fn.stdpath("data") .. "/mason/packages"

            local codelldb_path = mason_path .. "/codelldb/extension/adapter/codelldb"
            local js_debug_cmd = mason_path .. "/js-debug-adapter/js-debug-adapter"

            require("nvim-dap-virtual-text").setup({})
            dapui.setup({
                layouts = {
                    {
                        elements = {
                            { id = "scopes", size = 0.45 },
                            { id = "breakpoints", size = 0.2 },
                            { id = "stacks", size = 0.2 },
                            { id = "watches", size = 0.15 },
                        },
                        position = "right",
                        size = 48,
                    },
                    {
                        elements = {
                            { id = "repl", size = 0.5 },
                            { id = "console", size = 0.5 },
                        },
                        position = "bottom",
                        size = 12,
                    },
                },
            })

            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            if vim.fn.executable(codelldb_path) == 1 then
                dap.adapters.codelldb = {
                    type = "server",
                    port = "${port}",
                    executable = {
                        command = codelldb_path,
                        args = { "--port", "${port}" },
                    },
                }

                for _, language in ipairs({ "c", "cpp" }) do
                    dap.configurations[language] = {
                        {
                            name = "Launch current file",
                            type = "codelldb",
                            request = "launch",
                            program = function()
                                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                            end,
                            cwd = "${workspaceFolder}",
                            stopOnEntry = false,
                        },
                        {
                            name = "Launch executable in current folder",
                            type = "codelldb",
                            request = "launch",
                            program = function()
                                return vim.fn.getcwd() .. "/" .. vim.fn.expand("%:t:r")
                            end,
                            cwd = "${workspaceFolder}",
                            stopOnEntry = false,
                        },
                    }
                end
            end

            if vim.fn.executable(js_debug_cmd) == 1 then
                require("dap-vscode-js").setup({
                    debugger_cmd = { js_debug_cmd },
                    adapters = {
                        "pwa-node",
                        "node-terminal",
                    },
                })

                for _, language in ipairs({ "javascript", "typescript" }) do
                    dap.configurations[language] = {
                        {
                            type = "pwa-node",
                            request = "launch",
                            name = "Launch current file",
                            program = "${file}",
                            cwd = "${workspaceFolder}",
                        },
                    }
                end
            end

            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticSignError" })
            vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticSignWarn" })
            vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticSignInfo" })
        end,
    },
}

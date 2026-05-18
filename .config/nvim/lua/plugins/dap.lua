return {
    {
        "mfussenegger/nvim-dap",
        cmd = {
            "DapContinue",
            "DapToggleBreakpoint",
            "DapStepInto",
            "DapStepOver",
            "DapStepOut",
            "DapTerminate",
            "DapToggleRepl",
        },
        keys = {
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Add or remove a breakpoint" },
            { "<F5>", function() require("dap").continue() end, desc = "Start or continue debugging" },
            { "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
            { "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
            { "<F12>", function() require("dap").step_out() end, desc = "Debug: step out" },
            { "<leader>dc", function() require("dap").continue() end, desc = "Start or continue debugging" },
            { "<leader>di", function() require("dap").step_into() end, desc = "Debug: step into" },
            { "<leader>do", function() require("dap").step_over() end, desc = "Debug: step over" },
            { "<leader>dO", function() require("dap").step_out() end, desc = "Debug: step out" },
            { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Open the debugger console" },
            { "<leader>du", function() require("dapui").toggle() end, desc = "Open the debugger panels" },
            { "<leader>dt", function() require("dap").terminate() end, desc = "Stop debugging" },
        },
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "nvim-neotest/nvim-nio",
            "mfussenegger/nvim-dap-python",
            "mxsdev/nvim-dap-vscode-js",
        },
        config = function()
            local dap = require("dap")
            local mason_path = vim.fn.stdpath("data") .. "/mason/packages"
            local dapui_ok, dapui = pcall(require, "dapui")
            local virtual_text_ok, dap_virtual_text = pcall(require, "nvim-dap-virtual-text")
            local dap_python_ok, dap_python = pcall(require, "dap-python")
            local js_debug_ok, dap_vscode_js = pcall(require, "dap-vscode-js")

            local codelldb_path = mason_path .. "/codelldb/extension/adapter/codelldb"
            local debugpy_path = mason_path .. "/debugpy/venv/bin/python"
            local js_debug_cmd = mason_path .. "/js-debug-adapter/js-debug-adapter"

            if virtual_text_ok then
                dap_virtual_text.setup({})
            end

            if dapui_ok then
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

            if js_debug_ok and vim.fn.executable(js_debug_cmd) == 1 then
                dap_vscode_js.setup({
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

            if dap_python_ok and vim.fn.executable(debugpy_path) == 1 then
                dap_python.setup(debugpy_path)
                dap.configurations.python = dap.configurations.python or {}
                table.insert(dap.configurations.python, {
                    type = "python",
                    request = "launch",
                    name = "Launch current file with args",
                    program = "${file}",
                    args = function()
                        local input = vim.fn.input("Args: ")
                        return vim.split(input, " ", { trimempty = true })
                    end,
                    console = "integratedTerminal",
                    justMyCode = false,
                })
            end

            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticSignError" })
            vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticSignWarn" })
            vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticSignInfo" })
        end,
    },
}

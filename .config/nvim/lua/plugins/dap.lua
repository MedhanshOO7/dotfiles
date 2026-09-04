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
            { "<S-F5>", function() require("dap").terminate() end, desc = "Debug: Stop" },
            { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
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
        },
        config = function()
            local dap = require("dap")
            local mason_path = vim.fn.stdpath("data") .. "/mason/packages"
            local dapui_ok, dapui = pcall(require, "dapui")
            local virtual_text_ok, dap_virtual_text = pcall(require, "nvim-dap-virtual-text")
            local dap_python_ok, dap_python = pcall(require, "dap-python")

            local is_win = vim.fn.has("win32") == 1
            local codelldb_path = mason_path .. "/codelldb/extension/adapter/codelldb"
            if is_win or vim.fn.executable(codelldb_path .. ".exe") == 1 then
                if vim.fn.executable(codelldb_path .. ".exe") == 1 then
                    codelldb_path = codelldb_path .. ".exe"
                end
            end

            local debugpy_path = mason_path .. "/debugpy/venv/bin/python"
            if vim.fn.executable(debugpy_path) ~= 1 then
                debugpy_path = mason_path .. "/debugpy/venv/Scripts/python.exe"
            end

            local js_debug_cmd = mason_path .. "/js-debug-adapter/js-debug-adapter"
            if is_win or vim.fn.executable(js_debug_cmd .. ".cmd") == 1 then
                if vim.fn.executable(js_debug_cmd .. ".cmd") == 1 then
                    js_debug_cmd = js_debug_cmd .. ".cmd"
                end
            end

            if virtual_text_ok then
                dap_virtual_text.setup({})
            end

            if dapui_ok then
                dapui.setup({
                    floating = { border = "rounded" },
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
                                local default_exe = vim.fn.getcwd() .. "/" .. vim.fn.expand("%:t:r") .. (is_win and ".exe" or "")
                                return vim.fn.input("Path to executable: ", default_exe, "file")
                            end,
                            cwd = "${workspaceFolder}",
                            stopOnEntry = false,
                        },
                        {
                            name = "Launch executable in current folder",
                            type = "codelldb",
                            request = "launch",
                            program = function()
                                return vim.fn.getcwd() .. "/" .. vim.fn.expand("%:t:r") .. (is_win and ".exe" or "")
                            end,
                            cwd = "${workspaceFolder}",
                            stopOnEntry = false,
                        },
                    }
                end
            end

            if vim.fn.executable(js_debug_cmd) == 1 then
                dap.adapters["pwa-node"] = {
                    type = "server",
                    host = "localhost",
                    port = "${port}",
                    executable = {
                        command = js_debug_cmd,
                        args = { "${port}" },
                    },
                }

                for _, language in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
                    dap.configurations[language] = {
                        {
                            type = "pwa-node",
                            request = "launch",
                            name = "Launch current file",
                            program = "${file}",
                            cwd = "${workspaceFolder}",
                        },
                        {
                            type = "pwa-node",
                            request = "attach",
                            name = "Attach to Node process",
                            processId = require("dap.utils").pick_process,
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

            if vim.fn.executable("arm-none-eabi-gdb") == 1 then
                dap.adapters.gdb = {
                    type = "executable",
                    command = "arm-none-eabi-gdb",
                    args = { "-i", "dap" },
                }
                dap.configurations.c = dap.configurations.c or {}
                table.insert(dap.configurations.c, {
                    name = "Embedded GDB",
                    type = "gdb",
                    request = "attach",
                    target = "localhost:3333",
                    cwd = "${workspaceFolder}",
                    program = function()
                        return vim.fn.input("Path to ELF: ", vim.fn.getcwd() .. "/build/zephyr/zephyr.elf", "file")
                    end,
                })
            end

            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticSignError" })
            vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticSignWarn" })
            vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticSignInfo" })
        end,
    },
}

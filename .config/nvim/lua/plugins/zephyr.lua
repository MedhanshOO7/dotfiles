return {
    -- Zephyr / nRF Connect SDK integration
    -- Provides west build, flash, and menuconfig commands inside Neovim.

    -- Overseer templates for west commands
    {
        "stevearc/overseer.nvim",
        opts = function(_, opts)
            opts.templates = opts.templates or {}
            table.insert(opts.templates, {
                name = "west build",
                builder = function()
                    return {
                        cmd = { "west" },
                        args = { "build", "-b", vim.g.zephyr_board or "nrf52840dk/nrf52840", "-p", "auto" },
                        cwd = vim.fn.getcwd(),
                        components = { "default" },
                    }
                end,
                desc = "Build Zephyr project with west",
            })
            table.insert(opts.templates, {
                name = "west flash",
                builder = function()
                    return {
                        cmd = { "west" },
                        args = { "flash" },
                        cwd = vim.fn.getcwd(),
                        components = { "default" },
                    }
                end,
                desc = "Flash firmware to nRF board",
            })
            table.insert(opts.templates, {
                name = "west debug",
                builder = function()
                    return {
                        cmd = { "west" },
                        args = { "build", "-b", vim.g.zephyr_board or "nrf52840dk/nrf52840", "-t", "debug" },
                        cwd = vim.fn.getcwd(),
                        components = { "default" },
                    }
                end,
                desc = "Debug Zephyr with GDB",
            })
            table.insert(opts.templates, {
                name = "west flash --erase",
                builder = function()
                    return {
                        cmd = { "west" },
                        args = { "flash", "--erase" },
                        cwd = vim.fn.getcwd(),
                        components = { "default" },
                    }
                end,
                desc = "Flash with mass erase",
            })
        end,
    },

    -- Keybinds and utility commands
    {
        "folke/which-key.nvim",
        opts = function(_, opts)
            -- Register group in which-key
            local wk = require("which-key")
            wk.add({
                { "<leader>N", group = "Embedded / nRF" },
            })
        end,
    },

    -- Standalone plugin-less keybinds for west
    {
        dir = vim.fn.stdpath("config"),
        name = "zephyr-keybinds",
        lazy = false,
        config = function()
            -- Set default board (user can override with :ZephyrBoard)
            vim.g.zephyr_board = vim.g.zephyr_board or "nrf52840dk/nrf52840"

            local function west_cmd(args, title)
                local cmd = "west " .. args
                vim.notify("Running: " .. cmd, vim.log.levels.INFO, { title = title or "Zephyr" })
                vim.cmd("split | terminal " .. cmd)
            end

            -- Scan available boards from the Zephyr SDK
            local function get_boards()
                local zephyr_base = vim.env.ZEPHYR_BASE or (vim.env.HOME .. "/ncs/zephyr")
                local boards = {}
                -- Scan both Zephyr and nRF SDK board directories
                local board_dirs = {
                    zephyr_base .. "/boards",
                    zephyr_base:gsub("/zephyr$", "/nrf/boards"),
                }
                for _, dir in ipairs(board_dirs) do
                    local handle = vim.uv.fs_scandir(dir)
                    if handle then
                        while true do
                            local name, type = vim.uv.fs_scandir_next(handle)
                            if not name then break end
                            if type == "directory" then
                                -- Scan vendor subdirectories (e.g., boards/nordic/nrf52840dk)
                                local vendor_handle = vim.uv.fs_scandir(dir .. "/" .. name)
                                if vendor_handle then
                                    while true do
                                        local board_name, board_type = vim.uv.fs_scandir_next(vendor_handle)
                                        if not board_name then break end
                                        if board_type == "directory" then
                                            -- Check if it has a board.yml (valid board)
                                            local yml = dir .. "/" .. name .. "/" .. board_name .. "/board.yml"
                                            if vim.uv.fs_stat(yml) then
                                                table.insert(boards, board_name)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                table.sort(boards)
                return boards
            end

            -- Telescope board picker
            local function pick_board()
                local ok, pickers = pcall(require, "telescope.pickers")
                if not ok then
                    vim.notify("Telescope not available", vim.log.levels.ERROR)
                    return
                end
                local finders = require("telescope.finders")
                local conf = require("telescope.config").values
                local actions = require("telescope.actions")
                local action_state = require("telescope.actions.state")

                local boards = get_boards()
                if #boards == 0 then
                    vim.notify("No boards found. Is ZEPHYR_BASE set?", vim.log.levels.WARN)
                    return
                end

                pickers.new({}, {
                    prompt_title = "  Select Zephyr Board",
                    finder = finders.new_table({ results = boards }),
                    sorter = conf.generic_sorter({}),
                    attach_mappings = function(prompt_bufnr)
                        actions.select_default:replace(function()
                            actions.close(prompt_bufnr)
                            local selection = action_state.get_selected_entry()
                            if selection then
                                vim.g.zephyr_board = selection[1]
                                vim.notify("Board set to: " .. vim.g.zephyr_board, vim.log.levels.INFO, { title = "Zephyr" })
                            end
                        end)
                        return true
                    end,
                }):find()
            end

            -- Build
            vim.keymap.set("n", "<leader>Nb", function()
                west_cmd("build -b " .. vim.g.zephyr_board .. " -p auto", "West Build")
            end, { desc = "nRF: Build project" })

            -- Flash
            vim.keymap.set("n", "<leader>Nf", function()
                west_cmd("flash", "West Flash")
            end, { desc = "nRF: Flash firmware" })

            -- Menuconfig (interactive Kconfig editor)
            vim.keymap.set("n", "<leader>Nm", function()
                west_cmd("build -t menuconfig", "Menuconfig")
            end, { desc = "nRF: Open menuconfig" })

            -- Clean build
            vim.keymap.set("n", "<leader>Nc", function()
                west_cmd("build -p always -b " .. vim.g.zephyr_board, "West Clean Build")
            end, { desc = "nRF: Clean build" })

            -- Board picker
            vim.keymap.set("n", "<leader>Ns", pick_board, { desc = "nRF: Select board" })

            -- New Zephyr Project Generator
            local function create_new_project()
                vim.ui.input({ prompt = "Project Name (creates folder in current dir): " }, function(name)
                    if not name or name == "" then return end
                    
                    local path = vim.fn.getcwd() .. "/" .. name
                    if vim.fn.isdirectory(path) == 1 then
                        vim.notify("Directory already exists!", vim.log.levels.ERROR, { title = "Zephyr" })
                        return
                    end
                    
                    -- Create directories
                    vim.fn.mkdir(path .. "/src", "p")
                    
                    -- Create CMakeLists.txt
                    local cmake = io.open(path .. "/CMakeLists.txt", "w")
                    if cmake then
                        cmake:write("cmake_minimum_required(VERSION 3.20.0)\n")
                        cmake:write("find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})\n")
                        cmake:write("project(" .. name .. ")\n\n")
                        cmake:write("target_sources(app PRIVATE src/main.c)\n")
                        cmake:close()
                    end
                    
                    -- Create prj.conf
                    local conf = io.open(path .. "/prj.conf", "w")
                    if conf then
                        conf:write("# " .. name .. " configuration\n")
                        conf:write("CONFIG_GPIO=y\n")
                        conf:close()
                    end
                    
                    -- Create src/main.c
                    local main = io.open(path .. "/src/main.c", "w")
                    if main then
                        main:write("#include <zephyr/kernel.h>\n")
                        main:write("#include <zephyr/drivers/gpio.h>\n\n")
                        main:write("int main(void) {\n")
                        main:write("    printk(\"Hello World from " .. name .. "\\n\");\n")
                        main:write("    return 0;\n")
                        main:write("}\n")
                        main:close()
                    end
                    
                    vim.notify("Created Zephyr project: " .. name, vim.log.levels.INFO, { title = "Zephyr" })
                    -- Change working directory to the new project
                    vim.cmd("cd " .. vim.fn.fnameescape(path))
                    -- Open the main.c file
                    vim.cmd("edit src/main.c")
                end)
            end
            vim.keymap.set("n", "<leader>Nn", create_new_project, { desc = "nRF: New project template" })

            -- Show current board
            vim.keymap.set("n", "<leader>Ni", function()
                vim.notify("Current board: " .. vim.g.zephyr_board, vim.log.levels.INFO, { title = "Zephyr" })
            end, { desc = "nRF: Show current board" })

            -- Set board command (with tab completion)
            vim.api.nvim_create_user_command("ZephyrBoard", function(opts_cmd)
                if opts_cmd.args == "" then
                    pick_board()
                else
                    vim.g.zephyr_board = opts_cmd.args
                    vim.notify("Zephyr board set to: " .. vim.g.zephyr_board, vim.log.levels.INFO)
                end
            end, {
                nargs = "?",
                complete = function()
                    return get_boards()
                end,
                desc = "Set the target Zephyr board (e.g., nrf52840dk/nrf52840)",
            })
        end,
    },
}

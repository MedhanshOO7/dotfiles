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
            -- [Antigravity] Set up advanced nRF Connect / Zephyr IDE features

            -- Virtual Text Annotator for Devicetree Pins
            local function annotate_dts_pins(buf)
                local ns = vim.api.nvim_create_namespace("zephyr_dts_pins")
                vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
                
                local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                for i, line in ipairs(lines) do
                    local psel_hex = line:match("<%s*(0x%x+)%s*>")
                    if psel_hex and #psel_hex >= 6 then
                        local num = tonumber(psel_hex)
                        if num then
                            local pin = bit.band(num, 0x1F)
                            local port = bit.band(bit.rshift(num, 5), 0x7)
                            local hint = string.format("  <- P%d.%02d ", port, pin)
                            pcall(vim.api.nvim_buf_set_extmark, buf, ns, i - 1, -1, {
                                virt_text = { { hint, "Comment" } },
                                virt_text_pos = "eol",
                            })
                        end
                    end
                end
            end

            vim.api.nvim_create_autocmd({"BufReadPost", "BufEnter"}, {
                pattern = "zephyr.dts",
                callback = function(args)
                    if vim.api.nvim_buf_is_valid(args.buf) then
                        annotate_dts_pins(args.buf)
                    end
                end
            })

            -- Custom nvim-cmp source for Kconfig (prj.conf) autocompletion
            local kconfig_source = {}
            kconfig_source.new = function()
                return setmetatable({}, { __index = kconfig_source })
            end
            
            function kconfig_source:get_keyword_pattern()
                return [[\w\+]]
            end
            
            function kconfig_source:complete(params, callback)
                local items = {}
                
                -- Find .config from the build directory
                local bufpath = vim.api.nvim_buf_get_name(params.context.bufnr)
                local dir = vim.fn.fnamemodify(bufpath, ":h")
                -- Walk up to find project root
                local root = dir
                for _ = 1, 20 do
                    if vim.fn.filereadable(root .. "/CMakeLists.txt") == 1 then break end
                    local parent = vim.fn.fnamemodify(root, ":h")
                    if parent == root then break end
                    root = parent
                end
                
                local config_files = vim.fn.glob(root .. "/build/**/zephyr/.config", false, true)
                if #config_files == 0 then
                    callback({ items = items })
                    return
                end
                
                local config_file = config_files[1]
                local lines = vim.fn.readfile(config_file)
                local section = ""
                
                for _, line in ipairs(lines) do
                    -- Track section comments
                    local sec = line:match("^#%s*(.+)$")
                    if sec then section = sec end
                    
                    local key, val = line:match("^(CONFIG_[%w_]+)=(.+)$")
                    if key then
                        table.insert(items, {
                            label = key,
                            kind = 6, -- Variable
                            detail = val,
                            documentation = {
                                kind = "markdown",
                                value = string.format("**%s**\n\nCurrent: `%s`\n\nSection: *%s*", key, val, section),
                            },
                        })
                    end
                end
                
                callback({ items = items })
            end
            
            function kconfig_source:is_available()
                return vim.bo.filetype == "kconfig"
            end
            
            -- Register the source with nvim-cmp
            local cmp_ok, cmp = pcall(require, "cmp")
            if cmp_ok then
                cmp.register_source("zephyr_kconfig", kconfig_source.new())
                cmp.setup.filetype("kconfig", {
                    sources = cmp.config.sources({
                        { name = "zephyr_kconfig", priority = 100 },
                        { name = "buffer" },
                    }),
                })
            end

            -- Set default board (user can override with :ZephyrBoard)
            vim.g.zephyr_board = vim.g.zephyr_board or "nrf52dk/nrf52832"

            local function get_project_root()
                local dir = vim.fn.expand("%:p:h")
                if dir == "" or dir == nil then dir = vim.fn.getcwd() end
                
                -- Traverse upwards to find CMakeLists.txt
                while dir ~= "" and dir ~= "/" do
                    if vim.fn.filereadable(dir .. "/CMakeLists.txt") == 1 then
                        return dir
                    end
                    dir = vim.fn.fnamemodify(dir, ":h")
                end
                
                -- Fallback to Neovim's current working directory
                return vim.fn.getcwd()
            end

            local function run_in_term(cmd, direction, show_serial_option, is_build)
                local source_win = vim.api.nvim_get_current_win()
                
                vim.cmd(direction)
                vim.cmd("enew")
                local buf = vim.api.nvim_get_current_buf()
                
                vim.bo[buf].buftype = "nofile"
                vim.bo[buf].bufhidden = "wipe"
                vim.bo[buf].swapfile = false
                
                vim.keymap.set('n', 'q', '<Cmd>close<CR>', { buffer = buf, silent = true })
                
                if show_serial_option then
                    vim.keymap.set('n', 's', function()
                        vim.cmd("close")
                        vim.schedule(function()
                            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<leader>Nt", true, false, true), "m", true)
                        end)
                    end, { buffer = buf, silent = true })
                end
                
                local msg = show_serial_option and "Press q to close, or s to open Serial Monitor." or "Press q to close."
                
                vim.fn.termopen({"bash", "-c", cmd .. "; echo ''; echo '--- Finished ---'; echo '" .. msg .. "'"}, {
                    on_exit = function(_, exit_code)
                        vim.schedule(function()
                            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", true)
                            
                            -- Target the original code buffer and run :e to force LSP reload
                            if is_build and vim.api.nvim_win_is_valid(source_win) then
                                vim.api.nvim_win_call(source_win, function()
                                    vim.cmd("silent! e")
                                end)
                                vim.notify("Buffer reloaded (LSP refreshed)", vim.log.levels.INFO, { title = "Zephyr" })
                            end
                        end)
                    end
                })
                vim.cmd("startinsert")
            end

            local function west_cmd(args, title)
                local root = get_project_root()
                local cmd = "cd " .. vim.fn.shellescape(root) .. " && CMAKE_EXPORT_COMPILE_COMMANDS=1 west " .. args .. " && cp $(find build -mindepth 2 -name compile_commands.json | head -n 1) build/ 2>/dev/null || true"
                
                -- LspRestart is now handled natively via Lua on_exit in run_in_term
                
                vim.notify("Directory: " .. root .. "\nRunning: west " .. args, vim.log.levels.INFO, { title = title or "Zephyr" })
                local show_serial = args:match("flash") ~= nil
                local is_build = args:match("^build") ~= nil
                
                local height = math.floor(vim.o.lines * 0.25)
                run_in_term(cmd, "botright " .. height .. "split", show_serial, is_build)
            end

            -- Scan available boards from the Zephyr SDK
            local function get_boards()
                local paths = vim.fn.systemlist("west boards -a 2>/dev/null")
                if vim.v.shell_error ~= 0 then
                    return {}
                end
                table.sort(paths)
                return paths
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
                west_cmd("flash --runner nrfjprog", "West Flash")
            end, { desc = "nRF: Flash firmware" })

            -- Serial Monitor
            vim.keymap.set("n", "<leader>Nt", function()
                local cmd = "tio /dev/serial/by-id/usb-SEGGER_J-Link* -b 115200"
                vim.notify("Starting Serial Monitor...", vim.log.levels.INFO, { title = "Zephyr" })
                local width = math.floor(vim.o.columns * 0.30)
                run_in_term(cmd, "botright " .. width .. "vsplit")
            end, { desc = "nRF: Serial Monitor (tio)" })

            -- Menuconfig (interactive Kconfig editor)
            vim.keymap.set("n", "<leader>Nm", function()
                west_cmd("build -t menuconfig", "Menuconfig")
            end, { desc = "nRF: Open menuconfig" })

            -- Clean build
            vim.keymap.set("n", "<leader>Nc", function()
                west_cmd("build -p always -b " .. vim.g.zephyr_board, "West Clean Build")
            end, { desc = "nRF: Clean build" })

            -- RAM/ROM Resource Report
            vim.keymap.set("n", "<leader>Nr", function()
                west_cmd("build -t rom_report && west build -t ram_report", "Resource Report")
            end, { desc = "nRF: ROM/RAM Report" })

            -- Devicetree Viewer
            vim.keymap.set("n", "<leader>Nd", function()
                local build_dir = get_project_root() .. "/build"
                local cmd = "find " .. vim.fn.shellescape(build_dir) .. " -name 'zephyr.dts' | head -n 1"
                local dt_paths = vim.fn.systemlist(cmd)
                
                if dt_paths and dt_paths[1] and dt_paths[1] ~= "" and vim.fn.filereadable(dt_paths[1]) == 1 then
                    vim.cmd("vsplit " .. vim.fn.fnameescape(dt_paths[1]))
                    vim.bo.readonly = true
                    vim.bo.modifiable = false
                    vim.notify("Opened compiled Devicetree (read-only)", vim.log.levels.INFO, { title = "Zephyr" })
                else
                    vim.notify("Devicetree not found. Please build the project first!", vim.log.levels.WARN, { title = "Zephyr" })
                end
            end, { desc = "nRF: View Compiled Devicetree" })

            -- Devicetree Hardware Explorer (Custom Parser)
            vim.keymap.set("n", "<leader>Np", function()
                local build_dir = get_project_root() .. "/build"
                local cmd = "find " .. vim.fn.shellescape(build_dir) .. " -name 'zephyr.dts' | head -n 1"
                local dt_paths = vim.fn.systemlist(cmd)
                
                if dt_paths and dt_paths[1] and dt_paths[1] ~= "" and vim.fn.filereadable(dt_paths[1]) == 1 then
                    local ok, pickers = pcall(require, "telescope.pickers")
                    if not ok then return end
                    local finders = require("telescope.finders")
                    local conf = require("telescope.config").values
                    
                    local dt_file = dt_paths[1]
                    local lines = vim.fn.readfile(dt_file)
                    local results = {}
                    
                    -- NRF_PSEL function lookup
                    local func_map = {
                        [0] = "UART_TX", [1] = "UART_RX", [2] = "UART_RTS", [3] = "UART_CTS",
                        [4] = "SPI_SCK", [5] = "SPI_MOSI", [6] = "SPI_MISO", [7] = "SPI_CSN",
                        [8] = "I2C_SCL", [9] = "I2C_SDA",
                        [10] = "PWM_OUT0", [11] = "PWM_OUT1", [12] = "PWM_OUT2", [13] = "PWM_OUT3",
                        [14] = "PDM_CLK", [15] = "PDM_DIN",
                        [16] = "I2S_SCK", [17] = "I2S_LRCK", [18] = "I2S_SDOUT", [19] = "I2S_SDIN", [20] = "I2S_MCK",
                        [21] = "QDEC_A", [22] = "QDEC_B", [23] = "QDEC_LED",
                    }
                    
                    -- First pass: collect all nodes and their pins
                    local node_pins = {}   -- node_name -> list of {func, pin_str, lnum}
                    local node_props = {}  -- node_name -> list of {prop, val, lnum}
                    local current_node = ""
                    
                    for i, line in ipairs(lines) do
                        local label, node = line:match("^%s*([%w_]+):%s*([%w_%-@]+)%s*{")
                        if label then
                            current_node = label
                            if not node_pins[current_node] then
                                node_pins[current_node] = {}
                                node_props[current_node] = {}
                            end
                            table.insert(results, {
                                display = string.format("󰒋 %-25s ( %s )", label, node),
                                ordinal = label .. " " .. node,
                                filename = dt_file,
                                lnum = i,
                                node_name = label,
                            })
                        end
                        
                        local alias, target = line:match("^%s*([%w_]+)%s*=%s*&([%w_]+);")
                        if alias then
                            table.insert(results, {
                                display = string.format("󰌷 %-25s → %s", alias, target),
                                ordinal = alias .. " " .. target,
                                filename = dt_file,
                                lnum = i,
                                node_name = alias,
                            })
                        end
                        
                        -- Collect GPIO property pins
                        local prop, val = line:match("^%s*([%w_%-]+)%s*=%s*<(.-)>;")
                        if prop and current_node ~= "" and (prop:match("gpios") or prop:match("tx%-pin") or prop:match("rx%-pin") or prop:match("cs%-gpios")) then
                            table.insert(node_props[current_node], { prop = prop, val = val, lnum = i })
                        end
                        
                        -- Collect decoded PSEL pins
                        local psel_hex = line:match("<%s*(0x%x+)%s*>")
                        if psel_hex and #psel_hex >= 6 and current_node ~= "" and node_pins[current_node] then
                            local num = tonumber(psel_hex)
                            if num then
                                local pin = bit.band(num, 0x1F)
                                local port = bit.band(bit.rshift(num, 5), 0x7)
                                local func_id = bit.rshift(num, 24)
                                local func_name = func_map[func_id] or ("FUNC_" .. func_id)
                                table.insert(node_pins[current_node], {
                                    func = func_name,
                                    pin_str = string.format("P%d.%02d", port, pin),
                                    lnum = i,
                                })
                            end
                        end
                    end
                    
                    local previewers = require("telescope.previewers")
                    
                    pickers.new({}, {
                        prompt_title = "Zephyr Hardware Explorer",
                        finder = finders.new_table({
                            results = results,
                            entry_maker = function(entry)
                                return {
                                    value = entry,
                                    display = entry.display,
                                    ordinal = entry.ordinal,
                                    filename = entry.filename,
                                    path = entry.filename,
                                    lnum = entry.lnum,
                                    col = 1,
                                }
                            end,
                        }),
                        sorter = conf.generic_sorter({}),
                        previewer = previewers.new_buffer_previewer({
                            title = "Pin Details",
                            define_preview = function(self, entry)
                                local name = entry.value.node_name or ""
                                local buf = self.state.bufnr
                                local preview_lines = {}
                                
                                table.insert(preview_lines, "╔══════════════════════════════════════╗")
                                table.insert(preview_lines, "║  󰒋  " .. name)
                                table.insert(preview_lines, "╚══════════════════════════════════════╝")
                                table.insert(preview_lines, "")
                                
                                -- Show decoded PSEL pins
                                local pins = node_pins[name]
                                if pins and #pins > 0 then
                                    table.insert(preview_lines, "  ─── Pin Assignments ───")
                                    table.insert(preview_lines, "")
                                    for _, p in ipairs(pins) do
                                        table.insert(preview_lines, string.format("    %-14s :  %s", p.func, p.pin_str))
                                    end
                                    table.insert(preview_lines, "")
                                end
                                
                                -- Show GPIO properties
                                local props = node_props[name]
                                if props and #props > 0 then
                                    table.insert(preview_lines, "  ─── GPIO Properties ───")
                                    table.insert(preview_lines, "")
                                    for _, p in ipairs(props) do
                                        table.insert(preview_lines, string.format("    %-14s :  %s", p.prop, p.val))
                                    end
                                    table.insert(preview_lines, "")
                                end
                                
                                if (not pins or #pins == 0) and (not props or #props == 0) then
                                    table.insert(preview_lines, "  (No pin assignments found)")
                                end
                                
                                table.insert(preview_lines, "")
                                table.insert(preview_lines, "  Line " .. entry.lnum .. " in zephyr.dts")
                                
                                vim.api.nvim_buf_set_lines(buf, 0, -1, false, preview_lines)
                            end,
                        }),
                        attach_mappings = function(prompt_bufnr)
                            local actions = require("telescope.actions")
                            local action_state = require("telescope.actions.state")
                            actions.select_default:replace(function()
                                actions.close(prompt_bufnr)
                                local selection = action_state.get_selected_entry()
                                if selection then
                                    vim.cmd("vsplit " .. vim.fn.fnameescape(selection.filename))
                                    vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
                                    vim.bo.readonly = true
                                    vim.bo.modifiable = false
                                end
                            end)
                            return true
                        end,
                    }):find()
                    
                else
                    vim.notify("Devicetree not found. Please build the project first!", vim.log.levels.WARN, { title = "Zephyr" })
                end
            end, { desc = "nRF: Devicetree Hardware Explorer" })

            -- Input Files Viewer (VS Code style)
            vim.keymap.set("n", "<leader>No", function()
                local root = get_project_root()
                local ok, pickers_mod = pcall(require, "telescope.pickers")
                if not ok then return end
                local finders_mod = require("telescope.finders")
                local conf = require("telescope.config").values
                
                -- Define the file patterns we care about
                local patterns = {
                    { glob = "src/**/*.c",          icon = " ", category = "Source" },
                    { glob = "src/**/*.h",          icon = " ", category = "Header" },
                    { glob = "*.overlay",           icon = "󰌗 ", category = "Overlay" },
                    { glob = "boards/*.overlay",    icon = "󰌗 ", category = "Overlay" },
                    { glob = "boards/*.conf",       icon = " ", category = "Config" },
                    { glob = "prj.conf",            icon = " ", category = "Config" },
                    { glob = "CMakeLists.txt",      icon = " ", category = "CMake" },
                    { glob = "Kconfig",             icon = " ", category = "Kconfig" },
                    { glob = "*.dts",               icon = "󰌗 ", category = "Devicetree" },
                    { glob = "*.dtsi",              icon = "󰌗 ", category = "Devicetree" },
                    { glob = "*.ld",                icon = " ", category = "Linker" },
                    { glob = "app.overlay",         icon = "󰌗 ", category = "Overlay" },
                }
                
                local results = {}
                local seen = {}
                for _, pat in ipairs(patterns) do
                    local found = vim.fn.glob(root .. "/" .. pat.glob, false, true)
                    for _, filepath in ipairs(found) do
                        if not seen[filepath] then
                            seen[filepath] = true
                            local rel = filepath:sub(#root + 2)
                            table.insert(results, {
                                display = string.format("%s %-12s  %s", pat.icon, pat.category, rel),
                                ordinal = pat.category .. " " .. rel,
                                filepath = filepath,
                            })
                        end
                    end
                end
                
                if #results == 0 then
                    vim.notify("No project files found!", vim.log.levels.WARN, { title = "Zephyr" })
                    return
                end
                
                pickers_mod.new({}, {
                    prompt_title = "Zephyr Input Files",
                    finder = finders_mod.new_table({
                        results = results,
                        entry_maker = function(entry)
                            return {
                                value = entry,
                                display = entry.display,
                                ordinal = entry.ordinal,
                                filename = entry.filepath,
                                path = entry.filepath,
                            }
                        end,
                    }),
                    sorter = conf.generic_sorter({}),
                    previewer = conf.file_previewer({}),
                }):find()
            end, { desc = "nRF: View Input Files" })

            -- Board picker
            vim.keymap.set("n", "<leader>Ns", pick_board, { desc = "nRF: Select board" })
            -- Create Project from Examples
            local function create_from_example()
                local ok, pickers = pcall(require, "telescope.pickers")
                if not ok then return vim.notify("Telescope required", vim.log.levels.ERROR) end
                local finders = require("telescope.finders")
                local conf = require("telescope.config").values
                local actions = require("telescope.actions")
                local action_state = require("telescope.actions.state")

                local zephyr_base = vim.env.ZEPHYR_BASE or (vim.env.HOME .. "/ncs/zephyr")
                local nrf_base = zephyr_base:gsub("/zephyr$", "/nrf")
                
                vim.ui.select({ "Zephyr OS Samples", "nRF SDK Samples", "Both" }, {
                    prompt = "Select SDK Source:",
                }, function(choice)
                    if not choice then return end

                    vim.notify("Scanning " .. choice .. "...", vim.log.levels.INFO)
                    
                    local search_paths = ""
                    if choice == "Zephyr OS Samples" then
                        search_paths = string.format("%s/samples", zephyr_base)
                    elseif choice == "nRF SDK Samples" then
                        search_paths = string.format("%s/samples", nrf_base)
                    else
                        search_paths = string.format("%s/samples %s/samples", zephyr_base, nrf_base)
                    end
                    
                    local cmd = string.format("find %s -mindepth 2 -maxdepth 4 -name CMakeLists.txt 2>/dev/null", search_paths)
                    local paths = vim.fn.systemlist(cmd)
                    
                    local examples = {}
                    for _, path in ipairs(paths) do
                        local dir = vim.fn.fnamemodify(path, ":h")
                        local display = dir:gsub(vim.env.HOME .. "/ncs/", "")
                        table.insert(examples, { display = display, path = dir })
                    end

                    if #examples == 0 then
                        return vim.notify("No examples found for " .. choice, vim.log.levels.WARN)
                    end

                    pickers.new({}, {
                        prompt_title = "  Zephyr/nRF Examples  ",
                        finder = finders.new_table({
                            results = examples,
                            entry_maker = function(entry)
                                return {
                                    value = entry,
                                    display = entry.display,
                                    ordinal = entry.display,
                                }
                            end,
                        }),
                        sorter = conf.generic_sorter({}),
                        attach_mappings = function(prompt_bufnr)
                            actions.select_default:replace(function()
                                actions.close(prompt_bufnr)
                                local selection = action_state.get_selected_entry()
                                if selection then
                                    local src = selection.value.path
                                    local basename = vim.fn.fnamemodify(src, ":t")
                                    
                                    vim.ui.input({ prompt = "Project Name or Path: ", default = basename }, function(name)
                                        if not name or name == "" then return end
                                        
                                        local function create_project(dest_path)
                                            if vim.fn.isdirectory(dest_path) == 1 then
                                                return vim.notify("Directory already exists!", vim.log.levels.ERROR)
                                            end
                                            
                                            vim.fn.mkdir(vim.fn.fnamemodify(dest_path, ":h"), "p")
                                            vim.fn.system(string.format("cp -r %s %s", vim.fn.shellescape(src), vim.fn.shellescape(dest_path)))
                                            vim.notify("Copied " .. selection.value.display .. " -> " .. name, vim.log.levels.INFO)
                                            
                                            vim.cmd("cd " .. vim.fn.fnameescape(dest_path))
                                            if vim.fn.filereadable(dest_path .. "/src/main.c") == 1 then
                                                vim.cmd("edit src/main.c")
                                            elseif vim.fn.filereadable(dest_path .. "/src/main.cpp") == 1 then
                                                vim.cmd("edit src/main.cpp")
                                            end
                                        end

                                        if name:find("/") then
                                            -- User provided a full path
                                            create_project(vim.fn.getcwd() .. "/" .. name)
                                        else
                                            -- User provided just a name, ask for location
                                            vim.ui.input({ prompt = "Location (leave blank for current dir): ", default = "" }, function(loc)
                                                local base = vim.fn.getcwd()
                                                if loc and loc ~= "" then
                                                    base = base .. "/" .. loc
                                                end
                                                create_project(base .. "/" .. name)
                                            end)
                                        end
                                    end)
                                end
                            end)
                            return true
                        end,
                    }):find()
                end)
            end
            vim.keymap.set("n", "<leader>Ne", create_from_example, { desc = "nRF: Example projects" })


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
                    
                    -- Create boards overlay file
                    vim.fn.mkdir(path .. "/boards", "p")
                    local board_filename = vim.g.zephyr_board:gsub("/", "_")
                    local overlay = io.open(path .. "/boards/" .. board_filename .. ".overlay", "w")
                    if overlay then
                        overlay:write("/* Devicetree overlay for " .. vim.g.zephyr_board .. " */\n\n")
                        overlay:write("/ {\n")
                        overlay:write("    /* Add custom hardware nodes here */\n")
                        overlay:write("};\n")
                        overlay:close()
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

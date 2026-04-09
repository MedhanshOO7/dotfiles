local map = vim.keymap.set

local function cmd(command)
    return "<cmd>" .. command .. "<CR>"
end

local function toggle_explorer()
    vim.cmd("Neotree toggle filesystem reveal left")
end

local function keymap_help()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    local modes = { "n", "i", "v", "x", "s", "o", "t", "c" }
    local mode_names = {
        n = "NORMAL",
        i = "INSERT",
        v = "VISUAL",
        x = "VISUAL-BLOCK",
        s = "SELECT",
        o = "OPERATOR",
        t = "TERMINAL",
        c = "COMMAND",
    }

    local seen = {}
    local items = {}

    local function add_maps(mode, maps, scope)
        for _, mapinfo in ipairs(maps) do
            local key = table.concat({
                scope,
                mode,
                mapinfo.lhs or "",
                mapinfo.rhs or "",
                mapinfo.desc or "",
            }, "\x1f")

            if not seen[key] then
                seen[key] = true

                local desc = mapinfo.desc or mapinfo.rhs or ""
                if desc == "" then
                    desc = "[no description]"
                end

                table.insert(items, {
                    mode = mode,
                    mode_label = mode_names[mode] or mode,
                    lhs = mapinfo.lhs or "",
                    rhs = mapinfo.rhs or "",
                    desc = desc,
                    scope = scope,
                    ordinal = table.concat({
                        mapinfo.lhs or "",
                        desc,
                        mode_names[mode] or mode,
                        scope,
                    }, " "),
                    display = string.format(
                        "%-12s %-18s %s",
                        mode_names[mode] or mode,
                        mapinfo.lhs or "",
                        desc
                    ),
                })
            end
        end
    end

    for _, mode in ipairs(modes) do
        add_maps(mode, vim.api.nvim_get_keymap(mode), "global")
        add_maps(mode, vim.api.nvim_buf_get_keymap(0, mode), "buffer")
    end

    table.sort(items, function(a, b)
        if a.mode == b.mode then
            return a.lhs < b.lhs
        end
        return a.mode < b.mode
    end)

    pickers.new({}, {
        prompt_title = "All Keymaps",
        finder = finders.new_table({
            results = items,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.display,
                    ordinal = entry.ordinal,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        previewer = false,
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)

                if selection and selection.value then
                    local message = string.format(
                        "%s %s -> %s",
                        selection.value.mode_label,
                        selection.value.lhs,
                        selection.value.desc
                    )
                    vim.notify(message)
                end
            end)

            return true
        end,
    }):find()
end

local function multicursor()
    return require("multicursor-nvim")
end

vim.api.nvim_create_user_command("KeymapsHelp", keymap_help, {
    desc = "Browse custom keybindings with plain-English descriptions",
})

-- File explorer
map("n", "<leader>e", toggle_explorer, { desc = "Open or close the file sidebar" })
map("n", "<leader>b", toggle_explorer, { desc = "Open or close the file sidebar" })
map("n", "<C-b>", toggle_explorer, { desc = "Open or close the file sidebar" })
map("i", "<C-b>", function()
    vim.cmd("stopinsert")
    toggle_explorer()
end, { desc = "Open or close the file sidebar" })
map("t", "<C-b>", function()
    local esc = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
    vim.api.nvim_feedkeys(esc, "n", false)
    toggle_explorer()
end, { desc = "Open or close the file sidebar" })
map("n", "<leader>fe", cmd("Explore"), { desc = "Open the classic netrw file list" })

-- Save like VS Code
map("n", "<C-s>", cmd("write"), { desc = "Save the current file" })
map("i", "<C-s>", "<Esc><cmd>write<CR>a", { desc = "Save the current file" })
map("v", "<C-s>", "<Esc><cmd>write<CR>", { desc = "Save the current file" })
map("c", "<C-s>", "<C-c><cmd>write<CR>", { desc = "Save the current file" })
map("n", "<leader>fs", cmd("write"), { desc = "Save the current file" })

-- Running code and terminal
map("n", "<leader>rr", cmd("RunCode"), { desc = "Run the current file" })
map("n", "<F5>", cmd("RunCode"), { desc = "Run the current file" })
map("n", "<leader>q", cmd("quit"), { desc = "Quit the current window" })
map("n", "<C-`>", cmd("ToggleTerm"), { desc = "Open or close the floating terminal" })
map("n", "<leader>to", cmd("ToggleTerm"), { desc = "Open or close the floating terminal" })
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Leave terminal mode" })
map("n", "<leader>zz", cmd("ZenMode"), { desc = "Focus on writing or reading without distractions" })
map("n", "<leader>zw", function()
    require("allMyLuaFiles.writing").toggle()
end, { desc = "Toggle low-noise writing mode for this buffer" })
map("n", "<leader>zt", cmd("Twilight"), { desc = "Dim unfocused text around the cursor" })

-- LSP and editing
map("n", "gd", vim.lsp.buf.definition, { desc = "Jump to where this symbol is defined" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Jump to the implementation" })
map("n", "K", vim.lsp.buf.hover, { desc = "Show documentation for the symbol under the cursor" })
map("n", "<leader>ld", vim.lsp.buf.definition, { desc = "Jump to where this symbol is defined" })
map("n", "<leader>lr", vim.lsp.buf.references, { desc = "Show every place this symbol is used" })
map("n", "<leader>li", vim.lsp.buf.implementation, { desc = "Jump to the implementation" })
map("n", "<leader>lh", vim.lsp.buf.hover, { desc = "Show documentation for the symbol under the cursor" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename this symbol everywhere" })
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Show suggested code fixes and actions" })
map("n", "<leader>cf", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format the current file" })

local lsp_enabled = true

map("n", "<leader>cl", function()
    lsp_enabled = not lsp_enabled

    if lsp_enabled then
        vim.cmd("LspStart")
        vim.diagnostic.enable()
        vim.notify("LSP and diagnostics are on")
    else
        vim.cmd("LspStop")
        vim.diagnostic.disable()
        vim.notify("LSP and diagnostics are off")
    end
end, { desc = "Turn language features on or off" })

local brainstorm = false

map("n", "<leader>uz", function()
    brainstorm = not brainstorm

    require("cmp").setup({ enabled = not brainstorm })
    vim.diagnostic.config({
        virtual_text = not brainstorm,
        signs = not brainstorm,
        underline = not brainstorm,
    })

    vim.notify(brainstorm and "Brainstorm mode is on" or "Normal coding mode is on")
end, { desc = "Hide coding noise for free-form writing" })

-- Buffers
map("n", "<Tab>", cmd("BufferLineCycleNext"), { desc = "Go to the next open tab" })
map("n", "<S-Tab>", cmd("BufferLineCyclePrev"), { desc = "Go to the previous open tab" })
map("n", "<leader>bn", cmd("BufferLineCycleNext"), { desc = "Go to the next open tab" })
map("n", "<leader>bp", cmd("BufferLineCyclePrev"), { desc = "Go to the previous open tab" })
map("n", "<leader>bd", cmd("bdelete"), { desc = "Close the current buffer" })

-- Folding
map("n", "<leader>fo", "zO", { desc = "Open the fold under the cursor completely" })
map("n", "<leader>fc", "zC", { desc = "Close the fold under the cursor completely" })
map("n", "<leader>fa", "za", { desc = "Toggle the fold under the cursor" })
map("n", "<leader>fR", "zR", { desc = "Open every fold in the file" })
map("n", "<leader>fM", "zM", { desc = "Close every fold in the file" })

-- Git
map("n", "]h", cmd("Gitsigns next_hunk"), { desc = "Go to the next git change" })
map("n", "[h", cmd("Gitsigns prev_hunk"), { desc = "Go to the previous git change" })
map("n", "<leader>hn", cmd("Gitsigns next_hunk"), { desc = "Go to the next git change" })
map("n", "<leader>hp", cmd("Gitsigns prev_hunk"), { desc = "Go to the previous git change" })
map("n", "<leader>hs", cmd("Gitsigns stage_hunk"), { desc = "Stage this changed block" })
map("n", "<leader>hr", cmd("Gitsigns reset_hunk"), { desc = "Discard this changed block" })
map("n", "<leader>hb", function()
    require("gitsigns").blame_line({ full = true })
end, { desc = "Show who changed this line and when" })
map("n", "<leader>hd", cmd("Gitsigns preview_hunk"), { desc = "Preview this changed block" })
map("n", "<leader>gg", cmd("Neogit"), { desc = "Open the full git panel" })
map("n", "<leader>gc", cmd("Neogit commit"), { desc = "Start a git commit" })

-- Search and discovery
map("n", "<C-p>", cmd("Telescope find_files"), { desc = "Find a file by name (VS Code style)" })
map("n", "<C-S-p>", cmd("Telescope commands"), { desc = "Open the command palette (VS Code style)" })
map("n", "<C-f>", cmd("Telescope current_buffer_fuzzy_find"), { desc = "Search in current file (VS Code style)" })
map("n", "<C-S-f>", cmd("Telescope live_grep"), { desc = "Search for text in the project (VS Code style)" })
map("n", "<C-S-o>", cmd("Telescope lsp_document_symbols"), { desc = "Search for symbols in this file (VS Code style)" })
map("n", "<C-g>", ":", { desc = "Go to line (VS Code style)" })
map({ "n", "x" }, "<C-A-Up>", function()
    multicursor().lineAddCursor(-1)
end, { desc = "Add cursor above" })
map({ "n", "x" }, "<C-A-Down>", function()
    multicursor().lineAddCursor(1)
end, { desc = "Add cursor below" })
map("n", "<A-LeftMouse>", function()
    multicursor().handleMouse()
end, { desc = "Add cursor at clicked position" })
map("n", "<A-LeftDrag>", function()
    multicursor().handleMouseDrag()
end, { desc = "Drag multicursor selection" })
map("n", "<A-LeftRelease>", function()
    multicursor().handleMouseRelease()
end, { desc = "Finish multicursor mouse selection" })
map({ "n", "x" }, "<leader><C-A-Up>", function()
    multicursor().lineSkipCursor(-1)
end, { desc = "Skip cursor above" })
map({ "n", "x" }, "<leader><C-A-Down>", function()
    multicursor().lineSkipCursor(1)
end, { desc = "Skip cursor below" })
map("n", "<leader>ma", function()
    multicursor().matchAddCursor(1)
end, { desc = "Add next matching cursor" })
map("n", "<leader>mx", function()
    multicursor().deleteCursor()
end, { desc = "Delete current multicursor" })
map("n", "<C-q>", function()
    multicursor().toggleCursor()
end, { desc = "Toggle multicursor for current match" })
map({ "n", "x" }, "<leader>sr", cmd("GrugFar"), { desc = "Search and replace across the project" })
map("v", "<leader>sr", cmd("'<,'>GrugFarWithin"), { desc = "Search and replace within selection" })

-- Commenting
map("n", "<C-/>", "gcc", { remap = true, desc = "Toggle line comment" })
map("v", "<C-/>", "gc", { remap = true, desc = "Toggle line comment" })
map("i", "<C-/>", "<Esc>gcc<cmd>startinsert<CR>", { remap = true, desc = "Toggle line comment" })

-- Moving lines like VS Code
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up" })

map("n", "<leader>p", cmd("Telescope commands"), { desc = "Open the command palette" })
map("n", "<leader>ff", cmd("Telescope find_files"), { desc = "Find a file by name" })
map("n", "<leader>fg", cmd("Telescope live_grep"), { desc = "Search for text in the project" })
map("n", "<leader>fb", cmd("Telescope buffers"), { desc = "Switch between open files" })
map("n", "<leader>ft", cmd("TodoTelescope"), { desc = "Find every TODO, NOTE, or FIX comment" })
map("n", "<leader>mp", cmd("MarkdownPreviewToggle"), { desc = "Open or close the markdown browser preview" })
map("n", "<leader>mo", cmd("AerialToggle"), { desc = "Open the document or code outline" })
map("n", "<leader>mn", cmd("AerialNavToggle"), { desc = "Open outline navigation in a floating picker" })
map("n", "<leader>tt", cmd("OverseerToggle"), { desc = "Open or close the task list" })
map("n", "<leader>tr", cmd("OverseerRun"), { desc = "Choose and run a project task" })
map("n", "<leader>ta", cmd("OverseerQuickAction"), { desc = "Run a task action on the current item" })
map("n", "<leader>tl", cmd("OverseerLoadBundle"), { desc = "Load saved task runs" })
map("n", "<leader>fk", keymap_help, { desc = "Browse every keybinding" })
map("n", "<leader>?", keymap_help, { desc = "Browse every keybinding" })

-- Themes
map("n", "<leader>ut", cmd("ThemePicker"), { desc = "Choose a theme" })
map("n", "<leader>un", cmd("ThemeNext"), { desc = "Switch to the next theme" })
map("n", "<leader>up", cmd("ThemePrev"), { desc = "Switch to the previous theme" })
map("n", "<leader>uy", cmd("ThemeTransparencyToggle"), { desc = "Turn transparency on or off" })
map("n", "<leader>ua", cmd("AutoSaveToggle"), { desc = "Turn autosave on or off" })
map("n", "<leader>ub", cmd("AutoSaveBufferToggle"), { desc = "Turn autosave on or off for this file" })
map("n", "<leader>cm", cmd("Mason"), { desc = "Open the tool installer" })

-- Diagnostics and lists
map("n", "<leader>xx", cmd("Trouble diagnostics toggle"), { desc = "Open the project problem list" })
map("n", "<leader>xd", cmd("Trouble diagnostics toggle filter.buf=0"), { desc = "Open the current file problem list" })
map("n", "<leader>xq", cmd("Trouble qflist toggle"), { desc = "Open the quickfix list" })
map("n", "<leader>xl", cmd("Trouble loclist toggle"), { desc = "Open the location list" })

-- Fast movement like LazyVim
map({ "n", "x", "o" }, "s", function()
    require("flash").jump()
end, { desc = "Jump quickly to any visible text" })
map({ "n", "x", "o" }, "S", function()
    require("flash").treesitter()
end, { desc = "Jump by syntax block" })
map("n", "<leader>sj", function()
    require("flash").jump()
end, { desc = "Jump quickly to any visible text" })
map("n", "<leader>ss", function()
    require("flash").treesitter()
end, { desc = "Jump by syntax block" })

-- Debugging
map("n", "<leader>db", function()
    require("dap").toggle_breakpoint()
end, { desc = "Add or remove a breakpoint" })
map("n", "<leader>dc", function()
    require("dap").continue()
end, { desc = "Start or continue debugging" })
map("n", "<leader>di", function()
    require("dap").step_into()
end, { desc = "Debug: step into" })
map("n", "<leader>do", function()
    require("dap").step_over()
end, { desc = "Debug: step over" })
map("n", "<leader>dO", function()
    require("dap").step_out()
end, { desc = "Debug: step out" })
map("n", "<leader>dr", function()
    require("dap").repl.toggle()
end, { desc = "Open the debugger console" })
map("n", "<leader>du", function()
    require("dapui").toggle()
end, { desc = "Open the debugger panels" })
map("n", "<leader>dt", function()
    require("dap").terminate()
end, { desc = "Stop debugging" })
map("n", "<F9>", function()
    require("dap").toggle_breakpoint()
end, { desc = "Add or remove a breakpoint" })
map("n", "<F10>", function()
    require("dap").step_over()
end, { desc = "Debug: step over" })
map("n", "<F11>", function()
    require("dap").step_into()
end, { desc = "Debug: step into" })
map("n", "<F12>", function()
    require("dap").step_out()
end, { desc = "Debug: step out" })
map("n", "<leader>d9", function()
    require("dap").toggle_breakpoint()
end, { desc = "Add or remove a breakpoint" })
map("n", "<leader>d0", function()
    require("dap").step_over()
end, { desc = "Debug: step over" })
map("n", "<leader>d1", function()
    require("dap").step_into()
end, { desc = "Debug: step into" })
map("n", "<leader>d2", function()
    require("dap").step_out()
end, { desc = "Debug: step out" })

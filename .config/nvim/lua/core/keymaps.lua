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

local function grug_far()
    return require("grug-far")
end

local function ufo()
    return require("ufo")
end

vim.api.nvim_create_user_command("KeymapsHelp", keymap_help, {
    desc = "Browse custom keybindings with plain-English descriptions",
})

-- Files
map("n", "<leader>e", toggle_explorer, { desc = "Open or close the file sidebar" })
map("n", "<leader>fe", cmd("Explore"), { desc = "Open the classic netrw file list" })
map("n", "<leader>fs", cmd("write"), { desc = "Save the current file" })
map("n", "<leader>cf", function()
    require("conform").format({ lsp_format = "fallback" })
end, { desc = "Format the current file" })
map("n", "<leader>uf", cmd("FormatToggle"), { desc = "Toggle auto-format on save" })
map("n", "<leader>q", cmd("quit"), { desc = "Quit the current window" })

-- Terminals and writing
map({ "n", "i", "t" }, "<C-`>", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })
map("n", "<leader>rr", cmd("RunCode"), { desc = "Run the current file" })
map("n", "<leader>to", cmd("ToggleTerm"), { desc = "Open or close the floating terminal" })
map("n", "<leader>tf", cmd("TerminalProject"), { desc = "Open the main project shell" })
map("n", "<leader>th", cmd("TerminalHorizontal"), { desc = "Open a bottom terminal panel" })
map("n", "<leader>tv", cmd("TerminalVertical"), { desc = "Open a side terminal panel" })
map("n", "<leader>tg", cmd("TerminalSelect"), { desc = "Pick from active terminal sessions" })
map("n", "<leader>zz", cmd("ZenMode"), { desc = "Focus on writing or reading without distractions" })
map("n", "<leader>zw", function()
    require("utils.writing").toggle()
end, { desc = "Toggle low-noise writing mode for this buffer" })
map("n", "<leader>zb", function()
    local md_modes = require("utils.markdown_modes")
    if md_modes.current_mode == md_modes.modes.BRAINSTORM then
        md_modes.toggle_professional()
    else
        md_modes.toggle_brainstorm()
    end
end, { desc = "Toggle Brainstorm mode (Universal)" })
map("n", "<leader>nt", cmd("Twilight"), { desc = "Dim unfocused text around the cursor" })
map("n", "<leader>ns", "viw<esc>a~~<esc>hbi~~<esc>lel", { desc = "Strikeout the word under the cursor" })
map("v", "<leader>ns", "c~~<C-r>\"~~<esc>", { desc = "Strikeout the selection" })

-- Buffers
map("n", "<leader>bb", cmd("Telescope buffers"), { desc = "Browse open buffers" })
map("n", "<leader>bn", cmd("BufferNext"), { desc = "Go to the next buffer" })
map("n", "<leader>bp", cmd("BufferPrevious"), { desc = "Go to the previous buffer" })
map("n", "<leader>bd", function()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.bufdelete then
        snacks.bufdelete()
    else
        vim.cmd("BufferClose")
    end
end, { desc = "Delete the current buffer" })
map("n", "<leader>bo", cmd("BufferCloseAllButCurrent"), { desc = "Delete every other buffer" })
for i = 1, 9 do
    map("n", "<C-" .. i .. ">", cmd("BufferGoto " .. i), { desc = "Go to buffer " .. i })
end

-- Folding
map("n", "<leader>fo", "zO", { desc = "Open the fold under the cursor completely" })
map("n", "<leader>fc", "zC", { desc = "Close the fold under the cursor completely" })
map("n", "<leader>fa", "za", { desc = "Toggle the fold under the cursor" })
map("n", "<leader>fv", function()
    local winid = ufo().peekFoldedLinesUnderCursor()
    if not winid then
        vim.lsp.buf.hover()
    end
end, { desc = "Preview folded lines under the cursor" })
map("n", "<leader>fR", function()
    ufo().openAllFolds()
end, { desc = "Open every fold in the file" })
map("n", "<leader>fM", function()
    ufo().closeAllFolds()
end, { desc = "Close every fold in the file" })

-- Git
map("n", "]h", cmd("Gitsigns next_hunk"), { desc = "Go to the next git change" })
map("n", "[h", cmd("Gitsigns prev_hunk"), { desc = "Go to the previous git change" })
map("n", "<leader>gn", cmd("Gitsigns next_hunk"), { desc = "Go to the next git change" })
map("n", "<leader>gp", cmd("Gitsigns prev_hunk"), { desc = "Go to the previous git change" })
map("n", "<leader>gs", cmd("Gitsigns stage_hunk"), { desc = "Stage this changed block" })
map("n", "<leader>gu", cmd("Gitsigns undo_stage_hunk"), { desc = "Undo staging for this changed block" })
map("n", "<leader>gr", cmd("Gitsigns reset_hunk"), { desc = "Discard this changed block" })
map("n", "<leader>gb", function()
    require("gitsigns").blame_line({ full = true })
end, { desc = "Show who changed this line and when" })
map("n", "<leader>gd", cmd("Gitsigns preview_hunk"), { desc = "Preview this changed block" })
map("n", "<leader>gD", cmd("Gitsigns diffthis"), { desc = "Compare this file against git" })
map("n", "<leader>gg", cmd("Neogit"), { desc = "Open the full git panel" })
map("n", "<leader>gc", cmd("Neogit commit"), { desc = "Start a git commit" })

-- Search and discovery
map("n", "<leader>p", cmd("Telescope commands"), { desc = "Open the command palette" })
map("n", "<leader>ff", cmd("Telescope find_files"), { desc = "Find a file by name" })
map("n", "<leader>fg", cmd("Telescope live_grep"), { desc = "Search for text in the project" })
map("n", "<leader>f/", cmd("Telescope current_buffer_fuzzy_find"), { desc = "Search in the current file" })
map("n", "<leader>fb", cmd("Telescope buffers"), { desc = "Switch between open files" })
map("n", "<leader>fp", cmd("Telescope git_files"), { desc = "Find a tracked project file" })
map("n", "<leader>fr", cmd("Telescope oldfiles"), { desc = "Reopen a recent file" })
map("n", "<leader>fS", cmd("Telescope lsp_document_symbols"), { desc = "Search symbols in this file" })
map("n", "<leader>fw", cmd("Telescope lsp_workspace_symbols"), { desc = "Search workspace symbols" })
map("n", "<leader>ft", cmd("TodoTelescope"), { desc = "Find every TODO, NOTE, or FIX comment" })
map("n", "<leader>fk", cmd("Telescope keymaps"), { desc = "Browse every keybinding" })
map("n", "<leader>?", cmd("Telescope keymaps"), { desc = "Browse every keybinding" })
map({ "n", "x" }, "<leader>sr", cmd("GrugFar"), { desc = "Search and replace across the project" })
map("v", "<leader>sr", cmd("'<,'>GrugFarWithin"), { desc = "Search and replace within selection" })
map("n", "<leader>sw", function()
    grug_far().open({
        prefills = {
            search = vim.fn.expand("<cword>"),
        },
    })
end, { desc = "Search for the word under the cursor across the project" })
map("n", "<leader>sB", function()
    grug_far().open({
        prefills = {
            paths = vim.fn.expand("%"),
        },
    })
end, { desc = "Search and replace only in the current file" })

-- Markdown and notebooks
map("n", "<leader>np", cmd("MarkdownPreviewToggle"), { desc = "Open or close the markdown browser preview" })
map("n", "<leader>nB", function()
    require("utils.markdown_modes").toggle_brainstorm()
end, { desc = "Markdown: Brainstorm Mode" })
map("n", "<leader>nP", function()
    require("utils.markdown_modes").toggle_professional()
end, { desc = "Markdown: Professional Mode" })
map("n", "<leader>no", cmd("AerialToggle"), { desc = "Open the document or code outline" })
map("n", "<leader>nn", cmd("AerialNavToggle"), { desc = "Open outline navigation in a floating picker" })

-- Obsidian
map("n", "<leader>os", cmd("ObsidianSearch"), { desc = "Obsidian: Search notes" })
map("n", "<leader>of", cmd("ObsidianQuickSwitch"), { desc = "Obsidian: Find notes" })
map("n", "<leader>on", cmd("ObsidianNew"), { desc = "Obsidian: New note" })
map("n", "<leader>ot", cmd("ObsidianToday"), { desc = "Obsidian: Today's daily note" })
map("n", "<leader>oy", cmd("ObsidianYesterday"), { desc = "Obsidian: Yesterday's daily note" })
map("n", "<leader>ob", cmd("ObsidianBacklinks"), { desc = "Obsidian: Show backlinks" })
map("n", "<leader>ol", cmd("ObsidianLinks"), { desc = "Obsidian: Show links in current note" })
map("n", "<leader>oi", cmd("ObsidianPasteImg"), { desc = "Obsidian: Paste image from clipboard" })
map("v", "<leader>on", cmd("ObsidianLinkNew"), { desc = "Obsidian: Link selection to new note" })
map("v", "<leader>ol", cmd("ObsidianLink"), { desc = "Obsidian: Link selection to existing note" })

map("n", "<leader>mi", cmd("MoltenInit"), { desc = "Initialize Molten and pick a kernel" })
map("n", "<leader>me", cmd("MoltenEvaluateOperator"), { desc = "Evaluate an operator selection" })
map("n", "<leader>ml", cmd("MoltenEvaluateLine"), { desc = "Evaluate the current line" })
map("v", "<leader>mv", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "Evaluate the visual selection" })
map("n", "<leader>md", cmd("MoltenDelete"), { desc = "Delete the current Molten cell" })
map("n", "<leader>mh", cmd("MoltenHideOutput"), { desc = "Hide Molten output" })
map("n", "<leader>ms", cmd("MoltenShowOutput"), { desc = "Show Molten output" })
map("n", "<leader>mr", cmd("MoltenRestart"), { desc = "Restart the active Molten kernel" })
map("n", "<leader>mo", cmd("MoltenOpenInBrowser"), { desc = "Open the current Molten output in a browser" })

-- Multi-cursor
local function add_cursor_above()
    multicursor().lineAddCursor(-1)
end

local function add_cursor_below()
    multicursor().lineAddCursor(1)
end

local function skip_cursor_above()
    multicursor().lineSkipCursor(-1)
end

local function skip_cursor_below()
    multicursor().lineSkipCursor(1)
end

map("n", "<leader>Ma", function()
    multicursor().matchAddCursor(1)
end, { desc = "Add the next matching cursor" })
map("n", "<leader>MA", function()
    multicursor().matchAllAddCursors()
end, { desc = "Add cursors for every match in the file" })
map("n", "<leader>Ms", function()
    multicursor().matchSkipCursor(1)
end, { desc = "Skip the next matching cursor" })
map("n", "<leader>Mv", function()
    multicursor().restoreCursors()
end, { desc = "Restore the last cleared multicursor set" })
map("n", "<leader>Mx", function()
    multicursor().deleteCursor()
end, { desc = "Delete current multicursor" })
map("n", "<leader>Mt", function()
    multicursor().toggleCursor()
end, { desc = "Toggle multicursor for current match" })
map({ "n", "x" }, "<leader>Mj", add_cursor_below, { desc = "Add cursor below" })
map({ "n", "x" }, "<leader>Mk", add_cursor_above, { desc = "Add cursor above" })
map({ "n", "x" }, "<leader>MJ", skip_cursor_below, { desc = "Skip cursor below" })
map({ "n", "x" }, "<leader>MK", skip_cursor_above, { desc = "Skip cursor above" })
map({ "n", "x" }, "<C-M-Up>", add_cursor_above, { desc = "Add cursor above" })
map({ "n", "x" }, "<C-M-Down>", add_cursor_below, { desc = "Add cursor below" })

-- Themes and utility toggles
map("n", "<leader>ut", cmd("ThemePicker"), { desc = "Choose a theme" })
map("n", "<leader>un", cmd("ThemeNext"), { desc = "Switch to the next theme" })
map("n", "<leader>up", cmd("ThemePrev"), { desc = "Switch to the previous theme" })
map("n", "<leader>us", function()
    vim.opt_local.spell = not vim.opt_local.spell:get()
    vim.notify(vim.opt_local.spell:get() and "Spell check is on" or "Spell check is off")
end, { desc = "Toggle spell check" })
map("n", "<leader>uy", cmd("ThemeTransparencyToggle"), { desc = "Turn transparency on or off" })
map("n", "<leader>ua", cmd("AutoSaveToggle"), { desc = "Turn autosave on or off" })
map("n", "<leader>ub", cmd("AutoSaveBufferToggle"), { desc = "Turn autosave on or off for this file" })
map("n", "<leader>uw", function()
    vim.opt_local.wrap = not vim.opt_local.wrap:get()
    vim.notify(vim.opt_local.wrap:get() and "Text wrap is on" or "Text wrap is off")
end, { desc = "Toggle text wrapping" })

-- Windows and sessions
map("n", "<leader>wv", cmd("vsplit"), { desc = "Split the window vertically" })
map("n", "<leader>wh", cmd("split"), { desc = "Split the window horizontally" })
map("n", "<leader>wc", cmd("close"), { desc = "Close the current window" })
map("n", "<leader>wo", cmd("only"), { desc = "Keep only the current window" })

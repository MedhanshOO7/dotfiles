local map = vim.keymap.set

local function cmd(command)
    return "<cmd>" .. command .. "<CR>"
end

local function toggle_explorer()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.picker then
        local pickers = snacks.picker.get({ source = "explorer" })
        if #pickers > 0 then
            pickers[1]:close()
        else
            snacks.explorer()
        end
    else
        local oil_ok, oil = pcall(require, "oil")
        if oil_ok and oil.open then
            oil.open()
        else
            pcall(vim.cmd, "Explore")
        end
    end
end

local function keymap_help()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.picker then
        snacks.picker.keymaps()
    else
        vim.cmd("checkhealth keymaps")
    end
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
map("n", "<leader>fe", function()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.explorer then snacks.explorer() else vim.cmd("Oil") end
end, { desc = "Open file explorer" })
map("n", "<leader>fs", cmd("write"), { desc = "Save the current file" })
map("n", "<leader>cf", function()
    if not vim.bo.modifiable then
        vim.notify("Buffer is read-only (not modifiable)", vim.log.levels.WARN, { title = "Formatter" })
        return
    end
    require("conform").format({ lsp_format = "fallback", async = true })
end, { desc = "Format the current file" })
map("n", "<leader>uf", cmd("FormatToggle"), { desc = "Toggle auto-format on save" })
map("n", "<leader>um", function()
    vim.bo.modifiable = not vim.bo.modifiable
    vim.notify(vim.bo.modifiable and "Buffer is now MODIFIABLE (editing enabled)  " or "Buffer is now READ-ONLY (editing disabled)  ", vim.log.levels.INFO)
end, { desc = "Toggle buffer modifiable state (unlock editing)" })
map("n", "<leader>q", cmd("quit"), { desc = "Quit the current window" })

-- Terminals and writing
map({ "n", "i", "t" }, "<C-`>", function()
    local ok, ts = pcall(require, "utils.terminal_style")
    if ok then ts.toggle() else vim.cmd("ToggleTerm") end
end, { desc = "Toggle active terminal" })
map("i", "<C-Left>", "<C-o>b", { desc = "Jump backward one word" })
map("i", "<C-Right>", "<C-o>w", { desc = "Jump forward one word" })
map({ "n", "v" }, "<leader>rr", function()
    local ft = vim.bo.filetype
    local mode = vim.api.nvim_get_mode().mode
    if ft == "sql" or ft == "mysql" or ft == "plsql" then
        require("utils.dadbod").run_sql(mode)
    elseif mode == "n" then
        pcall(vim.cmd, "RunFile")
    else
        pcall(vim.cmd, "RunCode")
    end
end, { desc = "Run: Current file / selection" })
map("n", "<leader>to", function()
    local ok, ts = pcall(require, "utils.terminal_style")
    if ok then ts.toggle() else vim.cmd("ToggleTerm") end
end, { desc = "Open or close the active terminal" })
map("n", "<leader>ts", function()
    local ok, ts = pcall(require, "utils.terminal_style")
    if ok then ts.select() else vim.cmd("TerminalStyle") end
end, { desc = "Choose terminal position (Center, Bottom, Right)" })
map("n", "<leader>tS", function()
    local ok, ts = pcall(require, "utils.terminal_style")
    if ok then ts.select() else vim.cmd("TerminalStyle") end
end, { desc = "Choose terminal & runner style (Center, Bottom, Right)" })
map("n", "<leader>tf", cmd("TerminalProject"), { desc = "Open the main project shell" })
map("n", "<leader>th", cmd("TerminalHorizontal"), { desc = "Open a bottom terminal panel" })
map("n", "<leader>tv", cmd("TerminalVertical"), { desc = "Open a side terminal panel" })
map("n", "<leader>tg", cmd("TerminalSelect"), { desc = "Pick from active terminal sessions" })
map("n", "<leader>zz", function()
    require("snacks").zen()
end, { desc = "Focus on writing or reading without distractions" })
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
map("n", "<leader>nh", function()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.notifier then snacks.notifier.show_history() end
end, { desc = "Notification history" })
map("n", "<leader>nd", function()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.notifier then snacks.notifier.hide() end
end, { desc = "Dismiss all notifications" })

-- Buffers and tabs
map("n", "<leader>bn", cmd("bnext"), { desc = "Go to the next open file" })
map("n", "<leader>bp", cmd("bprevious"), { desc = "Go to the previous open file" })
map("n", "<leader>bd", function()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.bufdelete then
        snacks.bufdelete()
    else
        vim.cmd("bdelete")
    end
end, { desc = "Close the current file" })
map("n", "<leader>bo", function()
    local current = vim.api.nvim_get_current_buf()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= current and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
            pcall(vim.api.nvim_buf_delete, buf, {})
        end
    end
    vim.notify("Closed other buffers", vim.log.levels.INFO)
end, { desc = "Close every file except this one" })

-- Folding
map("n", "<leader>za", "za", { desc = "Toggle fold" })
map("n", "<leader>zc", "zc", { desc = "Close fold" })
map("n", "<leader>zo", "zo", { desc = "Open fold" })
map("n", "<leader>zR", function() require("ufo").openAllFolds() end, { desc = "Open all folds" })
map("n", "<leader>zM", function() require("ufo").closeAllFolds() end, { desc = "Close all folds" })
map("n", "<leader>zv", function()
    local winid = require("ufo").peekFoldedLinesUnderCursor()
    if not winid then
        vim.lsp.buf.hover()
    end
end, { desc = "Preview fold" })

-- Git
map("n", "]h", cmd("Gitsigns next_hunk"), { desc = "Go to the next git change" })
map("n", "[h", cmd("Gitsigns prev_hunk"), { desc = "Go to the previous git change" })
map("n", "<leader>gn", cmd("Gitsigns next_hunk"), { desc = "Go to the next git change" })
map("n", "<leader>gN", cmd("Gitsigns prev_hunk"), { desc = "Go to the previous git change" })
map("n", "<leader>gs", cmd("Gitsigns stage_hunk"), { desc = "Stage this changed block" })
map("n", "<leader>gu", cmd("Gitsigns undo_stage_hunk"), { desc = "Undo staging for this changed block" })
map("n", "<leader>gr", cmd("Gitsigns reset_hunk"), { desc = "Discard this changed block" })
map("n", "<leader>gb", function()
    require("gitsigns").blame_line({ full = true })
end, { desc = "Show who changed this line and when" })
map("n", "<leader>gp", cmd("Gitsigns preview_hunk"), { desc = "Preview this changed block" })
map("n", "<leader>gd", cmd("DiffviewOpen"), { desc = "Open side-by-side git diffview" })
map("n", "<leader>gD", cmd("DiffviewClose"), { desc = "Close git diffview" })
map("n", "<leader>gg", cmd("Neogit"), { desc = "Open the full git panel" })
map("n", "<leader>gc", cmd("Neogit commit"), { desc = "Start a git commit" })

-- Search and discovery
local function pick_files()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.picker then snacks.picker.files() else vim.cmd("find") end
end
local function live_grep()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.picker then snacks.picker.grep() end
end
local function pick_buffers()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.picker then snacks.picker.buffers() end
end
local function pick_recent()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.picker then snacks.picker.recent() end
end
local function pick_keymaps()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.picker then
        snacks.picker.keymaps({
            layout = { preset = "vscode" },
        })
    else
        pcall(function() require("which-key").show() end)
    end
end

map("n", "<leader>p", function()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.picker then snacks.picker.commands() end
end, { desc = "Open the command palette" })
map("n", "<leader>ff", pick_files, { desc = "Find a file by name" })
map("n", "<leader>fg", live_grep, { desc = "Search for text in the project" })
map("n", "<leader>f/", function()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.picker then snacks.picker.lines() end
end, { desc = "Search in the current file" })
map("n", "<leader>fb", pick_buffers, { desc = "Switch between open files" })
map("n", "<leader>fp", function()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.picker then snacks.picker.git_files() end
end, { desc = "Find a tracked project file" })
map("n", "<leader>fr", pick_recent, { desc = "Reopen a recent file" })
map("n", "<leader>fS", function()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.picker then snacks.picker.lsp_symbols() end
end, { desc = "Search symbols in this file" })
map("n", "<leader>fw", function()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.picker then snacks.picker.lsp_workspace_symbols() end
end, { desc = "Search workspace symbols" })
map("n", "<leader>ft", function()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.picker then
        snacks.picker.todo_comments()
    else
        pcall(vim.cmd, "TodoQuickFix")
    end
end, { desc = "Find every TODO, NOTE, or FIX comment" })
map("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next TODO comment" })
map("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous TODO comment" })
map("n", "<leader>fk", pick_keymaps, { desc = "Browse every keybinding" })
map("n", "<leader>?", pick_keymaps, { desc = "Browse every keybinding" })
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
map({ "n", "i", "x" }, "<M-LeftMouse>", function()
    multicursor().handleMouse()
end, { desc = "Toggle cursor at mouse position" })

-- Themes and comprehensive distro-grade UI & System toggles (<leader>u...)
map("n", "<leader>uu", function() require("utils.updater").update() end, { desc = "Update Neovim config from Git repository" })
map("n", "<leader>ut", cmd("ThemePicker"), { desc = "Choose a theme" })
map("n", "<leader>un", cmd("ThemeNext"), { desc = "Switch to the next theme" })
map("n", "<leader>up", cmd("ThemePrev"), { desc = "Switch to the previous theme" })
map("n", "<leader>uy", cmd("ThemeTransparencyToggle"), { desc = "Turn transparency on or off" })
map("n", "<leader>uS", cmd("StatusStyle"), { desc = "Choose statusline & header color style" })
map("n", "<leader>uT", function()
    local ok, ts = pcall(require, "utils.terminal_style")
    if ok then ts.select() else vim.cmd("TerminalStyle") end
end, { desc = "Choose terminal & code runner style (Center, Bottom, Right)" })

map("n", "<leader>ud", function()
    local enabled = vim.diagnostic.is_enabled()
    vim.diagnostic.enable(not enabled)
    vim.notify(not enabled and "LSP Diagnostics ENABLED 󰒕 " or "LSP Diagnostics DISABLED 󰂭 ", vim.log.levels.INFO)
end, { desc = "Toggle LSP diagnostics" })

map("n", "<leader>uh", function()
    local filter = { bufnr = 0 }
    local enabled = vim.lsp.inlay_hint.is_enabled(filter)
    vim.lsp.inlay_hint.enable(not enabled, filter)
    vim.notify(not enabled and "Inlay Hints ENABLED 󰌵 " or "Inlay Hints DISABLED 󰂭 ", vim.log.levels.INFO)
end, { desc = "Toggle LSP inlay hints" })

map("n", "<leader>ul", function()
    if vim.wo.relativenumber then
        vim.wo.relativenumber = false
        vim.notify("Line numbers: Absolute", vim.log.levels.INFO)
    else
        vim.wo.relativenumber = true
        vim.notify("Line numbers: Relative", vim.log.levels.INFO)
    end
end, { desc = "Toggle relative line numbers" })

map("n", "<leader>uc", function()
    local level = vim.wo.conceallevel == 0 and 2 or 0
    vim.wo.conceallevel = level
    vim.notify("Conceal level: " .. level, vim.log.levels.INFO)
end, { desc = "Toggle conceal level" })

map("n", "<leader>ux", function()
    local ok, ts_ctx = pcall(require, "treesitter-context")
    if ok then
        ts_ctx.toggle()
        vim.notify("Treesitter Context toggled", vim.log.levels.INFO)
    end
end, { desc = "Toggle Treesitter sticky header" })

map("n", "<leader>us", function()
    vim.opt_local.spell = not vim.opt_local.spell:get()
    vim.notify(vim.opt_local.spell:get() and "Spell check is on" or "Spell check is off", vim.log.levels.INFO)
end, { desc = "Toggle spell check" })

map("n", "<leader>uw", function()
    vim.opt_local.wrap = not vim.opt_local.wrap:get()
    vim.notify(vim.opt_local.wrap:get() and "Text wrap is on" or "Text wrap is off", vim.log.levels.INFO)
end, { desc = "Toggle text wrapping" })

map("n", "<leader>ua", cmd("AutoSaveToggle"), { desc = "Turn autosave on or off" })
map("n", "<leader>ub", cmd("AutoSaveBufferToggle"), { desc = "Turn autosave on or off for this file" })

-- Windows and sessions are defined in lua/plugins/windows.lua

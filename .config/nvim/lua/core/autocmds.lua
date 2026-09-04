-- ── Reset Terminal Colors on Exit ────────────────────────────
-- Fixes Kitty/Wezterm background color bleeding when closing Neovim
vim.api.nvim_create_autocmd("VimLeave", {
    group = vim.api.nvim_create_augroup("RestoreTerminalColors", { clear = true }),
    callback = function()
        io.stdout:write("\27]111\27\\") -- Reset background
        io.stdout:write("\27]110\27\\") -- Reset foreground
        io.stdout:write("\27]112\27\\") -- Reset cursor
    end,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = function()
        if vim.fn.executable("zen-browser") == 1 then
            vim.env.BROWSER = "zen-browser"
        elseif vim.fn.executable("zen") == 1 then
            vim.env.BROWSER = "zen"
        end
    end,
})

-- ── Quick Dismiss Windows (q & Esc) ───────────────────────────
vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("QuickDismissWindows", { clear = true }),
    pattern = "*",
    callback = function(event)
        local bt = vim.bo[event.buf].buftype
        local ft = vim.bo[event.buf].filetype or ""

        -- Do not hijack keys in interactive explorer / DB buffers / terminal buffers
        if ft == "dbui" or ft == "dbout" or ft == "dadbod" or ft == "oil" or ft:match("dbui") or bt == "terminal" then
            return
        end

        if bt == "nofile" or bt == "quickfix" or ft:match("overseer") or ft:match("Overseer") or ft == "qf" or ft == "help" or ft == "notify" then
            local function close_win()
                if #vim.api.nvim_tabpage_list_wins(0) > 1 then
                    pcall(vim.cmd, "close")
                else
                    pcall(vim.cmd, "bdelete")
                end
            end
            pcall(vim.keymap.set, "n", "q", close_win, { buffer = event.buf, silent = true, desc = "Close window" })
            pcall(vim.keymap.set, "n", "<Esc>", close_win, { buffer = event.buf, silent = true, desc = "Close window" })
        end
    end,
})

-- ── Manpage Enhancements ─────────────────────────────────────
local man_group = vim.api.nvim_create_augroup("ManPageSettings", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = man_group,
    pattern = "man",
    callback = function()
        local opt = vim.opt_local
        opt.wrap = true
        opt.linebreak = true
        opt.number = false
        opt.relativenumber = false
        opt.signcolumn = "no"
        opt.list = false
        opt.keywordprg = ":Man"
        opt.foldcolumn = "0"
        opt.statuscolumn = ""
        opt.colorcolumn = ""
        opt.cursorline = false
        opt.scrolloff = 1
        opt.sidescrolloff = 0
        opt.spell = false
        opt.conceallevel = 0
        opt.showbreak = "↪ "
        
        -- Full-screen clean look (laststatus is global, save and restore it)
        local prev_laststatus = vim.o.laststatus
        vim.o.laststatus = 0
        vim.api.nvim_create_autocmd("BufLeave", {
            buffer = vim.api.nvim_get_current_buf(),
            once = true,
            callback = function()
                vim.o.laststatus = prev_laststatus
            end,
        })

        -- Map 'q' to close the buffer
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, silent = true, desc = "Close Manpage" })
        vim.keymap.set("n", "<Space>", "<C-d>", { buffer = true, silent = true, desc = "Scroll Down" })
        vim.keymap.set("n", "<S-Space>", "<C-u>", { buffer = true, silent = true, desc = "Scroll Up" })
        vim.keymap.set("n", "J", "<C-d>", { buffer = true, silent = true, desc = "Scroll Down" })
        vim.keymap.set("n", "K", "<C-u>", { buffer = true, silent = true, desc = "Scroll Up" })
        vim.keymap.set("n", "d", "<C-d>", { buffer = true, silent = true, desc = "Scroll Down" })
        vim.keymap.set("n", "u", "<C-u>", { buffer = true, silent = true, desc = "Scroll Up" })
        
        -- 'gd' to go to definition (jump to referenced man page)
        vim.keymap.set("n", "gd", "K", { buffer = true, silent = true, desc = "Jump to reference" })
        vim.keymap.set("n", "gO", "<C-]>", { buffer = true, silent = true, desc = "Open referenced man page" })
        vim.keymap.set("n", "gh", "<C-T>", { buffer = true, silent = true, desc = "Jump back from referenced man page" })
        vim.keymap.set("n", "/", "/\\v", { buffer = true, remap = false, desc = "Regex search" })
        
        -- Use built-in regex syntax for manpages as Treesitter 'man' is unsupported
        vim.bo.syntax = "man"

        -- ── Heuristic Code Highlighting ──────────────────────────
        -- Since manpages don't have formal code block tags, we use regex
        -- to find common C patterns in indented lines.
        vim.cmd([[
            syntax match manCInclude /^\s\+#include\s\+[<"].*[>"]/
            syntax match manCKeyword /^\s\+\(if\|else\|while\|for\|return\|int\|char\|void\|static\|struct\|fprintf\|stdout\|printf\|NULL\)\>/
            syntax region manCString start=/"/ skip=/\\"/ end=/"/ oneline
            syntax match manCComment /^\s\+\/\/.*$/
            syntax match manCComment /^\s\+\/\*.*\*\//

            highlight link manCInclude PreProc
            highlight link manCKeyword Statement
            highlight link manCString String
            highlight link manCComment Comment
        ]])
    end,
})

-- ── Help Page Enhancements ───────────────────────────────────
local help_group = vim.api.nvim_create_augroup("HelpPageSettings", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = help_group,
    pattern = "help",
    callback = function()
        -- Help pages usually have their own keybindings, but we ensure 'q' works if not set
        if vim.fn.maparg("q", "n") == "" then
            vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, silent = true, desc = "Close Help" })
        end
    end,
})

-- ── ANSI Color Support (Pager) ───────────────────────────────
-- Automatically trigger colorizer if ANSI escape codes are detected
-- in plain text buffers (common for piped output like 'git log | nvim')
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("AnsiColorDetection", { clear = true }),
    callback = function()
        if vim.bo.filetype == "" or vim.bo.filetype == "text" then
            local lines = vim.api.nvim_buf_get_lines(0, 0, 50, false)
            local content = table.concat(lines, "\n")
            if content:find("\27%[") then
                -- Schedule to ensure plugin is loaded
                vim.schedule(function()
                    pcall(vim.cmd, "ColorizerAttachToBuffer")
                end)
            end
        end
    end,
})

vim.api.nvim_create_autocmd("StdinReadPre", {
    group = vim.api.nvim_create_augroup("PagerMode", { clear = true }),
    callback = function()
        vim.g.started_as_pager = true
    end,
})

vim.api.nvim_create_autocmd("StdinReadPost", {
    group = vim.api.nvim_create_augroup("PagerPolish", { clear = true }),
    callback = function()
        if not vim.g.started_as_pager then
            return
        end

        local opt = vim.opt_local
        opt.bufhidden = "wipe"
        opt.buftype = "nofile"
        opt.modifiable = false
        opt.readonly = true
        opt.wrap = true
        opt.linebreak = true
        opt.number = false
        opt.relativenumber = false
        opt.signcolumn = "no"
        opt.list = false
        opt.spell = false
        opt.statuscolumn = ""
        opt.colorcolumn = ""
        opt.cursorline = false
        opt.foldcolumn = "0"
        vim.o.laststatus = 0

        local opts = { buffer = true, silent = true }
        vim.keymap.set("n", "q", "<cmd>qa!<cr>", vim.tbl_extend("force", opts, { desc = "Quit pager" }))
        vim.keymap.set("n", "<Esc>", "<cmd>qa!<cr>", vim.tbl_extend("force", opts, { desc = "Quit pager" }))
        vim.keymap.set("n", "J", "<C-d>", opts)
        vim.keymap.set("n", "K", "<C-u>", opts)
    end,
})

-- ── Window & Explorer Size Inspector ─────────────────────────
vim.api.nvim_create_user_command("WinSize", function()
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    local w = vim.api.nvim_win_get_width(win)
    local h = vim.api.nvim_win_get_height(win)
    local total_w = vim.o.columns
    local total_h = vim.o.lines
    local pct_w = math.floor((w / total_w) * 100)
    local pct_h = math.floor((h / total_h) * 100)
    local ft = vim.bo[buf].filetype
    if ft == "" then ft = "none" end
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
    if name == "" then name = "[No Name]" end

    local msg = string.format("📐 %s (%s)\n• Width:  %d columns (%d%% of screen)\n• Height: %d rows (%d%% of screen)", name, ft, w, pct_w, h, pct_h)
    vim.notify(msg, vim.log.levels.INFO, { title = "Window Size" })
end, { desc = "Show current window dimensions" })

vim.api.nvim_create_user_command("ExplorerSize", function(opts)
    local target_w = tonumber(opts.args)
    -- Look for explorer window
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.bo[buf].filetype
        if ft == "snacks_explorer" or ft:match("explorer") then
            if target_w and target_w >= 10 then
                vim.api.nvim_win_set_width(win, target_w)
                vim.notify(string.format("📁 File Explorer resized to %d columns", target_w), vim.log.levels.INFO)
                return
            end
            local w = vim.api.nvim_win_get_width(win)
            local h = vim.api.nvim_win_get_height(win)
            local total_w = vim.o.columns
            local pct_w = math.floor((w / total_w) * 100)
            local msg = string.format("📁 File Explorer Size:\n• Width:  %d columns (%d%%)\n• Height: %d rows", w, pct_w, h)
            vim.notify(msg, vim.log.levels.INFO, { title = "Explorer Size" })
            return
        end
    end
    -- If not open or focused elsewhere, check current window
    local w = vim.api.nvim_win_get_width(0)
    if target_w and target_w >= 10 then
        vim.cmd("vertical resize " .. target_w)
        vim.notify(string.format("Current window resized to %d columns", target_w), vim.log.levels.INFO)
    else
        vim.notify(string.format("Current Window Width: %d columns", w), vim.log.levels.INFO)
    end
end, { nargs = "?", desc = "Show or set explorer / window width (e.g. :ExplorerSize 24)" })

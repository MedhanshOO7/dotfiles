local group = vim.api.nvim_create_augroup("ZenModeAuto", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "markdown", "text" },
    callback = function()
        -- Check if we are inside a code project by looking for .git or package.json
        local in_project = vim.fn.finddir(".git", ".;") ~= "" or vim.fn.findfile("package.json", ".;") ~= "" or vim.fn.findfile("Cargo.toml", ".;") ~= ""
        
        if not in_project then
            -- Use schedule to avoid issues with window initialization
            vim.schedule(function()
                local view_ok, view = pcall(require, "zen-mode.view")
                if view_ok and not view.is_open() then
                    vim.cmd("ZenMode")
                end
            end)
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
        
        -- Full-screen clean look
        vim.opt_local.laststatus = 0

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
        opt.laststatus = 0

        local opts = { buffer = true, silent = true }
        vim.keymap.set("n", "q", "<cmd>qa!<cr>", vim.tbl_extend("force", opts, { desc = "Quit pager" }))
        vim.keymap.set("n", "<Esc>", "<cmd>qa!<cr>", vim.tbl_extend("force", opts, { desc = "Quit pager" }))
        vim.keymap.set("n", "J", "<C-d>", opts)
        vim.keymap.set("n", "K", "<C-u>", opts)
    end,
})

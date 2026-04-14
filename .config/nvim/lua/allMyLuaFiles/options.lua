local opt          = vim.opt

-- ── Appearance ──────────────────────────────────────────────
opt.termguicolors  = true  -- 24-bit RGB colours (needed by most themes)
opt.number         = true  -- show absolute line numbers
opt.relativenumber = false -- VS Code-style absolute line numbers
opt.signcolumn     = "yes" -- always show the sign column (prevents layout jumps)
opt.cursorline     = true  -- highlight the current line
opt.scrolloff      = 3     -- keep a little context around the cursor
opt.sidescrolloff  = 0     -- no horizontal cursor padding
opt.wrap           = false -- don't wrap long lines
opt.colorcolumn    = "0"   -- no hard ruler by default
opt.showmode       = false -- mode is shown in the statusline instead
opt.cmdheight      = 1     -- command bar height
opt.laststatus     = 3     -- single statusline across all windows

-- ── Indentation ─────────────────────────────────────────────
opt.expandtab      = true -- convert tabs → spaces
opt.shiftwidth     = 4    -- indent width (Lua/C use 4; change per filetype)
opt.tabstop        = 4    -- how wide a real <Tab> looks
opt.softtabstop    = 4    -- how wide <Tab>/<BS> feel in insert mode
opt.smartindent    = true -- auto-indent new lines based on context
opt.shiftround     = true -- round indents to nearest shiftwidth multiple
opt.backspace      = { "indent", "eol", "start" } -- make <BS> work across autoindent and line joins

-- ── Search ──────────────────────────────────────────────────
opt.hlsearch       = true -- highlight all search matches
opt.incsearch      = true -- show matches as you type
opt.ignorecase     = true -- case-insensitive by default …
opt.smartcase      = true -- … unless the pattern contains uppercase

-- ── Splits & windows ────────────────────────────────────────
opt.splitright     = true -- vertical splits open to the right
opt.splitbelow     = true -- horizontal splits open below

-- ── Files & buffers ─────────────────────────────────────────
opt.hidden         = true                               -- allow switching away from unsaved buffers
opt.autowrite      = true                               -- auto-save before :make / :next etc.
opt.swapfile       = false                              -- no swap files
opt.backup         = false                              -- no backup files
opt.undofile       = true                               -- persist undo history across sessions
opt.undodir        = vim.fn.stdpath("state") .. "/undo" -- undo dir location
opt.confirm        = true                               -- prompt before losing unsaved work

-- ── Completion & menus ──────────────────────────────────────
opt.completeopt    = { "menuone", "noselect" } -- nvim-cmp friendly
opt.pumheight      = 10                        -- max items in popup menu
opt.shortmess:append("c")                      -- suppress completion messages
opt.updatetime     = 250                       -- snappier diagnostics and git updates
opt.timeoutlen     = 300                       -- faster which-key popup and mappings
opt.splitkeep      = "screen"                  -- avoid layout jumps when opening or closing splits
opt.inccommand     = "split"                   -- preview substitutions live
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- ── Clipboard ───────────────────────────────────────────────
opt.clipboard      = "unnamedplus" -- sync with system clipboard

-- ── Folding (Treesitter-ready) ───────────────────────────────
opt.foldmethod     = "expr"
opt.foldexpr       = "v:lua.vim.treesitter.foldexpr()"
opt.foldenable     = true
opt.foldlevel      = 99 -- keep folds open by default
opt.foldlevelstart = 99
opt.foldnestmax    = 6
opt.foldcolumn     = "0"
opt.fillchars:append({
    foldopen = "",
    foldclose = "",
    foldsep = " ",
})

-- ── Misc ────────────────────────────────────────────────────
opt.mouse          = "a"  -- enable mouse in all modes
opt.breakindent    = true -- wrapped lines preserve indentation
opt.list           = false -- keep whitespace guides hidden by default
opt.listchars      = {    -- … configured as:
    tab   = "» ",
    trail = "·",
    nbsp  = "␣",
}
opt.formatoptions:remove("cro") -- stop auto-inserting comment leaders
opt.iskeyword:append("-")       -- treat hyphenated-words as one word

-- Keep netrw available as a fallback with familiar directory listings.
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25
vim.g.netrw_banner = 0
vim.g.netrw_sort_sequence = "[\\/]$,*,\\.o$,\\.obj$,\\.pyc$,\\.class$"
vim.g.netrw_fastbrowse = 2
vim.g.netrw_keepdir = 0

local language_group = vim.api.nvim_create_augroup("language_defaults", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = language_group,
    pattern = { "markdown", "text", "gitcommit" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = true
        vim.opt_local.spelllang = { "en" }
        vim.opt_local.conceallevel = 2
        vim.opt_local.colorcolumn = "0"
        vim.opt_local.list = false
        vim.opt_local.signcolumn = "no"
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.foldmethod = "manual"
        vim.opt_local.foldexpr = "0"
        vim.opt_local.foldcolumn = "0"
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = language_group,
    pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "html", "css", "json", "markdown", "yaml" },
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = language_group,
    pattern = { "c", "cpp", "lua", "python", "sh" },
    callback = function()
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
        vim.opt_local.softtabstop = 4
    end,
})

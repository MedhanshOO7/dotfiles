local opt          = vim.opt

-- ── Appearance ──────────────────────────────────────────────
opt.termguicolors  = true  -- 24-bit RGB colours (needed by most themes)
opt.number         = true  -- show absolute line numbers
opt.relativenumber = true  -- show relative line numbers (great for motions)
opt.signcolumn     = "yes" -- always show the sign column (prevents layout jumps)
opt.cursorline     = true  -- highlight the current line
opt.scrolloff      = 8     -- keep 8 lines visible above/below cursor
opt.sidescrolloff  = 8     -- keep 8 columns visible left/right
opt.wrap           = false -- don't wrap long lines
opt.colorcolumn    = "80"  -- ruler at column 80  (adjust to taste)
opt.showmode       = false -- mode is shown in the statusline instead
opt.cmdheight      = 1     -- command bar height

-- ── Indentation ─────────────────────────────────────────────
opt.expandtab      = true -- convert tabs → spaces
opt.shiftwidth     = 4    -- indent width (Lua/C use 4; change per filetype)
opt.tabstop        = 4    -- how wide a real <Tab> looks
opt.softtabstop    = 4    -- how wide <Tab>/<BS> feel in insert mode
opt.smartindent    = true -- auto-indent new lines based on context
opt.shiftround     = true -- round indents to nearest shiftwidth multiple

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

-- ── Completion & menus ──────────────────────────────────────
opt.completeopt    = { "menuone", "noselect" } -- nvim-cmp friendly
opt.pumheight      = 10                        -- max items in popup menu
opt.shortmess:append("c")                      -- suppress completion messages

-- ── Clipboard ───────────────────────────────────────────────
opt.clipboard      = "unnamedplus" -- sync with system clipboard

-- ── Folding (Treesitter-ready) ───────────────────────────────
opt.foldmethod     = "expr"
opt.foldexpr       = "nvim_treesitter#foldexpr()"
opt.foldlevel      = 99 -- open all folds by default
opt.foldlevelstart = 99

-- ── Misc ────────────────────────────────────────────────────
opt.mouse          = "a"  -- enable mouse in all modes
opt.breakindent    = true -- wrapped lines preserve indentation
opt.list           = true -- show invisible characters …
opt.listchars      = {    -- … configured as:
    tab   = "» ",
    trail = "·",
    nbsp  = "␣",
}
opt.formatoptions:remove("cro") -- stop auto-inserting comment leaders
opt.iskeyword:append("-")       -- treat hyphenated-words as one word


------NETRW-------------
-- Tree style
vim.g.netrw_liststyle = 3

-- Size of the sidebar
vim.g.netrw_winsize = 25

-- Remove banner
vim.g.netrw_banner = 0

-- Better sorting (dirs first)
vim.g.netrw_sort_sequence = "[\\/]$,*,\\.o$,\\.obj$,\\.pyc$,\\.class$"

-- Faster browsing
vim.g.netrw_fastbrowse = 2

-- Keep working directory stable
vim.g.netrw_keepdir = 0

vim.cmd("hi Directory guifg=#8be9fd gui=bold") -- Dracula cyan
vim.opt.cursorline = true


-- Neo-tree (modern explorer)
vim.keymap.set("n", "<C-b>", ":Neotree toggle<CR>", { silent = true })

-- Netrw (classic)
vim.keymap.set("n", "<leader>e", ":Explore<CR>", { silent = true })

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.autoformat_enabled = false
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.python3_host_prog = vim.fn.expand("~/.venvs/neovim/bin/python")

local function ensure_dir(path)
    pcall(vim.fn.mkdir, path, "p")
    return vim.fn.isdirectory(path) == 1 and vim.fn.filewritable(path) == 2
end

local cache_dir = vim.fn.stdpath("cache")
local state_dir = vim.fn.stdpath("state")
vim.g.user_disable_lazy_cache = not ensure_dir(cache_dir)
vim.g.user_state_writable = ensure_dir(state_dir)
vim.g.user_undo_writable = ensure_dir(state_dir .. "/undo")

if vim.loader and vim.loader.enable and vim.g.user_disable_lazy_cache then
    vim.loader.enable(false)
end

if not vim.g.user_state_writable then
    vim.opt.shadafile = "NONE"
    if vim.lsp and vim.lsp.log and vim.lsp.log._set_filename then
        vim.lsp.log._set_filename("/tmp/nvim-lsp.log")
    end
end

vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")

require("core.options")
require("core.autocmds")
require("core.lazy")
require("utils.theme").setup()
require("core.keymaps")

-- Fix "Unknown filetype" warnings for LSP and Noice
vim.filetype.add({
    extension = {
        mdx = "markdown.mdx",
    },
    pattern = {
        ["docker%-compose%.ya?ml"] = "yaml.docker-compose",
        ["gitlab%-ci%.ya?ml"] = "yaml.gitlab",
    },
})

vim.opt.conceallevel = 2
vim.opt.concealcursor = "nc"

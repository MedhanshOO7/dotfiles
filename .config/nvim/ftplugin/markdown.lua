if vim.b.did_ftplugin == 1 then
    return
end
vim.b.did_ftplugin = 1

vim.opt_local.textwidth = 0
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.opt_local.spell = true
vim.opt_local.spelllang = { "en" }
vim.opt_local.conceallevel = 2
vim.opt_local.number = true
vim.opt_local.relativenumber = true
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
-- vim.opt_local.colorcolumn = "106"
vim.opt_local.formatoptions:append("rnqj")
vim.opt_local.formatoptions:remove("tco")

vim.keymap.set("n", "gO", "<cmd>AerialToggle<CR>",  { buffer = 0, silent = true,  desc = "Show an Outline of the current buffer" })
vim.keymap.set("n", "]]", "<cmd>AerialNext<CR>",    { buffer = 0, silent = false, desc = "Jump to next section" })
vim.keymap.set("n", "[[", "<cmd>AerialPrev<CR>",    { buffer = 0, silent = false, desc = "Jump to previous section" })
vim.keymap.set("n", "j",  "gj", { buffer = true, silent = true })
vim.keymap.set("n", "k",  "gk", { buffer = true, silent = true })
vim.keymap.set("n", "0",  "g0", { buffer = true, silent = true })
vim.keymap.set("n", "$",  "g$", { buffer = true, silent = true })

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "")
    .. "\nsetlocal textwidth< wrap< linebreak< breakindent< spell< spelllang< conceallevel<"
    .. " expandtab< shiftwidth< tabstop< softtabstop< colorcolumn< formatoptions<"
    .. '\n sil! exe "nunmap <buffer> gO"'
    .. '\n sil! exe "nunmap <buffer> ]]" | sil! exe "nunmap <buffer> [["'
    .. '\n sil! exe "nunmap <buffer> j"'
    .. '\n sil! exe "nunmap <buffer> k"'
    .. '\n sil! exe "nunmap <buffer> 0"'
    .. '\n sil! exe "nunmap <buffer> $"'

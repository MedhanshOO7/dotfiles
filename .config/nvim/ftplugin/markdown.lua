if vim.b.did_ftplugin == 1 then
    return
end

vim.b.did_ftplugin = 1

vim.opt_local.textwidth = 50
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.opt_local.spell = true
vim.opt_local.spelllang = { "en" }
vim.opt_local.conceallevel = 2
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.colorcolumn = "51"
vim.opt_local.formatoptions:append("trnqj")
vim.opt_local.formatoptions:remove("co")

vim.keymap.set("n", "gO", "<cmd>AerialToggle<CR>", { buffer = 0, silent = true, desc = "Show an Outline of the current buffer" })

vim.keymap.set("n", "]]", "<cmd>AerialNext<CR>", { buffer = 0, silent = false, desc = "Jump to next section" })

vim.keymap.set("n", "[[", "<cmd>AerialPrev<CR>", { buffer = 0, silent = false, desc = "Jump to previous section" })

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "")
    .. "\nsetlocal textwidth< wrap< linebreak< breakindent< spell< spelllang< conceallevel<"
    .. " expandtab< shiftwidth< tabstop< softtabstop< colorcolumn< formatoptions<"
    .. '\n sil! exe "nunmap <buffer> gO"'
    .. '\n sil! exe "nunmap <buffer> ]]" | sil! exe "nunmap <buffer> [["'

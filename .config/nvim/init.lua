vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")
print("Hello world")
require('allMyLuaFiles.options')
require('allMyLuaFiles.keybinds')
require('allMyLuaFiles.lazy')
vim.opt.conceallevel = 2
vim.opt.concealcursor = "nc"

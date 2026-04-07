vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")

require("allMyLuaFiles.options")
require("allMyLuaFiles.keybinds")
require("allMyLuaFiles.lazy")

vim.opt.conceallevel = 2
vim.opt.concealcursor = "nc"

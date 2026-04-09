vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")

require("allMyLuaFiles.options")
require("allMyLuaFiles.keybinds")
require("allMyLuaFiles.lazy")

vim.opt.conceallevel = 2
vim.opt.concealcursor = "nc"

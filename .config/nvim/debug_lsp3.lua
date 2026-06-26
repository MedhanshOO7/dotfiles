-- Force lazy to load and configure lspconfig
require("lazy").load({ plugins = { "nvim-lspconfig" } })

local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")

if configs.clangd then
    print("clangd IS configured!")
else
    print("clangd is NOT configured!")
end

local file = vim.fn.expand("%:p")
print("Editing: " .. file)

-- Start LSP for the buffer
vim.cmd("LspStart clangd")

vim.defer_fn(function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then
        print("NO LSP CLIENTS ATTACHED")
    else
        for _, client in ipairs(clients) do
            print("Attached: " .. client.name)
        end
    end
    vim.cmd("qa")
end, 2000)

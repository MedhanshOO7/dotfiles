local file = "test_sfml.cpp"
-- Force load lazy plugins first
require("lazy").load({ plugins = { "nvim-lspconfig" } })
vim.cmd("edit " .. file)
vim.cmd("doautocmd BufReadPre " .. file)
vim.cmd("doautocmd BufReadPost " .. file)

-- Wait a bit for LSP to attach and process
vim.defer_fn(function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    print("--- LSP CLIENTS ---")
    if #clients == 0 then
        print("NO LSP CLIENTS ATTACHED")
    else
        for _, client in ipairs(clients) do
            print("Attached: " .. client.name)
        end
    end

    print("--- DIAGNOSTICS ---")
    local diags = vim.diagnostic.get(0)
    if #diags == 0 then
        print("No diagnostics (No errors!)")
    else
        for _, d in ipairs(diags) do
            print(string.format("[%s] %s", d.source or "unknown", d.message))
        end
    end
    vim.cmd("qa")
end, 3000)

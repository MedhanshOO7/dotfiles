return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        local caps = require("cmp_nvim_lsp").default_capabilities()

        vim.lsp.config["clangd"] = {
            capabilities = caps,
        }

        vim.lsp.enable("clangd")
        vim.api.nvim_create_autocmd("BufWritePre", {
            callback = function()
                vim.lsp.buf.format({ async = false })
            end,
        })
        vim.diagnostic.config({
            virtual_text = {
                prefix = "●", -- cleaner than default
            },
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = {
                border = "rounded",
                source = "always",
            },
        })
        vim.fn.sign_define("DiagnosticSignError", { text = "✘" })
        vim.fn.sign_define("DiagnosticSignWarn",  { text = "▲" })
        vim.fn.sign_define("DiagnosticSignHint",  { text = "⚑" })
        vim.fn.sign_define("DiagnosticSignInfo",  { text = "»" })

        -- javascript and related
        vim.lsp.config["ts_ls"] = {}
        vim.lsp.enable("ts_ls")
        -- python

        vim.lsp.config["pylsp"] = {}
        vim.lsp.enable("pylsp")
        -- bash
        vim.lsp.config["bashls"] = {}
        vim.lsp.enable("bashls")
        -- html
        vim.lsp.config["html"] = {}
        vim.lsp.enable("html")

        vim.lsp.config["cssls"] = {}
        vim.lsp.enable("cssls")
        --lua
vim.lsp.config["luals"] = {
  root_markers = { ".git" }, -- KEEP SIMPLE
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
}

-- FORCE attach for config files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.lsp.start({
      name = "luals",
      cmd = { "lua-language-server" },
    })
  end,
})


    end,

}

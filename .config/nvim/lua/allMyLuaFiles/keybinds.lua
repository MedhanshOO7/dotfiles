vim.g.mapleader = " "

-- file explorer
vim.keymap.set("n", "<leader>e", vim.cmd.Ex)

-- LSP keymaps
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "K", vim.lsp.buf.hover)

-- LSP toggle
local lsp_enabled = true

vim.keymap.set("n", "<leader>l", function()
    lsp_enabled = not lsp_enabled

    if lsp_enabled then
        vim.cmd("LspStart")
        vim.diagnostic.enable()
        print("LSP ON")
    else
        vim.cmd("LspStop")
        vim.diagnostic.disable()
        print("LSP OFF")
    end
end)

-- terminal toggle (clean version)
-- local function toggle_terminal()
--     -- save current file if modified
--     if vim.bo.modified then
--         vim.cmd("w")
--     end
--
--     -- check if terminal already exists → close it
--     for _, win in ipairs(vim.api.nvim_list_wins()) do
--         local buf = vim.api.nvim_win_get_buf(win)
--         if vim.bo[buf].buftype == "terminal" then
--             vim.api.nvim_win_close(win, true)
--             return
--         end
--     end
--
--     -- open terminal in current file directory
--     vim.cmd("lcd %:p:h")
--
--     vim.cmd("split | terminal")
--     vim.cmd("startinsert")
-- end

-- keymaps (ALL modes)
-- vim.keymap.set("n", "<C-`>", toggle_terminal)
--
-- vim.keymap.set("i", "<C-`>", function()
--     vim.cmd("stopinsert")
--     toggle_terminal()
-- end)
--
-- vim.keymap.set("t", "<C-`>", function()
--     vim.cmd("stopinsert")
--     toggle_terminal()
-- end)
--
-- -- exit terminal mode easily
-- vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])
-- vim.keymap.set("t", "<C-n>", [[<C-\><C-n>]])

--save file
-- Normal mode
vim.keymap.set('n', '<C-s>', ':w<CR>', { desc = 'Save file' })

-- Insert mode (important: exit insert first)
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>a', { desc = 'Save file' })

-- Visual mode
vim.keymap.set('v', '<C-s>', '<Esc>:w<CR>', { desc = 'Save file' })

-- Command mode
vim.keymap.set('c', '<C-s>', '<C-c>:w<CR>', { desc = 'Save file' })

local brainstorm = false

vim.keymap.set("n", "<leader>z", function()
    brainstorm = not brainstorm

    -- toggle autocomplete
    require("cmp").setup({ enabled = not brainstorm })

    -- toggle diagnostics
    vim.diagnostic.config({
        virtual_text = not brainstorm,
        signs        = not brainstorm,
        underline    = not brainstorm,
    })

    print(brainstorm and "🧠 Brainstorm ON" or "💻 Normal mode")
end, { desc = "Toggle brainstorm mode" })

-- FORMAT (Conform)
vim.keymap.set("n", "<leader>f", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format file", silent = true })

-- RUN (Code Runner)
vim.keymap.set("n", "<leader>r", ":RunCode<CR>", { desc = "Run code", silent = true })
vim.keymap.set("n", "<C-b>", ":RunCode<CR>", { desc = "Run code", silent = true })

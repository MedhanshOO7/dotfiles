return {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    config = function()
        require("toggleterm").setup({
            open_mapping = [[<C-`>]],
            direction = "float",
            start_in_insert = true,
            persist_mode = true,
            persist_size = true,
            close_on_exit = false,
            insert_mappings = true,
            terminal_mappings = true,
            shade_terminals = false,
            shell = vim.o.shell,
            float_opts = {
                border = "rounded",
                winblend = 0,
            },
            highlights = {
                Normal = {
                    link = "Normal",
                },
                NormalFloat = {
                    link = "Normal",
                },
                FloatBorder = {
                    link = "FloatBorder",
                },
            },
        })

        vim.api.nvim_create_autocmd("TermOpen", {
            group = vim.api.nvim_create_augroup("editing_terminal_keymaps", { clear = true }),
            callback = function(event)
                local opts = { buffer = event.buf, silent = true }
                vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], vim.tbl_extend("force", opts, {
                    desc = "Leave terminal mode",
                }))
                vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
                vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
                vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
                vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
            end,
        })
    end,
}

return {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    config = function()
        local function terminal_size(term)
            if term.direction == "horizontal" then
                return math.max(14, math.floor(vim.o.lines * 0.22))
            elseif term.direction == "vertical" then
                return math.max(52, math.floor(vim.o.columns * 0.40))
            end
        end

        require("toggleterm").setup({
            size = terminal_size,
            open_mapping = [[<C-`>]],
            hide_numbers = true,
            direction = "float",
            start_in_insert = true,
            persist_mode = true,
            persist_size = true,
            close_on_exit = false,
            insert_mappings = true,
            terminal_mappings = true,
            shade_terminals = false,
            shade_filetypes = {},
            autochdir = true,
            shell = vim.o.shell,
            auto_scroll = true,
            float_opts = {
                border = "rounded",
                width = function()
                    return math.floor(vim.o.columns * 0.88)
                end,
                height = function()
                    return math.floor(vim.o.lines * 0.82)
                end,
                winblend = 0,
                title_pos = "center",
            },
            winbar = {
                enabled = true,
                name_formatter = function(term)
                    return term.display_name or term.name
                end,
            },
            responsiveness = {
                horizontal_breakpoint = 135,
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

        local Terminal = require("toggleterm.terminal").Terminal

        local project_terminal = Terminal:new({
            hidden = true,
            direction = "float",
            display_name = "Project Shell",
        })

        local horizontal_terminal = Terminal:new({
            hidden = true,
            direction = "horizontal",
            display_name = "Bottom Shell",
        })

        local vertical_terminal = Terminal:new({
            hidden = true,
            direction = "vertical",
            display_name = "Side Shell",
        })

        vim.api.nvim_create_user_command("TerminalProject", function()
            project_terminal:toggle()
        end, { desc = "Toggle the main project shell" })

        vim.api.nvim_create_user_command("TerminalHorizontal", function()
            horizontal_terminal:toggle()
        end, { desc = "Toggle a horizontal shell" })

        vim.api.nvim_create_user_command("TerminalVertical", function()
            vertical_terminal:toggle()
        end, { desc = "Toggle a vertical shell" })

        vim.api.nvim_create_user_command("TerminalSelect", function()
            vim.cmd("TermSelect")
        end, { desc = "Pick from open terminals" })

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
                vim.keymap.set("t", "<C-w>", [[<C-\><C-n><Cmd>close<CR>]], vim.tbl_extend("force", opts, {
                    desc = "Close terminal window",
                }))
            end,
        })
    end,
}

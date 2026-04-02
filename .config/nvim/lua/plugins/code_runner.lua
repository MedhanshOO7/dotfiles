return {
    "CRAG666/code_runner.nvim",
    config = function()
        require("code_runner").setup({
            mode = "term",
            focus = true,
            startinsert = true,
            term = {
                position = "belowright",
                size = 12,
            },
            filetype = {
                c = "cd $dir && gcc $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt",
                cpp = "cd $dir && g++ $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt",
                python = "python3 -u $fileName",
                javascript = "node $fileName",
                sh = "bash $fileName",
            },
        })

        -- run keymaps
        vim.keymap.set("n", "<leader>r", ":RunCode<CR>", { silent = true })
        vim.keymap.set("n", "<C-b>", ":RunCode<CR>", { silent = true })
    end,
}

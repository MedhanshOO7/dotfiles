return {
    "CRAG666/code_runner.nvim",
    cmd = "RunCode",
    config = function()
        require("code_runner").setup({
            mode = "float",
            focus = true,
            startinsert = true,
            float = {
                border = "rounded",
                width = 0.8,
                height = 0.8,
                x = 0.5,
                y = 0.5,
            },
            filetype = {
                c = "cd $dir && gcc -std=c11 -Wall -Wextra $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt",
                cpp = "cd $dir && g++ -std=c++20 -Wall -Wextra $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt",
                python = "python3 -u $fileName",
                javascript = "node $fileName",
                sh = "bash $fileName",
            },
        })
    end,
}

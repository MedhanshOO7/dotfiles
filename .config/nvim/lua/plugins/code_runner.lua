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
                c = "cd $dir && gcc -std=c11 -Wall -Wextra $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt",
                cpp = "cd $dir && g++ -std=c++20 -Wall -Wextra $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt",
                python = "python3 -u $fileName",
                javascript = "node $fileName",
                sh = "bash $fileName",
            },
        })
    end,
}

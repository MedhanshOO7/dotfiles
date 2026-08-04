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
                title = " Code Runner  (q / Esc to quit) ",
            },
            filetype = {
                c = "cd $dir && gcc -std=c11 -Wall -Wextra $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt",
                cpp = "cd $dir && g++ -std=c++20 -Wall -Wextra $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt",
                python = "cd $dir && python3 -u $fileName",
                javascript = "cd $dir && node $fileName",
                sh = "cd $dir && bash $fileName",
            },
        })

        -- After process exits, stay open and only close on q/Esc
        vim.api.nvim_create_autocmd("TermClose", {
            callback = function(args)
                local buf = args.buf
                if not vim.api.nvim_buf_is_valid(buf) then return end
                -- Only act on floating windows
                local wins = vim.fn.win_findbuf(buf)
                for _, win in ipairs(wins) do
                    if vim.api.nvim_win_get_config(win).relative ~= "" then
                        -- Prevent default "press any key to close"
                        vim.schedule(function()
                            if not vim.api.nvim_buf_is_valid(buf) then return end
                            pcall(vim.cmd, "stopinsert")
                            local close = function()
                                if vim.api.nvim_win_is_valid(win) then
                                    vim.api.nvim_win_close(win, true)
                                end
                            end
                            vim.keymap.set("n", "q", close, { buffer = buf, nowait = true })
                            vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true })
                        end)
                    end
                end
            end,
        })
    end,
}

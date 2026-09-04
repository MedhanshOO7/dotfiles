return {
    "barrett-ruth/live-server.nvim",
    ft = "html",
    cmd = { "LiveServerStart", "LiveServerStop", "LiveServerToggle" },
    config = function()
        local args = {
            "--port=5500",
            "--host=127.0.0.1",
        }
        if vim.fn.executable("zen-browser") == 1 then
            table.insert(args, "--browser=zen-browser")
        elseif vim.fn.executable("zen") == 1 then
            table.insert(args, "--browser=zen")
        end

        require("live-server").setup({
            args = args,
        })
    end,
    keys = {
        {
            "<leader>lv",
            function()
                local dir = vim.fn.expand("%:p:h")
                local file = vim.fn.expand("%:t")
                if dir ~= "" and dir ~= "." then
                    vim.cmd("LiveServerStart " .. vim.fn.fnameescape(dir))
                    vim.notify("Live Server started serving: " .. vim.fn.expand("%:t"), vim.log.levels.INFO, { title = "Live Server" })
                else
                    vim.cmd("LiveServerStart")
                end
            end,
            desc = "Live Server Start (Current Directory)",
        },
        { "<leader>lV", "<cmd>LiveServerStop<cr>", desc = "Live Server Stop" },
    },
}

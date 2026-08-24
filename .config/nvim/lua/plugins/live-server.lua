return {
    "barrett-ruth/live-server.nvim",
    cmd = { "LiveServerStart", "LiveServerStop", "LiveServerToggle" },
    config = function()
        require("live-server").setup({
            args = {
                "--port=5500",
                "--host=127.0.0.1",
                "--browser=zen-browser",
            },
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

return {
    "barrett-ruth/live-server.nvim",
    ft = "html",
    cmd = { "LiveServerStart", "LiveServerStop", "LiveServerToggle" },
    init = function()
        -- v0.2+ is configured through this global; setup() and the old `args`
        -- (--browser=...) were removed. The page opens via vim.ui.open, i.e. the
        -- system default browser.
        vim.g.live_server = {
            port = 5500,
        }
    end,
    keys = {
        {
            "<leader>lv",
            function()
                local dir = vim.fn.expand("%:p:h")
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

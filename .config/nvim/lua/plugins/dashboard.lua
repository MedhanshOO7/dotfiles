return {
    "folke/snacks.nvim",
    opts = {
        dashboard = {
            enabled = true,
            sections = {
                { section = "header" },
                { section = "keys", gap = 1, padding = 1 },
                { pane = 2, section = "terminal", cmd = "pokemon-colorscripts -r --no-title; sleep .1", height = 20, padding = 1, ttl = 3600 },
                { section = "recent_files", limit = 8, padding = 1 },
                { section = "projects", limit = 4, padding = 1 },
                {
                    pane = 2,
                    icon = " ",
                    title = "Git Status",
                    section = "terminal",
                    enabled = function()
                        local ok, snacks = pcall(require, "snacks")
                        return ok and snacks.git.get_root() ~= nil
                    end,
                    cmd = "git --no-pager status --short --branch --renames",
                    height = 10,
                    padding = 1,
                    ttl = 300,
                },
                {
                    icon = " ",
                    title = "Startup Info",
                    section = "startup",
                    padding = 1,
                    format = function()
                        local stats = require("lazy").stats()
                        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                        local os_info = vim.loop.os_uname()
                        local time = os.date("%R")
                        local git_info = ""
                        local ok, git = pcall(require, "snacks.git")
                        if ok then
                            local branch = git.get_branch()
                            if branch then
                                git_info = "  •   " .. branch
                            end
                        end
                        return {
                            { "󱐋 " .. ms .. "ms", hl = "SnacksDashboardFooter" },
                            { "  •    " .. os_info.machine, hl = "SnacksDashboardFooter" },
                            { "  •    " .. time, hl = "SnacksDashboardFooter" },
                            { git_info, hl = "SnacksDashboardFooter" },
                        }
                    end,
                },
            },
        },
    },
}

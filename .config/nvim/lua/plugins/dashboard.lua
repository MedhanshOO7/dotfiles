local pokemon_cache = vim.fn.stdpath("cache") .. "/pokemon.ansi"

return {
    "folke/snacks.nvim",
    opts = {
        dashboard = {
            enabled = true,
            pane_gap = 10,
            sections = {
                -- 1. Pokémon Header (Reserving space with padding and height)
                {
                    section = "terminal",
                    cmd = "pokemon-colorscripts -r --no-title > " .. pokemon_cache .. "; cat " .. pokemon_cache,
                    height = 22, -- Fixed height to reserve lines
                    padding = { top = 1, bottom = 12 }, -- User's fix: reserve lines after the image
                    ttl = 3600, -- Cache for 1 hour
                },
                -- 2. Navigation Keys
                { section = "keys", gap = 1, padding = 1 },
                -- 3. Workspace / Projects
                { section = "recent_files", limit = 5, padding = 1, title = "Recent Files", icon = " " },
                { section = "projects", limit = 5, padding = 1, title = "Projects", icon = " " },
                -- 4. Contextual Footer
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

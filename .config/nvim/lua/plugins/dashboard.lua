return {
    "folke/snacks.nvim",
    opts = {
        dashboard = {
            enabled = true,
            pane_gap = 4,
            preset = {
                header = [[
███╗   ██╗██╗   ██╗██╗███╗   ███╗
████╗  ██║██║   ██║██║████╗ ████║
██╔██╗ ██║██║   ██║██║██╔████╔██║
██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
                ]],
                keys = {
                    { icon = " ", key = "f", desc = "Find File", action = ":Telescope find_files" },
                    { icon = " ", key = "g", desc = "Find Text", action = ":Telescope live_grep" },
                    { icon = " ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
                    { icon = " ", key = "s", desc = "Restore Session", action = ":SessionRestore" },
                    { icon = " ", key = "e", desc = "Explorer", action = ":Neotree toggle filesystem reveal left" },
                    { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
                    { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                },
            },
            sections = {
                { section = "header" },
                { section = "keys", gap = 1, padding = 1 },
                { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", limit = 6, indent = 2, padding = 1 },
                { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
                {
                    pane = 2,
                    icon = " ",
                    title = "Git Snapshot",
                    section = "terminal",
                    enabled = function()
                        local ok, snacks = pcall(require, "snacks")
                        return ok and snacks.git.get_root() ~= nil
                    end,
                    cmd = "git --no-pager status --short --branch --renames",
                    height = 6,
                    ttl = 300,
                    indent = 3,
                    padding = 1,
                },
                { icon = " ", title = "Startup", section = "startup", padding = 1 },
            },
        },
    },
}

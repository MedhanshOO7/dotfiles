return {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        -- Only show the dashboard when Neovim starts "empty". If a file or a directory
        -- was requested explicitly, get out of the way and let the real workflow start.
        if vim.fn.argc(-1) > 0 then
            return
        end

        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        -- Keep the landing screen functional: a short identity header, then actions that
        -- actually start work instead of decorative shortcuts that duplicate other menus.
        dashboard.section.header.val = {
            "                                                     ",
            "  ███╗   ██╗██╗   ██╗██╗███╗   ███╗                  ",
            "  ████╗  ██║██║   ██║██║████╗ ████║                  ",
            "  ██╔██╗ ██║██║   ██║██║██╔████╔██║                  ",
            "  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║                  ",
            "  ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║                  ",
            "  ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝                  ",
            "                                                     ",
            "  Productivity first. Friction last.                 ",
            "                                                     ",
        }

        dashboard.section.buttons.val = {
            dashboard.button("f", "  Find file", "<cmd>Telescope find_files<CR>"),
            dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
            dashboard.button("p", "  Project grep", "<cmd>Telescope live_grep<CR>"),
            dashboard.button("s", "  Restore session", "<cmd>SessionRestore<CR>"),
            dashboard.button("t", "  Pick theme", "<cmd>ThemePicker<CR>"),
            dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
        }

        dashboard.section.header.opts.hl = "Type"
        dashboard.section.buttons.opts.hl = "Keyword"
        dashboard.section.footer.opts.hl = "Comment"
        dashboard.opts.opts.noautocmd = true

        dashboard.section.footer.val = function()
            local stats = require("lazy").stats()
            return string.format(
                "Loaded %d plugins in %.2fms",
                stats.count,
                stats.startuptime
            )
        end

        alpha.setup(dashboard.opts)
    end,
}

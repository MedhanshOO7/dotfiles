local pokemon_cache = vim.fn.stdpath("cache") .. "/pokemon.ansi"
local obsidian_vault = vim.fn.expand("~/Documents/Obsidian Vault")

-- A curated list of quotes for the 'Peak Potential' footer
local quotes = {
    "The best way to predict the future is to invent it.",
    "Stay hungry, stay foolish.",
    "First, solve the problem. Then, write the code.",
    "Experience is the name everyone gives to their mistakes.",
    "In order to be irreplaceable, one must always be different.",
    "Software is a great combination between artistry and engineering.",
    "Talk is cheap. Show me the code.",
    "Programming isn't about what you know; it's about what you can figure out.",
    "Simplicity is the soul of efficiency.",
    "Code is like humor. If you have to explain it, it’s bad.",
}

return {
    "folke/snacks.nvim",
    opts = {
        dashboard = {
            enabled = true,
            pane_gap = 10,
            sections = {
                -- ── CENTERED TOP HEADER (Pokémon Art) ────────────────────────
                {
                    section = "terminal",
                    cmd = "pokemon-colorscripts -r --no-title > " .. pokemon_cache .. "; cat " .. pokemon_cache,
                    height = 16,
                    padding = { 16, 0 }, -- { bottom, top } padding. Forces buffer lines to exist so the image doesn't overlap menus!
                    ttl = 3600,
                },

                -- ── LEFT PANE: NAVIGATION & HISTORY ───────────────────────
                {
                    pane = 1,
                    section = "keys",
                    gap = 1,
                    padding = 1,
                    header = "󰙅  COMMAND CENTER",
                },
                {
                    pane = 1,
                    section = "recent_files",
                    limit = 8,
                    padding = 1,
                    header = "  RECENT HISTORY",
                    icon = " ",
                    indent = 2,
                },

                -- ── RIGHT PANE: VISUALS & ANALYTICS ──────────────────────
                {
                    pane = 2,
                    section = "projects",
                    limit = 4,
                    padding = 1,
                    header = "  ACTIVE PROJECTS",
                    icon = "󰉋 ",
                    indent = 2,
                },
                {
                    pane = 2,
                    header = "󰠮  KNOWLEDGE BASE",
                    section = "recent_files",
                    cwd = obsidian_vault,
                    limit = 4,
                    padding = 1,
                    indent = 2,
                },
                {
                    pane = 2,
                    header = "  GIT ANALYTICS",
                    section = "terminal",
                    enabled = function()
                        local ok, snacks = pcall(require, "snacks")
                        return ok and snacks.git.get_root() ~= nil
                    end,
                    cmd = "git --no-pager status --short --branch --renames",
                    height = 6,
                    padding = 1,
                    ttl = 300,
                    indent = 2,
                },

                -- ── FULL WIDTH FOOTER ─────────────────────────────────────
                {
                    section = "startup",
                    padding = 2,
                    format = function()
                        local stats = require("lazy").stats()
                        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                        local os_info = vim.loop.os_uname()
                        local quote = quotes[math.random(#quotes)]
                        
                        return {
                            { "󱐋 " .. ms .. "ms  •  " .. stats.count .. " Plugins  •  " .. os_info.sysname .. " (" .. os_info.machine .. ")", hl = "SnacksDashboardFooter" },
                            { "  ", hl = "SnacksDashboardFooter" },
                            { "󰅖  " .. quote, hl = "SnacksDashboardFooter" },
                        }
                    end,
                },
            },
        },
    },
}

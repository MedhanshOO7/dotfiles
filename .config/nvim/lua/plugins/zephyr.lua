return {
    -- Zephyr / nRF Connect SDK integration
    -- Provides west build, flash, and menuconfig commands inside Neovim.

    -- Overseer templates for west commands
    {
        "stevearc/overseer.nvim",
        opts = function(_, opts)
            opts.templates = opts.templates or {}
            table.insert(opts.templates, {
                name = "west build",
                builder = function()
                    return {
                        cmd = { "west" },
                        args = { "build", "-b", vim.g.zephyr_board or "nrf52840dk/nrf52840", "-p", "auto" },
                        cwd = vim.fn.getcwd(),
                        components = { "default" },
                    }
                end,
                desc = "Build Zephyr project with west",
            })
            table.insert(opts.templates, {
                name = "west flash",
                builder = function()
                    return {
                        cmd = { "west" },
                        args = { "flash" },
                        cwd = vim.fn.getcwd(),
                        components = { "default" },
                    }
                end,
                desc = "Flash firmware to nRF board",
            })
        end,
    },

    -- Keybinds and utility commands
    {
        "folke/which-key.nvim",
        opts = function(_, opts)
            -- Register group in which-key
            local wk = require("which-key")
            wk.add({
                { "<leader>E", group = "Embedded / nRF" },
            })
        end,
    },

    -- Standalone plugin-less keybinds for west
    {
        dir = vim.fn.stdpath("config"),
        name = "zephyr-keybinds",
        lazy = false,
        config = function()
            -- Set default board (user can override with :ZephyrBoard)
            vim.g.zephyr_board = vim.g.zephyr_board or "nrf52840dk/nrf52840"

            local function west_cmd(args, title)
                local cmd = "west " .. args
                vim.notify("Running: " .. cmd, vim.log.levels.INFO, { title = title or "Zephyr" })
                vim.cmd("split | terminal " .. cmd)
            end

            -- Build
            vim.keymap.set("n", "<leader>Eb", function()
                west_cmd("build -b " .. vim.g.zephyr_board .. " -p auto", "West Build")
            end, { desc = "nRF: Build project" })

            -- Flash
            vim.keymap.set("n", "<leader>Ef", function()
                west_cmd("flash", "West Flash")
            end, { desc = "nRF: Flash firmware" })

            -- Menuconfig (interactive Kconfig editor)
            vim.keymap.set("n", "<leader>Em", function()
                west_cmd("build -t menuconfig", "Menuconfig")
            end, { desc = "nRF: Open menuconfig" })

            -- Clean build
            vim.keymap.set("n", "<leader>Ec", function()
                west_cmd("build -p always -b " .. vim.g.zephyr_board, "West Clean Build")
            end, { desc = "nRF: Clean build" })

            -- Set board command
            vim.api.nvim_create_user_command("ZephyrBoard", function(opts_cmd)
                vim.g.zephyr_board = opts_cmd.args
                vim.notify("Zephyr board set to: " .. vim.g.zephyr_board, vim.log.levels.INFO)
            end, {
                nargs = 1,
                desc = "Set the target Zephyr board (e.g., nrf52840dk/nrf52840)",
            })
        end,
    },
}

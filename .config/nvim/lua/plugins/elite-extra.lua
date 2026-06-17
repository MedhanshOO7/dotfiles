return {
    -- 1. Image.nvim (Kitty Power Flex)
    -- Renders images directly in Neovim buffers using the Kitty protocol.
    {
        "3rd/image.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {
            backend = "kitty",
            integrations = {
                markdown = {
                    enabled = true,
                    clear_in_insert_mode = false,
                    download_remote_images = true,
                    only_render_image_at_cursor = false,
                    filetypes = { "markdown", "vimwiki", "quarto" },
                },
                neorg = { enabled = true },
            },
            max_width = nil,
            max_height = nil,
            max_width_window_percentage = nil,
            max_height_window_percentage = 50,
            window_overlap_clear_enabled = false,
            window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
            editor_only_render_when_focused = false,
            tmux_show_only_in_active_window = false,
            hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" },
        },
    },

    -- 2. Tiny-Code-Action.nvim (Visual Refactoring Preview)
    -- Replaces the standard code action menu with a beautiful live diff preview.
    {
        "rachartier/tiny-code-action.nvim",
        dependencies = {
            {"nvim-lua/plenary.nvim"},
            {"nvim-telescope/telescope.nvim"},
        },
        event = "LspAttach",
        keys = {
            {
                "<leader>ca",
                function()
                    require("tiny-code-action").code_action()
                end,
                desc = "Code: Actions (visual preview)",
            },
        },
        opts = {
            backend = "delta", -- Use delta for pretty diffs if available, else standard
        },
    },

    -- 3. Neotest (The Ultimate IDE Feature)
    -- Professional testing framework integrated into the editor.
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            -- Adapters
            "nvim-neotest/neotest-python",
            "nvim-neotest/neotest-plenary",
            "haydenmeade/neotest-jest",
            "alfaix/neotest-gtest",
        },
        keys = {
            { "<leader>tr", function() require("neotest").run.run() end, desc = "Test: Run nearest" },
            { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test: Run file" },
            { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test: Toggle summary" },
            { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Test: Open output" },
            { "<leader>tp", function() require("neotest").output_panel.toggle() end, desc = "Test: Toggle output panel" },
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-python")({
                        dap = { adapter = "python" },
                    }),
                    require("neotest-plenary"),
                    require("neotest-jest"),
                    require("neotest-gtest"),
                },
                status = { virtual_text = true },
                output = { open_on_run = true },
                summary = {
                    enabled = true,
                    expand_errors = true,
                    follow = true,
                    mappings = {
                        expand = { "<CR>", "<2-LeftMouse>" },
                        run = "r",
                    },
                },
            })
        end,
    },
}

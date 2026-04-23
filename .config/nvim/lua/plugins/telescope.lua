return {
    'nvim-telescope/telescope.nvim',
    version = '*',
    cmd = "Telescope",
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")

        telescope.setup({
            defaults = {
                prompt_prefix = "  ",
                selection_caret = " ",
                path_display = { "truncate" },
                sorting_strategy = "ascending",
                layout_strategy = "horizontal",
                border = true,
                file_ignore_patterns = {
                    "%.git/",
                    "node_modules/",
                    "dist/",
                    "build/",
                },
                layout_config = {
                    prompt_position = "top",
                    width = 0.92,
                    height = 0.88,
                    horizontal = {
                        preview_width = 0.58,
                    },
                },
                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                    },
                    n = {
                        ["j"] = actions.move_selection_next,
                        ["k"] = actions.move_selection_previous,
                    },
                },
            },
            pickers = {
                find_files = {
                    hidden = true,
                    previewer = false,
                },
                oldfiles = {
                    previewer = false,
                },
            },
            extensions = {
                ["ui-select"] = require("telescope.themes").get_dropdown({
                    previewer = false,
                    initial_mode = "normal",
                }),
            },
        })

        pcall(telescope.load_extension, "fzf")
    end,
}

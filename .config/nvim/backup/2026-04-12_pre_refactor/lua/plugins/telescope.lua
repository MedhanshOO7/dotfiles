return {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
        local telescope = require("telescope")

        telescope.setup({
            defaults = {
                prompt_prefix = "  ",
                selection_caret = "  ",
                path_display = { "smart" },
                sorting_strategy = "ascending",
                layout_config = {
                    prompt_position = "top",
                },
            },
            pickers = {
                find_files = {
                    hidden = true,
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

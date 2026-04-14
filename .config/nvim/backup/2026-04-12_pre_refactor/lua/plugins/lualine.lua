return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "SmiteshP/nvim-navic",
    },
    config = function()
        local function navic_component()
            local ok, navic = pcall(require, "nvim-navic")
            if not ok or not navic.is_available() then
                return ""
            end

            return navic.get_location()
        end

        require("lualine").setup({
            options = {
                theme = "auto",
                globalstatus = true,
                section_separators = { left = "", right = "" },
                component_separators = { left = "│", right = "│" },
                disabled_filetypes = {
                    winbar = { "neo-tree", "Trouble", "toggleterm", "aerial" },
                },
            },
            sections = {
                lualine_a = {},
                lualine_b = { "branch", "diff" },
                lualine_c = {
                    {
                        "filename",
                        file_status = true,
                        path = 1,
                    },
                },
                lualine_x = {
                    {
                        "diagnostics",
                        sources = { "nvim_diagnostic" },
                        symbols = { error = " ", warn = " ", info = " ", hint = " " },
                    },
                    {
                        "lsp_status",
                        icon = "",
                        symbols = {
                            spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
                            done = "✓",
                            separator = " ",
                        },
                    },
                    "searchcount",
                    "filetype",
                },
                lualine_y = { "progress", "fileformat" },
                lualine_z = { "location" },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { "filename" },
                lualine_x = { "location" },
                lualine_y = {},
                lualine_z = {},
            },
            winbar = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {
                    {
                        "filename",
                        path = 1,
                        file_status = false,
                        newfile_status = false,
                    },
                    {
                        navic_component,
                        cond = function()
                            local ok, navic = pcall(require, "nvim-navic")
                            return ok and navic.is_available()
                        end,
                    },
                },
                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            },
            inactive_winbar = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {
                    {
                        "filename",
                        path = 1,
                        file_status = false,
                        newfile_status = false,
                    },
                },
                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            },
            extensions = { "neo-tree", "trouble", "quickfix", "toggleterm", "lazy", "mason" },
        })
    end,
}

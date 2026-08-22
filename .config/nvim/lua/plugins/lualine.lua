return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "SmiteshP/nvim-navic",
    },
    config = function()
        local lualine_group = vim.api.nvim_create_augroup("dynamic_lualine_theme", { clear = true })

        local function navic_component()
            local ok, navic = pcall(require, "nvim-navic")
            if not ok or not navic.is_available() then
                return ""
            end

            return navic.get_location()
        end

        local function macro_recording()
            local reg = vim.fn.reg_recording()
            if reg == "" then return "" end
            return "󰑋 REC @" .. reg
        end

        local function copilot_status()
            local ok, client = pcall(require, "copilot.client")
            if not ok then return "" end
            if client.is_disabled() then
                return "󰂭 "
            end
            return "󰚩 "
        end

        local function hl_hex(name, key, default)
            local ok, val = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
            if ok and val and val[key] then
                return string.format("#%06x", val[key])
            end
            return default
        end

        local function get_opaque_theme()
            local bg_dark = hl_hex("TabLineFill", "bg", hl_hex("StatusLine", "bg", "#181825"))
            local bg_surface = hl_hex("CursorLine", "bg", hl_hex("Pmenu", "bg", "#1e1e2e"))
            local fg_text = hl_hex("Normal", "fg", "#cdd6f4")
            local fg_muted = hl_hex("Comment", "fg", "#6c7086")

            local blue = hl_hex("Function", "fg", "#89b4fa")
            local green = hl_hex("String", "fg", "#a6e3a1")
            local yellow = hl_hex("DiagnosticWarn", "fg", "#f9e2af")
            local purple = hl_hex("Statement", "fg", "#cba6f7")
            local red = hl_hex("DiagnosticError", "fg", "#f38ba8")
            local cyan = hl_hex("Special", "fg", "#89dceb")

            return {
                normal = {
                    a = { fg = bg_dark, bg = blue, gui = "bold" },
                    b = { fg = fg_text, bg = bg_surface },
                    c = { fg = fg_text, bg = bg_dark },
                    x = { fg = fg_text, bg = bg_dark },
                    y = { fg = fg_text, bg = bg_surface },
                    z = { fg = bg_dark, bg = blue, gui = "bold" },
                },
                insert = {
                    a = { fg = bg_dark, bg = green, gui = "bold" },
                    b = { fg = fg_text, bg = bg_surface },
                    c = { fg = fg_text, bg = bg_dark },
                    x = { fg = fg_text, bg = bg_dark },
                    y = { fg = fg_text, bg = bg_surface },
                    z = { fg = bg_dark, bg = green, gui = "bold" },
                },
                visual = {
                    a = { fg = bg_dark, bg = purple, gui = "bold" },
                    b = { fg = fg_text, bg = bg_surface },
                    c = { fg = fg_text, bg = bg_dark },
                    x = { fg = fg_text, bg = bg_dark },
                    y = { fg = fg_text, bg = bg_surface },
                    z = { fg = bg_dark, bg = purple, gui = "bold" },
                },
                replace = {
                    a = { fg = bg_dark, bg = red, gui = "bold" },
                    b = { fg = fg_text, bg = bg_surface },
                    c = { fg = fg_text, bg = bg_dark },
                    x = { fg = fg_text, bg = bg_dark },
                    y = { fg = fg_text, bg = bg_surface },
                    z = { fg = bg_dark, bg = red, gui = "bold" },
                },
                command = {
                    a = { fg = bg_dark, bg = yellow, gui = "bold" },
                    b = { fg = fg_text, bg = bg_surface },
                    c = { fg = fg_text, bg = bg_dark },
                    x = { fg = fg_text, bg = bg_dark },
                    y = { fg = fg_text, bg = bg_surface },
                    z = { fg = bg_dark, bg = yellow, gui = "bold" },
                },
                inactive = {
                    a = { fg = fg_muted, bg = bg_surface },
                    b = { fg = fg_muted, bg = bg_surface },
                    c = { fg = fg_muted, bg = bg_dark },
                    x = { fg = fg_muted, bg = bg_dark },
                    y = { fg = fg_muted, bg = bg_surface },
                    z = { fg = fg_muted, bg = bg_surface },
                },
            }
        end

        local function apply()
            require("lualine").setup({
                options = {
                    theme = get_opaque_theme(),
                    globalstatus = true,
                    section_separators = { left = "", right = "" },
                    component_separators = { left = "", right = "" },
                    always_divide_middle = false,
                    disabled_filetypes = {
                        statusline = { "snacks_picker_input", "snacks_explorer", "noice", "nui", "notify", "prompt", "lazy", "mason" },
                        winbar = { "snacks_picker_input", "snacks_explorer", "noice", "nui", "notify", "prompt", "Trouble", "toggleterm", "aerial" },
                    },
                },
                sections = {
                    lualine_a = {
                        {
                            "mode",
                            separator = { left = "" },
                            padding = { left = 0, right = 2 },
                            fmt = function(value)
                                return value:sub(1, 1)
                            end,
                        },
                    },
                    lualine_b = { "branch", "diff" },
                    lualine_c = {
                        {
                            "filename",
                            file_status = true,
                            path = 1,
                        },
                    },
                    lualine_x = {
                        { macro_recording, color = { fg = "#f38ba8", gui = "bold" } },
                        { copilot_status, color = { fg = "#a6e3a1", gui = "bold" } },
                        {
                            "diagnostics",
                            sources = { "nvim_diagnostic" },
                            symbols = { error = " ", warn = " ", info = " ", hint = " " },
                        },
                        {
                            function()
                                local clients = vim.lsp.get_clients({ bufnr = 0 })
                                if #clients == 0 then
                                    return ""
                                end
                                local names = {}
                                for _, client in ipairs(clients) do
                                    table.insert(names, client.name)
                                end
                                return "  " .. table.concat(names, ", ")
                            end,
                            color = { fg = "#8aadf4", gui = "bold" },
                        },
                        "searchcount",
                        "filetype",
                    },
                    lualine_y = { "progress", "fileencoding" },
                    lualine_z = {
                        { "location", separator = { right = "" }, padding = { left = 2, right = 0 } },
                    },
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
                extensions = { "trouble", "quickfix", "toggleterm", "lazy", "mason" },
            })
        end

        apply()

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = lualine_group,
            callback = function()
                vim.schedule(apply)
            end,
        })
    end,
}

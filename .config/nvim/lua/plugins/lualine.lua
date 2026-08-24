return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local lualine_group = vim.api.nvim_create_augroup("dynamic_lualine_theme", { clear = true })

        local function macro_recording()
            local reg = vim.fn.reg_recording()
            if reg == "" then return "" end
            return "󰑋 REC @" .. reg
        end

        local function copilot_status()
            local ok, client = pcall(require, "copilot.client")
            if not ok then return "" end
            if client.is_disabled() then
                return "󰂭"
            end
            return "󰚩"
        end

        local function lsp_status()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if #clients == 0 then
                return ""
            end
            local names = {}
            for _, client in ipairs(clients) do
                table.insert(names, client.name)
            end
            return " " .. table.concat(names, ", ")
        end

        local function hl_hex(name, key, default)
            local ok, val = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
            if ok and val and val[key] then
                return string.format("#%06x", val[key])
            end
            return default
        end

        local function get_floating_theme()
            local bg_dark = "NONE"
            local bg_pill = hl_hex("CursorLine", "bg", hl_hex("Pmenu", "bg", "#1e1e2e"))
            local fg_text = hl_hex("Normal", "fg", "#cdd6f4")
            local fg_muted = hl_hex("Comment", "fg", "#6c7086")

            local blue = hl_hex("Function", "fg", "#89b4fa")
            local green = hl_hex("String", "fg", "#a6e3a1")
            local yellow = hl_hex("DiagnosticWarn", "fg", "#f9e2af")
            local purple = hl_hex("Statement", "fg", "#cba6f7")
            local red = hl_hex("DiagnosticError", "fg", "#f38ba8")

            return {
                normal = {
                    a = { fg = "#11111b", bg = blue, gui = "bold" },
                    b = { fg = fg_text, bg = bg_pill },
                    c = { fg = fg_text, bg = bg_dark },
                    x = { fg = fg_text, bg = bg_dark },
                    y = { fg = fg_text, bg = bg_pill },
                    z = { fg = "#11111b", bg = blue, gui = "bold" },
                },
                insert = {
                    a = { fg = "#11111b", bg = green, gui = "bold" },
                    b = { fg = fg_text, bg = bg_pill },
                    c = { fg = fg_text, bg = bg_dark },
                    x = { fg = fg_text, bg = bg_dark },
                    y = { fg = fg_text, bg = bg_pill },
                    z = { fg = "#11111b", bg = green, gui = "bold" },
                },
                visual = {
                    a = { fg = "#11111b", bg = purple, gui = "bold" },
                    b = { fg = fg_text, bg = bg_pill },
                    c = { fg = fg_text, bg = bg_dark },
                    x = { fg = fg_text, bg = bg_dark },
                    y = { fg = fg_text, bg = bg_pill },
                    z = { fg = "#11111b", bg = purple, gui = "bold" },
                },
                replace = {
                    a = { fg = "#11111b", bg = red, gui = "bold" },
                    b = { fg = fg_text, bg = bg_pill },
                    c = { fg = fg_text, bg = bg_dark },
                    x = { fg = fg_text, bg = bg_dark },
                    y = { fg = fg_text, bg = bg_pill },
                    z = { fg = "#11111b", bg = red, gui = "bold" },
                },
                command = {
                    a = { fg = "#11111b", bg = yellow, gui = "bold" },
                    b = { fg = fg_text, bg = bg_pill },
                    c = { fg = fg_text, bg = bg_dark },
                    x = { fg = fg_text, bg = bg_dark },
                    y = { fg = fg_text, bg = bg_pill },
                    z = { fg = "#11111b", bg = yellow, gui = "bold" },
                },
                inactive = {
                    a = { fg = fg_muted, bg = bg_pill },
                    b = { fg = fg_muted, bg = bg_pill },
                    c = { fg = fg_muted, bg = bg_dark },
                    x = { fg = fg_muted, bg = bg_dark },
                    y = { fg = fg_muted, bg = bg_pill },
                    z = { fg = fg_muted, bg = bg_pill },
                },
            }
        end

        local function apply()
            require("lualine").setup({
                options = {
                    theme = get_floating_theme(),
                    globalstatus = true,
                    section_separators = { left = "", right = "" },
                    component_separators = { left = "", right = "" },
                    always_divide_middle = true,
                    disabled_filetypes = {
                        statusline = { "snacks_picker_input", "snacks_explorer", "noice", "nui", "notify", "prompt", "lazy", "mason" },
                    },
                },
                sections = {
                    lualine_a = {
                        {
                            "mode",
                            separator = { left = "", right = "" },
                            padding = { left = 1, right = 1 },
                            fmt = function(mode_name)
                                local mode_map = {
                                    ["NORMAL"] = "NORMAL",
                                    ["O-PENDING"] = "OP",
                                    ["INSERT"] = "INSERT",
                                    ["VISUAL"] = "VISUAL",
                                    ["V-LINE"] = "V-LINE",
                                    ["V-BLOCK"] = "V-BLOCK",
                                    ["SELECT"] = "SELECT",
                                    ["S-LINE"] = "S-LINE",
                                    ["S-BLOCK"] = "S-BLOCK",
                                    ["REPLACE"] = "REPLACE",
                                    ["V-REPLACE"] = "V-REP",
                                    ["COMMAND"] = "COMMAND",
                                    ["EX"] = "EX",
                                    ["MORE"] = "MORE",
                                    ["CONFIRM"] = "CONFIRM",
                                    ["SHELL"] = "SHELL",
                                    ["TERMINAL"] = "TERM",
                                }
                                return mode_map[mode_name] or mode_name
                            end,
                        },
                    },
                    lualine_b = {
                        {
                            "branch",
                            icon = "",
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            "diff",
                            symbols = { added = " ", modified = " ", removed = " " },
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_c = {
                        {
                            "filename",
                            file_status = true,
                            path = 1,
                            symbols = {
                                modified = " ●",
                                readonly = " 󰌾",
                                unnamed = "[No Name]",
                                newfile = "[New]",
                            },
                        },
                    },
                    lualine_x = {
                        {
                            macro_recording,
                            color = { fg = "#f38ba8", gui = "bold" },
                            separator = { left = "", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            copilot_status,
                            color = { fg = "#a6e3a1", gui = "bold" },
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            "diagnostics",
                            sources = { "nvim_diagnostic" },
                            symbols = { error = " ", warn = " ", info = " ", hint = " " },
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            lsp_status,
                            color = { fg = "#89b4fa", gui = "bold" },
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_y = {
                        {
                            "filetype",
                            icon_only = false,
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_z = {
                        {
                            "location",
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
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

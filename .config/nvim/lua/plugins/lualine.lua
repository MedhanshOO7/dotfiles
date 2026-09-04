return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    cmd = "StatusStyle",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local lualine_group = vim.api.nvim_create_augroup("dynamic_lualine_theme", { clear = true })

        local function to_hex(value)
            if type(value) == "number" then
                return string.format("#%06x", value)
            end
            return value
        end

        local function hex_to_rgb(hex)
            hex = to_hex(hex)
            if type(hex) ~= "string" then hex = "#1e1e2e" end
            hex = hex:gsub("#", "")
            if hex == "" or hex:lower() == "none" then
                hex = "1e1e2e"
            elseif #hex == 3 then
                hex = hex:gsub(".", "%1%1")
            elseif #hex < 6 then
                hex = hex .. string.rep("0", 6 - #hex)
            elseif #hex > 6 then
                hex = hex:sub(1, 6)
            end
            local r = tonumber(hex:sub(1, 2), 16) or 30
            local g = tonumber(hex:sub(3, 4), 16) or 30
            local b = tonumber(hex:sub(5, 6), 16) or 46
            return r, g, b
        end

        local function blend(fg, bg, alpha)
            local fr, fg_green, fb = hex_to_rgb(fg)
            local br, bg_green, bb = hex_to_rgb(bg)
            alpha = math.max(0, math.min(alpha or 0, 1))
            local function channel(top, bottom)
                return math.floor((alpha * top) + ((1 - alpha) * bottom) + 0.5)
            end
            return string.format("#%02x%02x%02x", channel(fr, br), channel(fg_green, bg_green), channel(fb, bb))
        end

        local function macro_recording()
            local reg = vim.fn.reg_recording()
            if reg == "" then return "" end
            return "󰑋 REC @" .. reg
        end

        local copilot_c, copilot_s
        local function get_copilot_state()
            if not copilot_c then
                local ok, client = pcall(require, "copilot.client")
                if not ok then return "hidden" end
                copilot_c = client
            end
            if copilot_c.is_disabled() then
                return "disabled"
            end
            if copilot_c.startup_error then
                return "issue"
            end
            if not copilot_s then
                local status_ok, status = pcall(require, "copilot.status")
                if status_ok then copilot_s = status end
            end
            if copilot_s and copilot_s.data then
                local s = string.lower(copilot_s.data.status or "")
                if s == "error" or s == "warning" then
                    return "issue"
                end
            end
            if not copilot_c.get() then
                return "disabled"
            end
            return "ready"
        end

        local function copilot_status()
            local state = get_copilot_state()
            if state == "ready" then
                return "󰚩"
            elseif state == "disabled" then
                return ""
            elseif state == "issue" then
                return "󰚩 󰌾"
            end
            return ""
        end

        local function lsp_status()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if #clients == 0 then
                return ""
            end
            local names = {}
            for _, client in ipairs(clients) do
                if client.name ~= "copilot" then
                    table.insert(names, client.name)
                end
            end
            if #names == 0 then
                return ""
            end
            return " " .. table.concat(names, ", ")
        end

        local function python_venv()
            if vim.bo.filetype ~= "python" then
                return ""
            end
            local venv = vim.env.VIRTUAL_ENV
            if venv then
                local venv_name = vim.fn.fnamemodify(venv, ":t")
                return " " .. venv_name
            end
            return " system"
        end

        local function hl_hex(name, key, default)
            local ok, val = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
            if ok and val and val[key] then
                return string.format("#%06x", val[key])
            end
            return default
        end

        -- Dynamically extracts all palette colors from whichever theme is active
        local cached_palette = nil
        local function get_theme_palette()
            if cached_palette then return cached_palette end
            local normal_bg = hl_hex("Normal", "bg", hl_hex("NormalFloat", "bg", "#1e1e2e"))
            local normal_fg = hl_hex("Normal", "fg", hl_hex("NormalFloat", "fg", "#cdd6f4"))
            local comment   = hl_hex("Comment", "fg", "#6c7086")

            local blue      = hl_hex("Function", "fg", hl_hex("Directory", "fg", "#89b4fa"))
            local green     = hl_hex("String", "fg", hl_hex("DiagnosticOk", "fg", "#a6e3a1"))
            local yellow    = hl_hex("DiagnosticWarn", "fg", hl_hex("Constant", "fg", "#f9e2af"))
            local purple    = hl_hex("Statement", "fg", hl_hex("Keyword", "fg", "#cba6f7"))
            local red       = hl_hex("DiagnosticError", "fg", hl_hex("Error", "fg", "#f38ba8"))
            local cyan      = hl_hex("Type", "fg", hl_hex("Special", "fg", "#89dceb"))
            local teal      = hl_hex("SpecialChar", "fg", hl_hex("Special", "fg", "#94e2d5"))
            local lavender  = hl_hex("Identifier", "fg", hl_hex("PreProc", "fg", "#b4befe"))
            local peach     = hl_hex("DiagnosticWarn", "fg", hl_hex("Number", "fg", "#fab387"))

            cached_palette = {
                normal_bg = normal_bg,
                normal_fg = normal_fg,
                comment   = comment,
                blue      = blue,
                green     = green,
                yellow    = yellow,
                purple    = purple,
                red       = red,
                cyan      = cyan,
                teal      = teal,
                lavender  = lavender,
                peach     = peach,
            }
            return cached_palette
        end

        local function contrast_fg(bg_color)
            local p = get_theme_palette()
            local r, g, b = hex_to_rgb(bg_color)
            local lum = (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255
            if lum > 0.36 then
                return p.normal_bg ~= "NONE" and p.normal_bg or "#181825"
            else
                return p.normal_fg ~= "NONE" and p.normal_fg or "#cdd6f4"
            end
        end

        local styles = {
            { id = "nvchad", name = "1. NvChad Style (Solid Accent Ends, Clean Transparent Center)" },
            { id = "lazyvim", name = "2. LazyVim Style (Fully Transparent, Minimal Icon Accents)" },
            { id = "evil", name = "3. Evil Lualine / Doom (Studio Bar with Mode Pillar ▌)" },
            { id = "frosted", name = "4. TokyoNight Frosted (Translucent Glass Pills & Glowing Icons)" },
        }

        local function get_mode_color()
            local p = get_theme_palette()
            local mode = vim.fn.mode()
            if mode:match("^[iI]") then
                return p.green
            elseif mode:match("^[vV\22]") then
                return p.purple
            elseif mode:match("^[rR]") then
                return p.red
            elseif mode:match("^[cC]") then
                return p.yellow
            end
            return p.blue
        end

        local function get_theme_spec()
            local p = get_theme_palette()
            local bg_dark = "NONE"

            local norm_bg = blend(p.blue, p.normal_bg, 0.60)
            local ins_bg  = blend(p.green, p.normal_bg, 0.60)
            local vis_bg  = blend(p.purple, p.normal_bg, 0.60)
            local rep_bg  = blend(p.red, p.normal_bg, 0.60)
            local cmd_bg  = blend(p.yellow, p.normal_bg, 0.60)
            local inact_bg = blend(p.normal_fg, p.normal_bg, 0.15)

            return {
                normal = {
                    a = { fg = contrast_fg(norm_bg), bg = norm_bg, gui = "bold" },
                    b = { fg = p.normal_fg, bg = bg_dark },
                    c = { fg = p.normal_fg, bg = bg_dark },
                    x = { fg = p.normal_fg, bg = bg_dark },
                    y = { fg = p.normal_fg, bg = bg_dark },
                    z = { fg = contrast_fg(norm_bg), bg = norm_bg, gui = "bold" },
                },
                insert = {
                    a = { fg = contrast_fg(ins_bg), bg = ins_bg, gui = "bold" },
                    b = { fg = p.normal_fg, bg = bg_dark },
                    c = { fg = p.normal_fg, bg = bg_dark },
                    x = { fg = p.normal_fg, bg = bg_dark },
                    y = { fg = p.normal_fg, bg = bg_dark },
                    z = { fg = contrast_fg(ins_bg), bg = ins_bg, gui = "bold" },
                },
                visual = {
                    a = { fg = contrast_fg(vis_bg), bg = vis_bg, gui = "bold" },
                    b = { fg = p.normal_fg, bg = bg_dark },
                    c = { fg = p.normal_fg, bg = bg_dark },
                    x = { fg = p.normal_fg, bg = bg_dark },
                    y = { fg = p.normal_fg, bg = bg_dark },
                    z = { fg = contrast_fg(vis_bg), bg = vis_bg, gui = "bold" },
                },
                replace = {
                    a = { fg = contrast_fg(rep_bg), bg = rep_bg, gui = "bold" },
                    b = { fg = p.normal_fg, bg = bg_dark },
                    c = { fg = p.normal_fg, bg = bg_dark },
                    x = { fg = p.normal_fg, bg = bg_dark },
                    y = { fg = p.normal_fg, bg = bg_dark },
                    z = { fg = contrast_fg(rep_bg), bg = rep_bg, gui = "bold" },
                },
                command = {
                    a = { fg = contrast_fg(cmd_bg), bg = cmd_bg, gui = "bold" },
                    b = { fg = p.normal_fg, bg = bg_dark },
                    c = { fg = p.normal_fg, bg = bg_dark },
                    x = { fg = p.normal_fg, bg = bg_dark },
                    y = { fg = p.normal_fg, bg = bg_dark },
                    z = { fg = contrast_fg(cmd_bg), bg = cmd_bg, gui = "bold" },
                },
                inactive = {
                    a = { fg = p.comment, bg = inact_bg },
                    b = { fg = p.comment, bg = inact_bg },
                    c = { fg = p.comment, bg = bg_dark },
                    x = { fg = p.comment, bg = bg_dark },
                    y = { fg = p.comment, bg = inact_bg },
                    z = { fg = p.comment, bg = inact_bg },
                },
            }
        end

        local mode_icons = {
            ["NORMAL"]    = "󰮯 ",
            ["INSERT"]    = "󰏫 ",
            ["VISUAL"]    = "󰒉 ",
            ["V-LINE"]    = "󰒉 ",
            ["V-BLOCK"]   = "󰒉 ",
            ["SELECT"]    = "󰒉 ",
            ["S-LINE"]    = "󰒉 ",
            ["S-BLOCK"]   = "󰒉 ",
            ["REPLACE"]   = "󰛔 ",
            ["V-REPLACE"] = "󰛔 ",
            ["COMMAND"]   = "󰘳 ",
            ["EX"]        = "󰘳 ",
            ["MORE"]      = "󰘳 ",
            ["CONFIRM"]   = "󰘳 ",
            ["TERMINAL"]  = "󰆍 ",
        }

        local function format_mode(str)
            local icon = mode_icons[str] or "󰮯 "
            return icon .. str
        end

        local function apply()
            local p = get_theme_palette()
            local style = vim.g.lualine_color_style or "frosted"
            local theme = get_theme_spec()

            vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })

            local sections = {}

            if style == "evil" or style == "3" then
                sections = {
                    lualine_a = {
                        {
                            function() return "▌" end,
                            color = function() return { fg = get_mode_color(), bg = "NONE" } end,
                            padding = { left = 0, right = 0 },
                        },
                        {
                            "mode",
                            color = function() return { fg = get_mode_color(), bg = "NONE", gui = "bold" } end,
                            fmt = format_mode,
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_b = {
                        {
                            "branch",
                            icon = "",
                            color = { fg = p.purple, bg = "NONE", gui = "bold" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            "diff",
                            symbols = { added = " ", modified = " ", removed = " " },
                            color = { bg = "NONE" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_c = {},
                    lualine_x = {
                        {
                            macro_recording,
                            color = { fg = p.red, bg = "NONE", gui = "bold" },
                        },
                        {
                            "diagnostics",
                            sources = { "nvim_diagnostic" },
                            symbols = { error = " ", warn = " ", info = " ", hint = " " },
                            color = { bg = "NONE" },
                        },
                        {
                            copilot_status,
                            color = function()
                                local state = get_copilot_state()
                                local fg = p.teal
                                if state == "disabled" then fg = p.comment
                                elseif state == "issue" then fg = p.yellow end
                                return { fg = fg, bg = "NONE", gui = "bold" }
                            end,
                            padding = { left = 1, right = 1 },
                        },
                        {
                            lsp_status,
                            color = { fg = p.cyan, bg = "NONE" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_y = {
                        {
                            python_venv,
                            color = { fg = p.green, bg = "NONE" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            "filetype",
                            color = { fg = p.yellow, bg = "NONE" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_z = {
                        {
                            "location",
                            icon = "",
                            color = { fg = p.blue, bg = "NONE", gui = "bold" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            function() return "▐" end,
                            color = function() return { fg = get_mode_color(), bg = "NONE" } end,
                            padding = { left = 0, right = 0 },
                        },
                    },
                }
            elseif style == "lazyvim" or style == "2" then
                sections = {
                    lualine_a = {
                        {
                            "mode",
                            separator = { left = "", right = "" },
                            color = function()
                                local m_color = get_mode_color()
                                local bg = blend(m_color, p.normal_bg, 0.40)
                                return { fg = contrast_fg(bg), bg = bg, gui = "bold" }
                            end,
                            fmt = format_mode,
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_b = {
                        {
                            "branch",
                            icon = "",
                            color = { fg = p.comment, bg = "NONE", gui = "bold" },
                        },
                        {
                            "diff",
                            symbols = { added = " ", modified = " ", removed = " " },
                            color = { bg = "NONE" },
                        },
                    },
                    lualine_c = {},
                    lualine_x = {
                        {
                            macro_recording,
                            color = { fg = p.red, bg = "NONE", gui = "bold" },
                        },
                        {
                            "diagnostics",
                            sources = { "nvim_diagnostic" },
                            symbols = { error = " ", warn = " ", info = " ", hint = " " },
                            color = { bg = "NONE" },
                        },
                        {
                            copilot_status,
                            color = function()
                                local state = get_copilot_state()
                                local fg = p.teal
                                if state == "disabled" then fg = p.comment
                                elseif state == "issue" then fg = p.yellow end
                                return { fg = fg, bg = "NONE", gui = "bold" }
                            end,
                        },
                        {
                            lsp_status,
                            color = { fg = p.comment, bg = "NONE" },
                        },
                    },
                    lualine_y = {
                        {
                            python_venv,
                            color = { fg = p.green, bg = "NONE" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            "filetype",
                            icon_only = false,
                            color = { fg = p.comment, bg = "NONE" },
                        },
                    },
                    lualine_z = {
                        {
                            "location",
                            icon = "",
                            separator = { left = " ", right = "" },
                            color = function()
                                local bg = blend(p.normal_fg, p.normal_bg, 0.15)
                                return { fg = p.normal_fg, bg = bg, gui = "bold" }
                            end,
                            padding = { left = 1, right = 1 },
                        },
                    },
                }
            elseif style == "frosted" or style == "4" then
                local function frost(accent_color)
                    local bg = blend(accent_color, p.normal_bg, 0.22)
                    return { fg = accent_color, bg = bg, gui = "bold" }
                end
                sections = {
                    lualine_a = {
                        {
                            "mode",
                            separator = { left = "", right = "" },
                            color = function()
                                local m_color = get_mode_color()
                                local bg = blend(m_color, p.normal_bg, 0.35)
                                return { fg = m_color, bg = bg, gui = "bold" }
                            end,
                            fmt = format_mode,
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_b = {
                        {
                            "branch",
                            icon = "",
                            color = function() return frost(p.green) end,
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            "diff",
                            symbols = { added = " ", modified = " ", removed = " " },
                            color = function() return frost(p.purple) end,
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_c = {},
                    lualine_x = {
                        {
                            macro_recording,
                            color = function() return frost(p.red) end,
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            copilot_status,
                            color = function()
                                local state = get_copilot_state()
                                local fg = p.teal
                                if state == "disabled" then fg = p.comment
                                elseif state == "issue" then fg = p.yellow end
                                return frost(fg)
                            end,
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            "diagnostics",
                            sources = { "nvim_diagnostic" },
                            symbols = { error = " ", warn = " ", info = " ", hint = " " },
                            color = function() return frost(p.peach) end,
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            lsp_status,
                            color = function() return frost(p.lavender) end,
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_y = {
                        {
                            python_venv,
                            color = { fg = p.green, bg = "NONE" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            "filetype",
                            icon_only = false,
                            color = function() return frost(p.cyan) end,
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_z = {
                        {
                            "location",
                            icon = "",
                            color = function()
                                local m_color = get_mode_color()
                                return frost(m_color)
                            end,
                            separator = { left = " ", right = "" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                }
            else -- "nvchad" or "1" (Default)
                sections = {
                    lualine_a = {
                        {
                            "mode",
                            separator = { left = "", right = "" },
                            color = function()
                                local m_color = get_mode_color()
                                local bg = blend(m_color, p.normal_bg, 0.60)
                                return { fg = contrast_fg(bg), bg = bg, gui = "bold" }
                            end,
                            fmt = format_mode,
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_b = {
                        {
                            "branch",
                            icon = "",
                            color = { fg = p.peach, bg = "NONE", gui = "bold" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            "diff",
                            symbols = { added = " ", modified = " ", removed = " " },
                            color = { bg = "NONE" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_c = {},
                    lualine_x = {
                        {
                            macro_recording,
                            color = { fg = p.red, bg = "NONE", gui = "bold" },
                        },
                        {
                            "diagnostics",
                            sources = { "nvim_diagnostic" },
                            symbols = { error = " ", warn = " ", info = " ", hint = " " },
                            color = { bg = "NONE" },
                        },
                        {
                            copilot_status,
                            color = function()
                                local state = get_copilot_state()
                                local fg = p.teal
                                if state == "disabled" then fg = p.comment
                                elseif state == "issue" then fg = p.yellow end
                                return { fg = fg, bg = "NONE", gui = "bold" }
                            end,
                            padding = { left = 1, right = 1 },
                        },
                        {
                            lsp_status,
                            color = { fg = p.lavender, bg = "NONE" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_y = {
                        {
                            python_venv,
                            color = { fg = p.green, bg = "NONE" },
                            padding = { left = 1, right = 1 },
                        },
                        {
                            "filetype",
                            icon_only = false,
                            color = { fg = p.cyan, bg = "NONE", gui = "bold" },
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_z = {
                        {
                            "location",
                            icon = "",
                            separator = { left = " ", right = "" },
                            color = function()
                                local m_color = get_mode_color()
                                local bg = blend(m_color, p.normal_bg, 0.60)
                                return { fg = contrast_fg(bg), bg = bg, gui = "bold" }
                            end,
                            padding = { left = 1, right = 1 },
                        },
                    },
                }
            end

            require("lualine").setup({
                options = {
                    theme = theme,
                    globalstatus = true,
                    section_separators = { left = "", right = "" },
                    component_separators = { left = "", right = "" },
                    always_divide_middle = true,
                    disabled_filetypes = {
                        statusline = { "snacks_explorer", "noice", "nui", "notify", "lazy", "mason" },
                    },
                },
                sections = sections,
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {},
                    lualine_x = { "location" },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = { "trouble", "quickfix", "toggleterm", "lazy", "mason" },
            })
        end

        local function set_statusline_style(style_id)
            if not style_id or style_id == "" then
                local opts = {}
                for _, s in ipairs(styles) do
                    table.insert(opts, s.name)
                end
                vim.ui.select(opts, { prompt = "Choose Statusline & Header Style:" }, function(choice)
                    if choice then
                        for _, s in ipairs(styles) do
                            if choice == s.name then
                                vim.g.lualine_color_style = s.id
                                apply()
                                pcall(function() require("incline").refresh() end)
                                vim.notify("Statusline Style: " .. s.id:upper(), vim.log.levels.INFO, { title = "Statusline Style" })
                                break
                            end
                        end
                    end
                end)
                return
            end

            if style_id == "next" then
                local cur = vim.g.lualine_color_style or "frosted"
                local next_idx = 1
                for i, s in ipairs(styles) do
                    if s.id == cur then
                        next_idx = (i % #styles) + 1
                        break
                    end
                end
                vim.g.lualine_color_style = styles[next_idx].id
                apply()
                pcall(function() require("incline").refresh() end)
                vim.notify("Statusline Style: " .. styles[next_idx].id:upper(), vim.log.levels.INFO, { title = "Statusline Style" })
                return
            end

            for _, s in ipairs(styles) do
                if style_id == s.id or style_id == tostring(s.id) or tostring(style_id) == s.id:sub(1, 1) then
                    vim.g.lualine_color_style = s.id
                    apply()
                    pcall(function() require("incline").refresh() end)
                    vim.notify("Statusline Style: " .. s.id:upper(), vim.log.levels.INFO, { title = "Statusline Style" })
                    return
                end
            end

            vim.g.lualine_color_style = style_id
            apply()
            pcall(function() require("incline").refresh() end)
        end

        vim.api.nvim_create_user_command("StatusStyle", function(opts)
            set_statusline_style(opts.args)
        end, {
            nargs = "?",
            complete = function()
                return { "nvchad", "lazyvim", "evil", "frosted", "next" }
            end,
            desc = "Switch Statusline and Incline header style",
        })

        apply()

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = lualine_group,
            pattern = "*",
            callback = function()
                cached_palette = nil
                apply()
            end,
        })
    end,
}

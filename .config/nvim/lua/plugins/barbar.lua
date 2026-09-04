return {
    "romgrk/barbar.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    init = function()
        vim.g.barbar_auto_setup = false
    end,
    config = function()
        local function hl_hex(name, key)
            local ok, val = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
            if ok and val and val[key] then
                return string.format("#%06x", val[key])
            end
        end

        local function first_hl(groups, key)
            for _, g in ipairs(groups) do
                local v = hl_hex(g, key)
                if v then
                    return v
                end
            end
        end

        local function hex_to_rgb(hex)
            if not hex or hex == "NONE" or not hex:match("^#?%x%x%x%x%x%x$") then return 0, 0, 0 end
            hex = hex:gsub("#", "")
            return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
        end

        local function blend(fg, bg, alpha)
            local r1, g1, b1 = hex_to_rgb(fg)
            local r2, g2, b2 = hex_to_rgb(bg)
            local r = math.floor(r1 * alpha + r2 * (1 - alpha))
            local g = math.floor(g1 * alpha + g2 * (1 - alpha))
            local b = math.floor(b1 * alpha + b2 * (1 - alpha))
            return string.format("#%02x%02x%02x", r, g, b)
        end

        local function apply()
            local base_bg = first_hl({ "Normal", "NormalFloat" }, "bg") or "#1a1b26"
            local text = first_hl({ "Normal" }, "fg") or "#c0caf5"
            local muted = first_hl({ "Comment", "LineNr" }, "fg") or "#565f89"
            local subtext = first_hl({ "NonText", "StatusLineNC" }, "fg") or "#7aa2f7"
            local accent = first_hl({ "Function", "Special", "Identifier" }, "fg") or "#7aa2f7"
            local error_fg = first_hl({ "DiagnosticError", "ErrorMsg" }, "fg") or "#f7768e"
            local warn_fg = first_hl({ "DiagnosticWarn", "WarningMsg" }, "fg") or "#e0af68"
            local modified = first_hl({ "DiagnosticWarn", "String" }, "fg") or "#ff9e64"

            local fill_bg = "NONE"
            local bg_surface = base_bg ~= "NONE" and base_bg or "#16161e"
            local curr_bg = blend(accent, bg_surface, 0.26)
            local inact_bg = blend(text, bg_surface, 0.08)
            local vis_bg = blend(accent, bg_surface, 0.16)

            local set = vim.api.nvim_set_hl

            -- Active buffer tab (Rounded frosted pill)
            set(0, "BufferCurrent", { fg = accent, bg = curr_bg, bold = true })
            set(0, "BufferCurrentIndex", { fg = accent, bg = curr_bg, bold = true })
            set(0, "BufferCurrentMod", { fg = modified, bg = curr_bg, bold = true })
            set(0, "BufferCurrentSign", { fg = curr_bg, bg = fill_bg })
            set(0, "BufferCurrentSignRight", { fg = curr_bg, bg = fill_bg })
            set(0, "BufferCurrentTarget", { fg = error_fg, bg = curr_bg, bold = true })
            set(0, "BufferCurrentIcon", { fg = accent, bg = curr_bg })
            set(0, "BufferCurrentBtn", { fg = accent, bg = curr_bg })
            set(0, "BufferCurrentPin", { fg = accent, bg = curr_bg })
            set(0, "BufferCurrentPinBtn", { fg = accent, bg = curr_bg })
            set(0, "BufferCurrentERROR", { fg = error_fg, bg = curr_bg, bold = true })
            set(0, "BufferCurrentWARN", { fg = warn_fg, bg = curr_bg, bold = true })
            set(0, "BufferCurrentINFO", { fg = accent, bg = curr_bg, bold = true })
            set(0, "BufferCurrentHINT", { fg = subtext, bg = curr_bg, bold = true })

            -- Inactive buffer tabs (Subtle translucent glass pills)
            set(0, "BufferInactive", { fg = muted, bg = inact_bg })
            set(0, "BufferInactiveIndex", { fg = muted, bg = inact_bg })
            set(0, "BufferInactiveMod", { fg = modified, bg = inact_bg })
            set(0, "BufferInactiveSign", { fg = inact_bg, bg = fill_bg })
            set(0, "BufferInactiveSignRight", { fg = inact_bg, bg = fill_bg })
            set(0, "BufferInactiveTarget", { fg = error_fg, bg = inact_bg })
            set(0, "BufferInactiveIcon", { fg = muted, bg = inact_bg })
            set(0, "BufferInactiveBtn", { fg = muted, bg = inact_bg })
            set(0, "BufferInactivePin", { fg = muted, bg = inact_bg })
            set(0, "BufferInactivePinBtn", { fg = muted, bg = inact_bg })
            set(0, "BufferInactiveERROR", { fg = error_fg, bg = inact_bg })
            set(0, "BufferInactiveWARN", { fg = warn_fg, bg = inact_bg })
            set(0, "BufferInactiveINFO", { fg = muted, bg = inact_bg })
            set(0, "BufferInactiveHINT", { fg = muted, bg = inact_bg })

            -- Visible in other split
            set(0, "BufferVisible", { fg = subtext, bg = vis_bg })
            set(0, "BufferVisibleIndex", { fg = subtext, bg = vis_bg })
            set(0, "BufferVisibleMod", { fg = modified, bg = vis_bg })
            set(0, "BufferVisibleSign", { fg = vis_bg, bg = fill_bg })
            set(0, "BufferVisibleSignRight", { fg = vis_bg, bg = fill_bg })
            set(0, "BufferVisibleTarget", { fg = error_fg, bg = vis_bg })
            set(0, "BufferVisibleIcon", { fg = subtext, bg = vis_bg })
            set(0, "BufferVisibleBtn", { fg = subtext, bg = vis_bg })
            set(0, "BufferVisiblePin", { fg = subtext, bg = vis_bg })
            set(0, "BufferVisiblePinBtn", { fg = subtext, bg = vis_bg })
            set(0, "BufferVisibleERROR", { fg = error_fg, bg = vis_bg })
            set(0, "BufferVisibleWARN", { fg = warn_fg, bg = vis_bg })
            set(0, "BufferVisibleINFO", { fg = subtext, bg = vis_bg })
            set(0, "BufferVisibleHINT", { fg = subtext, bg = vis_bg })

            -- Transparent tabline background (100% zero color bleeding)
            set(0, "BufferTabpageFill", { bg = fill_bg })
            set(0, "BufferTabpages", { fg = accent, bg = fill_bg, bold = true })
            set(0, "BufferTabpagesSep", { fg = muted, bg = fill_bg })
            set(0, "BufferOffset", { bg = fill_bg })
            set(0, "BufferScrollArrow", { fg = accent, bg = fill_bg, bold = true })
            set(0, "TabLine", { bg = fill_bg })
            set(0, "TabLineFill", { bg = fill_bg })
            set(0, "TabLineSel", { fg = accent, bg = curr_bg, bold = true })
        end

        require("barbar").setup({
            animation = true,
            auto_hide = false,
            tabpages = false,
            clickable = true,
            focus_on_close = "left",
            maximum_padding = 1,
            minimum_padding = 1,
            maximum_length = 25,
            minimum_length = 0,
            insert_at_end = true,
            semantic_letters = true,
            sort = { ignore_case = true },

            icons = {
                buffer_index = false,
                buffer_number = false,
                button = "",
                modified = { button = "●" },
                filetype = { enabled = true, custom_colors = false },
                separator = { left = "", right = "" },
                separator_at_end = true,
                pinned = { button = "", filename = true },
                diagnostics = {
                    [vim.diagnostic.severity.ERROR] = { enabled = true, icon = "  " },
                    [vim.diagnostic.severity.WARN]  = { enabled = true, icon = "  " },
                    [vim.diagnostic.severity.INFO]  = { enabled = false },
                    [vim.diagnostic.severity.HINT]  = { enabled = false },
                },
                gitsigns = {
                    added = { enabled = false },
                    changed = { enabled = false },
                    deleted = { enabled = false },
                },
                current = { buffer_index = false },
                inactive = { button = "" },
                visible = { modified = { buffer_number = false } },
            },

            sidebar_filetypes = {
                ["snacks_picker_input"] = { event = "BufWipeout", text = "  Explorer", align = "left" },
                ["snacks_explorer"]     = { event = "BufWipeout", text = "  Explorer", align = "left" },
                ["oil"]                 = { event = "BufWipeout", text = "  Oil Browser", align = "left" },
                ["mini.files"]           = { event = "BufWipeout", text = "  Mini Files", align = "left" },
            },

            highlight_alternate = false,
            highlight_inactive_file_icons = false,
            highlight_visible = true,
        })

        apply()

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("barbar_dynamic_hl", { clear = true }),
            pattern = "*",
            callback = function()
                apply()
                vim.schedule(apply)
            end,
        })

        local map = vim.keymap.set
        local opts = { noremap = true, silent = true }

        for i = 1, 9 do
            map("n", "<C-" .. i .. ">", "<Cmd>BufferGoto " .. i .. "<CR>", opts)
        end

        map("n", "<C-0>", "<Cmd>BufferLast<CR>", opts)
        map("n", "<C-,>", "<Cmd>BufferPrevious<CR>", opts)
        map("n", "<C-.>", "<Cmd>BufferNext<CR>", opts)
        map("n", "<C-<>", "<Cmd>BufferMovePrevious<CR>", opts)
        map("n", "<C->>", "<Cmd>BufferMoveNext<CR>", opts)
    end,
}

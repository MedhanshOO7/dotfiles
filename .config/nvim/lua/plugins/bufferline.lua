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

        local function apply()
            local base_bg = first_hl({ "Normal", "NormalFloat" }, "bg") or "#1e1e2e"
            local mantle = first_hl({ "TabLineFill", "StatusLine" }, "bg") or "#181825"
            local text = first_hl({ "Normal" }, "fg") or "#cdd6f4"
            local muted = first_hl({ "Comment", "LineNr" }, "fg") or "#6c7086"
            local subtext = first_hl({ "NonText", "StatusLineNC" }, "fg") or "#a6adc8"
            local accent = first_hl({ "Function", "Special", "Identifier" }, "fg") or "#b4befe"
            local error_fg = first_hl({ "DiagnosticError", "ErrorMsg" }, "fg") or "#f38ba8"
            local warn_fg = first_hl({ "DiagnosticWarn", "WarningMsg" }, "fg") or "#fab387"
            local modified = first_hl({ "DiagnosticWarn", "String" }, "fg") or "#f9e2af"

            -- inactive clearly darker than active
            local inactive_bg = mantle

            local set = vim.api.nvim_set_hl

            -- active — underdouble for thick line, | prefix via sign
            set(0, "BufferCurrent", { fg = text, bg = base_bg, bold = true, underdouble = true, sp = accent })
            set(0, "BufferCurrentIndex", { fg = accent, bg = base_bg, underdouble = true, sp = accent })
            set(0, "BufferCurrentMod", { fg = modified, bg = base_bg, bold = true, underdouble = true, sp = accent })
            set(0, "BufferCurrentSign", { fg = accent, bg = base_bg, underdouble = true, sp = accent })
            set(0, "BufferCurrentTarget", { fg = error_fg, bg = base_bg, bold = true })
            set(0, "BufferCurrentIcon", { bg = base_bg, underdouble = true, sp = accent })
            set(0, "BufferCurrentERROR", { fg = error_fg, bg = base_bg, underdouble = true, sp = accent })
            set(0, "BufferCurrentWARN", { fg = warn_fg, bg = base_bg, underdouble = true, sp = accent })

            -- inactive — clearly dimmed
            set(0, "BufferInactive", { fg = muted, bg = inactive_bg })
            set(0, "BufferInactiveIndex", { fg = muted, bg = inactive_bg })
            set(0, "BufferInactiveMod", { fg = modified, bg = inactive_bg })
            set(0, "BufferInactiveSign", { fg = muted, bg = inactive_bg })
            set(0, "BufferInactiveTarget", { fg = error_fg, bg = inactive_bg })
            set(0, "BufferInactiveIcon", { bg = inactive_bg })
            set(0, "BufferInactiveERROR", { fg = error_fg, bg = inactive_bg })
            set(0, "BufferInactiveWARN", { fg = warn_fg, bg = inactive_bg })

            -- visible (split)
            set(0, "BufferVisible", { fg = subtext, bg = inactive_bg })
            set(0, "BufferVisibleIndex", { fg = subtext, bg = inactive_bg })
            set(0, "BufferVisibleMod", { fg = modified, bg = inactive_bg })
            set(0, "BufferVisibleSign", { fg = subtext, bg = inactive_bg })
            set(0, "BufferVisibleTarget", { fg = error_fg, bg = inactive_bg })
            set(0, "BufferVisibleERROR", { fg = error_fg, bg = inactive_bg })
            set(0, "BufferVisibleWARN", { fg = warn_fg, bg = inactive_bg })

            set(0, "BufferTabpageFill", { bg = mantle })
            set(0, "BufferTabpages", { fg = accent, bg = mantle, bold = true })
        end

        require("barbar").setup({
            animation = true,
            auto_hide = 1,
            tabpages = false,
            clickable = true,
            focus_on_close = "left",
            maximum_padding = 2,
            minimum_padding = 1,
            maximum_length = 25,
            minimum_length = 0,
            insert_at_end = true,
            semantic_letters = true,
            sort = { ignore_case = true },

            icons = {
                buffer_index = false,
                buffer_number = false,
                button = false,
                modified = { button = "●" },
                filetype = { enabled = true, custom_colors = false },
                -- | left indicator + clean right
                separator = { left = "▎", right = " " },
                separator_at_end = false,
                pinned = { button = "", filename = true },
                diagnostics = {
                    [vim.diagnostic.severity.ERROR] = { enabled = true, icon = " " },
                    [vim.diagnostic.severity.WARN] = { enabled = true, icon = " " },
                    [vim.diagnostic.severity.INFO] = { enabled = false },
                    [vim.diagnostic.severity.HINT] = { enabled = false },
                },
                gitsigns = {
                    added = { enabled = false },
                    changed = { enabled = false },
                    deleted = { enabled = false },
                },
                current = { buffer_index = false },
                inactive = { button = false },
                visible = { modified = { buffer_number = false } },
            },

            sidebar_filetypes = {
                ["neo-tree"] = {
                    event = "BufWipeout",
                    text = "  Explorer",
                    align = "left",
                },
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
        map("n", "<C-w>", "<Cmd>BufferClose<CR>", opts)
        map("n", "<C-W>", "<Cmd>BufferCloseAllButCurrent<CR>", opts)
        map("n", "<C-p>", "<Cmd>BufferPin<CR>", opts)
        map("n", "<leader>bp", "<Cmd>BufferPick<CR>", opts)
        map("n", "<leader>bd", "<Cmd>BufferPickDelete<CR>", opts)
    end,
}

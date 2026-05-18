local M = {}

local state_file = vim.fn.stdpath("state") .. "/theme.json"

-- Keep the theme list curated. Every entry here should be something worth cycling to,
-- not just every colorscheme installed in the runtime.
M.dark_themes = {
    "tokyonight",
    "tokyonight-night",
    "tokyonight-storm",
    "tokyonight-moon",
    "vscode",
    "catppuccin-macchiato",
    "catppuccin-mocha",
    "catppuccin-frappe",
    "dracula",
    "gruvbox",
    "everforest",
    "rose-pine",
    "rose-pine-moon",
    "kanagawa-wave",
    "kanagawa-dragon",
    "nightfox",
    "duskfox",
    "nordfox",
    "terafox",
    "carbonfox",
    "pywal",
    "cyberdream",
    "material",
    "gruvbox-material",
    "nord",
    "melange",
    "monokai",
    "onedark",
    "oxocarbon",
}

M.light_themes = {
    "tokyonight-day",
    "catppuccin-latte",
    "rose-pine-dawn",
    "kanagawa-lotus",
    "dayfox",
    "dawnfox",
}

M.themes = {}
for _, t in ipairs(M.dark_themes) do table.insert(M.themes, t) end
for _, t in ipairs(M.light_themes) do table.insert(M.themes, t) end

M.default_theme = "tokyonight"
M.default_transparency = false

M.theme_aliases = {
    catppuccin = "catppuccin-macchiato",
    dracula = "dracula",
    everforest = "everforest",
    gruvbox = "gruvbox",
    kanagawa = "kanagawa-wave",
    mellow = "tokyonight",
    ["rose-pine"] = "rose-pine",
    vscode = "vscode",
    material = "material",
    nord = "nord",
}

local nightfox_themes = {
    dayfox = true,
    nightfox = true,
    duskfox = true,
    nordfox = true,
    terafox = true,
    carbonfox = true,
    dawnfox = true,
}

-- Highlight APIs return integer RGB values. The helpers below normalize everything to
-- hex strings so the chrome layer can blend colors consistently across themes.
local function to_hex(value)
    if type(value) == "number" then
        return string.format("#%06x", value)
    end

    return value
end

local function hex_to_rgb(hex)
    hex = to_hex(hex)

    if type(hex) ~= "string" then
        hex = "#000000"
    end

    hex = hex:gsub("#", "")

    if hex == "" or hex:lower() == "none" then
        hex = "000000"
    elseif #hex == 3 then
        hex = hex:gsub(".", "%1%1")
    elseif #hex < 6 then
        hex = hex .. string.rep("0", 6 - #hex)
    elseif #hex > 6 then
        hex = hex:sub(1, 6)
    end

    local r = tonumber(hex:sub(1, 2), 16) or 0
    local g = tonumber(hex:sub(3, 4), 16) or 0
    local b = tonumber(hex:sub(5, 6), 16) or 0
    return r, g, b
end

local function blend(fg, bg, alpha)
    local fr, fg_green, fb = hex_to_rgb(fg)
    local br, bg_green, bb = hex_to_rgb(bg)
    alpha = math.max(0, math.min(alpha or 0, 1))

    local function channel(top, bottom)
        return math.floor((alpha * top) + ((1 - alpha) * bottom) + 0.5)
    end

    return string.format(
        "#%02x%02x%02x",
        channel(fr, br),
        channel(fg_green, bg_green),
        channel(fb, bb)
    )
end

-- Glass Effect configuration
-- When transparency is enabled, floating windows receive a subtle background
-- to create a "frosted glass" look against the terminal's background.
local function get_glass_bg(normal_bg, normal_fg, transparent)
    if not transparent then
        -- Default subtle blend for opaque mode
        return blend(normal_fg, normal_bg, 0.06)
    end
    -- In transparent mode, we use a very dark, slightly opaque color
    -- This works best if the terminal (Kitty) has blur enabled.
    return blend("#000000", normal_bg, 0.4)
end

local function hl_hex(name, key, fallback)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok and hl and hl[key] then
        return to_hex(hl[key])
    end

    return fallback
end

local function current_index()
    local active = vim.g.preferred_theme or M.default_theme

    for index, name in ipairs(M.themes) do
        if name == active then
            return index
        end
    end

    return 1
end

local function read_state()
    local file = io.open(state_file, "r")
    if not file then
        return nil
    end

    local content = file:read("*a")
    file:close()

    if not content or content == "" then
        return nil
    end

    local ok, data = pcall(vim.json.decode, content)
    if ok and type(data) == "table" then
        return data
    end

    return nil
end

local function write_state(theme, transparent)
    vim.fn.mkdir(vim.fn.fnamemodify(state_file, ":h"), "p")

    local file = io.open(state_file, "w")
    if not file then
        vim.notify("Could not persist the theme settings", vim.log.levels.WARN)
        return
    end

    file:write(vim.json.encode({
        theme = theme,
        transparent = transparent,
    }))
    file:close()
end

-- Some themes do not fully clear plugin windows when transparency changes, so this
-- explicitly removes backgrounds from the editor surfaces that matter most.
local function set_transparent_highlights(enabled)
    local normal_bg = enabled and "none" or nil

    local groups = {
        "Normal",
        "NormalNC",
        "NormalFloat",
        "EndOfBuffer",
        "SignColumn",
        "NeoTreeNormal",
        "NeoTreeNormalNC",
        "StatusLine",
        "StatusLineNC",
        "FloatBorder",
        "TelescopeNormal",
        "TelescopeBorder",
        "TelescopePromptNormal",
        "TelescopePromptBorder",
        "TelescopeResultsNormal",
        "TelescopeResultsBorder",
        "TelescopePreviewNormal",
        "TelescopePreviewBorder",
        "WinSeparator",
    }

    for _, group in ipairs(groups) do
        vim.api.nvim_set_hl(0, group, { bg = normal_bg })
    end
end

-- This is the final polish layer that keeps all plugin windows visually coherent
-- after the base colorscheme loads.
local function apply_editor_chrome(transparent)
    local normal_bg = hl_hex("Normal", "bg", "#24273a")
    local normal_fg = hl_hex("Normal", "fg", "#cad3f5")
    local comment = hl_hex("Comment", "fg", "#6e738d")
    local accent = hl_hex("Function", "fg", hl_hex("Identifier", "fg", "#8aadf4"))
    local accent_alt = hl_hex("Statement", "fg", "#c6a0f6")
    local success = hl_hex("String", "fg", "#a6da95")
    local warning = hl_hex("DiagnosticWarn", "fg", "#eed49f")
    local danger = hl_hex("DiagnosticError", "fg", "#ed8796")

    local float_bg = get_glass_bg(normal_bg, normal_fg, transparent)
    local sidebar_bg = transparent and "NONE" or blend(normal_fg, normal_bg, 0.04)
    local accent_bg = transparent and "NONE" or blend(accent, normal_bg, 0.12)
    local soft_edge = blend(comment, normal_bg, 0.45)

    local highlights = {
        -- ── Editor chrome ─────────────────────────────────────────────────────
        CursorLine = { bg = transparent and "NONE" or blend(accent, normal_bg, 0.07) },
        CursorLineNr = { fg = accent, bold = true },
        LineNr = { fg = blend(comment, normal_bg, 0.85) },
        Visual = { bg = blend(accent_alt, normal_bg, 0.20) },
        Search = { fg = normal_fg, bg = blend(warning, normal_bg, 0.26) },
        IncSearch = { fg = normal_fg, bg = blend(danger, normal_bg, 0.30) },
        CurSearch = { fg = normal_fg, bg = blend(danger, normal_bg, 0.30), bold = true },
        StatusLine = { fg = normal_fg, bg = sidebar_bg },
        StatusLineNC = { fg = comment, bg = sidebar_bg },

        -- ── Completion menu ────────────────────────────────────────────────────
        Pmenu = { fg = normal_fg, bg = float_bg },
        PmenuSel = { fg = normal_fg, bg = blend(accent, normal_bg, 0.20), bold = true },
        PmenuSbar = { bg = blend(comment, normal_bg, 0.18) },
        PmenuThumb = { bg = blend(accent, normal_bg, 0.42) },

        -- ── Floating windows ──────────────────────────────────────────────────
        NormalFloat = { fg = normal_fg, bg = float_bg },
        FloatBorder = { fg = blend(accent, normal_bg, 0.80), bg = float_bg },
        FloatTitle = { fg = accent, bg = float_bg, bold = true },
        WinSeparator = { fg = soft_edge, bg = transparent and "NONE" or normal_bg },

        -- ── Neo-tree ──────────────────────────────────────────────────────────
        NeoTreeNormal = { fg = normal_fg, bg = sidebar_bg },
        NeoTreeNormalNC = { fg = normal_fg, bg = sidebar_bg },
        NeoTreeFloatBorder = { fg = blend(accent, normal_bg, 0.80), bg = sidebar_bg },
        NeoTreeWinSeparator = { fg = soft_edge, bg = transparent and "NONE" or normal_bg },

        -- ── Bufferline / tabline ──────────────────────────────────────────────
        BufferLineFill = { bg = sidebar_bg },
        TabLineFill = { bg = sidebar_bg },

        -- ── Telescope ─────────────────────────────────────────────────────────
        TelescopeNormal = { fg = normal_fg, bg = float_bg },
        TelescopeBorder = { fg = soft_edge, bg = float_bg },
        TelescopePromptNormal = { fg = normal_fg, bg = accent_bg },
        TelescopePromptBorder = { fg = blend(accent, normal_bg, 0.85), bg = accent_bg },
        TelescopePromptTitle = { fg = normal_bg, bg = accent, bold = true },
        TelescopePreviewTitle = { fg = normal_bg, bg = success, bold = true },
        TelescopeResultsTitle = { fg = normal_bg, bg = accent_alt, bold = true },

        -- ── Trouble ───────────────────────────────────────────────────────────
        TroubleNormal = { fg = normal_fg, bg = float_bg },
        TroubleNormalNC = { fg = normal_fg, bg = float_bg },
        TroublePreview = { bg = float_bg },
        TroubleIndent = { fg = blend(comment, normal_bg, 0.75) },
        TroublePos = { fg = comment },

        -- ── Notify ────────────────────────────────────────────────────────────
        NotifyBackground = { bg = float_bg },

        -- ── Indent blankline ──────────────────────────────────────────────────
        IblIndent = { fg = blend(comment, normal_bg, 0.35) },
        IblScope = { fg = blend(accent, normal_bg, 0.75) },

        -- ── Render-markdown ───────────────────────────────────────────────────
        Headline1Bg = { fg = normal_fg, bg = blend(danger, normal_bg, 0.18), bold = true },
        Headline2Bg = { fg = normal_fg, bg = blend(success, normal_bg, 0.18), bold = true },
        Headline3Bg = { fg = normal_fg, bg = blend(accent, normal_bg, 0.18), bold = true },
        Headline4Bg = { fg = normal_fg, bg = blend(warning, normal_bg, 0.18), bold = true },
        Headline5Bg = { fg = normal_fg, bg = blend(accent_alt, normal_bg, 0.18), bold = true },
        Headline6Bg = { fg = normal_fg, bg = blend(comment, normal_bg, 0.24), bold = true },
        Headline1Fg = { fg = danger, bold = true },
        Headline2Fg = { fg = success, bold = true },
        Headline3Fg = { fg = accent, bold = true },
        Headline4Fg = { fg = warning, bold = true },
        Headline5Fg = { fg = accent_alt, bold = true },
        Headline6Fg = { fg = comment, bold = true },
        RenderMarkdownCode = { bg = float_bg },
        RenderMarkdownBullet = { fg = accent_alt },
        RenderMarkdownUnchecked = { fg = warning },
        RenderMarkdownChecked = { fg = success },

        -- ── Gitsigns ──────────────────────────────────────────────────────────
        GitSignsAdd = { fg = success },
        GitSignsChange = { fg = accent },
        GitSignsDelete = { fg = danger },

        -- ── DAP UI ────────────────────────────────────────────────────────────
        DapUIScope = { fg = accent },
        DapUIType = { fg = accent_alt },
        DapUIValue = { fg = normal_fg },
        DapUIFrameName = { fg = normal_fg },
        DapUIThread = { fg = success },
        DapUIWatchesValue = { fg = success },
        DapUIBreakpointsCurrentLine = { fg = accent, bold = true },
        DapUIBreakpointsLine = { fg = warning },
        DapUIBreakpointsInfo = { fg = success },
        DapUINormalNC = { bg = float_bg },
        DapUINormal = { fg = normal_fg, bg = float_bg },
        DapUIFloatBorder = { fg = blend(accent, normal_bg, 0.80), bg = float_bg },

        -- ── Toggleterm ────────────────────────────────────────────────────────
        ToggleTerm = { fg = normal_fg, bg = float_bg },
        ToggleTermBorder = { fg = soft_edge, bg = float_bg },
        ToggleTermNormal = { fg = normal_fg, bg = float_bg },

        -- ── Noice ─────────────────────────────────────────────────────────────
        NoiceCmdline = { fg = normal_fg, bg = float_bg },
        NoiceCmdlineIcon = { fg = accent },
        NoiceCmdlineIconSearch = { fg = warning },
        NoiceCmdlinePopup = { fg = normal_fg, bg = float_bg },
        NoiceCmdlinePopupBorder = { fg = blend(accent, normal_bg, 0.80), bg = float_bg },
        NoicePopup = { fg = normal_fg, bg = float_bg },
        NoicePopupBorder = { fg = soft_edge, bg = float_bg },
        NoiceConfirm = { fg = normal_fg, bg = float_bg },
        NoiceConfirmBorder = { fg = blend(accent, normal_bg, 0.80), bg = float_bg },

        -- ── Which-key ─────────────────────────────────────────────────────────
        WhichKey = { fg = accent },
        WhichKeyGroup = { fg = accent_alt },
        WhichKeyDesc = { fg = normal_fg },
        WhichKeyBorder = { fg = soft_edge, bg = float_bg },
        WhichKeyNormal = { fg = normal_fg, bg = float_bg },
        WhichKeySeparator = { fg = comment },
        WhichKeyValue = { fg = comment },

        -- ── Snacks ───────────────────────────────────────────────────────────
        SnacksNormal = { fg = normal_fg, bg = float_bg },
        SnacksNormalNC = { fg = normal_fg, bg = float_bg },
        SnacksPicker = { fg = normal_fg, bg = float_bg },
        SnacksPickerBorder = { fg = soft_edge, bg = float_bg },
        SnacksPickerTitle = { fg = normal_bg, bg = accent, bold = true },
        SnacksInputNormal = { fg = normal_fg, bg = float_bg },
        SnacksInputBorder = { fg = blend(accent, normal_bg, 0.80), bg = float_bg },
        SnacksIndent = { fg = blend(comment, normal_bg, 0.32) },
        SnacksIndentScope = { fg = blend(accent, normal_bg, 0.82), bold = true },
        SnacksDashboardHeader = { fg = accent, bold = true },
        SnacksDashboardDesc = { fg = normal_fg },
        SnacksDashboardKey = { fg = accent_alt, bold = true },
        SnacksDashboardDir = { fg = comment },
        SnacksDashboardFooter = { fg = comment },

        -- ── Neogit ────────────────────────────────────────────────────────────
        NeogitBranch = { fg = accent },
        NeogitRemote = { fg = accent_alt },
        NeogitHunkHeader = { fg = normal_fg, bg = blend(accent, normal_bg, 0.12) },
        NeogitHunkHeaderHighlight = { fg = normal_fg, bg = blend(accent, normal_bg, 0.20), bold = true },
        NeogitDiffAdd = { fg = success, bg = blend(success, normal_bg, 0.10) },
        NeogitDiffDelete = { fg = danger, bg = blend(danger, normal_bg, 0.10) },
        NeogitDiffContext = { fg = normal_fg, bg = float_bg },
        NeogitDiffContextHighlight = { fg = normal_fg, bg = blend(accent, normal_bg, 0.07) },

        -- ── Fidget / progress chrome ────────────────────────────────────────
        FidgetTitle = { fg = accent, bold = true },
        FidgetTask = { fg = normal_fg },
        FidgetNormal = { fg = normal_fg, bg = float_bg },

        -- ── Alpha (dashboard) ─────────────────────────────────────────────────
        AlphaHeader = { fg = accent },
        AlphaButtons = { fg = accent_alt },
        AlphaShortcut = { fg = warning },
        AlphaFooter = { fg = comment },

        -- ── Window labels ────────────────────────────────────────────────────
        InclineNormal = { fg = normal_fg, bg = blend(accent, normal_bg, 0.14) },
        InclineNormalNC = { fg = comment, bg = blend(comment, normal_bg, 0.12) },

        -- ── Aerial ────────────────────────────────────────────────────────────
        AerialLine = { bg = blend(accent, normal_bg, 0.12) },
        AerialGuide = { fg = blend(comment, normal_bg, 0.45) },
        AerialNormal = { fg = normal_fg, bg = sidebar_bg },

        -- ── Overseer ──────────────────────────────────────────────────────────
        OverseerTaskBorder = { fg = soft_edge, bg = float_bg },
        OverseerOutput = { fg = normal_fg, bg = float_bg },
        OverseerComponent = { fg = accent_alt },
        OverseerTask = { fg = normal_fg },
        OverseerTaskNumber = { fg = accent },

        -- ── Todo-comments ─────────────────────────────────────────────────────
        TodoBgTODO = { fg = normal_bg, bg = accent, bold = true },
        TodoBgFIX = { fg = normal_bg, bg = danger, bold = true },
        TodoBgWARN = { fg = normal_bg, bg = warning, bold = true },
        TodoBgNOTE = { fg = normal_bg, bg = success, bold = true },
        TodoBgHACK = { fg = normal_bg, bg = accent_alt, bold = true },
        TodoFgTODO = { fg = accent },
        TodoFgFIX = { fg = danger },
        TodoFgWARN = { fg = warning },
        TodoFgNOTE = { fg = success },
        TodoFgHACK = { fg = accent_alt },

        -- ── Zen-mode / Twilight ───────────────────────────────────────────────
        ZenBg = { bg = transparent and "NONE" or normal_bg },
        Twilight = { fg = blend(comment, normal_bg, 0.60) },

        -- ── Grug-far ──────────────────────────────────────────────────────────
        GrugFarInputLabel = { fg = accent },
        GrugFarInputPlaceholder = { fg = comment },
        GrugFarResultsMatch = { fg = normal_fg, bg = blend(warning, normal_bg, 0.26) },
        GrugFarResultsLineNo = { fg = comment },
        GrugFarResultsHeader = { fg = accent, bold = true },

        -- ── nvim-ufo (folding) ────────────────────────────────────────────────
        UfoFoldedFg = { fg = normal_fg },
        UfoFoldedBg = { bg = blend(accent, normal_bg, 0.10) },
        UfoCursorFoldedLine = { bg = blend(accent, normal_bg, 0.14), bold = true },
    }

    for group, value in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, value)
    end
end

local function apply_catppuccin(theme, transparent)
    local flavour = theme:gsub("^catppuccin%-?", "")
    if flavour == "" then
        flavour = "mocha"
    end

    require("catppuccin").setup({
        flavour = flavour,
        transparent_background = transparent,
        term_colors = true,
        integrations = {
            aerial = true,
            bufferline = true,
            cmp = true,
            gitsigns = true,
            neotree = true,
            noice = true,
            notify = true,
            render_markdown = true,
            telescope = true,
            treesitter = true,
            which_key = true,
        },
    })

    local ok = pcall(vim.cmd.colorscheme, "catppuccin")
    if not ok then
        vim.cmd.colorscheme("catppuccin-nvim")
    end
end

local function apply_rose_pine(theme, transparent)
    local variant = theme == "rose-pine" and "main" or theme:match("^rose%-pine%-(.+)$") or "main"

    require("rose-pine").setup({
        variant = variant,
        dark_variant = "main",
        disable_background = transparent,
        disable_float_background = transparent,
        disable_italics = true,
    })

    vim.cmd.colorscheme("rose-pine")
end

local function apply_kanagawa(theme, transparent)
    local variant = theme:match("^kanagawa%-(.+)$") or "wave"

    require("kanagawa").setup({
        theme = variant,
        transparent = transparent,
        commentStyle = { italic = false },
        keywordStyle = { italic = false },
        statementStyle = { bold = false },
    })

    vim.cmd.colorscheme("kanagawa")
end

local function apply_nightfox(theme, transparent)
    require("nightfox").setup({
        options = {
            transparent = transparent,
        },
    })

    vim.cmd.colorscheme(theme)
end

-- Apply the requested theme first, then re-style the surrounding UI so plugin windows
-- look intentional instead of inheriting whatever defaults the colorscheme shipped with.
local function apply_theme(theme, transparent)
    if theme:match("^catppuccin") then
        apply_catppuccin(theme, transparent)
        set_transparent_highlights(transparent)
        apply_editor_chrome(transparent)
        return true
    end

    if theme:match("^rose%-pine") then
        apply_rose_pine(theme, transparent)
        set_transparent_highlights(transparent)
        apply_editor_chrome(transparent)
        return true
    end

    if theme:match("^kanagawa") then
        apply_kanagawa(theme, transparent)
        set_transparent_highlights(transparent)
        apply_editor_chrome(transparent)
        return true
    end

    if nightfox_themes[theme] then
        apply_nightfox(theme, transparent)
        set_transparent_highlights(transparent)
        apply_editor_chrome(transparent)
        return true
    end

    if theme == "material" then
        vim.g.material_style = "ocean"
    elseif theme == "monokai" then
        -- Standard monokai setup
    elseif theme == "onedark" then
        require("onedarkpro").setup({
            options = { transparency = transparent }
        })
    elseif theme == "oxocarbon" then
        -- oxocarbon doesn't have a setup, just a colorscheme
    elseif theme == "gruvbox-material" then
        vim.g.gruvbox_material_background = "hard"
        vim.g.gruvbox_material_transparent_background = transparent and 1 or 0
    end

    if theme:match("^tokyonight") then
        vim.g.tokyonight_transparent = transparent
    elseif theme == "gruvbox" then
        vim.g.gruvbox_transparent_bg = transparent and 1 or 0
    elseif theme == "dracula" then
        vim.g.dracula_transparent_bg = transparent
    end

    local ok, err = pcall(vim.cmd.colorscheme, theme)
    if not ok then
        vim.notify("Could not load theme " .. theme .. ": " .. err, vim.log.levels.ERROR)
        return false
    end

    set_transparent_highlights(transparent)
    apply_editor_chrome(transparent)
    return true
end

function M.apply(name)
    local transparent = vim.g.preferred_transparent
    if transparent == nil then
        transparent = M.default_transparency
    end

    if not vim.tbl_contains(M.themes, name) then
        vim.notify("Theme not available: " .. name, vim.log.levels.WARN)
        return
    end

    if not apply_theme(name, transparent) then
        return
    end

    vim.g.preferred_theme = name
    write_state(name, transparent)
    vim.notify("Theme switched to " .. name)
end

function M.toggle_transparency()
    local theme = vim.g.preferred_theme or M.default_theme
    local transparent = not vim.g.preferred_transparent

    if not apply_theme(theme, transparent) then
        return
    end

    vim.g.preferred_transparent = transparent
    write_state(theme, transparent)
    vim.notify(transparent and "Transparency is on" or "Transparency is off")
end

function M.select()
    vim.ui.select({ "Dark Themes", "Light Themes" }, {
        prompt = "Select Category",
    }, function(category)
        if not category then return end

        local theme_list = category == "Dark Themes" and M.dark_themes or M.light_themes
        
        vim.ui.select(theme_list, {
            prompt = "Choose " .. category:lower(),
            format_item = function(item)
                if item == M.default_theme then
                    return item .. " (default)"
                end
                return item
            end,
        }, function(choice)
            if choice then
                M.apply(choice)
            end
        end)
    end)
end

function M.cycle(step)
    local index = current_index()
    local next_index = ((index - 1 + step) % #M.themes) + 1
    M.apply(M.themes[next_index])
end

function M.setup()
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("theme_editor_chrome", { clear = true }),
        callback = function()
            apply_editor_chrome(vim.g.preferred_transparent == true)
        end,
    })

    -- Re-apply after NeoTree buffer opens (it resets its own highlights on FileType)
    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("theme_neotree_chrome", { clear = true }),
        pattern = "neo-tree",
        callback = function()
            apply_editor_chrome(vim.g.preferred_transparent == true)
        end,
    })

    -- Re-apply when focusing back into a NeoTree window
    vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("theme_neotree_reenter", { clear = true }),
        pattern = "*",
        callback = function()
            if vim.bo.filetype == "neo-tree" then
                apply_editor_chrome(vim.g.preferred_transparent == true)
            end
        end,
    })

    vim.api.nvim_create_user_command("ThemePicker", function()
        M.select()
    end, { desc = "Pick a colorscheme" })

    vim.api.nvim_create_user_command("ThemeNext", function()
        M.cycle(1)
    end, { desc = "Switch to the next colorscheme" })

    vim.api.nvim_create_user_command("ThemePrev", function()
        M.cycle(-1)
    end, { desc = "Switch to the previous colorscheme" })

    vim.api.nvim_create_user_command("ThemeTransparencyToggle", function()
        M.toggle_transparency()
    end, { desc = "Turn transparency on or off" })

    local saved = read_state()
    local theme = saved and saved.theme or M.default_theme
    local transparent = saved and saved.transparent

    theme = M.theme_aliases[theme] or theme

    if transparent == nil then
        transparent = M.default_transparency
    end

    vim.g.preferred_transparent = transparent

    if vim.tbl_contains(M.themes, theme) then
        apply_theme(theme, transparent)
        vim.g.preferred_theme = theme
    else
        apply_theme(M.default_theme, transparent)
        vim.g.preferred_theme = M.default_theme
    end
end

return M

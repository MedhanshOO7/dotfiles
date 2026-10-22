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
    "matugen",
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

M.default_theme = "catppuccin-macchiato"
M.default_transparency = true

M.theme_aliases = {
    catppuccin = "catppuccin-macchiato",
    dracula = "dracula",
    everforest = "everforest",
    gruvbox = "gruvbox",
    kanagawa = "kanagawa-wave",
    mellow = "mellow",
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
    if transparent then
        return "NONE"
    end
    return blend(normal_fg, normal_bg, 0.06)
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

-- Explicitly removes backgrounds from all editor surfaces when transparency is enabled.
-- Preserves existing foreground colors and attributes instead of blanking them out.
local function set_transparent_highlights(enabled)
    if not enabled then
        return
    end

    local transparent_groups = {
        "Normal",
        "NormalNC",
        "SignColumn",
        "LineNr",
        "CursorLineNr",
        "EndOfBuffer",
        "FoldColumn",
        "Folded",
        "StatusLine",
        "StatusLineNC",
        "WinBar",
        "WinBarNC",
        "WinSeparator",
        "VertSplit",
        "FloatBorder",
        "FloatTitle",
        "FloatFooter",
        "NormalFloat",
        "SnacksNormal",
        "SnacksNormalNC",
        "SnacksPicker",
        "SnacksPickerList",
        "SnacksPickerInput",
        "SnacksPickerBox",
        "SnacksPickerPreview",
        "SnacksPickerBorder",
        "SnacksPickerBoxBorder",
        "SnacksPickerInputBorder",
        "SnacksPickerListBorder",
        "SnacksPickerPreviewBorder",
        "SnacksInputNormal",
        "SnacksInputBorder",
        "SnacksInputTitle",
        "SnacksBackdrop",
        "SnacksDashboardNormal",
        "NoiceCmdline",
        "NoiceCmdlinePopup",
        "NoiceCmdlinePopupBorder",
        "NoicePopup",
        "NoicePopupBorder",
        "NoiceConfirm",
        "NoiceConfirmBorder",
        "NoicePopupmenu",
        "NoicePopupmenuBorder",
        "NotifyBackground",
        "NotifyBorder",
        "ToggleTerm",
        "ToggleTermNormal",
        "ToggleTermBorder",
        "TroubleNormal",
        "TroubleNormalNC",
        "TroublePreview",
        "WhichKey",
        "WhichKeyNormal",
        "WhichKeyBorder",
        "AerialNormal",
        "DapUINormal",
        "DapUINormalNC",
        "DapUIFloatBorder",
        "DropBarMenuNormalFloat",
        "DropBarMenuFloatBorder",
        "ZenBg",
    }

    for _, group in ipairs(transparent_groups) do
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
        if ok and hl then
            hl.bg = "NONE"
            pcall(vim.api.nvim_set_hl, 0, group, hl)
        else
            pcall(vim.api.nvim_set_hl, 0, group, { bg = "NONE" })
        end
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

    -- Matugen accents only apply to the matugen theme; every other theme keeps
    -- the accents of its own palette.
    local matugen_active = vim.g.preferred_theme == "matugen"
    package.loaded["matugen-colors"] = nil
    local ok_matugen, matugen = false, nil
    if matugen_active then
        ok_matugen, matugen = pcall(require, "matugen-colors")
    end
    if ok_matugen and type(matugen) == "table" then
        accent = matugen.primary or accent
        accent_alt = matugen.secondary or accent_alt
        danger = matugen.error or danger
        if not transparent and matugen.surface then
            normal_bg = blend(matugen.surface, normal_bg, 0.6)
        end
    end

    local float_bg = transparent and "NONE" or get_glass_bg(normal_bg, normal_fg, transparent)
    local float_border = blend(accent, normal_bg, 0.60)
    local sidebar_bg = transparent and "NONE" or blend(normal_fg, normal_bg, 0.04)
    local soft_edge = blend(comment, normal_bg, 0.60)

    local highlights = {
        -- ── Editor chrome ─────────────────────────────────────────────────────
        Normal = { fg = normal_fg, bg = transparent and "NONE" or normal_bg },
        NormalNC = { fg = normal_fg, bg = transparent and "NONE" or normal_bg },
        CursorLine = { bg = transparent and "NONE" or blend(accent, normal_bg, 0.07) },
        CursorLineNr = { fg = accent, bg = "NONE", bold = true },
        LineNr = { fg = blend(comment, normal_bg, 0.85), bg = "NONE" },
        SignColumn = { bg = "NONE" },
        EndOfBuffer = { fg = comment, bg = "NONE" },
        Visual = { bg = blend(accent_alt, normal_bg, 0.20) },
        Search = { fg = normal_fg, bg = blend(warning, normal_bg, 0.26) },
        IncSearch = { fg = normal_fg, bg = blend(danger, normal_bg, 0.30) },
        CurSearch = { fg = normal_fg, bg = blend(danger, normal_bg, 0.30), bold = true },
        StatusLine = { fg = normal_fg, bg = "NONE" },
        StatusLineNC = { fg = comment, bg = "NONE" },

        -- ── Completion menu & AI Ghost Text ────────────────────────────────────
        Pmenu = { fg = normal_fg, bg = float_bg },
        PmenuSel = { fg = normal_fg, bg = blend(accent, normal_bg, 0.20), bold = true },
        PmenuSbar = { bg = blend(comment, normal_bg, 0.18) },
        PmenuThumb = { bg = blend(accent, normal_bg, 0.42) },
        CopilotSuggestion = { fg = blend(comment, normal_bg, 0.65), italic = true },
        CopilotAnnotation = { fg = blend(comment, normal_bg, 0.60), italic = true },

        -- ── Floating windows ──────────────────────────────────────────────────
        NormalFloat = { fg = normal_fg, bg = float_bg },
        FloatBorder = { fg = float_border, bg = "NONE" },
        FloatTitle = { fg = accent, bg = "NONE", bold = true },
        FloatFooter = { fg = comment, bg = "NONE" },
        WinSeparator = { fg = soft_edge, bg = "NONE" },

        TabLineFill = { bg = sidebar_bg },

        -- ── Trouble ───────────────────────────────────────────────────────────
        TroubleNormal = { fg = normal_fg, bg = float_bg },
        TroubleNormalNC = { fg = normal_fg, bg = float_bg },
        TroublePreview = { bg = float_bg },
        TroubleIndent = { fg = blend(comment, normal_bg, 0.75) },
        TroublePos = { fg = comment },

        -- ── Notify ────────────────────────────────────────────────────────────
        NotifyBackground = { bg = float_bg },
        NotifyBorder = { fg = float_border, bg = float_bg },

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
        RenderMarkdownCodeInline = { bg = float_bg },
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
        DapUIFloatBorder = { fg = float_border, bg = float_bg },

        -- ── Toggleterm ────────────────────────────────────────────────────────
        ToggleTerm = { fg = normal_fg, bg = float_bg },
        ToggleTermBorder = { fg = float_border, bg = float_bg },
        ToggleTermNormal = { fg = normal_fg, bg = float_bg },

        -- ── Noice ─────────────────────────────────────────────────────────────
        NoiceCmdline = { fg = normal_fg, bg = float_bg },
        NoiceCmdlineIcon = { fg = accent },
        NoiceCmdlineIconSearch = { fg = warning },
        NoiceCmdlinePopup = { fg = normal_fg, bg = float_bg },
        NoiceCmdlinePopupBorder = { fg = accent, bg = "NONE" },
        NoiceCmdlinePopupTitle = { fg = accent, bg = "NONE", bold = true },
        NoicePopup = { fg = normal_fg, bg = float_bg },
        NoicePopupBorder = { fg = accent, bg = "NONE" },
        NoiceConfirm = { fg = normal_fg, bg = float_bg },
        NoiceConfirmBorder = { fg = accent, bg = "NONE" },
        NoicePopupmenu = { fg = normal_fg, bg = float_bg },
        NoicePopupmenuBorder = { fg = accent, bg = "NONE" },
        NoicePopupmenuSelected = { fg = normal_fg, bg = blend(accent, normal_bg, 0.20), bold = true },
        NoicePopupmenuMatch = { fg = accent, bold = true },

        -- ── Which-key ─────────────────────────────────────────────────────────
        WhichKey = { fg = accent },
        WhichKeyGroup = { fg = accent_alt },
        WhichKeyDesc = { fg = normal_fg },
        WhichKeyBorder = { fg = float_border, bg = float_bg },
        WhichKeyNormal = { fg = normal_fg, bg = float_bg },
        WhichKeySeparator = { fg = comment },
        WhichKeyValue = { fg = comment },

        -- ── Snacks ───────────────────────────────────────────────────────────
        SnacksNormal = { fg = normal_fg, bg = transparent and "NONE" or sidebar_bg },
        SnacksNormalNC = { fg = normal_fg, bg = transparent and "NONE" or sidebar_bg },
        SnacksPicker = { fg = normal_fg, bg = transparent and "NONE" or sidebar_bg },
        SnacksPickerList = { fg = normal_fg, bg = transparent and "NONE" or sidebar_bg },
        SnacksPickerInput = { fg = normal_fg, bg = transparent and "NONE" or sidebar_bg },
        SnacksPickerBox = { fg = normal_fg, bg = transparent and "NONE" or sidebar_bg },
        SnacksPickerPreview = { fg = normal_fg, bg = transparent and "NONE" or sidebar_bg },
        SnacksPickerBorder = { fg = float_border, bg = transparent and "NONE" or float_bg },
        SnacksPickerBoxBorder = { fg = float_border, bg = transparent and "NONE" or float_bg },
        SnacksPickerInputBorder = { fg = float_border, bg = transparent and "NONE" or float_bg },
        SnacksPickerListBorder = { fg = float_border, bg = transparent and "NONE" or float_bg },
        SnacksPickerPreviewBorder = { fg = float_border, bg = transparent and "NONE" or float_bg },
        SnacksPickerTitle = { fg = normal_bg, bg = accent, bold = true },
        SnacksPickerMatch = { fg = accent, bold = true },
        SnacksPickerSelected = { fg = accent, bg = blend(accent, normal_bg, 0.15), bold = true },
        SnacksPickerDir = { fg = comment },
        SnacksPickerTotals = { fg = comment, italic = true },
        SnacksInputNormal = { fg = normal_fg, bg = transparent and "NONE" or float_bg },
        SnacksInputBorder = { fg = accent, bg = "NONE" },
        SnacksInputTitle = { fg = accent, bg = "NONE", bold = true },
        SnacksInputPrompt = { fg = accent_alt, bold = true },
        SnacksInputIcon = { fg = accent },
        SnacksBackdrop = { bg = "NONE" },
        SnacksDashboardNormal = { bg = transparent and "NONE" or normal_bg },
        SnacksIndent = { fg = blend(comment, normal_bg, 0.32) },
        SnacksIndentScope = { fg = blend(accent, normal_bg, 0.60) },
        SnacksIndentChunk = { link = "SnacksIndentScope" },
        SnacksDashboardHeader = { fg = accent, bold = true },
        SnacksDashboardDesc = { fg = normal_fg },
        SnacksDashboardKey = { fg = accent_alt, bold = true },
        SnacksDashboardDir = { fg = comment },
        SnacksDashboardFooter = { fg = comment, italic = true },

        -- ── Neogit ────────────────────────────────────────────────────────────
        NeogitBranch = { fg = accent },
        NeogitRemote = { fg = accent_alt },
        NeogitHunkHeader = { fg = normal_fg, bg = blend(accent, normal_bg, 0.12) },
        NeogitHunkHeaderHighlight = { fg = normal_fg, bg = blend(accent, normal_bg, 0.20), bold = true },
        NeogitDiffAdd = { fg = success, bg = blend(success, normal_bg, 0.10) },
        NeogitDiffDelete = { fg = danger, bg = blend(danger, normal_bg, 0.10) },
        NeogitDiffContext = { fg = normal_fg, bg = float_bg },
        NeogitDiffContextHighlight = { fg = normal_fg, bg = blend(accent, normal_bg, 0.07) },

        -- ── Aerial ────────────────────────────────────────────────────────────
        AerialLine = { bg = blend(accent, normal_bg, 0.12) },
        AerialGuide = { fg = blend(comment, normal_bg, 0.60) },
        AerialNormal = { fg = normal_fg, bg = sidebar_bg },

        -- ── Overseer ──────────────────────────────────────────────────────────
        OverseerTaskBorder = { fg = float_border, bg = float_bg },
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

        -- ── Dropbar (Breadcrumbs) ─────────────────────────────────────────────
        DropBarIconKindDefault = { fg = accent },
        DropBarIconKindFile = { fg = accent },
        DropBarIconKindFolder = { fg = accent_alt },
        DropBarIconKindPackage = { fg = accent_alt },
        DropBarIconKindNamespace = { fg = accent_alt },
        DropBarIconKindClass = { fg = warning },
        DropBarIconKindMethod = { fg = accent },
        DropBarIconKindProperty = { fg = normal_fg },
        DropBarIconKindField = { fg = normal_fg },
        DropBarIconKindConstructor = { fg = accent },
        DropBarIconKindEnum = { fg = warning },
        DropBarIconKindInterface = { fg = warning },
        DropBarIconKindFunction = { fg = accent },
        DropBarIconKindVariable = { fg = normal_fg },
        DropBarIconKindConstant = { fg = success },
        DropBarIconKindString = { fg = success },
        DropBarIconKindNumber = { fg = accent_alt },
        DropBarIconKindBoolean = { fg = warning },
        DropBarIconKindArray = { fg = accent_alt },
        DropBarIconKindObject = { fg = warning },
        DropBarIconKindKey = { fg = accent },
        DropBarIconKindNull = { fg = comment },
        DropBarIconKindEnumMember = { fg = success },
        DropBarIconKindStruct = { fg = warning },
        DropBarIconKindEvent = { fg = accent },
        DropBarIconKindOperator = { fg = accent_alt },
        DropBarIconKindTypeParameter = { fg = warning },
        DropBarMenuNormalFloat = { fg = normal_fg, bg = float_bg },
        DropBarMenuFloatBorder = { fg = float_border, bg = float_bg },
        DropBarMenuHoverEntry = { bg = blend(accent, normal_bg, 0.18), bold = true },

        -- ── Mode-morphing cursor highlights ─────────────────────────────
        Cursor = { fg = normal_bg, bg = accent },
        InsertCursor = { fg = normal_bg, bg = success },
        ReplaceCursor = { fg = normal_bg, bg = danger },
        VisualCursor = { fg = normal_bg, bg = accent_alt },

        -- ── Markdown markup (syntax colours are left to the colorscheme) ───
        ["@markup.raw.block.markdown"] = { bg = float_bg },
        ["@markup.link.label.markdown_inline"] = { fg = accent, bold = true, underline = true },
        ["@markup.link.url.markdown_inline"] = { fg = comment, underline = true },
    }

    for group, value in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, value)
    end

    -- Completion kind colours: only for themes that don't style blink.cmp
    -- themselves (blink links every BlinkCmpKind<Kind> to one plain group).
    local kind_colors = {
        Function = accent, Method = accent, Constructor = accent, Event = accent, File = accent,
        Class = warning, Interface = warning, Struct = warning, Enum = warning, Unit = warning,
        Snippet = warning, TypeParameter = warning,
        Variable = accent_alt, Keyword = accent_alt, Folder = accent_alt, Module = accent_alt,
        Operator = accent_alt,
        Constant = success, Value = success, EnumMember = success,
        Property = normal_fg, Field = normal_fg, Text = normal_fg,
    }
    for kind, color in pairs(kind_colors) do
        local group = "BlinkCmpKind" .. kind
        local current = vim.api.nvim_get_hl(0, { name = group })
        if vim.tbl_isempty(current) or current.link == "BlinkCmpKind" then
            vim.api.nvim_set_hl(0, group, { fg = color })
        end
    end
end

local function apply_catppuccin(theme, transparent)
    local flavour = theme:gsub("^catppuccin%-?", "")
    if flavour == "" or flavour == "catppuccin" then
        flavour = "macchiato"
    end

    local ok, catppuccin = pcall(require, "catppuccin")
    if ok then
        catppuccin.setup({
            flavour = flavour,
            transparent_background = transparent,
            term_colors = true,
            integrations = {
                aerial = true,
                barbar = true,
                bufferline = true,
                cmp = true,
                gitsigns = true,
                neotree = true,
                noice = true,
                notify = true,
                render_markdown = true,
                snacks = true,
                telescope = true,
                treesitter = true,
                which_key = true,
            },
        })
    end

    local res = pcall(vim.cmd.colorscheme, "catppuccin-" .. flavour)
    if not res then
        pcall(vim.cmd.colorscheme, "catppuccin")
    end
end

local function apply_tokyonight(theme, transparent)
    local style = theme:gsub("^tokyonight%-?", "")
    if style == "" or style == "tokyonight" then
        style = "night"
    end

    local ok, tokyonight = pcall(require, "tokyonight")
    if ok then
        tokyonight.setup({
            style = style,
            transparent = transparent,
            styles = {
                sidebars = transparent and "transparent" or "dark",
                floats = transparent and "transparent" or "dark",
            },
        })
    end

    vim.g.tokyonight_transparent = transparent
    pcall(vim.cmd.colorscheme, theme)
end

local function apply_rose_pine(theme, transparent)
    local variant = theme == "rose-pine" and "main" or theme:match("^rose%-pine%-(.+)$") or "main"

    local ok, rose_pine = pcall(require, "rose-pine")
    if ok then
        rose_pine.setup({
            variant = variant,
            dark_variant = "main",
            disable_background = transparent,
            disable_float_background = transparent,
            disable_italics = true,
        })
    end

    pcall(vim.cmd.colorscheme, "rose-pine")
end

local function apply_kanagawa(theme, transparent)
    local variant = theme:match("^kanagawa%-(.+)$") or "wave"

    local ok, kanagawa = pcall(require, "kanagawa")
    if ok then
        kanagawa.setup({
            theme = variant,
            transparent = transparent,
            commentStyle = { italic = false },
            keywordStyle = { italic = false },
            statementStyle = { bold = false },
        })
    end

    pcall(vim.cmd.colorscheme, "kanagawa")
end

local function apply_nightfox(theme, transparent)
    local ok, nightfox = pcall(require, "nightfox")
    if ok then
        nightfox.setup({
            options = {
                transparent = transparent,
            },
        })
    end

    pcall(vim.cmd.colorscheme, theme)
end

local function apply_gruvbox(theme, transparent)
    local ok, gruvbox = pcall(require, "gruvbox")
    if ok then
        gruvbox.setup({
            transparent_mode = transparent,
            contrast = "hard",
        })
    end
    vim.g.gruvbox_transparent_bg = transparent and 1 or 0
    pcall(vim.cmd.colorscheme, "gruvbox")
end

local function apply_gruvbox_material(theme, transparent)
    vim.g.gruvbox_material_background = "hard"
    vim.g.gruvbox_material_transparent_background = transparent and 1 or 0
    pcall(vim.cmd.colorscheme, "gruvbox-material")
end

local function apply_everforest(theme, transparent)
    vim.g.everforest_background = "hard"
    vim.g.everforest_transparent_background = transparent and 1 or 0
    pcall(vim.cmd.colorscheme, "everforest")
end

local function apply_dracula(theme, transparent)
    local ok, dracula = pcall(require, "dracula")
    if ok then
        dracula.setup({
            transparent_bg = transparent,
        })
    end
    vim.g.dracula_transparent_bg = transparent
    pcall(vim.cmd.colorscheme, "dracula")
end

local function apply_cyberdream(theme, transparent)
    local ok, cyberdream = pcall(require, "cyberdream")
    if ok then
        cyberdream.setup({
            transparent = transparent,
            italic_comments = false,
            hide_fillchars = true,
            borderless_telescope = false,
        })
    end
    pcall(vim.cmd.colorscheme, "cyberdream")
end

local function apply_onedark(theme, transparent)
    local ok, onedarkpro = pcall(require, "onedarkpro")
    if ok then
        onedarkpro.setup({
            options = { transparency = transparent },
        })
    end
    pcall(vim.cmd.colorscheme, "onedark")
end

local function apply_material(theme, transparent)
    local ok, material = pcall(require, "material")
    if ok then
        material.setup({
            disable = {
                background = transparent,
                float_background = transparent,
            },
        })
    end
    vim.g.material_style = "ocean"
    pcall(vim.cmd.colorscheme, "material")
end

local function apply_nord(theme, transparent)
    vim.g.nord_disable_background = transparent
    pcall(vim.cmd.colorscheme, "nord")
end

local function apply_vscode(theme, transparent)
    local ok, vscode = pcall(require, "vscode")
    if ok then
        vscode.setup({
            transparent = transparent,
            italic_comments = false,
        })
    end
    pcall(vim.cmd.colorscheme, "vscode")
end

local function apply_matugen(theme, transparent)
    -- Force-reload the generated palette so we always pick up fresh colors.
    package.loaded["matugen-colors"] = nil
    local ok, m = pcall(require, "matugen-colors")
    if not ok or type(m) ~= "table" or not m.primary then
        vim.notify("matugen-colors.lua missing or invalid — run matugen first", vim.log.levels.WARN)
        return
    end

    -- Reset everything before applying our own palette.
    vim.cmd("highlight clear")

    -- Aliases for readability.
    local bg           = transparent and "NONE" or m.background
    local fg           = m.on_background
    local surface      = transparent and "NONE" or m.surface
    local surface_c    = m.surface_container or m.surface_variant
    local surface_cl   = m.surface_container_low or surface_c
    local surface_ch   = m.surface_container_high or surface_c
    local surface_chst = m.surface_container_highest or surface_ch
    local surface_v    = m.surface_variant
    local on_surface   = m.on_surface
    local on_sv        = m.on_surface_variant
    local outline      = m.outline
    local outline_v    = m.outline_variant
    local primary      = m.primary
    local on_primary   = m.on_primary
    local primary_c    = m.primary_container
    local on_primary_c = m.on_primary_container
    local secondary    = m.secondary
    local on_secondary = m.on_secondary
    local secondary_c  = m.secondary_container
    local on_sec_c     = m.on_secondary_container
    local tertiary     = m.tertiary
    local on_tertiary  = m.on_tertiary
    local tertiary_c   = m.tertiary_container
    local on_tert_c    = m.on_tertiary_container
    local error_col    = m.error
    local on_error     = m.on_error
    local error_c      = m.error_container
    local on_error_c   = m.on_error_container
    local inv_surface  = m.inverse_surface
    local inv_on_surf  = m.inverse_on_surface
    local inv_primary  = m.inverse_primary
    local surf_bright  = m.surface_bright
    local surf_dim     = m.surface_dim

    local hl = function(group, opts) vim.api.nvim_set_hl(0, group, opts) end

    -- ── Editor chrome ────────────────────────────────────────────────────
    hl("Normal",        { fg = fg, bg = bg })
    hl("NormalNC",      { fg = fg, bg = bg })
    hl("NormalFloat",   { fg = fg, bg = transparent and "NONE" or surface_cl })
    hl("FloatBorder",   { fg = outline, bg = "NONE" })
    hl("FloatTitle",    { fg = primary, bg = "NONE", bold = true })
    hl("FloatFooter",   { fg = outline, bg = "NONE" })
    hl("WinSeparator",  { fg = outline_v, bg = "NONE" })
    hl("VertSplit",     { fg = outline_v, bg = "NONE" })

    -- Cursor & lines
    hl("Cursor",        { fg = bg, bg = primary })
    hl("lCursor",       { fg = bg, bg = primary })
    hl("CursorLine",    { bg = transparent and "NONE" or surface_c })
    hl("CursorColumn",  { bg = transparent and "NONE" or surface_c })
    hl("CursorLineNr",  { fg = primary, bold = true })
    hl("LineNr",        { fg = outline })
    hl("SignColumn",    { bg = "NONE" })
    hl("EndOfBuffer",   { fg = outline_v })
    hl("ColorColumn",   { bg = surface_c })
    hl("Conceal",       { fg = outline })

    -- Selection & search
    hl("Visual",        { bg = primary_c })
    hl("VisualNOS",     { bg = primary_c })
    hl("Search",        { fg = on_primary_c, bg = primary_c })
    hl("IncSearch",     { fg = on_secondary, bg = secondary })
    hl("CurSearch",     { fg = on_primary, bg = primary, bold = true })
    hl("Substitute",    { fg = on_error, bg = error_col })

    -- Statusline
    hl("StatusLine",    { fg = on_surface, bg = transparent and "NONE" or surface_c })
    hl("StatusLineNC",  { fg = outline, bg = transparent and "NONE" or surface_cl })
    hl("WinBar",        { fg = on_surface, bg = "NONE" })
    hl("WinBarNC",      { fg = outline, bg = "NONE" })

    -- Tabs & folds
    hl("TabLine",       { fg = on_sv, bg = surface_cl })
    hl("TabLineSel",    { fg = primary, bg = surface_c, bold = true })
    hl("TabLineFill",   { bg = transparent and "NONE" or surface_cl })
    hl("Folded",        { fg = outline, bg = transparent and "NONE" or surface_cl })
    hl("FoldColumn",    { fg = outline, bg = "NONE" })

    -- Popup menu
    hl("Pmenu",         { fg = on_surface, bg = surface_c })
    hl("PmenuSel",      { fg = on_primary_c, bg = primary_c, bold = true })
    hl("PmenuSbar",     { bg = surface_ch })
    hl("PmenuThumb",    { bg = primary })

    -- Messages & mode
    hl("MsgArea",       { fg = on_surface })
    hl("ModeMsg",       { fg = primary, bold = true })
    hl("MoreMsg",       { fg = primary })
    hl("WarningMsg",    { fg = error_col })
    hl("ErrorMsg",      { fg = on_error, bg = error_col })
    hl("Question",      { fg = primary })
    hl("Title",         { fg = primary, bold = true })
    hl("Directory",     { fg = primary })

    -- Diff
    hl("DiffAdd",       { bg = blend(primary, m.background, 0.15) })
    hl("DiffChange",    { bg = blend(secondary, m.background, 0.12) })
    hl("DiffDelete",    { fg = error_col, bg = blend(error_col, m.background, 0.10) })
    hl("DiffText",      { bg = blend(primary, m.background, 0.25) })

    -- Spell
    hl("SpellBad",      { sp = error_col, undercurl = true })
    hl("SpellCap",      { sp = primary, undercurl = true })
    hl("SpellLocal",    { sp = secondary, undercurl = true })
    hl("SpellRare",     { sp = tertiary, undercurl = true })

    -- Misc
    hl("NonText",       { fg = outline_v })
    hl("SpecialKey",    { fg = outline_v })
    hl("MatchParen",    { fg = primary, bg = surface_v, bold = true })

    -- ── Syntax highlighting ──────────────────────────────────────────────
    hl("Comment",       { fg = outline, italic = true })
    hl("Constant",      { fg = tertiary })
    hl("String",        { fg = secondary })
    hl("Character",     { fg = secondary })
    hl("Number",        { fg = tertiary })
    hl("Boolean",       { fg = tertiary, bold = true })
    hl("Float",         { fg = tertiary })
    hl("Identifier",    { fg = on_surface })
    hl("Function",      { fg = primary })
    hl("Statement",     { fg = primary, bold = true })
    hl("Conditional",   { fg = primary })
    hl("Repeat",        { fg = primary })
    hl("Label",         { fg = primary })
    hl("Operator",      { fg = on_sv })
    hl("Keyword",       { fg = tertiary })
    hl("Exception",     { fg = error_col })
    hl("PreProc",       { fg = tertiary })
    hl("Include",       { fg = tertiary })
    hl("Define",        { fg = tertiary })
    hl("Macro",         { fg = tertiary })
    hl("PreCondit",     { fg = tertiary })
    hl("Type",          { fg = secondary })
    hl("StorageClass",  { fg = secondary })
    hl("Structure",     { fg = secondary })
    hl("Typedef",       { fg = secondary })
    hl("Special",       { fg = primary })
    hl("SpecialChar",   { fg = primary })
    hl("Tag",           { fg = primary })
    hl("Delimiter",     { fg = on_sv })
    hl("SpecialComment",{ fg = primary, italic = true })
    hl("Debug",         { fg = error_col })
    hl("Underlined",    { fg = primary, underline = true })
    hl("Bold",          { bold = true })
    hl("Italic",        { italic = true })
    hl("Ignore",        { fg = outline_v })
    hl("Error",         { fg = on_error, bg = error_col })
    hl("Todo",          { fg = on_primary, bg = primary, bold = true })

    -- ── Diagnostics ──────────────────────────────────────────────────────
    hl("DiagnosticError",          { fg = error_col })
    hl("DiagnosticWarn",           { fg = tertiary })
    hl("DiagnosticInfo",           { fg = primary })
    hl("DiagnosticHint",           { fg = secondary })
    hl("DiagnosticOk",             { fg = primary })
    hl("DiagnosticUnderlineError", { sp = error_col, undercurl = true })
    hl("DiagnosticUnderlineWarn",  { sp = tertiary, undercurl = true })
    hl("DiagnosticUnderlineInfo",  { sp = primary, undercurl = true })
    hl("DiagnosticUnderlineHint",  { sp = secondary, undercurl = true })
    hl("DiagnosticVirtualTextError", { fg = error_col, bg = blend(error_col, m.background, 0.10) })
    hl("DiagnosticVirtualTextWarn",  { fg = tertiary, bg = blend(tertiary, m.background, 0.10) })
    hl("DiagnosticVirtualTextInfo",  { fg = primary, bg = blend(primary, m.background, 0.10) })
    hl("DiagnosticVirtualTextHint",  { fg = secondary, bg = blend(secondary, m.background, 0.10) })

    -- ── LSP ──────────────────────────────────────────────────────────────
    hl("LspReferenceText",  { bg = blend(primary, m.background, 0.12) })
    hl("LspReferenceRead",  { bg = blend(primary, m.background, 0.12) })
    hl("LspReferenceWrite", { bg = blend(primary, m.background, 0.18) })
    hl("LspInlayHint",     { fg = outline, bg = blend(outline, m.background, 0.06), italic = true })

    -- ── Treesitter ───────────────────────────────────────────────────────
    hl("@variable",                 { fg = on_surface })
    hl("@variable.builtin",         { fg = tertiary, italic = true })
    hl("@variable.parameter",       { fg = on_sv, italic = true })
    hl("@variable.member",          { fg = on_surface })
    hl("@constant",                 { fg = tertiary })
    hl("@constant.builtin",         { fg = tertiary, bold = true })
    hl("@module",                   { fg = secondary })
    hl("@string",                   { fg = secondary })
    hl("@string.escape",            { fg = primary })
    hl("@string.regex",             { fg = tertiary })
    hl("@character",                { fg = secondary })
    hl("@number",                   { fg = tertiary })
    hl("@boolean",                  { fg = tertiary, bold = true })
    hl("@float",                    { fg = tertiary })
    hl("@function",                 { fg = primary })
    hl("@function.builtin",         { fg = primary, italic = true })
    hl("@function.call",            { fg = primary })
    hl("@function.macro",           { fg = tertiary })
    hl("@method",                   { fg = primary })
    hl("@method.call",              { fg = primary })
    hl("@constructor",              { fg = primary })
    hl("@keyword",                  { fg = tertiary })
    hl("@keyword.function",         { fg = tertiary })
    hl("@keyword.operator",         { fg = on_sv })
    hl("@keyword.return",           { fg = error_col, bold = true })
    hl("@keyword.coroutine",        { fg = tertiary, bold = true })
    hl("@keyword.exception",        { fg = error_col, bold = true })
    hl("@conditional",              { fg = primary })
    hl("@repeat",                   { fg = primary })
    hl("@label",                    { fg = primary })
    hl("@operator",                 { fg = on_sv })
    hl("@exception",                { fg = error_col })
    hl("@type",                     { fg = secondary })
    hl("@type.builtin",             { fg = secondary, italic = true })
    hl("@type.qualifier",           { fg = tertiary })
    hl("@include",                  { fg = tertiary })
    hl("@punctuation.bracket",      { fg = on_sv })
    hl("@punctuation.delimiter",    { fg = on_sv })
    hl("@punctuation.special",      { fg = primary })
    hl("@comment",                  { fg = outline, italic = true })
    hl("@comment.documentation",    { fg = outline, italic = true })
    hl("@tag",                      { fg = primary })
    hl("@tag.attribute",            { fg = tertiary, italic = true })
    hl("@tag.delimiter",            { fg = on_sv })
    hl("@attribute",                { fg = tertiary })
    hl("@property",                 { fg = on_surface })
    hl("@text.strong",              { bold = true })
    hl("@text.emphasis",            { italic = true })
    hl("@text.underline",           { underline = true })
    hl("@text.title",               { fg = primary, bold = true })
    hl("@text.uri",                 { fg = primary, underline = true })
    hl("@text.todo",                { fg = on_primary, bg = primary, bold = true })
    hl("@text.note",                { fg = on_primary_c, bg = primary_c })
    hl("@text.warning",             { fg = on_error_c, bg = error_c })
    hl("@text.danger",              { fg = on_error, bg = error_col })

    -- Semantic tokens (LSP)
    hl("@lsp.type.comment",         { fg = outline, italic = true })
    hl("@lsp.type.interface",       { fg = secondary, bold = true })
    hl("@lsp.type.struct",          { fg = secondary, bold = true })
    hl("@lsp.type.typeParameter",   { fg = tertiary, italic = true })
    hl("@lsp.type.decorator",       { fg = tertiary, bold = true })

    -- Markup (markdown)
    hl("@markup.raw.block.markdown",          { bg = transparent and "NONE" or surface_cl })
    hl("@markup.link.label.markdown_inline",  { fg = primary, bold = true, underline = true })
    hl("@markup.link.url.markdown_inline",    { fg = outline, underline = true })

    -- ── Git signs ────────────────────────────────────────────────────────
    hl("GitSignsAdd",    { fg = primary })
    hl("GitSignsChange", { fg = secondary })
    hl("GitSignsDelete", { fg = error_col })
end

-- Apply the requested theme first, then re-style the surrounding UI so plugin windows
-- look intentional instead of inheriting whatever defaults the colorscheme shipped with.
local function apply_theme(theme, transparent)
    if theme:match("^catppuccin") then
        apply_catppuccin(theme, transparent)
    elseif theme:match("^tokyonight") then
        apply_tokyonight(theme, transparent)
    elseif theme == "matugen" then
        apply_matugen(theme, transparent)
    elseif theme:match("^rose%-pine") then
        apply_rose_pine(theme, transparent)
    elseif theme:match("^kanagawa") then
        apply_kanagawa(theme, transparent)
    elseif nightfox_themes[theme] then
        apply_nightfox(theme, transparent)
    elseif theme == "gruvbox" then
        apply_gruvbox(theme, transparent)
    elseif theme == "gruvbox-material" then
        apply_gruvbox_material(theme, transparent)
    elseif theme == "everforest" then
        apply_everforest(theme, transparent)
    elseif theme == "dracula" then
        apply_dracula(theme, transparent)
    elseif theme == "cyberdream" then
        apply_cyberdream(theme, transparent)
    elseif theme == "onedark" then
        apply_onedark(theme, transparent)
    elseif theme == "material" then
        apply_material(theme, transparent)
    elseif theme == "nord" then
        apply_nord(theme, transparent)
    elseif theme == "vscode" then
        apply_vscode(theme, transparent)
    else
        local ok, err = pcall(vim.cmd.colorscheme, theme)
        if not ok then
            vim.notify("Could not load theme " .. theme .. ": " .. tostring(err), vim.log.levels.ERROR)
            return false
        end
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

    vim.g.preferred_theme = name
    write_state(name, transparent)

    if not apply_theme(name, transparent) then
        return
    end

    vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "*" })
    vim.api.nvim_exec_autocmds("User", { pattern = "StatusStyleChanged" })

    vim.notify("Theme switched to " .. name, vim.log.levels.INFO, { title = "Theme" })
end

function M.toggle_transparency()
    local theme = vim.g.preferred_theme or M.default_theme
    local transparent = not (vim.g.preferred_transparent == true)

    vim.g.preferred_transparent = transparent
    write_state(theme, transparent)

    if not apply_theme(theme, transparent) then
        return
    end

    vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "*" })
    vim.api.nvim_exec_autocmds("User", { pattern = "StatusStyleChanged" })

    vim.notify(transparent and "Transparency is on" or "Transparency is off", vim.log.levels.INFO, { title = "Theme" })
end

function M.select()
    local ok, snacks = pcall(require, "snacks")
    local initial_theme = vim.g.preferred_theme or M.default_theme
    local confirmed = false
    local preview_timer = vim.uv.new_timer()

    local items = {}
    for _, t in ipairs(M.dark_themes) do
        local is_def = (t == M.default_theme)
        table.insert(items, {
            text = t,
            category = "Dark",
            is_default = is_def,
            theme = t,
        })
    end
    for _, t in ipairs(M.light_themes) do
        local is_def = (t == M.default_theme)
        table.insert(items, {
            text = t,
            category = "Light",
            is_default = is_def,
            theme = t,
        })
    end

    local function preview_theme(name)
        if not name then return end
        if preview_timer then preview_timer:stop() end
        -- 35ms debounce makes rapid j/k scrolling silky smooth without any UI lag
        preview_timer:start(35, 0, vim.schedule_wrap(function()
            if not confirmed and name then
                apply_theme(name, vim.g.preferred_transparent == true)
                pcall(function()
                    vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "*" })
                end)
            end
        end))
    end

    if ok and snacks.picker then
        snacks.picker.pick({
            title = " Colorscheme (Live Preview) ",
            items = items,
            format = function(item)
                local icon = item.category == "Dark" and "󰖔 " or "󰖙 "
                local def_str = item.is_default and " (default)" or ""
                return {
                    { icon, "SnacksPickerDim" },
                    { item.text .. " ", "Normal" },
                    { "[" .. item.category .. "]", "Comment" },
                    { def_str, "DiagnosticInfo" },
                }
            end,
            layout = {
                preset = "select",
                preview = false,
                width = 0.58,
                min_width = 45,
                height = 0.60,
            },
            on_change = function(item)
                if item and item.theme then
                    preview_theme(item.theme)
                end
            end,
            confirm = function(picker, item)
                confirmed = true
                if preview_timer then preview_timer:stop() end
                picker:close()
                if item and item.theme then
                    M.apply(item.theme)
                end
            end,
            cancel = function(picker)
                confirmed = true
                if preview_timer then preview_timer:stop() end
                picker:close()
                apply_theme(initial_theme, vim.g.preferred_transparent == true)
            end,
        })
        return
    end

    -- Fallback to standard vim.ui.select if snacks is not ready
    vim.ui.select(items, {
        prompt = "Select a colorscheme:",
        format_item = function(item)
            local icon = item.category == "Dark" and "󰖔 " or "󰖙 "
            local def_str = item.is_default and " (default)" or ""
            return string.format("%s %-22s [%s]%s", icon, item.text, item.category, def_str)
        end,
    }, function(choice)
        if choice and choice.theme then
            M.apply(choice.theme)
        end
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

    -- Live-reload: when matugen regenerates colors it sends SIGUSR1 to all nvim
    -- instances. Re-apply the matugen theme so the new palette takes effect.
    vim.api.nvim_create_autocmd("Signal", {
        group = vim.api.nvim_create_augroup("matugen_live_reload", { clear = true }),
        pattern = "SIGUSR1",
        callback = function()
            if vim.g.preferred_theme == "matugen" then
                local transparent = vim.g.preferred_transparent == true
                apply_theme("matugen", transparent)
                apply_editor_chrome(transparent)
                vim.api.nvim_exec_autocmds("User", { pattern = "StatusStyleChanged" })
                vim.notify("Matugen colors reloaded", vim.log.levels.INFO, { title = "Theme" })
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
    vim.g.lualine_color_style = vim.g.lualine_color_style or "evil"
end

return M

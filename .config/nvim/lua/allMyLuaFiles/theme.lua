local M = {}

local state_file = vim.fn.stdpath("state") .. "/theme.json"

M.themes = {
    "catppuccin",
    "catppuccin-latte",
    "catppuccin-frappe",
    "catppuccin-macchiato",
    "catppuccin-mocha",
    "dracula",
    "tokyonight",
    "gruvbox",
    "rose-pine",
}

M.default_theme = "catppuccin"
M.default_transparency = false

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
            bufferline = true,
            cmp = true,
            gitsigns = true,
            neotree = true,
            noice = true,
            notify = true,
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

local function apply_theme(theme, transparent)
    if theme:match("^catppuccin") then
        apply_catppuccin(theme, transparent)
        set_transparent_highlights(transparent)
        return true
    end

    if theme == "tokyonight" then
        vim.g.tokyonight_transparent = transparent
    elseif theme == "gruvbox" then
        vim.g.gruvbox_transparent_bg = transparent and 1 or 0
    elseif theme == "dracula" then
        vim.g.dracula_transparent_bg = transparent
    elseif theme == "rose-pine" then
        vim.g.rose_pine_disable_background = transparent
    end

    local ok, err = pcall(vim.cmd.colorscheme, theme)
    if not ok then
        vim.notify("Could not load theme " .. theme .. ": " .. err, vim.log.levels.ERROR)
        return false
    end

    set_transparent_highlights(transparent)
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
    vim.ui.select(M.themes, {
        prompt = "Choose a theme",
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
end

function M.cycle(step)
    local index = current_index()
    local next_index = ((index - 1 + step) % #M.themes) + 1
    M.apply(M.themes[next_index])
end

function M.setup()
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

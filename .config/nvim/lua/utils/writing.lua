local M = {}

local state = {}

local tracked_options = {
    "colorcolumn",
    "cursorline",
    "linebreak",
    "list",
    "number",
    "relativenumber",
    "signcolumn",
    "spell",
    "wrap",
}

local function save_state(buf)
    state[buf] = state[buf] or {}

    for _, option in ipairs(tracked_options) do
        state[buf][option] = vim.opt_local[option]:get()
    end

    state[buf].diagnostics = vim.diagnostic.is_enabled({ bufnr = buf })
end

local function restore_state(buf)
    if not state[buf] then
        return
    end

    for option, value in pairs(state[buf]) do
        if option ~= "diagnostics" then
            vim.opt_local[option] = value
        end
    end

    vim.diagnostic.enable(state[buf].diagnostics, { bufnr = buf })
    state[buf] = nil
end

function M.toggle()
    local buf = vim.api.nvim_get_current_buf()

    if vim.b.writing_mode then
        vim.b.writing_mode = false
        restore_state(buf)
        vim.notify("Writing mode is off")
        return
    end

    save_state(buf)

    vim.b.writing_mode = true
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.list = false
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.cursorline = false
    vim.opt_local.colorcolumn = "0"
    vim.diagnostic.enable(false, { bufnr = buf })

    vim.notify("Writing mode is on")
end

return M

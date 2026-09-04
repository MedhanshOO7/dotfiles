local M = {}

M.modes = {
    BRAINSTORM = "Brainstorm",
    PROFESSIONAL = "Professional",
}

M.current_mode = M.modes.PROFESSIONAL

local function get_config_path(mode)
    local config_dir = vim.fn.stdpath("config")
    if mode == M.modes.BRAINSTORM then
        return config_dir .. "/.markdownlint-loose.json"
    else
        return config_dir .. "/.markdownlint-strict.json"
    end
end

function M.set_mode(mode)
    if not M.modes[mode] and not vim.tbl_contains(vim.tbl_values(M.modes), mode) then
        vim.notify("Invalid Markdown mode: " .. mode, vim.log.levels.ERROR)
        return
    end

    local target_mode = M.modes[mode] or mode
    M.current_mode = target_mode
    local is_brainstorm = (target_mode == M.modes.BRAINSTORM)

    -- 1. Update nvim-lint markdownlint arguments
    local lint_ok, lint = pcall(require, "lint")
    if lint_ok then
        local config_path = get_config_path(target_mode)
        lint.linters.markdownlint.args = {
            "--stdin",
            "--config", config_path,
        }
        -- Trigger linting to update diagnostics immediately
        if vim.bo.filetype == "markdown" then
            lint.try_lint()
        end
    end

    -- 2. Toggle diagnostic noise buffer-locally
    local cur_buf = vim.api.nvim_get_current_buf()
    pcall(vim.diagnostic.enable, not is_brainstorm, { bufnr = cur_buf })

    vim.notify("Markdown: " .. target_mode .. " Mode active", vim.log.levels.INFO)
end

function M.toggle_brainstorm()
    M.set_mode(M.modes.BRAINSTORM)
end

function M.toggle_professional()
    M.set_mode(M.modes.PROFESSIONAL)
end

return M

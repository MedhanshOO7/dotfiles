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

    -- 2. Toggle completion (snippets) via nvim-cmp
    local cmp_ok, cmp = pcall(require, "cmp")
    if cmp_ok then
        cmp.setup.buffer({ enabled = not is_brainstorm })
    end

    -- 3. Toggle diagnostic noise
    vim.diagnostic.config({
        virtual_text = not is_brainstorm,
        signs = not is_brainstorm,
        underline = not is_brainstorm,
    })

    vim.notify("Markdown: " .. target_mode .. " Mode active", vim.log.levels.INFO)
end

function M.toggle_brainstorm()
    M.set_mode(M.modes.BRAINSTORM)
end

function M.toggle_professional()
    M.set_mode(M.modes.PROFESSIONAL)
end

return M

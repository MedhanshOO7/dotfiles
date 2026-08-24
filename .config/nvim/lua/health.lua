local M = {}

M.check = function()
    vim.health.start("Medhansh's Neovim Config")

    local python_path = vim.fn.expand("~/.venvs/neovim/bin/python")
    if vim.fn.executable(python_path) == 1 then
        vim.health.ok("Python virtual environment found: " .. python_path)
    elseif vim.fn.executable("python3") == 1 then
        vim.health.warn("Default system python3 found. Recommended: python -m venv ~/.venvs/neovim")
    else
        vim.health.error("No python3 provider detected.")
    end

    local jupytext_path = vim.fn.expand("~/.venvs/neovim/bin/jupytext")
    if vim.fn.executable(jupytext_path) == 1 or vim.fn.executable("jupytext") == 1 then
        vim.health.ok("Jupytext installed (Molten notebook conversion supported)")
    else
        vim.health.warn("Jupytext missing. Molten notebook conversion requires jupytext in python venv.")
    end

    if vim.fn.executable("colorscript") == 1 then
        vim.health.ok("pokemon-colorscripts detected for dashboard header")
    else
        vim.health.info("colorscript missing (dashboard using clean fallback)")
    end

    if vim.fn.executable("git") == 1 then
        vim.health.ok("Git binary found")
    else
        vim.health.error("Git binary missing")
    end
end

return M

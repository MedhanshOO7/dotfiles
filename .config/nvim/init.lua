local path_sep = vim.fn.has("win32") == 1 and ";" or ":"
local extra_paths = {
    "/opt/homebrew/bin",
    "/opt/homebrew/sbin",
    "/usr/local/bin",
    "/usr/local/sbin",
    vim.fn.expand("~/.cargo/bin"),
    vim.fn.expand("~/.local/bin"),
}

for _, p in ipairs(extra_paths) do
    if vim.fn.isdirectory(p) == 1 and not string.find(vim.env.PATH or "", p, 1, true) then
        vim.env.PATH = p .. path_sep .. (vim.env.PATH or "")
    end
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ── Safety Gutter for Headless Mode & Plugins ───────────────────
-- Ensures core highlights exist early to prevent crashes in plugins
-- that calculate color blends (like snacks.nvim) before the theme loads.
if #vim.api.nvim_list_uis() == 0 then
    vim.api.nvim_set_hl(0, "Normal", { fg = "#ffffff", bg = "#000000" })
    vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#ffffff" })
end

vim.g.autoformat_enabled = false
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
local python_path = vim.fn.expand("~/.venvs/neovim/bin/python")
if vim.fn.executable(python_path) ~= 1 then
    python_path = vim.fn.expand("~/.venvs/neovim/Scripts/python.exe")
end
if vim.fn.executable(python_path) == 1 then
    vim.g.python3_host_prog = python_path
elseif vim.fn.executable("python3") == 1 then
    vim.g.python3_host_prog = vim.fn.exepath("python3")
elseif vim.fn.executable("python") == 1 then
    vim.g.python3_host_prog = vim.fn.exepath("python")
end

local function ensure_dir(path)
    pcall(vim.fn.mkdir, path, "p")
    return vim.fn.isdirectory(path) == 1 and vim.fn.filewritable(path) == 2
end

local cache_dir = vim.fn.stdpath("cache")
local state_dir = vim.fn.stdpath("state")
vim.g.user_disable_lazy_cache = not ensure_dir(cache_dir)
vim.g.user_state_writable = ensure_dir(state_dir)
vim.g.user_undo_writable = ensure_dir(state_dir .. "/undo")

if vim.loader then
    vim.loader.enable()
end

if not vim.g.user_state_writable then
    vim.opt.shadafile = "NONE"
end

vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")

require("core.options")
require("core.autocmds")
require("core.lazy")
require("utils.theme").setup()
require("core.keymaps")

-- Lazy-loaded utility commands (zero startup cost)
vim.api.nvim_create_user_command("ConfigUpdate", function()
    require("utils.updater").update()
end, { desc = "Pull latest configuration changes from Git repository" })

vim.api.nvim_create_user_command("NvimUpdate", function()
    require("utils.updater").update()
end, { desc = "Pull latest configuration changes from Git repository" })

vim.api.nvim_create_user_command("ReportBuild", function()
    require("utils.report_tool").build({ pdf = true })
end, { desc = "Build practical report from current markdown file" })

vim.api.nvim_create_user_command("ReportPreview", function()
    require("utils.report_tool").build({ pdf = true, open_pdf = true })
end, { desc = "Build practical report and open PDF preview" })

vim.api.nvim_create_user_command("ReportInit", function()
    require("utils.report_tool").init_template()
end, { desc = "Scaffold a new practical report template" })

-- Fix "Unknown filetype" warnings for LSP and Noice
vim.filetype.add({
    extension = {
        mdx = "markdown.mdx",
    },
    pattern = {
        ["docker%-compose%.ya?ml"] = "yaml.docker-compose",
        ["gitlab%-ci%.ya?ml"] = "yaml.gitlab",
    },
})

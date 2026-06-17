-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        local message = "Failed to clone lazy.nvim:\n" .. out
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
        }, true, {})

        -- Headless or non-UI startup must fail fast instead of blocking on getchar().
        if #vim.api.nvim_list_uis() == 0 then
            error(message)
        end

        vim.api.nvim_echo({
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)
-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        -- import your plugins
        { import = "plugins" },
    },
    defaults = {
        lazy = true,
    },
    rocks = {
        enabled = false,
        hererocks = false,
    },
    ui = {
        border = "rounded",
    },
    install = {
        colorscheme = { "tokyonight" },
    },
    change_detection = { notify = false },
})

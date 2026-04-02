-- =========================
-- TRANSPARENCY FUNCTION
-- =========================
local function Etrans()
    -- Core UI
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })

    -- Neo-tree
    vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "none" })
    vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "none" })
end

return {

    -- =========================
    -- DRACULA (LOAD FIRST)
    -- =========================
    {
        "Mofiqul/dracula.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd("colorscheme dracula")
            Etrans()

            -- Reapply if anything overrides
            vim.api.nvim_create_autocmd("ColorScheme", {
                pattern = "*",
                callback = function()
                    Etrans()
                end,
            })
        end,
    },

    -- =========================
    -- NEO-TREE (MANUAL ONLY)
    -- =========================
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("neo-tree").setup({
                filesystem = {
                    hijack_netrw_behavior = "disabled", -- IMPORTANT
                },
            })

            -- Ctrl + b → Neo-tree
            vim.keymap.set("n", "<C-b>", ":Neotree toggle<CR>", { silent = true })
        end,
    },

    -- =========================
    -- NETRW (RESTORED)
    -- =========================
    {
        "nvim-tree/nvim-web-devicons", -- optional but harmless
        config = function()
            vim.g.netrw_banner = 0
            vim.g.netrw_liststyle = 3
            vim.g.netrw_browse_split = 0 -- no split
            vim.g.netrw_fastbrowse = 2
            vim.g.netrw_keepdir = 0
            vim.g.netrw_sort_sequence = "[\\/]$,*,\\.o$,\\.pyc$"

            -- leader + e → netrw
            vim.keymap.set("n", "<leader>e", ":Explore<CR>", { silent = true })
        end,
    },

    -- =========================
    -- LUALINE
    -- =========================
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            theme = "dracula",
        },
    },
}

return {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    build = "make install_jsregexp",
    dependencies = {
        "rafamadriz/friendly-snippets",
    },
    config = function()
        local luasnip = require("luasnip")

        luasnip.config.setup({
            history = true,
            delete_check_events = "TextChanged",
            region_check_events = { "CursorMoved", "CursorHold", "InsertEnter" },
            updateevents = "TextChanged,TextChangedI",
        })

        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_lua").load({
            paths = vim.fn.stdpath("config") .. "/lua/snippets",
        })

        vim.keymap.set({ "i", "s" }, "<C-l>", function()
            if luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            end
        end, { silent = true, desc = "Snippet: expand or jump forward" })

        vim.keymap.set({ "i", "s" }, "<C-j>", function()
            if luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            end
        end, { silent = true, desc = "Snippet: jump backward" })

        vim.keymap.set({ "i", "s" }, "<C-.>", function()
            if luasnip.choice_active() then
                luasnip.change_choice(1)
            end
        end, { silent = true, desc = "Snippet: cycle choices" })
    end,
}

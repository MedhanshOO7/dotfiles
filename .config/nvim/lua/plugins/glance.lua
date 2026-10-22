return {
    "dnlhc/glance.nvim",
    cmd = "Glance",
    config = function()
        local glance = require("glance")
        local actions = glance.actions
        glance.setup({
            height = 18,
            zindex = 50,
            preview_win_opts = { cursorline = true, number = true, wrap = true },
            border = { enable = true, top_char = "─", bottom_char = "─" },
            list = { position = "right", width = 0.33 },
            theme = { enable = true, mode = "auto" },
            mappings = {
                list = {
                    ["j"] = actions.next,
                    ["k"] = actions.previous,
                    ["<Tab>"] = actions.enter_win("preview"),
                    ["q"] = actions.close,
                },
                preview = {
                    ["q"] = actions.close,
                    ["<Tab>"] = actions.enter_win("list"),
                },
            },
            hooks = {
                before_open = function(results, open, jump)
                    if #results == 1 then
                        jump(results[1])
                    else
                        open(results)
                    end
                end,
            },
        })
    end,
    keys = {
        { "<leader>vd", "<cmd>Glance definitions<cr>", desc = "Peek Definition" },
        { "<leader>vr", "<cmd>Glance references<cr>", desc = "Peek References" },
        { "<leader>vi", "<cmd>Glance implementations<cr>", desc = "Peek Implementations" },
        { "<leader>vt", "<cmd>Glance type_definitions<cr>", desc = "Peek Type Definitions" },
    },
}

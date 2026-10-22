return {
    {
        "tpope/vim-dadbod",
        cmd = { "DB" },
        ft = { "sql", "mysql", "plsql" },
        keys = {
            {
                "<leader>Ds",
                function()
                    require("utils.dadbod").select_database()
                end,
                desc = "Select database for current file",
            },
            {
                "<leader>DS",
                function()
                    require("utils.dadbod").view_table_schema()
                end,
                desc = "View table schema inspector",
            },
        },
        config = function()
            vim.api.nvim_create_user_command("DBSelect", function()
                require("utils.dadbod").select_database()
            end, { desc = "Select MariaDB Database for current buffer" })
            vim.api.nvim_create_user_command("DBSchema", function()
                require("utils.dadbod").view_table_schema()
            end, { desc = "View schema and columns for tables" })
        end,
    },
    {
        "kristijanhusak/vim-dadbod-completion",
        dependencies = { "tpope/vim-dadbod" },
        ft = { "sql", "mysql", "plsql" }, -- source is wired in blink.cmp (lua/plugins/cmp.lua)
    },
    {
        "kristijanhusak/vim-dadbod-ui",
        dependencies = {
            { "tpope/vim-dadbod" },
            { "kristijanhusak/vim-dadbod-completion" },
        },
        cmd = {
            "DBUI",
            "DBUIToggle",
            "DBUIAddConnection",
            "DBUIFindBuffer",
        },
        keys = {
            { "<leader>Db", "<cmd>DBUIToggle<cr>", desc = "Toggle Dadbod UI (Database Browser)" },
            { "<leader>Dc", "<cmd>DBUIAddConnection<cr>", desc = "Add DB Connection" },
            { "<leader>Df", "<cmd>DBUIFindBuffer<cr>", desc = "Find DB Buffer" },
            { "<leader>Dr", "<cmd>DBUIRenameBuffer<cr>", desc = "Rename DB Buffer" },
            { "<leader>Dl", "<cmd>DBUILastQueryInfo<cr>", desc = "Last DB Query Info" },
        },
        init = function()
            vim.g.db_ui_use_nerd_fonts = 1
            vim.g.db_ui_show_database_icon = 1
            vim.g.db_ui_force_echo_notifications = 1
            vim.g.db_ui_winwidth = 35
            vim.g.db_ui_auto_execute_table_helpers = true
            vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"

            local user = os.getenv("MARIADB_USER") or "root"
            local pass = os.getenv("MARIADB_PASSWORD")
            local auth = pass and (user .. ":" .. pass) or user
            local host = "127.0.0.1:3306"

            local dbs = {
                "ccet_committees",
                "campus_placement",
                "banking_dbms",
                "ccet",
                "cities",
                "university_6th",
                "computational_data",
            }

            vim.g.dbs = {}
            for _, name in ipairs(dbs) do
                table.insert(vim.g.dbs, { name = name, url = ("mariadb://%s@%s/%s"):format(auth, host, name) })
            end
        end,
    },
}

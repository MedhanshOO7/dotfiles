return {
    {
        "tpope/vim-dadbod",
        cmd = { "DB", "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer", "DBSelect", "DBSchema" },
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
        ft = { "sql", "mysql", "plsql" },
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
            { "<leader>Df", "<cmd>DBUIFindBuffer<cr>", desc = "Find DB Buffer" },
            { "<leader>Dr", "<cmd>DBUIRenameBuffer<cr>", desc = "Rename DB Buffer" },
            { "<leader>Dl", "<cmd>DBUILastQueryInfo<cr>", desc = "Last DB Query Info" },
        },
        init = function()
            vim.g.db_ui_use_nerd_fonts = 1
            vim.g.db_ui_show_database_icon = 1
            vim.g.db_ui_force_echo_notifications = 1
            vim.g.db_ui_winwidth = 35
            vim.g.db_ui_auto_execute_table_helpers = 1
            vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"

            vim.g.dbs = {
                { name = "ccet_committees", url = "mariadb://root@127.0.0.1:3306/ccet_committees" },
                { name = "campus_placement", url = "mariadb://root@127.0.0.1:3306/campus_placement" },
                { name = "banking_dbms", url = "mariadb://root@127.0.0.1:3306/banking_dbms" },
                { name = "ccet", url = "mariadb://root@127.0.0.1:3306/ccet" },
                { name = "cities", url = "mariadb://root@127.0.0.1:3306/cities" },
                { name = "university_6th", url = "mariadb://root@127.0.0.1:3306/university_6th" },
                { name = "computational_data", url = "mariadb://root@127.0.0.1:3306/computational_data" },
            }
        end,
    },
}

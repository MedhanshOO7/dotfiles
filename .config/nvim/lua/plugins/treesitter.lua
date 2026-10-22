return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        lazy = false, -- the main branch does not support lazy-loading
        dependencies = {
            { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
        },
        config = function()
            -- nvim-treesitter `main` branch: setup() only takes install_dir.
            -- Highlighting, indent and parser installs are wired up explicitly below.
            local ts = require("nvim-treesitter")
            ts.setup()

            local parsers = {
                "bash",
                "c",
                "cmake",
                "comment",
                "cpp",
                "css",
                "devicetree",
                "diff",
                "dockerfile",
                "go",
                "html",
                "hyprlang",
                "javascript",
                "json",
                "latex",
                "lua",
                "luadoc",
                "markdown",
                "markdown_inline",
                "mermaid",
                -- "norg",
                "python",
                "qmljs",
                "query",
                "regex",
                "ruby",
                "rust",
                "scss",
                "sql",
                "svelte",
                "toml",
                "tsx",
                "typescript",
                "typst",
                "vim",
                "vimdoc",
                "vue",
                "yaml",
            }
            -- Async and a no-op when everything is installed; deferred off the startup path
            vim.api.nvim_create_autocmd("User", {
                pattern = "VeryLazy",
                once = true,
                callback = function()
                    ts.install(parsers)
                end,
            })
            vim.treesitter.language.register("json", "jsonc") -- main has no separate jsonc parser

            local function too_big(buf)
                return vim.b[buf].large_file or vim.b[buf].bigfile or vim.api.nvim_buf_line_count(buf) > 5000
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("user_treesitter_start", { clear = true }),
                callback = function(args)
                    local buf = args.buf
                    if too_big(buf) then
                        return
                    end
                    local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
                    if not lang or not pcall(vim.treesitter.start, buf, lang) then
                        return
                    end
                    -- Only take over indentation where the parser ships indent queries
                    local has_indents = pcall(vim.treesitter.query.get, lang, "indents")
                        and vim.treesitter.query.get(lang, "indents")
                    if has_indents then
                        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })

            -- Text objects (af/if, ac/ic, aa/ia, ...) come from mini.ai; this plugin only
            -- provides structural motions. Node selection is built in since 0.12: v_an / v_in.
            require("nvim-treesitter-textobjects").setup({ move = { set_jumps = true } })
            local move = require("nvim-treesitter-textobjects.move")
            vim.g.no_python_maps = true -- python's regex ]m/]] buffer maps would shadow these
            local motions = {
                { "]m", "goto_next_start", "@function.outer", "Next function start" },
                { "[m", "goto_previous_start", "@function.outer", "Previous function start" },
                { "]]", "goto_next_start", "@class.outer", "Next class start" },
                { "[[", "goto_previous_start", "@class.outer", "Previous class start" },
            }
            for _, m in ipairs(motions) do
                vim.keymap.set({ "n", "x", "o" }, m[1], function()
                    move[m[2]](m[3], "textobjects")
                end, { desc = m[4] })
            end
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        ft = { "html", "xml", "javascriptreact", "typescriptreact", "vue", "svelte", "astro", "markdown" },
        opts = {},
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = "BufReadPost",
        keys = {
            { "<leader>ux", function() require("treesitter-context").toggle() end, desc = "Toggle Treesitter sticky header" },
        },
        opts = {
            max_lines = 3,            -- show up to 3 context lines at top
            min_window_height = 0,
            line_numbers = true,
            multiline_threshold = 20, -- collapse multiline contexts above 20 lines
            trim_scope = "outer",
            mode = "cursor",
        },
    },
}

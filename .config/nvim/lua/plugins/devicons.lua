return {
    "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    config = function()
        local devicons = require("nvim-web-devicons")

        local function resolve_group(groups)
            for _, group in ipairs(groups) do
                local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
                if ok and hl and not vim.tbl_isempty(hl) then
                    return group
                end
            end
        end

        local function set_devicon_link(name, groups)
            local target = resolve_group(groups)
            if target then
                vim.api.nvim_set_hl(0, "DevIcon" .. name, { link = target })
            end
        end

        local function apply_highlights()
            set_devicon_link("Default", { "Directory", "Normal" })
            set_devicon_link("GitIgnore", { "DiagnosticWarn", "Special" })
            set_devicon_link("GitAttributes", { "DiagnosticWarn", "Special" })
            set_devicon_link("Zshrc", { "String", "Identifier" })
            set_devicon_link("Bashrc", { "Constant", "Special" })
            set_devicon_link("Readme", { "Function", "Special" })
            set_devicon_link("License", { "Constant", "Special" })
            set_devicon_link("InitLua", { "Function", "Identifier" })
            set_devicon_link("LazyLock", { "Statement", "Special" })
            set_devicon_link("PackageJson", { "String", "Identifier" })
            set_devicon_link("TsConfig", { "Function", "Type" })
            set_devicon_link("TailwindConfigJs", { "Type", "Special" })
            set_devicon_link("TailwindConfigTs", { "Type", "Special" })
            set_devicon_link("Dockerfile", { "Function", "Special" })
            set_devicon_link("Lua", { "Function", "Identifier" })
            set_devicon_link("Markdown", { "Function", "Special" })
            set_devicon_link("Text", { "Directory", "Normal" })
            set_devicon_link("Json", { "Constant", "Special" })
            set_devicon_link("Toml", { "Constant", "Special" })
            set_devicon_link("Yaml", { "Constant", "Special" })
            set_devicon_link("Yml", { "Constant", "Special" })
            set_devicon_link("Sh", { "String", "Identifier" })
            set_devicon_link("Zsh", { "String", "Identifier" })
            set_devicon_link("Bash", { "Constant", "Special" })
            set_devicon_link("Js", { "Constant", "Special" })
            set_devicon_link("Jsx", { "Function", "Special" })
            set_devicon_link("Ts", { "Function", "Type" })
            set_devicon_link("Tsx", { "Type", "Special" })
            set_devicon_link("Html", { "Constant", "Special" })
            set_devicon_link("Css", { "Function", "Identifier" })
            set_devicon_link("Python", { "Constant", "Special" })
            set_devicon_link("Rust", { "Constant", "Special" })
            set_devicon_link("Go", { "Type", "Special" })
        end

        devicons.setup({
            default = true,
            color_icons = true,
            strict = true,
            override = {
                default_icon = {
                    icon = "󰈔",
                    name = "Default",
                },
            },
            override_by_filename = {
                [".gitignore"] = { icon = "", name = "GitIgnore" },
                [".gitattributes"] = { icon = "", name = "GitAttributes" },
                [".zshrc"] = { icon = "", name = "Zshrc" },
                [".bashrc"] = { icon = "", name = "Bashrc" },
                ["README.md"] = { icon = "󰍔", name = "Readme" },
                ["LICENSE"] = { icon = "󰿃", name = "License" },
                ["init.lua"] = { icon = "", name = "InitLua" },
                ["lazy-lock.json"] = { icon = "󰒲", name = "LazyLock" },
                ["package.json"] = { icon = "󰎙", name = "PackageJson" },
                ["tsconfig.json"] = { icon = "", name = "TsConfig" },
                ["tailwind.config.js"] = { icon = "󱏿", name = "TailwindConfigJs" },
                ["tailwind.config.ts"] = { icon = "󱏿", name = "TailwindConfigTs" },
                ["Dockerfile"] = { icon = "󰡨", name = "Dockerfile" },
            },
            override_by_extension = {
                lua = { icon = "", name = "Lua" },
                md = { icon = "󰍔", name = "Markdown" },
                txt = { icon = "󰈙", name = "Text" },
                json = { icon = "󰘦", name = "Json" },
                toml = { icon = "󰰤", name = "Toml" },
                yaml = { icon = "󰈙", name = "Yaml" },
                yml = { icon = "󰈙", name = "Yml" },
                sh = { icon = "", name = "Sh" },
                zsh = { icon = "", name = "Zsh" },
                bash = { icon = "", name = "Bash" },
                js = { icon = "", name = "Js" },
                jsx = { icon = "", name = "Jsx" },
                ts = { icon = "", name = "Ts" },
                tsx = { icon = "", name = "Tsx" },
                html = { icon = "", name = "Html" },
                css = { icon = "", name = "Css" },
                py = { icon = "", name = "Python" },
                rs = { icon = "", name = "Rust" },
                go = { icon = "", name = "Go" },
            },
        })

        apply_highlights()

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("devicons_theme_sync_user", { clear = true }),
            pattern = "*",
            callback = apply_highlights,
        })
    end,
}

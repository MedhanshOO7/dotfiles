return {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    opts = function()
        local slate = "#7a88cf"
        local aqua = "#7dcfff"
        local mint = "#9ecea8"
        local gold = "#e0af68"
        local rose = "#f7768e"
        local peach = "#ff9e64"
        local frost = "#89b4fa"
        local lilac = "#bb9af7"
        local sky = "#73daca"

        return {
            default = true,
            color_icons = true,
            strict = true,
            override = {
                default_icon = {
                    icon = "󰈔",
                    color = slate,
                    name = "Default",
                },
            },
            override_by_filename = {
                [".gitignore"] = { icon = "", color = rose, name = "GitIgnore" },
                [".gitattributes"] = { icon = "", color = rose, name = "GitAttributes" },
                [".zshrc"] = { icon = "", color = mint, name = "Zshrc" },
                [".bashrc"] = { icon = "", color = peach, name = "Bashrc" },
                ["README.md"] = { icon = "󰍔", color = aqua, name = "Readme" },
                ["LICENSE"] = { icon = "󰿃", color = gold, name = "License" },
                ["init.lua"] = { icon = "", color = frost, name = "InitLua" },
                ["lazy-lock.json"] = { icon = "󰒲", color = lilac, name = "LazyLock" },
                ["package.json"] = { icon = "󰎙", color = mint, name = "PackageJson" },
                ["tsconfig.json"] = { icon = "", color = aqua, name = "TsConfig" },
                ["tailwind.config.js"] = { icon = "󱏿", color = sky, name = "TailwindConfigJs" },
                ["tailwind.config.ts"] = { icon = "󱏿", color = sky, name = "TailwindConfigTs" },
                ["Dockerfile"] = { icon = "󰡨", color = aqua, name = "Dockerfile" },
            },
            override_by_extension = {
                lua = { icon = "", color = frost, name = "Lua" },
                md = { icon = "󰍔", color = aqua, name = "Markdown" },
                txt = { icon = "󰈙", color = slate, name = "Text" },
                json = { icon = "󰘦", color = gold, name = "Json" },
                toml = { icon = "󰰤", color = peach, name = "Toml" },
                yaml = { icon = "󰈙", color = gold, name = "Yaml" },
                yml = { icon = "󰈙", color = gold, name = "Yml" },
                sh = { icon = "", color = mint, name = "Sh" },
                zsh = { icon = "", color = mint, name = "Zsh" },
                bash = { icon = "", color = peach, name = "Bash" },
                js = { icon = "", color = gold, name = "Js" },
                jsx = { icon = "", color = aqua, name = "Jsx" },
                ts = { icon = "", color = aqua, name = "Ts" },
                tsx = { icon = "", color = sky, name = "Tsx" },
                html = { icon = "", color = peach, name = "Html" },
                css = { icon = "", color = frost, name = "Css" },
                py = { icon = "", color = gold, name = "Python" },
                rs = { icon = "", color = peach, name = "Rust" },
                go = { icon = "", color = sky, name = "Go" },
            },
        }
    end,
}

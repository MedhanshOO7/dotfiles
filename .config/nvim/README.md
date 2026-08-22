# ✦ Neovim configuration

Built to understand the editor, not just use it. Engineered for embedded hardware, high-performance C/C++, full-stack web, Jupyter data science, and distraction-free writing.

![Neovim](https://img.shields.io/badge/Neovim-0.10+-blue.svg?style=flat-square&logo=neovim) ![Lua](https://img.shields.io/badge/Written_in-Lua-blue.svg?style=flat-square&logo=lua) ![Startup Time](https://img.shields.io/badge/Startup_Time-~38ms-green.svg?style=flat-square)

## Who built this

I'm Medhansh — 18, based in Chandigarh. I build from scratch before I reach for a framework.  
Not out of stubbornness. Because the day something breaks, you need to know what's underneath it.

This config is the same philosophy applied to my editor.

Most people inherit a Neovim config. Copy-paste from a Reddit thread, clone someone's dotfiles,  
run `:Lazy sync` and call it done. It works — until it doesn't. Then you're debugging someone  
else's abstractions with no idea what's underneath them.

I wanted to know what was underneath. So I built it myself.

Every plugin here has a reason. Every keybind was a decision. Nothing is in here because  
it came with a starter template.

If that sounds like how you think about software — this config might be useful to you.  
If you just want something that works out of the box, there are better options — [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), [LazyVim](https://github.com/LazyVim/LazyVim), [AstroNvim](https://github.com/AstroNvim/AstroNvim).

---

## 🌟 Highlights & Superpowers

* **⚡ Ultra-Fast Cold Starts (~38ms)**: Built with aggressive bytecode caching, lazy loading, and lightweight pure Lua modules.
* **🔍 Instant Search & Multi-Modal Pickers**: Powered by **`snacks.picker`** with image thumbnails, hidden dotfile search, and git status.
* **🛡️ Interactive Diagnostic Callout Cards**: **`tiny-inline-diagnostic.nvim`** renders compiler-style curved callouts (`╭─`, `╰─`) directly under code errors.
* **🤖 Multi-File Aware AI Agents**: **`CopilotChat.nvim`** + **`supermaven`** equipped with workspace read tools (`glob`, `grep`, `file`, `gitdiff`) and 1-key floating prompt modal (`<leader>cp`).
* **🔬 Embedded & Zephyr RTOS Automation**: Integrated **`overseer.nvim`** templates for `west build`, `west flash --erase`, `west debug`, and bare-metal ARM GDB DAP debugging (`arm-none-eabi-gdb`).
* **📊 Jupyter Data Science & REPL**: Cell-by-cell notebook execution with **`molten-nvim`**, inline image rendering, and **`vim-slime`**.
* **📝 Obsidian & Markdown Studio**: Inline rendered callouts, Unicode tables, auto bullet lists, and live auto-sync in **Zen Browser** (`<leader>np`).
* **🎛️ Unified Distro-Grade `<leader>u` Hub**: Single-key toggles for diagnostics, inlay hints, line numbers, conceal, wrap, spellcheck, and image hover.
* **🔄 Automatic 1-Key Multi-Device Sync**: Press **`<leader>uu`** (or `:ConfigUpdate`) to pull and sync the config across any laptop.

---

## Table of Contents

- [Who built this](#who-built-this)
- [Requirements](#requirements)
- [Installation](#installation)
- [Aesthetics](#aesthetics)
- [Plugins](#plugins)
- [Keybinds](#keybinds)
- [Multi-Device Updating](#multi-device-updating)
- [Special thanks](#special-thanks)

---

## Requirements

This configuration is built for performance and deep tool integration. To ensure everything (including image rendering, Jupyter notebooks, formatting, and linting) works correctly, install the following dependencies.

### Minimum version
* **Neovim v0.10.0+** (v0.11+ / v0.12+ recommended).
* **Python 3.11+** for Molten and language provider support.
* **Zen Browser** (or your preferred browser) for live HTML and Markdown previews.

### System packages

#### Arch Linux
```bash
sudo pacman -S --needed neovim git curl ripgrep fd nodejs npm \
  base-devel unzip python python-pip xdg-utils wl-clipboard man-db lazygit \
  imagemagick kitty make shfmt tree-sitter
```
For the custom dashboard (AUR):
```bash
yay -S pokemon-colorscripts-git
```

#### Debian / Ubuntu
```bash
sudo apt update
sudo apt install -y neovim git curl ripgrep fd-find nodejs npm \
  build-essential unzip python3 python3-venv python3-pip xdg-utils wl-clipboard \
  man-db lazygit imagemagick kitty make shfmt
```

#### Fedora
```bash
sudo dnf install neovim git curl ripgrep fd-find tree-sitter-cli nodejs npm \
  development-tools unzip python3 python3-pip xdg-utils wl-clipboard \
  man-db lazygit imagemagick kitty make shfmt
```

#### macOS (Homebrew)
```bash
brew install neovim git ripgrep fd tree-sitter node python lazygit \
  imagemagick make shfmt stylua
```

### Dedicated Python environment
The configuration uses a dedicated virtual environment for the Python provider and Jupyter (Molten) support:

```bash
# Create the venv
python3 -m venv ~/.venvs/neovim

# Install core dependencies
~/.venvs/neovim/bin/pip install --upgrade pip
~/.venvs/neovim/bin/pip install pynvim jupytext jupyter_client ipykernel nbformat cairosvg pnglatex plotly pyperclip
```

### Recommended terminal
**Kitty** is recommended as it provides native support for the Kitty Graphics Protocol used by `snacks.image` and `molten-nvim` for in-terminal floating image rendering.

---

## Installation

1. Back up your existing Neovim configuration:
   ```bash
   mv ~/.config/nvim ~/.config/nvim.bak
   mv ~/.local/share/nvim ~/.local/share/nvim.bak
   ```
2. Clone this repository directly into your config directory:
   ```bash
   git clone https://github.com/MedhanshOO7/nvim-config.git ~/.config/nvim
   ```
3. Launch Neovim:
   ```bash
   nvim
   ```

On first launch, `lazy.nvim` will automatically bootstrap itself, clone all plugins, build parsers, and install Mason tools.

---

## Aesthetics

* **Colorscheme**: Dynamically managed via a custom theme engine in `lua/utils/theme.lua`. Supports **Matugen** dynamic wallpaper accent extraction, TokyoNight, Catppuccin, Rose Pine, Kanagawa, Nightfox, Gruvbox, VSCode, Dracula, Everforest, Cyberdream, and Pywal.
* **Font**: [JetBrains Mono Nerd Font](https://www.nerdfonts.com/font-downloads), size 16.
* **Top Tabline**: Powered by `barbar.nvim` with smooth pill separators, file icons, and diagnostic badges.
* **Bottom Statusline**: Powered by `lualine.nvim` with solid opaque sections and rounded pill geometry (`` / ``).
* **Fluid Motion**: Powered by `smear-cursor.nvim` for smooth cursor trail animations.
* **Delimiters**: Powered by `rainbow-delimiters.nvim` for colorful nested brackets and scopes.
* **Transparency**: Toggle global glass transparency on the fly using `<leader>uy`.

---

## Plugins

### Package management & core
| Plugin | Purpose |
| :--- | :--- |
| [folke/lazy.nvim](https://github.com/folke/lazy.nvim) | Fast, feature-rich plugin manager with bytecode caching |
| [folke/snacks.nvim](https://github.com/folke/snacks.nvim) | High-performance picker, explorer, dashboard, zen mode, scratchpad, dimming, smooth scroll |
| [folke/which-key.nvim](https://github.com/folke/which-key.nvim) | Interactive keybinding discovery menu |
| [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | Core Lua utility functions |
| [nvim-tree/nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | Standard Nerd Font file icons |

### LSP, completion & diagnostics
| Plugin | Purpose |
| :--- | :--- |
| [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Preconfigured language server configurations |
| [mason-org/mason.nvim](https://github.com/mason-org/mason.nvim) | Portable package manager for LSPs, linters, and formatters |
| [mason-org/mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim) | Bridges mason.nvim with lspconfig |
| [WhoIsSethDaniel/mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) | Automatically ensures all tools are installed |
| [folke/lazydev.nvim](https://github.com/folke/lazydev.nvim) | Full type signatures and autocompletion for Neovim Lua APIs |
| [b0o/schemastore.nvim](https://github.com/b0o/schemastore.nvim) | JSON/YAML schema validation catalog |
| [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Completion engine with LSP, buffer, path, and snippet sources |
| [onsails/lspkind.nvim](https://github.com/onsails/lspkind.nvim) | VS Code-style pictograms for completion items |
| [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Extensible snippet engine |
| [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | Comprehensive community snippet collection |
| [rachartier/tiny-inline-diagnostic.nvim](https://github.com/rachartier/tiny-inline-diagnostic.nvim) | Modern compiler-style curved diagnostic callouts |
| [dnlhc/glance.nvim](https://github.com/dnlhc/glance.nvim) | VS Code-style peek definition, references, and implementations |
| [SmiteshP/nvim-navic](https://github.com/SmiteshP/nvim-navic) | LSP symbol breadcrumbs |

### Editing, formatting & linting
| Plugin | Purpose |
| :--- | :--- |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax parsing and highlighting |
| [nvim-treesitter/nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) | Sticky function/struct context header at top of buffer |
| [nvim-treesitter/nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) | Treesitter-aware functions, classes, and parameter textobjects |
| [windwp/nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) | Auto close and rename HTML/JSX tags |
| [Wansmer/treesj](https://github.com/Wansmer/treesj) | Split and join code blocks |
| [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim) | High-speed asynchronous formatter engine |
| [mfussenegger/nvim-lint](https://github.com/mfussenegger/nvim-lint) | Asynchronous linter engine |
| [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto-close brackets and quotes |
| [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim) | Smart commenting with line and block motions |
| [kylechui/nvim-surround](https://github.com/kylechui/nvim-surround) | Add, change, and delete surrounding delimiters (`ys`, `cs`, `ds`) |
| [jake-stewart/multicursor.nvim](https://github.com/jake-stewart/multicursor.nvim) | True multiple cursors with mouse and keyboard bindings |
| [smjonas/inc-rename.nvim](https://github.com/smjonas/inc-rename.nvim) | Live incremental symbol renaming |
| [ThePrimeagen/refactoring.nvim](https://github.com/ThePrimeagen/refactoring.nvim) | Extract function, extract variable, and code refactoring |
| [echasnovski/mini.ai](https://github.com/echasnovski/mini.ai) | Extended text objects for functions, classes, and tags |
| [gbprod/yanky.nvim](https://github.com/gbprod/yanky.nvim) | Improved yank and put with cycle history ring |
| [okuuva/auto-save.nvim](https://github.com/okuuva/auto-save.nvim) | Automatic buffer saving |

### Navigation & search
| Plugin | Purpose |
| :--- | :--- |
| [folke/snacks.nvim](https://github.com/folke/snacks.nvim) (`picker`) | Ultra-fast fuzzy finder for files, buffers, grep, git, and symbols |
| [ThePrimeagen/harpoon](https://github.com/ThePrimeagen/harpoon) | Lightning-fast file pinning and switching |
| [folke/flash.nvim](https://github.com/folke/flash.nvim) | 2D motion navigation with 2-character search labels |
| [MagicDuck/grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim) | Project-wide find and replace |
| [stevearc/aerial.nvim](https://github.com/stevearc/aerial.nvim) | Live code outline sidebar |
| [folke/trouble.nvim](https://github.com/folke/trouble.nvim) | Diagnostics, references, and results list |
| [folke/todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Highlight and search `TODO`, `NOTE`, `FIX`, `PERF` comments |
| [stevearc/oil.nvim](https://github.com/stevearc/oil.nvim) | Edit your filesystem like a standard text buffer (`-`) |
| [mbbill/undotree](https://github.com/mbbill/undotree) | Visual undo history graph |

### UI & visual polish
| Plugin | Purpose |
| :--- | :--- |
| [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Solid opaque statusline with rounded pill caps (`` / ``) |
| [romgrk/barbar.nvim](https://github.com/romgrk/barbar.nvim) | Sleek buffer tabline with close glyphs and diagnostic counters |
| [folke/noice.nvim](https://github.com/folke/noice.nvim) | Modern cmdline popup, floating notifications, and doc borders |
| [sphamba/smear-cursor.nvim](https://github.com/sphamba/smear-cursor.nvim) | Fluid cursor trail animation |
| [HiPhish/rainbow-delimiters.nvim](https://github.com/HiPhish/rainbow-delimiters.nvim) | Vibrant rainbow-colored matching brackets |
| [NvChad/nvim-colorizer.lua](https://github.com/NvChad/nvim-colorizer.lua) | Virtual text color swatches (`██`) without background highlight clutter |
| [kevinhwang91/nvim-ufo](https://github.com/kevinhwang91/nvim-ufo) | Ultra fold preview and provider |
| [RRethy/vim-illuminate](https://github.com/RRethy/vim-illuminate) | Highlight other uses of the word under cursor |
| [j-hui/fidget.nvim](https://github.com/j-hui/fidget.nvim) | Non-intrusive LSP progress spinner in bottom right |
| [m4xshen/smartcolumn.nvim](https://github.com/m4xshen/smartcolumn.nvim) | Smart color column that only appears past 80/100 chars |
| [stevearc/quicker.nvim](https://github.com/stevearc/quicker.nvim) | Quickfix list enhancements with inline editing |
| [rachartier/tiny-code-action.nvim](https://github.com/rachartier/tiny-code-action.nvim) | Code actions menu with live diff preview |

### Git
| Plugin | Purpose |
| :--- | :--- |
| [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Inline git blame, gutter diff signs, hunk staging |
| [NeogitOrg/neogit](https://github.com/NeogitOrg/neogit) | Magit-like full Git management panel |
| [sindrets/diffview.nvim](https://github.com/sindrets/diffview.nvim) | Interactive side-by-side diff and merge viewer |
| [folke/snacks.nvim](https://github.com/folke/snacks.nvim) (`lazygit`) | Floating Lazygit terminal panel (`<leader>gl`) |

### Development, Embedded & Debugging
| Plugin | Purpose |
| :--- | :--- |
| [mfussenegger/nvim-dap](https://github.com/mfussenegger/nvim-dap) | Debug Adapter Protocol client with embedded GDB support |
| [rcarriga/nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | Full visual debugger layout (scopes, breakpoints, stacks, watches) |
| [theHamsta/nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text) | Live variable values rendered as virtual text |
| [nvim-neotest/neotest](https://github.com/nvim-neotest/neotest) | Test runner with Python, Plenary, Jest, and GTest adapters |
| [stevearc/overseer.nvim](https://github.com/stevearc/overseer.nvim) | Task runner with **Zephyr RTOS** `west build`, `west flash --erase`, and `west debug` |
| [Civitasv/cmake-tools.nvim](https://github.com/Civitasv/cmake-tools.nvim) | CMake configure, build, and run integration |
| [p00f/clangd_extensions.nvim](https://github.com/p00f/clangd_extensions.nvim) | Clangd AST hierarchy, type formatting, and inlay hints |
| [linux-cultist/venv-selector.nvim](https://github.com/linux-cultist/venv-selector.nvim) | Auto-detect and switch Python virtual environments |
| [kristijanhusak/vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui) | Database browser and interactive SQL editor |
| [barrett-ruth/live-server.nvim](https://github.com/barrett-ruth/live-server.nvim) | Live web development server synced to **Zen Browser** |
| [jpalardy/vim-slime](https://github.com/jpalardy/vim-slime) | Seamless line and selection REPL sender |

### AI assistants
| Plugin | Purpose |
| :--- | :--- |
| [zbirenbaum/copilot.lua](https://github.com/zbirenbaum/copilot.lua) | GitHub Copilot inline ghost text completion |
| [CopilotC-Nvim/CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim) | Multi-file aware Copilot Chat with workspace tools (`glob`, `grep`, `file`) |
| [supermaven-inc/supermaven-nvim](https://github.com/supermaven-inc/supermaven-nvim) | Ultra-fast Supermaven inline AI completion |
| [olimorris/codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) | AI inline assistant and prompt actions |

### Notes, Markdown & Jupyter
| Plugin | Purpose |
| :--- | :--- |
| [MeanderingProgrammer/render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Rich in-buffer rendered headings, callouts, checkboxes, and pipe tables |
| [epwalsh/obsidian.nvim](https://github.com/epwalsh/obsidian.nvim) | Obsidian vault integration, wikilinks, daily notes, and tags |
| [ice345/markdown-table-wrap.nvim](https://github.com/ice345/markdown-table-wrap.nvim) | Formatted markdown table viewer and wrapping |
| [iamcco/markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Live auto-sync browser preview in **Zen Browser** (`<leader>np`) |
| [benlubas/molten-nvim](https://github.com/benlubas/molten-nvim) | Interactive Jupyter REPL and notebook runner |
| [gaoDean/autolist.nvim](https://github.com/gaoDean/autolist.nvim) | Automatic bullet list continuation and smart renumbering |

---

## Keybinds

The leader key is set to `<Space>`.

### Files, Search & Pickers (`Snacks.picker`)
| Key | Action | Engine |
| :--- | :--- | :--- |
| `<leader><space>` | Smart Find Files (smart priority) | snacks.picker |
| `<leader>e` | Open Project File Explorer | snacks.explorer |
| `-` | Edit filesystem as text buffer | oil.nvim |
| `<leader>ff` | Find files by name | snacks.picker |
| `<leader>fg` | Live grep workspace text | snacks.picker |
| `<leader>fr` | Browse recent files | snacks.picker |
| `<leader>bb` | Browse open buffers | snacks.picker |
| `<leader>bd` | Delete current buffer cleanly | snacks.bufdelete |
| `<leader>fp` | Find tracked project files | snacks.picker |
| `<leader>fS` / `<leader>lo` | Document symbols outline | snacks.picker |
| `<leader>fw` / `<leader>ls` | Workspace symbols search | snacks.picker |
| `<leader>fu` | Visual undo history | snacks.picker |
| `<leader>ft` | Find TODO / NOTE / FIX comments | todo-comments |
| `<leader>p` | Command palette | snacks.picker |
| `<leader>?` / `<leader>fk` | Interactive keymap finder (VS Code style) | snacks.picker |
| `<leader>sr` | Project-wide find and replace | grug-far |
| `<leader>si` | Browse workspace images (floating preview) | snacks.picker |
| `<leader>sj` | Jump anywhere on screen | flash.nvim |

### Code Navigation, LSP & Refactoring
| Key | Action | Engine |
| :--- | :--- | :--- |
| `gd` | Go to definition | LSP |
| `gpd` | **Peek Definition** in float overlay | glance.nvim |
| `gpr` | **Peek References** in float overlay | glance.nvim |
| `gpi` | **Peek Implementations** in float overlay | glance.nvim |
| `gpt` | **Peek Type Definitions** in float overlay | glance.nvim |
| `gr` | List references | LSP |
| `gi` | Go to implementation | LSP |
| `K` | Hover documentation | LSP |
| `<leader>ca` | Code actions with live diff preview | tiny-code-action |
| `<leader>cf` | Format current file | conform.nvim |
| `<leader>rn` | Live incremental rename | inc-rename.nvim |
| `<leader>ce` | Extract function (visual selection) | refactoring.nvim |
| `<leader>cv` | Extract variable (visual selection) | refactoring.nvim |
| `<leader>ci` | Inline variable | refactoring.nvim |
| `[d` / `]d` | Jump to previous / next diagnostic | Builtin |
| `<leader>xx` | Diagnostics list | trouble.nvim |

### Distro-Grade UI & System Toggle Hub (`<leader>u...`)
| Key | Action | Visual Status |
| :--- | :--- | :--- |
| **`<leader>uu`** | **Update Neovim Config (Git Pull & Sync)** | ` Synced commits` |
| **`<leader>ud`** | **Toggle LSP Diagnostics** | `󰒕 ON` / `󰂭 OFF` |
| **`<leader>uh`** | **Toggle LSP Inlay Hints** | `󰌵 ON` / `󰂭 OFF` |
| **`<leader>ul`** | **Toggle Relative Line Numbers** | Absolute / Relative |
| **`<leader>uc`** | **Toggle Conceal Level** | Level 0 / 2 |
| **`<leader>ux`** | **Toggle Treesitter Sticky Context** | Header on/off |
| **`<leader>ui`** | **Toggle Hovering Image Previews** | `󰋩 ON` / `󰂭 OFF` |
| **`<leader>us`** | **Toggle Spellcheck** | Spell on/off |
| **`<leader>uw`** | **Toggle Word Wrap** | Wrap on/off |
| **`<leader>ua`** | **Toggle Auto-Save (Global)** | Auto-save on/off |
| **`<leader>ub`** | **Toggle Auto-Save (Buffer)** | Buffer auto-save |
| **`<leader>uy`** | **Toggle Background Transparency** | Opaque / Glass |
| **`<leader>ut`** | **Choose Theme** | Theme picker |
| **`<leader>un`** | **Notification History / Next Theme** | snacks.notifier |

### AI Coding & Chat
| Key | Action | Engine |
| :--- | :--- | :--- |
| `<leader>cp` / `<leader>Cq` | **Floating Ask Copilot Prompt Box** | CopilotChat |
| `<leader>Cc` / `<leader>co` | Toggle Copilot Chat Sidebar | CopilotChat |
| `<leader>Ce` | Copilot Explain Code (visual selection) | CopilotChat |
| `<leader>Cf` | Copilot Fix Bug (visual selection) | CopilotChat |
| `<leader>CD` | Copilot Write Documentation | CopilotChat |
| `<leader>Ct` | Copilot Generate Unit Tests | CopilotChat |
| `<leader>Cg` | Copilot Generate Commit Message | CopilotChat |
| `<leader>CM` | Switch Copilot Model | CopilotChat |

### Markdown, Notes & Writing
| Key | Action | Engine |
| :--- | :--- | :--- |
| `<leader>np` / `<leader>mp` | **Markdown Preview in Zen Browser (Auto-Sync)** | markdown-preview |
| `<leader>z` | **Toggle Zen Focus Mode** | snacks.zen |
| `<leader>Z` | Toggle Zoom Window | snacks.zen |
| `<leader>ih` | Hover preview image under cursor | snacks.image |
| `<leader>mTi` | Toggle markdown table inline view | markdown-table-wrap |
| `<leader>mTr` | Toggle markdown table reader view | markdown-table-wrap |
| `<leader>on` | Obsidian: New note | obsidian.nvim |
| `<leader>of` | Obsidian: Find notes | obsidian.nvim |
| `<leader>ot` | Obsidian: Daily note | obsidian.nvim |
| `<leader>ob` | Obsidian: Show backlinks | obsidian.nvim |

### Development, Embedded & Tasks
| Key | Action | Engine |
| :--- | :--- | :--- |
| `<leader>lv` | **Start Live Web Server (Zen Browser)** | live-server.nvim |
| `<leader>lV` | Stop Live Web Server | live-server.nvim |
| `<leader>tr` | Run task (**Zephyr `west build`, `west flash`**) | overseer.nvim |
| `<leader>tt` | Toggle task list panel | overseer.nvim |
| `<leader>db` / `<F9>` | Toggle breakpoint | nvim-dap |
| `<F5>` | Start / Continue Debugging (ARM GDB / Python) | nvim-dap |
| `<S-F5>` | Terminate Debugging Session | nvim-dap |
| `<leader>du` | Toggle DAP Debugger UI | nvim-dap-ui |
| `<leader>Tnr` | Run nearest unit test | neotest |
| `<leader>Tnf` | Run current test file | neotest |
| `<leader>rs` | Send selection to REPL | vim-slime |
| `<leader>rl` | Send line to REPL | vim-slime |
| `<leader>mi` | Initialize Molten Jupyter kernel | molten-nvim |
| `<leader>me` | Evaluate Molten cell operator | molten-nvim |
| `<leader>ml` | Evaluate Molten line | molten-nvim |

---

## Multi-Device Updating

If you run this configuration across multiple laptops or work machines:
1. Open Neovim.
2. Press **`<leader>uu`** (or execute **`:ConfigUpdate`**).
3. Neovim will pull the latest changes, report synced commits, and automatically run `Lazy sync` in the background.

---

## Special thanks

* [LazyVim](https://github.com/LazyVim/LazyVim) & [folke](https://github.com/folke) - For creating `snacks.nvim`, `lazy.nvim`, `flash.nvim`, and setting the modern Neovim standard.
* [NvChad](https://github.com/NvChad/NvChad) - For colorizer and dynamic aesthetic inspiration.
* [AstroNvim](https://github.com/AstroNvim/AstroNvim) - For UI toggle concepts.
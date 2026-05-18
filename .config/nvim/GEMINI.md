# Neovim Configuration Overview

This directory contains a highly customized, modular Neovim configuration designed to provide a complete, IDE-like experience. The configuration is written entirely in Lua and uses `lazy.nvim` for package management.

## Project Architecture

The codebase is organized with a clear separation of concerns to ensure scalability, reliability, and maintainability:

- **`init.lua`**: The main entry point. It sets up basic globals (like `<leader>` keys) and bootstraps the rest of the configuration.
- **`lua/core/`**: Contains the foundational settings.
    - `options.lua`: Core Neovim options (UI, behavior, folding, etc.).
    - `keymaps.lua`: Global keybindings and custom commands.
    - `lazy.lua`: The `lazy.nvim` bootstrapper that loads the plugin specs.
- **`lua/plugins/`**: Individual plugin specifications loaded dynamically. Each file usually handles the configuration for one plugin (or a closely related group of plugins).
- **`lua/lsp/`**: Language Server configurations.
    - `servers.lua`: A clean, isolated dictionary defining the settings and features for each LSP server (e.g., `clangd`, `pyright`, `ts_ls`, `lua_ls`).
- **`lua/utils/`**: Helper utilities and custom workflows.
    - `theme.lua`: Handles dynamic theme switching and transparency.
    - `writing.lua`: Toggles a custom distraction-free "writing mode."

## Key Technologies & Plugins

- **Package Management**: [lazy.nvim](https://github.com/folke/lazy.nvim)
- **LSP & Completion**: `nvim-lspconfig` (configured natively via `vim.lsp.config` for Neovim 0.11+), `mason.nvim` (for downloading servers), and `nvim-cmp`.
- **Syntax & Parsing**: `nvim-treesitter` (with numerous parsers installed).
- **Formatting & Linting**: `conform.nvim` (auto-formatting disabled by default, triggered manually) and `nvim-lint`.
- **UI & Navigation**:
    - `telescope.nvim` (Fuzzy finding)
    - `neo-tree.nvim` (File explorer)
    - `lualine.nvim` (Statusline)
    - `bufferline.nvim` (Buffer tabs, easily switched via `<C-1>`, `<C-2>`, etc.)
- **Terminal**: `toggleterm.nvim` (Accessible via `<C-\`>`)
- **Data Science / Notebooks**: `molten-nvim` (Configured specifically to use the `kitty` terminal image backend for rich visual outputs).

## Development Conventions & Workflows

1.  **Adding Plugins**: New plugins should be added as `.lua` files inside the `lua/plugins/` directory, following the `lazy.nvim` specification format.
2.  **LSP Modifications**: To add or configure a new language server, modify `lua/lsp/servers.lua` and ensure it's listed in the `mason-lspconfig` `ensure_installed` array within `lua/plugins/lsp.lua`.
3.  **Keybindings**: Global keybindings reside in `lua/core/keymaps.lua`. Plugin-specific keybindings (like LSP actions) are often defined inside the plugin's `config` function or an `on_attach` callback. You can press `<leader>fk` or `<leader>?` to browse a comprehensive, searchable list of all active keymaps.
4.  **Health Checks**: Neovim's health can be validated by running `:checkhealth` within the editor.

## Common Keybindings

| Keybinding         | Action                         |
| :----------------- | :----------------------------- |
| `<leader>e`        | Toggle file explorer           |
| `<C-\`>`           | Toggle floating terminal       |
| `<C-1>` to `<C-9>` | Switch to specific buffer tabs |
| `<leader>cf`       | Format the current file        |
| `<leader>uf`       | Toggle "format on save"        |
| `<leader>rr`       | Run the current file           |
| `<leader>ff`       | Find files (Telescope)         |
| `<leader>fg`       | Live grep project (Telescope)  |

> Note: The leader key is mapped to `<Space>`.

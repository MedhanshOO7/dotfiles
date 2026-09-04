# System Requirements

Verified and tested on Linux (Arch / Ubuntu / Fedora), macOS, and Windows 10/11.

This file lists the packages and system dependencies required for full functionality across all operating systems. Everything handled by `lazy.nvim` and `mason.nvim` is installed automatically unless it requires a system runtime.

### Core expectations:

- Python virtual environment (`~/.venvs/neovim` on Unix, `$HOME\.venvs\neovim` on Windows) with `pynvim` and Jupyter tools
- `git`, `ripgrep` (`rg`), `fd`, `tree-sitter-cli`, `node` + `npm`
- A C/C++ compiler toolchain (GCC / Clang / MSVC) for Treesitter parser compilation and code runner
- A Nerd Font (e.g. JetBrainsMono Nerd Font)
- Optional: `lazygit`, `imagemagick`, `kitty` (Unix) or `Windows Terminal` (Windows)

---

## Windows Setup (PowerShell / Windows Terminal)

> [!TIP]
> For a full Windows guide with aesthetic Windows Terminal configurations, `Ctrl+G` quick-launch shortcuts, and troubleshooting common path/symlink issues, see the dedicated [Windows Setup Guide (windows.md)](windows.md).

### 1. Install System Packages via Winget

Open PowerShell (or Windows Terminal) as Administrator or regular user:

```powershell
winget install --id Neovim.Neovim -e
winget install --id Git.Git -e
winget install --id BurntSushi.ripgrep.MSVC -e
winget install --id sharkdp.fd -e
winget install --id tree-sitter.tree-sitter -e
winget install --id OpenJS.NodeJS.LTS -e
winget install --id Python.Python.3.12 -e
winget install --id JesseDuffield.lazygit -e
winget install --id LLVM.LLVM -e
winget install --id 7zip.7zip -e
winget install --id Microsoft.WindowsTerminal -e
winget install --id NerdFonts.JetBrainsMono -e
```

*Or install all in a single command:*

```powershell
winget install Neovim.Neovim Git.Git BurntSushi.ripgrep.MSVC sharkdp.fd tree-sitter.tree-sitter OpenJS.NodeJS.LTS Python.Python.3.12 JesseDuffield.lazygit LLVM.LLVM 7zip.7zip Microsoft.WindowsTerminal NerdFonts.JetBrainsMono
```

*(Alternative package managers: `scoop install neovim git ripgrep fd tree-sitter nodejs python lazygit llvm 7zip` or `choco install neovim git ripgrep fd treesitter nodejs python lazygit llvm 7zip`)*

### 2. Create the Dedicated Python Host Environment

```powershell
# Create virtual environment in $HOME\.venvs\neovim
python -m venv "$HOME\.venvs\neovim"

# Upgrade pip and install required Neovim / Molten dependencies
& "$HOME\.venvs\neovim\Scripts\pip.exe" install --upgrade pip
& "$HOME\.venvs\neovim\Scripts\pip.exe" install pynvim jupytext jupyter_client ipykernel nbformat cairosvg pnglatex plotly pyperclip
```

### 3. Clone and Setup the Configuration

```powershell
# Backup existing config if present
Rename-Item -Path "$env:LOCALAPPDATA\nvim" -NewName "nvim.bak" -ErrorAction SilentlyContinue
Rename-Item -Path "$env:LOCALAPPDATA\nvim-data" -NewName "nvim-data.bak" -ErrorAction SilentlyContinue

# Clone this repo into Windows Neovim config directory
git clone https://github.com/codebyneeraj/nvim-config.git "$env:LOCALAPPDATA\nvim"

# Launch Neovim
nvim
```

---

## Arch Linux

```bash
sudo pacman -S --needed neovim git curl ripgrep fd tree-sitter-cli nodejs npm \
  base-devel unzip python python-pip xdg-utils wl-clipboard man-db lazygit \
  imagemagick kitty make shfmt
```

For the Pokémon dashboard (AUR):

```bash
yay -S pokemon-colorscripts-git
```

Create the Python host environment:

```bash
python -m venv ~/.venvs/neovim
~/.venvs/neovim/bin/pip install --upgrade pip
~/.venvs/neovim/bin/pip install pynvim jupytext jupyter_client ipykernel nbformat cairosvg pnglatex plotly pyperclip
```

---

## Debian / Ubuntu

```bash
sudo apt update
sudo apt install -y neovim git curl ripgrep fd-find tree-sitter-cli nodejs npm \
  build-essential unzip python3 python3-venv python3-pip xdg-utils wl-clipboard \
  man-db lazygit imagemagick kitty make shfmt
```

Debian / Ubuntu symlink for `fd`:

```bash
mkdir -p ~/.local/bin
ln -sf "$(command -v fdfind)" ~/.local/bin/fd
```

Create the Python host environment:

```bash
python3 -m venv ~/.venvs/neovim
~/.venvs/neovim/bin/pip install --upgrade pip
~/.venvs/neovim/bin/pip install pynvim jupytext jupyter_client ipykernel nbformat cairosvg pnglatex plotly pyperclip
```

---

## macOS (Homebrew)

> [!TIP]
> For a full macOS guide with aesthetic Ghostty / Kitty / WezTerm / iTerm2 configurations, `Ctrl+G` quick-launch shortcuts, Apple Silicon notes, and troubleshooting common Option key / PATH issues, see the dedicated [macOS Setup Guide (macos.md)](macos.md).

### 1. Install Xcode Command Line Tools (Compilers & SDKs)

```bash
xcode-select --install
```

### 2. Install System Packages & Nerd Font via Homebrew

```bash
brew install neovim git ripgrep fd tree-sitter node python@3.12 lazygit imagemagick make shfmt stylua
brew install --cask font-jetbrains-mono-nerd-font
```

### 3. Create the Dedicated Python Host Environment

```bash
python3 -m venv ~/.venvs/neovim
~/.venvs/neovim/bin/pip install --upgrade pip
~/.venvs/neovim/bin/pip install pynvim jupytext jupyter_client ipykernel nbformat cairosvg pnglatex plotly pyperclip
```

### 4. Clone and Setup the Configuration

```bash
# Backup existing config if present
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null

# Clone this repo into macOS Neovim config directory
git clone https://github.com/codebyneeraj/nvim-config.git ~/.config/nvim

# Launch Neovim
nvim
```

---

## What each requirement is for:

- `neovim`: Core editor (v0.10+ required, v0.11+ / v0.12+ recommended)
- `git`, `curl`: Plugin bootstrapping and `:ConfigUpdate` syncing
- `ripgrep` (`rg`), `fd`: Instant fuzzy search, grep, and file discovery via `snacks.picker`
- `tree-sitter-cli`, C/C++ compiler (`gcc`/`clang`): Compiling Treesitter grammars and syntax trees
- `node`, `npm`: Markdown preview, LSP servers, and web tooling
- `python`, `pynvim`: Python provider, Molten notebook execution, and debugpy
- `lazygit`: Floating interactive git interface (`<leader>gl`)
- `Nerd Font`: Icons for filetypes, diagnostic glyphs, statuslines, and tabs
- `imagemagick` & terminal graphics (`kitty`/`wezterm`/`windows terminal`): Terminal image rendering

---

## Managed Automatically by Mason

Mason handles the following language servers, formatters, and debug adapters out of the box (no need to install manually):

- **LSPs**: `lua_ls`, `clangd`, `basedpyright`, `pylsp`, `vtsls`, `html`, `cssls`, `tailwindcss`, `emmet_language_server`, `jsonls`, `yamlls`, `marksman`, `qmlls`, `sqls`, `bashls`
- **Formatters**: `stylua`, `clang-format`, `ruff`, `prettier`, `prettierd`, `shfmt`, `sql-formatter`
- **Linters**: `selene`, `ruff`, `eslint_d`, `markdownlint`, `shellcheck`
- **Debuggers**: `codelldb`, `debugpy`, `js-debug-adapter`

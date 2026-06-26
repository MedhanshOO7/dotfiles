# System Requirements

Bro, verified this on my Arch install on 2026-05-18. It works flawlessly. 

This file lists the packages you actually need to install yourself. Everything handled by `lazy.nvim`, `mason.nvim` is left out unless it needs a system runtime. 

My config expects:
- `~/.venvs/neovim/bin/python` to exist (don't skip this)
- `pynvim` installed in that venv
- `git`, `rg`, `fd`, `tree-sitter`, `node`, and a C/C++ toolchain 
- `man` support cause I use Neovim as a manpager
- `imagemagick` for `image.nvim`
- `pokemon-colorscripts` for my sick dashboard
- `kitty` as your terminal (seriously, use kitty)

## Arch Linux (I use Arch btw)

Just install these from the official repos:

```bash
sudo pacman -S --needed neovim git curl ripgrep fd tree-sitter-cli nodejs npm \
  base-devel unzip python python-pip xdg-utils wl-clipboard man-db lazygit \
  imagemagick kitty
```

For the Pokémon dashboard (it's in the AUR):
```bash
# Using yay:
yay -S pokemon-colorscripts-git
```

Create the Python host environment:
```bash
python -m venv ~/.venvs/neovim
~/.venvs/neovim/bin/pip install --upgrade pip
~/.venvs/neovim/bin/pip install pynvim 
```

Why u need this stuff:
- `neovim`: duh
- `kitty`: required for `image.nvim` to actually work.
- `imagemagick`: allows Neovim to parse images.
- `pokemon-colorscripts`: the ASCII art generator for the startup screen.
- `git` and `curl`: plugin bootstrap
- `ripgrep`: Telescope and search 
- `fd`: fast file discovery
- `tree-sitter-cli`: parser tooling
- `nodejs` and `npm`: markdown preview and Mason tooling 
- `base-devel` and `unzip`: native plugin compilation
- `python`, `python-pip`: Python provider
- `xdg-utils`: open URLs 
- `wl-clipboard`: Wayland clipboard support
- `man-db`: manpager workflow
- `lazygit`: the visual Git UI (`<leader>gl`)

## Debian / Ubuntu (if u have to)

If you're stuck on Debian/Ubuntu:

```bash
sudo apt update
sudo apt install -y neovim git curl ripgrep fd-find tree-sitter-cli nodejs npm \
  build-essential unzip python3 python3-venv python3-pip xdg-utils wl-clipboard \
  man-db lazygit imagemagick kitty
```

Debian ships `fd-find` as `fdfind` so u gotta symlink it:
```bash
mkdir -p ~/.local/bin
ln -sf "$(command -v fdfind)" ~/.local/bin/fd
```

You'll need to manually compile/install `pokemon-colorscripts` from GitLab since it's not in the APT repos lol.

## macOS (Homebrew)

```bash
brew install neovim git ripgrep fd tree-sitter-cli node python lazygit imagemagick
```

macOS users also need to manually build `pokemon-colorscripts`.

## Not Included On Purpose

Mason handles these so don't install them system-wide or it'll conflict:
- `clangd`, `black`, `ruff`, `prettier`, `stylua`
- Debuggers: `debugpy`, `codelldb`, `js-debug-adapter`
- Testing Adapters: `neotest-gtest`, `neotest-jest`, etc.

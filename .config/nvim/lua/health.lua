local M = {}

M.check = function()
    vim.health.start("System & OS Environment")

    local uname = vim.uv.os_uname()
    local is_mac = uname.sysname == "Darwin"
    local is_win = vim.fn.has("win32") == 1
    local is_linux = uname.sysname == "Linux"

    local os_str = uname.sysname .. " " .. uname.release .. " (" .. uname.machine .. ")"
    vim.health.ok("Operating System: " .. os_str)

    -- macOS Specific Environment
    if is_mac then
        local xcode_clt = vim.fn.system("xcode-select -p 2>/dev/null")
        if vim.v.shell_error == 0 and xcode_clt ~= "" then
            vim.health.ok("Xcode Command Line Tools installed: " .. vim.trim(xcode_clt))
        else
            vim.health.warn("Xcode Command Line Tools not detected. Run: xcode-select --install")
        end

        if vim.fn.executable("brew") == 1 then
            vim.health.ok("Homebrew package manager detected: " .. vim.fn.exepath("brew"))
        else
            vim.health.warn("Homebrew not found in PATH. Recommended for macOS: https://brew.sh")
        end
    elseif is_linux then
        local session_type = vim.env.XDG_SESSION_TYPE or "unknown"
        vim.health.info("Linux Session Type: " .. session_type)
    elseif is_win then
        if vim.fn.executable("winget") == 1 then
            vim.health.ok("Winget package manager detected")
        end
    end

    -- Terminal & Graphics Environment
    local term_program = vim.env.TERM_PROGRAM or vim.env.TERM or "unknown"
    if vim.env.GHOSTTY_RESOURCES_DIR then
        vim.health.ok("Terminal Emulator: Ghostty (Kitty Graphics Protocol supported)")
    elseif vim.env.KITTY_PID then
        vim.health.ok("Terminal Emulator: Kitty (Kitty Graphics Protocol supported)")
    elseif vim.env.WEZTERM_PANE then
        vim.health.ok("Terminal Emulator: WezTerm (Terminal Graphics supported)")
    else
        vim.health.info("Terminal: " .. term_program)
    end

    -- ── Core Host Binaries ──────────────────────────────────────────
    vim.health.start("Core Host Dependencies")

    local function check_bin(bin_name, desc, required, alt_bin)
        local found = vim.fn.executable(bin_name) == 1
        if not found and alt_bin then
            found = vim.fn.executable(alt_bin) == 1
            if found then
                bin_name = alt_bin
            end
        end

        if found then
            vim.health.ok(desc .. " (" .. bin_name .. "): " .. vim.fn.exepath(bin_name))
        elseif required then
            vim.health.error(desc .. " (" .. bin_name .. ") is missing. Required for full functionality.")
        else
            vim.health.warn(desc .. " (" .. bin_name .. ") is missing.")
        end
        return found
    end

    check_bin("git", "Git version control", true)
    check_bin("rg", "ripgrep (fuzzy search engine)", true)
    check_bin("fd", "fd (fast file finder)", true, "fdfind")
    check_bin("tree-sitter", "Tree-sitter CLI (parser generator)", false)
    check_bin("node", "Node.js (LSP & web tooling runtime)", true)
    check_bin("npm", "npm package manager", true)
    check_bin("make", "GNU Make (native module builds)", false)

    -- ── C/C++ Compiler Toolchain ────────────────────────────────────
    vim.health.start("C/C++ Compiler Toolchain")
    local has_clang = vim.fn.executable("clang") == 1
    local has_gcc = vim.fn.executable("gcc") == 1
    local has_cl = vim.fn.executable("cl") == 1

    if has_clang then
        vim.health.ok("Clang compiler detected: " .. vim.fn.exepath("clang"))
    elseif has_gcc then
        vim.health.ok("GCC compiler detected: " .. vim.fn.exepath("gcc"))
    elseif has_cl then
        vim.health.ok("MSVC compiler detected: " .. vim.fn.exepath("cl"))
    else
        vim.health.warn("No C/C++ compiler detected in PATH (clang/gcc/cl). Required for Treesitter parser compilation.")
    end

    -- ── System Clipboard ───────────────────────────────────────────
    vim.health.start("System Clipboard")
    if is_mac then
        if vim.fn.executable("pbcopy") == 1 and vim.fn.executable("pbpaste") == 1 then
            vim.health.ok("macOS native clipboard provider (pbcopy/pbpaste) active")
        else
            vim.health.warn("pbcopy/pbpaste not found in PATH")
        end
    elseif is_linux then
        if vim.fn.executable("wl-copy") == 1 then
            vim.health.ok("Wayland clipboard provider (wl-clipboard) active")
        elseif vim.fn.executable("xclip") == 1 then
            vim.health.ok("X11 clipboard provider (xclip) active")
        elseif vim.fn.executable("xsel") == 1 then
            vim.health.ok("X11 clipboard provider (xsel) active")
        else
            vim.health.warn("No Linux clipboard tool found. Install wl-clipboard (Wayland) or xclip (X11).")
        end
    elseif is_win then
        if vim.fn.executable("win32yank.exe") == 1 or vim.fn.executable("win32yank") == 1 then
            vim.health.ok("Windows clipboard provider (win32yank) active")
        else
            vim.health.info("Using standard Windows PowerShell/system clipboard")
        end
    end

    -- ── Python Virtual Environment (Molten & Jupyter) ──────────────
    vim.health.start("Python Virtual Environment (Molten & Jupyter)")

    local python_path = vim.fn.expand("~/.venvs/neovim/bin/python")
    if vim.fn.executable(python_path) ~= 1 then
        python_path = vim.fn.expand("~/.venvs/neovim/Scripts/python.exe")
    end

    if vim.fn.executable(python_path) == 1 then
        vim.health.ok("Dedicated Python virtual environment found: " .. python_path)
    elseif vim.fn.executable("python3") == 1 then
        vim.health.warn("Default system python3 found. Recommended: python -m venv ~/.venvs/neovim")
    elseif vim.fn.executable("python") == 1 then
        vim.health.warn("Default system python found. Recommended: python -m venv ~/.venvs/neovim")
    else
        vim.health.error("No python3 provider detected.")
    end

    local jupytext_path = vim.fn.expand("~/.venvs/neovim/bin/jupytext")
    if vim.fn.executable(jupytext_path) ~= 1 then
        jupytext_path = vim.fn.expand("~/.venvs/neovim/Scripts/jupytext.exe")
    end
    if vim.fn.executable(jupytext_path) == 1 or vim.fn.executable("jupytext") == 1 then
        vim.health.ok("Jupytext installed (Molten notebook conversion supported)")
    else
        vim.health.warn("Jupytext missing. Molten notebook conversion requires jupytext in python venv.")
    end

    -- ── Optional Tools & Aesthetics ────────────────────────────────
    vim.health.start("Optional Tools & Visual Polish")

    if vim.fn.executable("magick") == 1 or vim.fn.executable("convert") == 1 then
        vim.health.ok("ImageMagick detected (terminal image rendering enabled)")
    else
        vim.health.info("ImageMagick missing (install imagemagick for image hover/thumbnails)")
    end

    if vim.fn.executable("lazygit") == 1 then
        vim.health.ok("lazygit detected for floating Git UI (<leader>gl)")
    else
        vim.health.info("lazygit missing (install lazygit for floating git UI)")
    end

    if vim.fn.executable("delta") == 1 then
        vim.health.ok("git-delta detected for side-by-side code actions")
    else
        vim.health.info("git-delta missing (code actions using clean vim diff fallback)")
    end

    if vim.fn.executable("colorscript") == 1 then
        vim.health.ok("pokemon-colorscripts detected for dashboard header")
    else
        vim.health.info("colorscript missing (dashboard using clean fallback banner)")
    end

    if vim.fn.executable("cmake") == 1 and vim.fn.executable("ninja") == 1 then
        vim.health.ok("CMake and Ninja detected for C/C++ project build automation")
    end
end

return M

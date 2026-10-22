return {
    "Civitasv/cmake-tools.nvim",
    ft = { "cmake", "c", "cpp" },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "stevearc/overseer.nvim",
    },
    opts = {
        cmake_build_directory = "build",
        cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
    },
    config = function(_, opts)
        require("cmake-tools").setup(opts)

        -- After cmake generates or builds, sync compile_commands.json to project root
        -- so clangd automatically picks up the compilation database.
        local function sync_compile_commands()
            local cwd = vim.fn.getcwd()
            local build_db = cwd .. "/build/compile_commands.json"
            local root_db  = cwd .. "/compile_commands.json"

            if vim.fn.filereadable(build_db) == 1 then
                -- Prefer a symlink so edits to the build db are reflected instantly
                if vim.fn.filereadable(root_db) == 0 and vim.fn.isdirectory(root_db) == 0 then
                    vim.fn.system({ "ln", "-sf", build_db, root_db })
                end

                -- Notify active clangd clients to refresh their compilation database
                for _, client in ipairs(vim.lsp.get_clients({ name = "clangd" })) do
                    client:notify("$/cacheRestart", {})
                end

                vim.notify(
                    "clangd: compile_commands.json synced from build/",
                    vim.log.levels.INFO,
                    { title = "CMake" }
                )
            end
        end

        vim.api.nvim_create_autocmd("User", {
            pattern = { "CMakeBuildComplete", "CMakeGenerateComplete" },
            group = vim.api.nvim_create_augroup("cmake_clangd_sync", { clear = true }),
            callback = sync_compile_commands,
        })
    end,
    keys = {
        { "<leader>Bg", "<cmd>CMakeGenerate<cr>", desc = "CMake: Generate" },
        { "<leader>Bb", "<cmd>CMakeBuild<cr>", desc = "CMake: Build" },
        { "<leader>Br", "<cmd>CMakeRun<cr>", desc = "CMake: Run" },
        { "<leader>Bd", "<cmd>CMakeDebug<cr>", desc = "CMake: Debug" },
        { "<leader>Bt", "<cmd>CMakeSelectBuildTarget<cr>", desc = "CMake: Select Build Target" },
    },
}

return {
    "Civitasv/cmake-tools.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda", "cmake" },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "stevearc/overseer.nvim",
    },
    opts = {
        cmake_build_directory = "build",
        cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
    },
    keys = {
        { "<leader>Bg", "<cmd>CMakeGenerate<cr>", desc = "CMake: Generate" },
        { "<leader>Bb", "<cmd>CMakeBuild<cr>", desc = "CMake: Build" },
        { "<leader>Br", "<cmd>CMakeRun<cr>", desc = "CMake: Run" },
        { "<leader>Bd", "<cmd>CMakeDebug<cr>", desc = "CMake: Debug" },
        { "<leader>Bt", "<cmd>CMakeSelectBuildTarget<cr>", desc = "CMake: Select Build Target" },
    },
}

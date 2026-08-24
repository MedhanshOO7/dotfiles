local M = {}

local config_dir = vim.fn.stdpath("config")

function M.update()
    vim.notify("Checking for configuration updates... ", vim.log.levels.INFO, { title = "Config Updater" })

    -- Step 1: Check if git repo
    vim.system({ "git", "-C", config_dir, "rev-parse", "--is-inside-work-tree" }, { text = true }, function(check_res)
        if check_res.code ~= 0 then
            vim.schedule(function()
                vim.notify("Config directory is not a Git repository! ", vim.log.levels.ERROR, { title = "Config Updater" })
            end)
            return
        end

        -- Step 2: Get current HEAD commit hash
        vim.system({ "git", "-C", config_dir, "rev-parse", "HEAD" }, { text = true }, function(head_res)
            local old_head = vim.trim(head_res.stdout or "")

            -- Step 3: Run git pull
            vim.system({ "git", "-C", config_dir, "pull", "--ff-only" }, { text = true }, function(pull_res)
                vim.schedule(function()
                    if pull_res.code ~= 0 then
                        -- Check if pull failed due to local changes
                        local stderr = pull_res.stderr or ""
                        if stderr:find("conflict") or stderr:find("local changes") then
                            vim.notify("Update failed: You have local uncommitted changes. Please commit or stash them first.\n\n" .. stderr, vim.log.levels.WARN, { title = "Config Updater" })
                        else
                            vim.notify("Update failed:\n" .. (stderr ~= "" and stderr or (pull_res.stdout or "")), vim.log.levels.ERROR, { title = "Config Updater" })
                        end
                        return
                    end

                    local output = vim.trim(pull_res.stdout or "")
                    if output:find("Already up to date") or output:find("Current branch is up to date") then
                        vim.notify("Your Neovim config is already up to date! ", vim.log.levels.INFO, { title = "Config Updater" })
                        return
                    end

                    -- Step 4: Find new commits pulled
                    vim.system({ "git", "-C", config_dir, "log", "--oneline", old_head .. "..HEAD" }, { text = true }, function(log_res)
                        vim.schedule(function()
                            local log = vim.trim(log_res.stdout or "")
                            local commit_count = 0
                            for _ in log:gmatch("[^\r\n]+") do
                                commit_count = commit_count + 1
                            end

                            local msg = string.format("Config updated successfully! \nSynced %d new commit(s).\n\n%s", commit_count, log)
                            vim.notify(msg, vim.log.levels.INFO, { title = "Config Updater" })

                            -- Step 5: Automatically sync Lazy plugins if lazy-lock changed
                            local ok_lazy, lazy = pcall(require, "lazy")
                            if ok_lazy then
                                vim.notify("Syncing plugins with Lazy.nvim... ", vim.log.levels.INFO, { title = "Config Updater" })
                                lazy.sync({ show = false })
                            end
                        end)
                    end)
                end)
            end)
        end)
    end)
end

function M.setup()
    vim.api.nvim_create_user_command("ConfigUpdate", function()
        M.update()
    end, { desc = "Pull latest configuration changes from Git repository" })

    vim.api.nvim_create_user_command("NvimUpdate", function()
        M.update()
    end, { desc = "Pull latest configuration changes from Git repository" })
end

return M

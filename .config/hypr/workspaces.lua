-- Workspace rules for multi-monitor setup
-- Laptop internal display: eDP-1 (Workspaces 1-5)
for i = 1, 5 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor = "eDP-1",
        default = (i == 1)
    })
end

-- External HDMI display: HDMI-A-1 (Workspaces 6-10)
for i = 6, 10 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor = "HDMI-A-1",
        default = (i == 6)
    })
end

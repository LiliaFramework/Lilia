net.Receive("sam_blind", function()
    local enabled = net.ReadBool()
    if enabled then
        hook.Add("HUDPaint", "sam_blind", function() draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255)) end)
    else
        hook.Remove("HUDPaint", "sam_blind")
    end
end)

lia.command.add("cleardecals", {
    adminOnly = true,
    privilege = "Clear Decals",
    onRun = function() end
})

lia.command.add("viewclaims", {
    privilege = "View Claims",
    description = "View the claims for all admins.",
    adminOnly = true,
    onRun = function() end
})

lia.command.add("playtime", {
    adminOnly = false,
    onRun = function() end
})

lia.command.add("viewclaims", {
    privilege = "View Claims",
    description = "View the claims for all admins.",
    adminOnly = true,
    onRun = function() end
})

lia.command.add("playtime", {
    adminOnly = false,
    privilege = "View Own Playtime",
    onRun = function() end
})

lia.command.add("plygetplaytime", {
    adminOnly = true,
    syntax = "[string charname]",
    privilege = "View Playtime",
    onRun = function() end
})

lia.command.add("plyviewclaims", {
    adminOnly = true,
    syntax = "[string charname]",
    privilege = "View Claims",
    onRun = function() end
})

lia.command.add("plygetplaytime", {
    adminOnly = true,
    syntax = "[string charname]",
    privilege = "View Playtime",
    onRun = function() end
})

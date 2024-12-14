lia.command.add("spawnadd", {
    privilege = "Manage Spawns",
    adminOnly = true,
    syntax = "<string faction> [string class]",
    onRun = function() end
})

lia.command.add("spawnremove", {
    privilege = "Manage Spawns",
    adminOnly = true,
    syntax = "[number radius]",
    onRun = function() end
})

lia.command.add("returnitems", {
    superAdminOnly = true,
    syntax = "<string name>",
    privilege = "Return Items",
    onRun = function() end
})
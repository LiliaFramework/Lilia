
lia.command.add("spawnadd", {
    privilege = "Change Spawns",
    adminOnly = true,
    syntax = "<string faction> [string class]",
    onRun = function() end
})


lia.command.add("returnitems", {
    superAdminOnly = true,
    syntax = "<string name>",
    privilege = "Return Items",
    onRun = function() end
})


lia.command.add("respawn", {
    privilege = "Forcelly Respawn",
    adminOnly = true,
    syntax = "<string target>",
    onRun = function() end
})


lia.command.add("spawnremove", {
    privilege = "Change Spawns",
    adminOnly = true,
    syntax = "[number radius]",
    onRun = function() end
})


--------------------------------------------------------------------------------------------------------
lia.command.add("spawnadd", {
    privilege = "Management - Change Spawns",
    adminOnly = true,
    syntax = "<string faction> [string class]",
    onRun = function(client, arguments) end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("spawnremove", {
    privilege = "Management - Change Spawns",
    adminOnly = true,
    syntax = "[number radius]",
    onRun = function(client, arguments) end
})
--------------------------------------------------------------------------------------------------------
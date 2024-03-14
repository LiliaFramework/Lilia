lia.command.add("storagelock", {
    privilege = "Lock Storage",
    adminOnly = true,
    syntax = "[string password]",
    onRun = function() end
})

lia.command.add("trunk", {
    adminOnly = false,
    onRun = function() end
})

lia.command.add("legacylogs", {
    adminOnly = true,
    privilege = "View Logs",
    onRun = function() end
})

lia.command.add("logger", {
    adminOnly = true,
    privilege = "View Logs",
    onRun = function() end
})

lia.command.add("deletelogs", {
    superAdminOnly = true,
    privilege = "Erase Logs",
    onRun = function() end
})

lia.command.add("netlogs", {
    superadminOnly = true,
    privilege = "View Advanced Logs",
    onRun = function() end
})

lia.command.add("concommandlogs", {
    superadminOnly = true,
    privilege = "View Advanced Logs",
    onRun = function() end
})

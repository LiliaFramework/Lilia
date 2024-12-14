lia.command.add("restockvendor", {
    privilege = "Manage Vendors",
    superAdminOnly = true,
    onRun = function() end
})

lia.command.add("restockallvendors", {
    privilege = "Manage Vendors",
    superAdminOnly = true,
    onRun = function() end
})

lia.command.add("resetallvendormoney", {
    privilege = "Manage Vendors",
    superAdminOnly = true,
    syntax = "<int amount>",
    onRun = function() end
})

lia.command.add("restockvendormoney", {
    privilege = "Manage Vendors",
    superAdminOnly = true,
    syntax = "<int amount>",
    onRun = function() end
})

lia.command.add("savevendors", {
    superAdminOnly = true,
    privilege = "Manage Vendors",
    onRun = function() end
})
lia.command.add("restockallvendors", {
    privilege = "Restock Vendors",
    superAdminOnly = true,
    onRun = function() end
})

lia.command.add("resetallvendormoney", {
    privilege = "Reset Vendor Money",
    superAdminOnly = true,
    syntax = "<int amount>",
    onRun = function() end
})

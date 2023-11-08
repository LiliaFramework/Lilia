-------------------------------------------------------------------------------------------------------
lia.command.add(
    "restockallvendors",
    {
        privilege = "Restock Vendors",
        superAdminOnly = true,
        onRun = function(client, arguments) end
    }
)

-------------------------------------------------------------------------------------------------------
lia.command.add(
    "resetallvendormoney",
    {
        privilege = "Reset Vendor Money",
        superAdminOnly = true,
        syntax = "<int amount>",
        onRun = function(client, arguments) end
    }
)
-------------------------------------------------------------------------------------------------------

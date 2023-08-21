--------------------------------------------------------------------------------------------------------
lia.command.add("charban", {
    superAdminOnly = true,
    syntax = "<string name>",
    privilege = "Characters - Ban Characters",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("charsetdesc", {
    adminOnly = true,
    syntax = "<string name> <string desc>",
    privilege = "Characters - Change Description",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("plytransfer", {
    adminOnly = true,
    syntax = "<string name> <string faction>",
    privilege = "Characters - Transfer Player",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("charsetname", {
    adminOnly = true,
    syntax = "<string name> [string newName]",
    privilege = "Characters - Change Name",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("chargetmodel", {
    adminOnly = true,
    syntax = "<string name>",
    privilegeprivilege = "Characters - Retrieve Model",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("charsetmodel", {
    adminOnly = true,
    syntax = "<string name> <string model>",
    privilege = "Characters - Change Model",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("charsetbodygroup", {
    adminOnly = true,
    syntax = "<string name> <string bodyGroup> [number value]",
    privilege = "Characters - Change Bodygroups",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("charsetskin", {
    adminOnly = true,
    syntax = "<string name> [number skin]",
    privilege = "Characters - Change Skin",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("chargetmoney", {
    adminOnly = true,
    syntax = "<string name>",
    privilege = "Characters - Retrieve Money",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("charsetmoney", {
    superAdminOnly = true,
    syntax = "<string target> <number amount>",
    privilege = "Characters - Change Money",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("charsetattrib", {
    superAdminOnly = true,
    syntax = "<string charname> <string attribname> <number level>",
    privilege = "Characters - Change Attributes",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("charaddattrib", {
    superAdminOnly = true,
    syntax = "<string charname> <string attribname> <number level>",
    privilege = "Characters - Change Attributes",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("checkinventory", {
    superAdminOnly = true,
    syntax = "<string target>",
    privilege = "Characters - Check Inventory",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("clearinv", {
    superAdminOnly = true,
    syntax = "<string name>",
    privilege = "Characters - Clear Inventory",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("flaggive", {
    adminOnly = true,
    syntax = "<string name> [string flags]",
    privilege = "Characters - Toggle Flags",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("flagtake", {
    adminOnly = true,
    syntax = "<string name> [string flags]",
    privilege = "Characters - Toggle Flags",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("charkick", {
    adminOnly = true,
    syntax = "<string name>",
    privilege = "Characters - Kick Characters",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("plywhitelist", {
    adminOnly = true,
    privilege = "Characters - Whitelist Characters",
    syntax = "<string name> <string faction>",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("plyunwhitelist", {
    adminOnly = true,
    privilege = "Characters - Un-Whitelist Characters",
    syntax = "<string name> <string faction>",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("charunban", {
    syntax = "<string name>",
    superAdminOnly = true,
    privilege = "Characters - Un-Ban Characters",
    onRun = function(client, arguments) end
})
--------------------------------------------------------------------------------------------------------
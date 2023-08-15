lia.command.add("freezeallprops", {
    superAdminOnly = true,
    privilege = "Management - Freeze All Props",
    onRun = function(client, arguments) end
})

lia.command.add("cleanitems", {
    superAdminOnly = true,
    privilege = "Management - Clean Items",
    onRun = function(client, arguments) end
})

lia.command.add("cleanprops", {
    superAdminOnly = true,
    privilege = "Management - Clean Props",
    onRun = function(client, arguments) end
})

lia.command.add("cleannpcs", {
    superAdminOnly = true,
    privilege = "Management - Clean NPCs",
    onRun = function(client, arguments) end
})

lia.command.add("flags", {
    adminOnly = true,
    syntax = "<string name>",
    privilege = "Management - Check Flags",
    onRun = function(client, arguments) end
})

lia.command.add("clearchat", {
    superAdminOnly = true,
    privilege = "Management - Clear Chat",
    onRun = function(client, arguments) end
})

lia.command.add("checkallmoney", {
    superAdminOnly = true,
    syntax = "<string charname>",
    privilege = "Management - Check All Money",
    onRun = function(client, arguments) end
})

lia.command.add("return", {
    adminOnly = true,
    privilege = "Management - Return",
    onRun = function(client, arguments) end
})

lia.command.add("findallflags", {
    adminOnly = false,
    privilege = "Management - Find All Flags",
    onRun = function(client, arguments) end
})

lia.command.add("chargiveitem", {
    superAdminOnly = true,
    syntax = "<string name> <string item>",
    privilege = "Management - Give Item",
    onRun = function(client, arguments) end
})

lia.command.add("netmessagelogs", {
    superAdminOnly = true,
    privilege = "Management - Check Net Message Log",
    onRun = function(client, arguments) end
})

lia.command.add("returnitems", {
    superAdminOnly = true,
    syntax = "<string name>",
    privilege = "Management - Return Items",
    onRun = function(client, arguments) end
})

lia.command.add("announce", {
    superAdminOnly = true,
    syntax = "<string factions> <string text>",
    privilege = "Management - Make Announcements",
    onRun = function(client, arguments) end
})

lia.command.add("logs", {
    adminOnly = true,
    privilege = "Management - Open MLogs",
    onRun = function(client, arguments) end
})
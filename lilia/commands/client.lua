lia.command.add("charsetspeed", {
    adminOnly = true,
    privilege = "Set Character Speed",
    syntax = "<string name> <number speed>",
    onRun = function() end
})

lia.command.add("playglobalsound", {
    superAdminOnly = true,
    privilege = "Play Global Sounds",
    onRun = function() end
})

lia.command.add("playsound", {
    superAdminOnly = true,
    privilege = "Play Targetted Sounds",
    syntax = "<string name> <string sound>",
    onRun = function() end
})

lia.command.add("charsetscale", {
    superAdminOnly = true,
    privilege = "Set Character scale",
    syntax = "<string name> <number value>",
    onRun = function() end
})

lia.command.add("charsetjump", {
    adminOnly = true,
    privilege = "Set Character Jump",
    syntax = "<string name> <number power>",
    onRun = function() end
})

lia.command.add("charaddmoney", {
    privilege = "Add Money",
    superAdminOnly = true,
    syntax = "<string target> <number amount>",
    onRun = function() end
})

lia.command.add("charban", {
    superAdminOnly = true,
    syntax = "<string name>",
    privilege = "Ban Characters",
    onRun = function() end
})

lia.command.add("charsetdesc", {
    adminOnly = true,
    syntax = "<string name> <string desc>",
    privilege = "Manage Character Informations",
    onRun = function() end
})

lia.command.add("charsetname", {
    adminOnly = true,
    syntax = "<string name> [string newName]",
    privilege = "Manage Character Informations",
    onRun = function() end
})

lia.command.add("chargetmodel", {
    adminOnly = true,
    syntax = "<string name>",
    privilege = "Retrieve Model",
    onRun = function() end
})

lia.command.add("charsetmodel", {
    adminOnly = true,
    syntax = "<string name> <string model>",
    privilege = "Manage Character Informations",
    onRun = function() end
})

lia.command.add("charsetbodygroup", {
    adminOnly = true,
    privilege = "Manage Bodygroups",
    syntax = "<string name> <string bodyGroup> [number value]",
    onRun = function() end
})

lia.command.add("charsetskin", {
    adminOnly = true,
    syntax = "<string name> [number skin]",
    privilege = "Manage Character Informations",
    onRun = function() end
})

lia.command.add("chargetmoney", {
    adminOnly = true,
    syntax = "<string name>",
    privilege = "Retrieve Money",
    onRun = function() end
})

lia.command.add("charsetmoney", {
    superAdminOnly = true,
    syntax = "<string target> <number amount>",
    privilege = "Change Money",
    onRun = function() end
})

lia.command.add("clearinv", {
    superAdminOnly = true,
    syntax = "<string name>",
    privilege = "Clear Inventory",
    onRun = function() end
})

lia.command.add("flaggive", {
    adminOnly = true,
    syntax = "<string name> [string flags]",
    privilege = "Manage Flags",
    onRun = function() end
})

lia.command.add("flaggiveall", {
    adminOnly = true,
    syntax = "<string name> [string flags]",
    privilege = "Manage All Flags",
    onRun = function() end
})

lia.command.add("flagtakeall", {
    adminOnly = true,
    syntax = "<string name> [string flags]",
    privilege = "Manage All Flags",
    onRun = function() end
})

lia.command.add("flagtake", {
    adminOnly = true,
    syntax = "<string name> [string flags]",
    privilege = "Manage Flags",
    onRun = function() end
})

lia.command.add("charkick", {
    adminOnly = true,
    syntax = "<string name>",
    privilege = "Kick Characters",
    onRun = function() end
})

lia.command.add("viewcoreinformation", {
    privilege = "See Core Information",
    superAdminOnly = true,
    onRun = function() end
})

lia.command.add("charunban", {
    syntax = "<string name>",
    superAdminOnly = true,
    privilege = "Un-Ban Characters",
    onRun = function() end
})

lia.command.add("flagpet", {
    privilege = "Give pet Flags",
    syntax = "[character name]",
    onRun = function() end
})

lia.command.add("flagragdoll", {
    adminOnly = true,
    privilege = "Hand Ragdoll Medals",
    syntax = "<string name>",
    onRun = function() end
})

lia.command.add("flags", {
    privilege = "Check Flags",
    adminOnly = true,
    syntax = "<string name>",
    onRun = function() end
})

lia.command.add("freezeallprops", {
    superAdminOnly = true,
    privilege = "Freeze All Props",
    onRun = function() end
})

lia.command.add("checkmoney", {
    syntax = "<string target>",
    privilege = "Check Money",
    adminOnly = true,
    onRun = function() end
})

lia.command.add("status", {
    onRun = function() end
})

lia.command.add("redownloadlightmaps", {
    adminOnly = false,
    onRun = function() end
})

lia.command.add("cleanitems", {
    superAdminOnly = true,
    privilege = "Clean Items",
    onRun = function() end
})

lia.command.add("cleanprops", {
    superAdminOnly = true,
    privilege = "Clean Props",
    onRun = function() end
})

lia.command.add("forcesave", {
    superAdminOnly = true,
    privilege = "Force Save Server",
    onRun = function() end
})

lia.command.add("cleannpcs", {
    superAdminOnly = true,
    privilege = "Clean NPCs",
    onRun = function() end
})

lia.command.add("flags", {
    adminOnly = true,
    syntax = "<string name>",
    privilege = "Check Flags",
    onRun = function() end
})

lia.command.add("checkallmoney", {
    superAdminOnly = true,
    syntax = "<string charname>",
    privilege = "Check All Money",
    onRun = function() end
})

lia.command.add("return", {
    adminOnly = true,
    privilege = "Return",
    onRun = function() end
})

lia.command.add("findallflags", {
    adminOnly = false,
    privilege = "Find All Flags",
    onRun = function() end
})

lia.command.add("chargiveitem", {
    superAdminOnly = true,
    syntax = "<string name> <string item>",
    privilege = "Give Item",
    onRun = function() end
})

lia.command.add("announce", {
    superAdminOnly = true,
    syntax = "<string factions> <string text>",
    privilege = "Make Announcements",
    onRun = function() end
})

lia.command.add("listents", {
    syntax = "<No Input>",
    onRun = function() end
})

lia.command.add("flip", {
    adminOnly = false,
    onRun = function() end
})

lia.command.add("liststaff", {
    adminOnly = false,
    privilege = "List Staff",
    onRun = function() end
})

lia.command.add("listondutystaff", {
    adminOnly = false,
    privilege = "List Staff",
    onRun = function() end
})

lia.command.add("listvip", {
    adminOnly = false,
    privilege = "List VIPs",
    onRun = function() end
})

lia.command.add("listusers", {
    adminOnly = false,
    privilege = "List Users",
    onRun = function() end
})

lia.command.add("rolld", {
    adminOnly = false,
    syntax = "<number dice> <number pips> <number bonus>",
    onRun = function() end
})

lia.command.add("vieweventlog", {
    adminOnly = false,
    onRun = function() end
})

lia.command.add("editeventlog", {
    adminOnly = true,
    privilege = "Can Edit Event Log",
    onRun = function() end
})

lia.command.add("roll", {
    adminOnly = false,
    onRun = function() end
})

lia.command.add("chardesc", {
    adminOnly = false,
    syntax = "<string desc>",
    onRun = function() end
})

lia.command.add("chargetup", {
    adminOnly = false,
    onRun = function() end
})

lia.command.add("givemoney", {
    adminOnly = false,
    syntax = "<number amount>",
    onRun = function() end
})

lia.command.add("bringlostitems", {
    adminOnly = false,
    onRun = function() end
})

lia.command.add("carddraw", {
    adminOnly = false,
    onRun = function() end
})

lia.command.add("fallover", {
    adminOnly = false,
    syntax = "[number time]",
    onRun = function() end
})

lia.command.add("getpos", {
    adminOnly = false,
    onRun = function() end
})

lia.command.add("entname", {
    adminOnly = false,
    onRun = function() end
})

lia.command.add("permflaggive", {
    superAdminOnly = true,
    privilege = "Manage Permanent Flags",
    syntax = "<string name> [string flags]",
    onRun = function() end
})

lia.command.add("permflagtake", {
    superAdminOnly = true,
    privilege = "Manage Permanent Flags",
    syntax = "<string name> [string flags]",
    onRun = function() end
})

lia.command.add("permflags", {
    adminOnly = true,
    privilege = "Check Permanent Flags",
    syntax = "<string name>",
    onRun = function() end
})

lia.command.add("flagblacklist", {
    superAdminOnly = true,
    privilege = "Manage Permanent Flags",
    syntax = "<string name> <string flags> <number minutes> <string reason>",
    onRun = function() end
})

lia.command.add("flagunblacklist", {
    superAdminOnly = true,
    privilege = "Manage Permanent Flags",
    syntax = "<string name> [string flags]",
    onRun = function() end
})

lia.command.add("flagblacklists", {
    superAdminOnly = true,
    privilege = "Manage Permanent Flags",
    syntax = "<string name>",
    onRun = function() end
})

lia.command.add("dropmoney", {
    syntax = "<number amount>",
    onRun = function() end
})

lia.command.add("membercount", {
    adminOnly = false,
    onRun = function() end
})

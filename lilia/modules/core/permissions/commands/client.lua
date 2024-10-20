lia.command.add("playglobalsound", {
    superAdminOnly = true,
    privilege = "Play Sounds",
    onRun = function() end
})

lia.command.add("playsound", {
    superAdminOnly = true,
    privilege = "Play Sounds",
    syntax = "<string name> <string sound>",
    onRun = function() end
})

lia.command.add("return", {
    adminOnly = true,
    privilege = "Return Players",
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

lia.command.add("fallover", {
    adminOnly = false,
    syntax = "[number time]",
    onRun = function() end
})

lia.command.add("dropmoney", {
    syntax = "<number amount>",
    onRun = function() end
})

lia.command.add("entityName", {
    adminOnly = false,
    onRun = function() end
})

lia.command.add("checkinventory", {
    adminOnly = true,
    privilege = "Check Inventories",
    syntax = "<string target>",
    onRun = function() end
})

lia.command.add("flagpet", {
    adminOnly = true,
    syntax = "[character name]",
    privilege = "Manage Flags",
    onRun = function() end
})

lia.command.add("flaggive", {
    adminOnly = true,
    syntax = "<string name> [string flags]",
    privilege = "Manage Flags",
    onRun = function() end,
    alias = {"giveflag"}
})

lia.command.add("flaggiveall", {
    adminOnly = true,
    syntax = "<string name> [string flags]",
    privilege = "Manage Flags",
    onRun = function() end
})

lia.command.add("flagpet", {
    adminOnly = true,
    privilege = "Manage Flags",
    onRun = function() end
})

lia.command.add("flagtakeall", {
    adminOnly = true,
    syntax = "<string name> [string flags]",
    privilege = "Manage Flags",
    onRun = function() end
})

lia.command.add("flagtake", {
    adminOnly = true,
    syntax = "<string name> [string flags]",
    privilege = "Manage Flags",
    onRun = function() end,
    alias = {"takeflag"}
})

lia.command.add("bringlostitems", {
    superAdminOnly = true,
    privilege = "Manage Items",
    onRun = function() end
})

lia.command.add("cleanitems", {
    superAdminOnly = true,
    privilege = "Clean Entities",
    onRun = function() end
})

lia.command.add("cleanprops", {
    superAdminOnly = true,
    privilege = "Clean Entities",
    onRun = function() end
})

lia.command.add("cleannpcs", {
    superAdminOnly = true,
    privilege = "Clean Entities",
    onRun = function() end
})

lia.command.add("charunban", {
    syntax = "<string name>",
    superAdminOnly = true,
    privilege = "Manage Characters",
    onRun = function() end
})

lia.command.add("clearinv", {
    superAdminOnly = true,
    syntax = "<string name>",
    privilege = "Manage Characters",
    onRun = function() end
})

lia.command.add("charkick", {
    adminOnly = true,
    syntax = "<string name>",
    privilege = "Kick Characters",
    onRun = function() end
})

lia.command.add("freezeallprops", {
    superAdminOnly = true,
    privilege = "Manage Characters",
    onRun = function() end
})

lia.command.add("charban", {
    superAdminOnly = true,
    syntax = "<string name>",
    privilege = "Manage Characters",
    onRun = function() end
})

lia.command.add("checkallmoney", {
    superAdminOnly = true,
    privilege = "Get Character Info",
    onRun = function() end
})

lia.command.add("findallflags", {
    adminOnly = false,
    privilege = "Get Character Info",
    onRun = function() end
})

lia.command.add("checkmoney", {
    syntax = "<string target>",
    privilege = "Get Character Info",
    adminOnly = true,
    onRun = function() end
})

lia.command.add("listbodygroups", {
    syntax = "<string target>",
    privilege = "Get Character Info",
    adminOnly = true,
    onRun = function() end
})

lia.command.add("chargetmodel", {
    adminOnly = true,
    syntax = "<string name>",
    privilege = "Get Character Info",
    onRun = function() end
})

lia.command.add("chargetmoney", {
    adminOnly = true,
    syntax = "<string name>",
    privilege = "Get Character Info",
    onRun = function() end
})

lia.command.add("charsetspeed", {
    adminOnly = true,
    privilege = "Manage Character Stats",
    syntax = "<string name> <number speed>",
    onRun = function() end
})

lia.command.add("charsetmodel", {
    adminOnly = true,
    syntax = "<string name> <string model>",
    privilege = "Manage Character Informations",
    onRun = function() end
})

lia.command.add("chargiveitem", {
    superAdminOnly = true,
    syntax = "<string name> <string item>",
    privilege = "Manage Items",
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

lia.command.add("charsetscale", {
    adminOnly = true,
    privilege = "Manage Character Stats",
    syntax = "<string name> <number value>",
    onRun = function() end
})

lia.command.add("charsetjump", {
    adminOnly = true,
    privilege = "Manage Character Stats",
    syntax = "<string name> <number power>",
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
    privilege = "Manage Character Stats",
    onRun = function() end
})

lia.command.add("charsetmoney", {
    superAdminOnly = true,
    syntax = "<string target> <number amount>",
    privilege = "Manage Characters",
    onRun = function() end
})

lia.command.add("charaddmoney", {
    superAdminOnly = true,
    syntax = "<string target> <number amount>",
    privilege = "Manage Characters",
    onRun = function() end,
    alias = {"chargivemoney"}
})

lia.command.add("flaglist", {
    adminOnly = true,
    privilege = "Manage Flags",
    onRun = function() end,
    alias = {"flags"}
})

lia.command.add("itemlist", {
    adminOnly = true,
    privilege = "List Items",
    onRun = function() end
})

lia.command.add("modulelist", {
    adminOnly = false,
    onRun = function() end,
    alias = {"modules"},
})

lia.command.add("listents", {
    syntax = "<No Input>",
    onRun = function() end
})

lia.command.add("liststaff", {
    adminOnly = true,
    privilege = "List Players",
    onRun = function() end
})

lia.command.add("listondutystaff", {
    adminOnly = true,
    privilege = "List Players",
    onRun = function() end
})

lia.command.add("listvip", {
    adminOnly = true,
    privilege = "List Players",
    onRun = function() end
})

lia.command.add("globalbotsay", {
    superAdminOnly = true,
    syntax = "<string message>",
    privilege = "Bot Say",
    onRun = function() end
})

lia.command.add("botsay", {
    superAdminOnly = true,
    syntax = "<string botName> <string message>",
    privilege = "Bot Say",
    onRun = function() end
})

lia.command.add("forcesay", {
    superAdminOnly = true,
    syntax = "<string botName> <string message>",
    privilege = "Force Say",
    onRun = function() end
})

lia.command.add("pm", {
    syntax = "<string target> <string message>",
    onRun = function() end
})
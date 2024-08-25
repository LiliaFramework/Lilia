lia.command.add("plytransfer", {
    adminOnly = true,
    syntax = "<string name> <string faction>",
    privilege = "Manage Transfers",
    onRun = function() end,
    alias = {"charsetfaction"}
})

lia.command.add("plywhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    syntax = "<string name> <string faction>",
    onRun = function() end,
    alias = {"factionwhitelist"}
})

lia.command.add("plyunwhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    syntax = "<string name> <string faction>",
    onRun = function() end,
    alias = {"factionunwhitelist"}
})

lia.command.add("beclass", {
    adminOnly = false,
    syntax = "<string class>",
    onRun = function() end
})

lia.command.add("setclass", {
    adminOnly = true,
    privilege = "Manage Classes",
    syntax = "<string target> <string class>",
    onRun = function() end,
})

lia.command.add("classwhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    syntax = "<string name> <string class>",
    onRun = function() end
})

lia.command.add("classunwhitelist", {
    adminOnly = true,
    privilege = "Manage Classes",
    syntax = "<string name> <string class>",
    onRun = function() end
})

lia.command.add("classlist", {
    adminOnly = false,
    onRun = function() end,
    alias = {"classes"}
})

lia.command.add("factionlist", {
    adminOnly = false,
    onRun = function() end,
    alias = {"factions"}
})

lia.command.add("getallwhitelists", {
    syntax = "<string target>",
    privilege = "Get All Whitelists",
    superAdminOnly = true,
    onRun = function() end
})

lia.command.add("getclasswhitelists", {
    syntax = "<string target>",
    privilege = "Get All Whitelists",
    superAdminOnly = true,
    onRun = function() end
})

lia.command.add("getfactionwhitelists", {
    syntax = "<string target>",
    privilege = "Get All Whitelists",
    superAdminOnly = true,
    onRun = function() end
})
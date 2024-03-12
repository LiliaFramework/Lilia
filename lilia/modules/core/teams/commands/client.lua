lia.command.add("classwhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    syntax = "<string name> <string class>",
    onRun = function() end
})

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
    onRun = function() end
})

lia.command.add("plyunwhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    syntax = "<string name> <string faction>",
    onRun = function() end
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
    onRun = function() end
})

lia.command.add("classunwhitelist", {
    adminOnly = true,
    privilege = "Manage Classes",
    syntax = "<string name> <string class>",
    onRun = function() end
})

lia.command.add("factionlist", {
    adminOnly = false,
    syntax = "<string text>",
    onRun = function() end
})
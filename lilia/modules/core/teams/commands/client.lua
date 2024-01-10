lia.command.add(
    "classwhitelist",
    {
        adminOnly = true,
        syntax = "<string name> <string class>",
        onRun = function() end
    }
)

lia.command.add(
    "plytransfer",
    {
        adminOnly = true,
        syntax = "<string name> <string faction>",
        privilege = "Transfer Player",
        onRun = function() end
    }
)

lia.command.add(
    "plywhitelist",
    {
        adminOnly = true,
        privilege = "Whitelist Characters",
        syntax = "<string name> <string faction>",
        onRun = function() end
    }
)

lia.command.add(
    "plyunwhitelist",
    {
        adminOnly = true,
        privilege = "Un-Whitelist Characters",
        syntax = "<string name> <string faction>",
        onRun = function() end
    }
)

lia.command.add(
    "beclass",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        syntax = "<string class>",
        onRun = function() end
    }
)

lia.command.add(
    "factionlist",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        syntax = "<string text>",
        onRun = function() end
    }
)

lia.command.add(
    "setclass",
    {
        privilege = "Set Class",
        adminOnly = true,
        syntax = "<string target> <string class>",
        onRun = function() end
    }
)

lia.command.add(
    "classunwhitelist",
    {
        adminOnly = true,
        syntax = "<string name> <string class>",
        onRun = function() end
    }
)


local MODULE = MODULE

lia.command.add(
    "doorsell",
    {
        privilege = "Basic User Permissions",
        onRun = function(client, arguments) end
    }
)


lia.command.add(
    "doorbuy",
    {
        privilege = "Basic User Permissions",
        onRun = function(client, arguments) end
    }
)


lia.command.add(
    "doorsetunownable",
    {
        adminOnly = true,
        syntax = "[string name]",
        privilege = "Management- Manage Doors",
        onRun = function(client, arguments) end
    }
)


lia.command.add(
    "doorsetownable",
    {
        adminOnly = true,
        syntax = "[string name]",
        privilege = "Management- Manage Doors",
        onRun = function(client, arguments) end
    }
)


lia.command.add(
    "dooraddfaction",
    {
        adminOnly = true,
        syntax = "[string faction]",
        privilege = "Management- Manage Doors",
        onRun = function(client, arguments) end
    }
)


lia.command.add(
    "doorremovefaction",
    {
        adminOnly = true,
        syntax = "[string faction]",
        privilege = "Management- Manage Doors",
        onRun = function(client, arguments) end
    }
)


lia.command.add(
    "doorsetdisabled",
    {
        adminOnly = true,
        syntax = "<bool disabled>",
        privilege = "Management- Manage Doors",
        onRun = function(client, arguments) end
    }
)


lia.command.add(
    "doorsettitle",
    {
        syntax = "<string title>",
        privilege = "Management- Manage Doors",
        onRun = function(client, arguments) end
    }
)


lia.command.add(
    "doorsetparent",
    {
        adminOnly = true,
        privilege = "Management- Manage Doors",
        onRun = function(client, arguments) end
    }
)


lia.command.add(
    "doorsetchild",
    {
        adminOnly = true,
        privilege = "Management- Manage Doors",
        onRun = function(client, arguments) end
    }
)


lia.command.add(
    "doorremovechild",
    {
        adminOnly = true,
        privilege = "Management- Manage Doors",
        onRun = function(client, arguments) end
    }
)


lia.command.add(
    "doorsethidden",
    {
        adminOnly = true,
        syntax = "<bool hidden>",
        privilege = "Management- Manage Doors",
        onRun = function(client, arguments) end
    }
)


lia.command.add(
    "doorsetclass",
    {
        adminOnly = true,
        syntax = "[string faction]",
        privilege = "Management- Manage Doors",
        onRun = function(client, arguments) end,
        alias = {"jobdoor"}
    }
)

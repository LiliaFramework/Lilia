--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "flip",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "liststaff",
    {
        adminOnly = false,
        privilege = "List Staff",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "listvip",
    {
        adminOnly = false,
        privilege = "List VIPs",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "listusers",
    {
        adminOnly = false,
        privilege = "List Users",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "rolld",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        syntax = "<number dice> <number pips> <number bonus>",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "roll",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "point",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        syntax = "[number maximum]",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "chardesc",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        syntax = "<string desc>",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "beclass",
    {
        adminOnly = false,
        syntax = "<string class>",
        privilege = "Default User Commands",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "chargetup",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "givemoney",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        syntax = "<number amount>",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "bringlostitems",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "carddraw",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "fallover",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        syntax = "[number time]",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "factionlist",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        syntax = "<string text>",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "getpos",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "doorname",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
if lia.config.FactionBroadcastEnabled then
    lia.command.add(
        "factionbroadcast",
        {
            adminOnly = false,
            privilege = "Default User Commands",
            syntax = "<string factions> <string text>",
            onRun = function(client, arguments) end
        }
    )
end

--------------------------------------------------------------------------------------------------------------------------
if lia.config.AdvertisementEnabled then
    lia.command.add(
        "advertisement",
        {
            adminOnly = false,
            privilege = "Default User Commands",
            syntax = "<string factions> <string text>",
            onRun = function(client, arguments) end
        }
    )
end

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "dropmoney",
    {
        privilege = "Default User Commands",
        syntax = "<number amount>",
        onRun = function(client, arguments) end
    }
)
--------------------------------------------------------------------------------------------------------------------------

lia.command.add(
    "roll",
    {
        adminOnly = false,
        syntax = "[number maximum]",
        onRun = function(client, arguments)
        end
    }
)

lia.command.add(
    "dropmoney",
    {
        adminOnly = false,
        syntax = "<number amount>",
        onRun = function(client, arguments)
        end
    }
)

lia.command.add(
    "chardesc",
    {
        adminOnly = false,
        syntax = "<string desc>",
        onRun = function(client, arguments)
        end
    }
)

lia.command.add(
    "beclass",
    {
        adminOnly = false,
        syntax = "<string class>",
        onRun = function(client, arguments)
        end
    }
)

lia.command.add(
    "chargetup",
    {
        adminOnly = false,
        onRun = function(client, arguments)
        end
    }
)

lia.command.add(
    "givemoney",
    {
        adminOnly = false,
        syntax = "<number amount>",
        onRun = function(client, arguments)
        end
    }
)

lia.command.add(
    "bringlostitems",
    {
        adminOnly = false,
        onRun = function(client, arguments)
        end
    }
)

lia.command.add(
    "carddraw",
    {
        adminOnly = false,
        onRun = function(client, arguments)
        end
    }
)

lia.command.add(
    "fallover",
    {
        adminOnly = false,
        syntax = "[number time]",
        onRun = function(client, arguments)
        end
    }
)

lia.command.add(
    "factionlist",
    {
        adminOnly = false,
        syntax = "<string text>",
        onRun = function(client, arguments)
        end
    }
)

lia.command.add(
    "getpos",
    {
        adminOnly = false,
        onRun = function(client, arguments)
        end
    }
)

lia.command.add(
    "doorname",
    {
        adminOnly = false,
        onRun = function(client, arguments)
        end
    }
)

if lia.config.FactionBroadcastEnabled then
    lia.command.add(
        "factionbroadcast",
        {
            adminOnly = false,
            syntax = "<string factions> <string text>",
            onRun = function(client, arguments)
            end
        }
    )
end

if lia.config.AdvertisementEnabled then
    lia.command.add(
        "advertisement",
        {
            adminOnly = false,
            syntax = "<string factions> <string text>",
            onRun = function(client, arguments)
            end
        }
    )
end

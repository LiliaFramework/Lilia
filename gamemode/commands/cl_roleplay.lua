--------------------------------------------------------------------------------------------------------
lia.command.add("roll", {
    adminOnly = false,
    privilege = "Basic User Permissions",
    syntax = "[number maximum]",
    onRun = function(client, arguments) end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("dropmoney", {
    adminOnly = false,
    privilege = "Basic User Permissions",
    syntax = "<number amount>",
    onRun = function(client, arguments) end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("chardesc", {
    adminOnly = false,
    privilege = "Basic User Permissions",
    syntax = "<string desc>",
    onRun = function(client, arguments) end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("beclass", {
    adminOnly = false,
    syntax = "<string class>",
    privilege = "Basic User Permissions",
    onRun = function(client, arguments) end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("chargetup", {
    adminOnly = false,
    privilege = "Basic User Permissions",
    onRun = function(client, arguments) end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("givemoney", {
    adminOnly = false,
    privilege = "Basic User Permissions",
    syntax = "<number amount>",
    onRun = function(client, arguments) end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("bringlostitems", {
    adminOnly = false,
    privilege = "Basic User Permissions",
    onRun = function(client, arguments) end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("carddraw", {
    adminOnly = false,
    privilege = "Basic User Permissions",
    onRun = function(client, arguments) end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("fallover", {
    adminOnly = false,
    privilege = "Basic User Permissions",
    syntax = "[number time]",
    onRun = function(client, arguments) end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("factionlist", {
    adminOnly = false,
    privilege = "Basic User Permissions",
    syntax = "<string text>",
    onRun = function(client, arguments) end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("getpos", {
    adminOnly = false,
    privilege = "Basic User Permissions",
    onRun = function(client, arguments) end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("doorname", {
    adminOnly = false,
    privilege = "Basic User Permissions",
    onRun = function(client, arguments) end
})
--------------------------------------------------------------------------------------------------------
if lia.config.FactionBroadcastEnabled then
    lia.command.add("factionbroadcast", {
        adminOnly = false,
        privilege = "Basic User Permissions",
        syntax = "<string factions> <string text>",
        onRun = function(client, arguments) end
    })
end
--------------------------------------------------------------------------------------------------------
if lia.config.AdvertisementEnabled then
    lia.command.add("advertisement", {
        adminOnly = false,
        privilege = "Basic User Permissions",
        syntax = "<string factions> <string text>",
        onRun = function(client, arguments) end
    })
end
--------------------------------------------------------------------------------------------------------
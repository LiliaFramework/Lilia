--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "freezeallprops",
    {
        superAdminOnly = true,
        privilege = "Freeze All Props",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "status",
    {
        privilege = "Default User Commands",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "setclass",
    {
        privilege = "Set Class",
        adminOnly = true,
        syntax = "<string target> <string class>",
        onRun = function(client, arguments) end,
    }
)

-------------------------------------------------------------------------------------------------------
lia.command.add(
    "checkmoney",
    {
        syntax = "<string target>",
        privilege = "Check Money",
        adminOnly = true,
        onRun = function(client, arguments) end
    }
)

-------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "cleanitems",
    {
        superAdminOnly = true,
        privilege = "Clean Items",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "cleanprops",
    {
        superAdminOnly = true,
        privilege = "Clean Props",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "savemap",
    {
        superAdminOnly = true,
        privilege = "Save Map Data",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "cleannpcs",
    {
        superAdminOnly = true,
        privilege = "Clean NPCs",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "flags",
    {
        adminOnly = true,
        syntax = "<string name>",
        privilege = "Check Flags",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "clearchat",
    {
        superAdminOnly = true,
        privilege = "Clear Chat",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "checkallmoney",
    {
        superAdminOnly = true,
        syntax = "<string charname>",
        privilege = "Check All Money",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "return",
    {
        adminOnly = true,
        privilege = "Return",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "findallflags",
    {
        adminOnly = false,
        privilege = "Find All Flags",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "chargiveitem",
    {
        superAdminOnly = true,
        syntax = "<string name> <string item>",
        privilege = "Give Item",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "netmessagelogs",
    {
        superAdminOnly = true,
        privilege = "Check Net Message Log",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "returnitems",
    {
        superAdminOnly = true,
        syntax = "<string name>",
        privilege = "Return Items",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "announce",
    {
        superAdminOnly = true,
        syntax = "<string factions> <string text>",
        privilege = "Make Announcements",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "voiceunban",
    {
        adminOnly = true,
        privilege = "Voice Unban Character",
        syntax = "<string name>",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "voiceban",
    {
        adminOnly = true,
        privilege = "Voice ban Character",
        syntax = "<string name>",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
for k, _ in pairs(lia.config.ServerURLs) do
    lia.command.add(
        k,
        {
            adminOnly = false,
            privilege = "Default User Commands",
            onRun = function(client, arguments) end
        }
    )
end
--------------------------------------------------------------------------------------------------------------------------

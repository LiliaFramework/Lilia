--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetspeed",
    {
        adminOnly = true,
        syntax = "<string name> <number speed>",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetjump",
    {
        adminOnly = true,
        syntax = "<string name> <number power>",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charaddmoney",
    {
        privilege = "Add Money",
        superAdminOnly = true,
        syntax = "<string target> <number amount>",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charban",
    {
        superAdminOnly = true,
        syntax = "<string name>",
        privilege = "Ban Characters",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetdesc",
    {
        adminOnly = true,
        syntax = "<string name> <string desc>",
        privilege = "Change Description",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "plytransfer",
    {
        adminOnly = true,
        syntax = "<string name> <string faction>",
        privilege = "Transfer Player",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetname",
    {
        adminOnly = true,
        syntax = "<string name> [string newName]",
        privilege = "Change Name",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "chargetmodel",
    {
        adminOnly = true,
        syntax = "<string name>",
        privilege = "Retrieve Model",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetmodel",
    {
        adminOnly = true,
        syntax = "<string name> <string model>",
        privilege = "Change Model",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetbodygroup",
    {
        adminOnly = true,
        syntax = "<string name> <string bodyGroup> [number value]",
        privilege = "Change Bodygroups",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetskin",
    {
        adminOnly = true,
        syntax = "<string name> [number skin]",
        privilege = "Change Skin",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "chargetmoney",
    {
        adminOnly = true,
        syntax = "<string name>",
        privilege = "Retrieve Money",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetmoney",
    {
        superAdminOnly = true,
        syntax = "<string target> <number amount>",
        privilege = "Change Money",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetattrib",
    {
        superAdminOnly = true,
        syntax = "<string charname> <string attribname> <number level>",
        privilege = "Change Attributes",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charaddattrib",
    {
        superAdminOnly = true,
        syntax = "<string charname> <string attribname> <number level>",
        privilege = "Change Attributes",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "checkinventory",
    {
        superAdminOnly = true,
        syntax = "<string target>",
        privilege = "Check Inventory",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "clearinv",
    {
        superAdminOnly = true,
        syntax = "<string name>",
        privilege = "Clear Inventory",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "flaggive",
    {
        adminOnly = true,
        syntax = "<string name> [string flags]",
        privilege = "Toggle Flags",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "flagtake",
    {
        adminOnly = true,
        syntax = "<string name> [string flags]",
        privilege = "Toggle Flags",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charkick",
    {
        adminOnly = true,
        syntax = "<string name>",
        privilege = "Kick Characters",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "plywhitelist",
    {
        adminOnly = true,
        privilege = "Whitelist Characters",
        syntax = "<string name> <string faction>",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "plyunwhitelist",
    {
        adminOnly = true,
        privilege = "Un-Whitelist Characters",
        syntax = "<string name> <string faction>",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charunban",
    {
        syntax = "<string name>",
        superAdminOnly = true,
        privilege = "Un-Ban Characters",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "viewextdescription",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "charsetextdescription",
    {
        adminOnly = true,
        privilege = "Change Description",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "flagpet",
    {
        privilege = "Give pet Flags",
        adminOnly = true,
        syntax = "[character name]",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "flags",
    {
        privilege = "Check Flags",
        adminOnly = true,
        syntax = "<string name>",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "flagragdoll",
    {
        adminOnly = true,
        privilege = "Hand Ragdoll Medals",
        syntax = "<string name>",
        onRun = function(client, arguments) end
    }
)
--------------------------------------------------------------------------------------------------------------------------
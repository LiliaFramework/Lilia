--[[
    This file documents COMMAND fields defined within the codebase.

    Generated automatically.
]]

--[[
    alias

    Description:
        Alternative command names that also trigger the same command.
        Can be a single string or a table of strings.

    Example Usage:
            alias = {"chargiveflag", "giveflag"}
]]

--[[
    adminOnly

    Description:
        When true only players with admin privileges (or higher)
        may run the command. A CAMI privilege is registered
        automatically.

    Example Usage:
            adminOnly = true
]]

--[[
    superAdminOnly

    Description:
        Restricts usage to super administrators. Like adminOnly this
        registers a CAMI privilege if needed.

    Example Usage:
            superAdminOnly = true
]]

--[[
    privilege

    Description:
        Name of the CAMI privilege checked when running the command.
        If omitted, the command name itself is used as the privilege.

    Example Usage:
            privilege = "Manage Doors"
]]

--[[
    syntax

    Description:
        Human readable syntax string shown in help menus. This has
        no effect on parsing but informs players how to format
        the arguments. The argument prompt only appears when
        each token follows the "[type Name]" format.

    Example Usage:
            syntax = "[string Target Name] [number Amount]"
]]

--[[
    desc

    Description:
        Short description of what the command does. Displayed in
        command lists and menus.

    Example Usage:
            desc = L("doorbuyDesc")
]]

--[[
    AdminStick

    Description:
        Table describing how the command should appear in admin
        utilities. Common keys include:
            Name        - display text in the menu.
            Category    - top level grouping.
            SubCategory - secondary grouping.
            Icon        - 16x16 icon path.
            ExtraFields - (optional) legacy field definitions. Missing
            arguments are now prompted automatically using the syntax string.

    Example Usage:
            AdminStick = {
                Name = "Set Character Skin",
                Category = "Player Informations",
                SubCategory = "Set Informations",
                Icon = "icon16/user_gray.png"
            }
]]

--[[
    onRun(client, arguments)

    Description:
        Function executed when the command is run. Arguments are
        already parsed and provided as a table.
        Return a string to notify the caller or nothing to stay silent.

    Example Usage:
            onRun = function(client, arguments)
                local target = lia.util.findPlayer(client, arguments[1])
                if target then
                    target:Kill()
                end
            end
]]

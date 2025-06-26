--[[
    This file documents the default MODULE fields
    provided by the Lilia framework.

    Generated automatically.
]]

--[[
    name

    Description:
        Identifies the module in logs and UI elements.

    Type:
        string

    Example Usage:
        MODULE.name = "My Module"
]]

--[[
    author

    Description:
        Name or SteamID64 of the module's author.

    Type:
        string

    Example Usage:
        MODULE.author = "Samael"
]]

--[[
    discord

    Description:
        Discord tag or support channel for the module.

    Type:
        string

    Example Usage:
        MODULE.discord = "@liliaplayer"
]]

--[[
    version

    Description:
        Version string used for compatibility checks.

    Type:
        string

    Example Usage:
        MODULE.version = "1.0"
]]

--[[
    desc

    Description:
        Short description of what the module provides.

    Type:
        string

    Example Usage:
        MODULE.desc = "Adds a Chatbox"
]]

--[[
    identifier

    Description:
        Unique key used to reference this module globally.

    Type:
        string

    Example Usage:
        MODULE.identifier = "example_mod"
]]

--[[
    CAMIPrivileges

    Description:
        Table defining CAMI privileges required or provided by the module.

    Type:
        table

    Example Usage:
        MODULE.CAMIPrivileges = {
            {Name = "Staff Permissions - Admin Chat", MinAccess = "admin"}
        }
]]

--[[
    WorkshopContent

    Description:
        Steam Workshop add-on IDs required by this module.

    Type:
        table

    Example Usage:
        MODULE.WorkshopContent = {"2959728255"}
]]

--[[
    enabled

    Description:
        Boolean or function that controls whether the module loads.

    Type:
        boolean or function

    Example Usage:
        MODULE.enabled = true
]]

--[[
    Dependencies

    Description:
        Files or folders that this module requires to run.

    Type:
        table

    Example Usage:
        MODULE.Dependencies = {
            {File = "logs.lua", Realm = "server"}
        }
]]

--[[
    folder

    Description:
        Filesystem path where the module is located.

    Type:
        string

    Example Usage:
        print(MODULE.folder)
]]

--[[
    path

    Description:
        Absolute path to the module's root directory.

    Type:
        string

    Example Usage:
        print(MODULE.path)
]]

--[[
    uniqueID

    Description:
        Identifier used internally for the module list.

    Type:
        string

    Example Usage:
        print(MODULE.uniqueID)
]]

--[[
    loading

    Description:
        True while the module is in the process of loading.

    Type:
        boolean

    Example Usage:
        if MODULE.loading then return end
]]

--[[
    ModuleLoaded

    Description:
        Optional callback run after the module finishes loading.

    Type:
        function

    Example Usage:
        function MODULE:ModuleLoaded()
            print("Module fully initialized")
        end
]]

--[[
    Public

    Description:
        When true, the module participates in public version checks.

    Type:
        boolean

    Example Usage:
        MODULE.Public = true
]]

--[[
    Private

    Description:
        When true, the module uses private version checking.

    Type:
        boolean

    Example Usage:
        MODULE.Private = true
]]


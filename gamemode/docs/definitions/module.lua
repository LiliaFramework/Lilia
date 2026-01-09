--[[
    Folder: Definitions
    File:  module.md
]]
--[[
    Module Definitions

    Module definition system for the Lilia framework.

    PLACEMENT INSTRUCTIONS:

    SCHEMA LOCATION:
    - Path: garrysmod/gamemodes/<SchemaName>/schema/modules/
    - File naming: Use descriptive names like "inventory.lua", "chatbox.lua", "doors.lua"
    - Registration: Each file should define a MODULE table and register it using lia.module.register()
    - Example: lia.module.register("inventory", MODULE)

    MODULE LOCATION:
    - Path: garrysmod/gamemodes/<SchemaName>/modules/<ModuleName>/
    - File naming: Use descriptive names like "sh_inventory.lua", "cl_inventory.lua", "sv_inventory.lua"
    - Registration: Each file should define a MODULE table and register it using lia.module.register()
    - Example: lia.module.register("custom_inventory", MODULE)

    FILE STRUCTURE EXAMPLES:
    Schema: garrysmod/gamemodes/myschema/schema/modules/inventory.lua
    Module: garrysmod/gamemodes/myschema/modules/custommodule/sh_inventory.lua

    NOTE: Modules represent self-contained systems that add specific functionality to the gamemode.
    Each module can have dependencies, privileges, network strings, and various configuration options.
    Modules support both server-side logic for gameplay mechanics and client-side properties for UI.
]]
--[[
    Overview:
    The module system provides comprehensive functionality for defining modules within the Lilia framework. Modules represent self-contained systems that add specific functionality to the gamemode, each with unique properties, behaviors, and configuration options. The system supports both server-side logic for gameplay mechanics and client-side properties for user interface and experience. Modules are defined using the MODULE table structure, which includes properties for identification, metadata, dependencies, privileges, and configuration. The system includes callback methods that are automatically invoked during key module lifecycle events, enabling dynamic behavior and customization. Modules can have dependencies, privileges, network strings, and various configuration options, providing a flexible foundation for modular systems.
]]
--[[
    Purpose:
        Sets the display name of the module

    Example Usage:
        ```lua
        -- Set the display name for the module
        MODULE.name = "Inventory System"
        ```
]]
MODULE.name = ""
--[[
    Purpose:
        Sets the author of the module

    Example Usage:
        ```lua
        -- Set the module author
        MODULE.author = "Samael"
        ```
]]
MODULE.author = ""
--[[
    Purpose:
        Sets the Discord contact for the module author

    Example Usage:
        ```lua
        -- Set the Discord contact for support
        MODULE.discord = "@liliaplayer"
        ```
]]
MODULE.discord = ""
--[[
    Purpose:
        Sets the description of the module

    Example Usage:
        ```lua
        -- Set a detailed description of what the module does
        MODULE.desc = "A comprehensive inventory management system"
        ```
]]
MODULE.desc = ""
--[[
    Purpose:
        Sets the version number of the module

    Example Usage:
        ```lua
        -- Set the module version number
        MODULE.version = 1.0
        ```
]]
MODULE.version = 0
--[[
    Purpose:
        Sets the unique version identifier for the module

    Example Usage:
        ```lua
        -- Set a unique identifier for version tracking
        MODULE.versionID = "private_inventory"
        ```
]]
MODULE.versionID = ""
--[[
    Purpose:
        Unique identifier for the module (INTERNAL - set automatically when loaded)

    When Called:
        Set automatically during module loading
    Note: This property is internal and should not be modified directly

    Example Usage:
        ```lua
        -- This is set automatically when the module is loaded from its folder name
        -- Module in folder "inventory" will have uniqueID = "inventory"
        ```
]]
MODULE.uniqueID = ""
--[[
    Purpose:
        Sets the privileges required for this module

    Example Usage:
        ```lua
        -- Define required privileges for module access
        MODULE.Privileges = {
            { Name = "canManageInventory", Min = 1 }
        }
        ```
]]
MODULE.Privileges = {}
--[[
    Purpose:
        Sets the file dependencies for this module

    Example Usage:
        ```lua
        -- Define required files for this module
        MODULE.Dependencies = {
            { File = "gridinv.lua", Type = "shared" }
        }
        ```
]]
MODULE.Dependencies = {}
--[[
    Purpose:
        Sets the network strings used by this module

    Example Usage:
        ```lua
        -- Define network strings for client-server communication
        MODULE.NetworkStrings = {"liaInventoryOpen", "liaInventorySync"}
        ```
]]
MODULE.NetworkStrings = {}
--[[
    Purpose:
        Sets the Workshop content IDs required by this module

    Example Usage:
        ```lua
        -- Set required Workshop content (single ID or table of IDs)
        MODULE.WorkshopContent = "1234567890"
        MODULE.WorkshopContent = {"1234567890", "0987654321"}
        ```
]]
MODULE.WorkshopContent = ""
--[[
    Purpose:
        Sets the web-hosted sound files used by this module

    Example Usage:
        ```lua
        -- Define web-hosted sound files for the module
        MODULE.WebSounds = {
            ["sounds/beep.wav"] = "https://example.com/sounds/beep.wav"
        }
        ```
]]
MODULE.WebSounds = {}
--[[
    Purpose:
        Sets the web-hosted image files used by this module

    Example Usage:
        ```lua
        -- Define web-hosted image files for the module
        MODULE.WebImages = {
            ["icons/inventory.png"] = "https://example.com/icons/inventory.png"
        }
        ```
]]
MODULE.WebImages = {}
--[[
    Purpose:
        Sets whether the module is enabled by default

    Example Usage:
        ```lua
        -- Enable or disable the module by default
        MODULE.enabled = function()
            if not lia.config.get("EnableInventory", true) then
                return false, "Inventory has been disabled in configuration"
            end

            return true
        end
        ```
]]
MODULE.enabled = true
--[[
    Purpose:
        Sets the folder path for the module
    Internal Variable: This is set automatically by the module system
]]
MODULE.folder = ""
--[[
    Purpose:
        Sets the file path for the module
    Internal Variable: This is set automatically by the module system
]]
MODULE.path = ""
--[[
    Purpose:
        Sets the variable name for the module
    Internal Variable: This is set automatically by the module system
]]
MODULE.variable = ""
--[[
    Purpose:
        Sets whether the module is currently loading
    Internal Variable: This is set automatically by the module system
]]
MODULE.loading = false
--[[
    Purpose:
        Persists module-specific data via lia.data using the module's uniqueID

    Example Usage:
        ```lua
        MODULE:setData({ pinned = true })
        ```
]]
function MODULE:setData(value, global, ignoreMap)
end

--[[
    Purpose:
        Retrieves the table saved by `setData` and returns the supplied default when nothing was stored yet

    Example Usage:
        ```lua
        local settings = MODULE:getData({ pinned = false })
        ```
]]
function MODULE:getData(default)
end

--[[
    Purpose:
        Called once the module and its dependencies have been fully initialized (permissions, includes, submodules, etc.) so you can do final setup.

    Example Usage:
        ```lua
        function MODULE:ModuleLoaded()
            print(self.name .. " ready.")
        end
        ```
]]
function MODULE:ModuleLoaded()
end

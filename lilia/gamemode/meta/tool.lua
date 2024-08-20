--[[--
A custom tool class based on the Base GMOD Toolgun, designed for integration with Lilia's framework.

The `ToolGun` class extends the functionality of the base GMOD toolgun, enabling seamless integration with Lilia's files and configuration. This custom tool class provides a flexible framework for creating and managing interactive tools within Garry's Mod, specifically tailored to work with Lilia's environment and system.

The `ToolGun` class is designed to work in conjunction with Lilia's file system and configuration setup. It allows for the implementation of toolguns that can be dynamically loaded and configured based on Lilia's files, offering a robust solution for extending tool functionalities in a modular way.

### Customization and Flexibility:
The `ToolGun` class provides a foundation for creating custom tools that integrate smoothly with Lilia's system. Developers can extend and modify the class to fit specific needs, leveraging Lilia's configuration files to dictate tool behavior and appearance. This approach ensures that tools can be easily adapted and updated in line with Lilia's framework, providing a consistent and maintainable tool environment.

By integrating with Lilia's files, the `ToolGun` class enables developers to build sophisticated tools that are fully compatible with Lilia's system, enhancing the overall gameplay experience and tool management within Garry's Mod.
]]
-- @toolmeta Framework
local toolGunMeta = lia.meta.tool or {}

--- Creates a new tool object.
-- This method initializes a new tool object with default properties. It sets up the metatable and various default values such as `Mode`, `SWEP`, `Owner`, `ClientConVar`, `ServerConVar`, `Objects`, `Stage`, `Message`, `LastMessage`, and `AllowedCVar`.
-- @realm shared
-- @return table A new tool object with default properties.
function toolGunMeta:Create()
    local object = {}
    setmetatable(object, self)
    self.__index = self
    object.Mode = nil
    object.SWEP = nil
    object.Owner = nil
    object.ClientConVar = {}
    object.ServerConVar = {}
    object.Objects = {}
    object.Stage = 0
    object.Message = "start"
    object.LastMessage = 0
    object.AllowedCVar = 0
    return object
end

--- Creates client and server convars for the tool.
-- This method generates convars (console variables) based on the tool's mode. Client convars are created on the client-side, while server convars are created on the server-side.
-- @realm shared
-- @see CreateClientConVar, CreateConVar
function toolGunMeta:CreateConVars()
    local mode = self:GetMode()
    if CLIENT then
        for cvar, default in pairs(self.ClientConVar) do
            CreateClientConVar(mode .. "_" .. cvar, default, true, true)
        end
        return
    else
        self.AllowedCVar = CreateConVar("toolmode_allow_" .. mode, 1, FCVAR_NOTIFY)
    end
end

--- Retrieves server-side information for a given property.
-- This method returns the value of a server-side convar associated with the tool's mode.
-- @realm shared
-- @string property The name of the property to retrieve.
-- @return string The value of the server convar.
function toolGunMeta:GetServerInfo(property)
    local mode = self:GetMode()
    return ConVar(mode .. "_" .. property)
end

--- Builds a list of client-side convars.
-- This method constructs a table of convars by appending the mode prefix to each convar name.
-- @realm shared
-- @return table A table containing the mode-prefixed convars.
function toolGunMeta:BuildConVarList()
    local mode = self:GetMode()
    local convars = {}
    for k, v in pairs(self.ClientConVar) do
        convars[mode .. "_" .. k] = v
    end
    return convars
end

--- Retrieves client-side information for a given property.
-- This method returns the value of a client-side convar associated with the tool's mode.
-- @realm shared
-- @string property The name of the property to retrieve.
-- @return string The value of the client convar.
function toolGunMeta:GetClientInfo(property)
    return self:GetOwner():GetInfo(self:GetMode() .. "_" .. property)
end

--- Retrieves a numerical value from client-side convars.
-- This method returns the value of a client-side convar as a number, or a default value if the convar does not exist.
-- @realm shared
-- @string property The name of the property to retrieve.
-- @number default The default value to return if the convar is not found.
-- @return number The numerical value of the client convar.
function toolGunMeta:GetClientNumber(property, default)
    return self:GetOwner():GetInfoNum(self:GetMode() .. "_" .. property, tonumber(default) or 0)
end

--- Checks if the tool is allowed on the server.
-- This method returns whether the tool is allowed based on the server convar `AllowedCVar`. It always returns true on the client-side.
-- @realm shared
-- @return boolean True if the tool is allowed, false otherwise.
function toolGunMeta:Allowed()
    if CLIENT then return true end
    return self.AllowedCVar:GetBool()
end

--- Placeholder for initializing the tool.
-- This method is intended to be overridden if initialization logic is needed when the tool is created.
-- @realm shared
function toolGunMeta:Init()
end

--- Retrieves the mode of the tool.
-- This method returns the current mode of the tool, which is a string representing the specific operation the tool is set to perform.
-- @realm shared
-- @return string The current mode of the tool.
function toolGunMeta:GetMode()
    return self.Mode
end

--- Retrieves the SWEP (Scripted Weapon) associated with the tool.
-- This method returns the SWEP object, which is typically the weapon the player is holding while using the tool.
-- @realm shared
-- @return SWEP The SWEP object associated with the tool.
function toolGunMeta:GetSWEP()
    return self.SWEP
end

--- Retrieves the owner of the tool.
-- This method returns the player who owns the tool by accessing the SWEP's `Owner` property.
-- @realm shared
-- @return Player The player who owns the tool.
function toolGunMeta:GetOwner()
    return self:GetSWEP().Owner or self:GetOwner()
end

--- Retrieves the weapon associated with the tool.
-- This method returns the weapon associated with the tool by accessing the SWEP's `Weapon` property or the tool's own `Weapon` property.
-- @realm shared
-- @return Weapon The weapon object associated with the tool.
function toolGunMeta:GetWeapon()
    return self:GetSWEP().Weapon or self.Weapon
end

--- Handles the left-click action with the tool.
-- This method is intended to be overridden to define what happens when the player left-clicks with the tool. By default, it does nothing and returns false.
-- @realm shared
-- @return boolean False by default, indicating no action was taken.
function toolGunMeta:LeftClick()
    return false
end

--- Handles the right-click action with the tool.
-- This method is intended to be overridden to define what happens when the player right-clicks with the tool. By default, it does nothing and returns false.
-- @realm shared
-- @return boolean False by default, indicating no action was taken.
function toolGunMeta:RightClick()
    return false
end

--- Handles the reload action with the tool.
-- This method clears the objects that the tool is currently manipulating when the player reloads with the tool.
-- @realm shared
function toolGunMeta:Reload()
    self:ClearObjects()
end

--- Deploys the tool.
-- This method is called when the player equips the tool. It releases any ghost entities associated with the tool.
-- @realm shared
function toolGunMeta:Deploy()
    self:ReleaseGhostEntity()
    return
end

--- Holsters the tool.
-- This method is called when the player unequips the tool. It releases any ghost entities associated with the tool.
-- @realm shared
function toolGunMeta:Holster()
    self:ReleaseGhostEntity()
    return
end

--- Handles the tool's "think" logic.
-- This method is called periodically to perform updates. By default, it releases any ghost entities associated with the tool.
-- @realm shared
function toolGunMeta:Think()
    self:ReleaseGhostEntity()
end

--- Checks the validity of objects the tool is manipulating.
-- This method iterates over the tool's objects and clears them if they are no longer valid, such as if the entity is no longer part of the world or is invalid.
-- @realm shared
function toolGunMeta:CheckObjects()
    for _, v in pairs(self.Objects) do
        if not v.Ent:IsWorld() and not v.Ent:IsValid() then self:ClearObjects() end
    end
end

lia.meta.tool = toolGunMeta
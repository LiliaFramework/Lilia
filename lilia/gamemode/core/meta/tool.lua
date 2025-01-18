
-- @toolmeta Framework
local ToolGunMeta = lia.meta.tool or {}
--- Creates a new tool object.
-- This method initializes a new tool object with default properties. It sets up the metatable and various default values such as `Mode`, `SWEP`, `Owner`, `ClientConVar`, `ServerConVar`, `Objects`, `Stage`, `Message`, `LastMessage`, and `AllowedCVar`.
-- @realm shared
-- @treturn Table A new tool object with default properties.
-- @usage
-- local tool = ToolGunMeta:Create()
-- tool.Mode = "builder"
function ToolGunMeta:Create()
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
-- @usage
-- tool:CreateConVars()
function ToolGunMeta:CreateConVars()
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
-- @treturn ConVar The server convar object.
-- @usage
-- local allowUse = tool:GetServerInfo("allow_use"):GetBool()
function ToolGunMeta:GetServerInfo(property)
    local mode = self:GetMode()
    return ConVar(mode .. "_" .. property)
end

--- Builds a list of client-side convars.
-- This method constructs a table of convars by appending the mode prefix to each convar name.
-- @realm shared
-- @treturn Table A table containing the mode-prefixed convars.
-- @usage
-- local convars = tool:BuildConVarList()
-- for k, v in pairs(convars) do
--     print(k, v)
-- end
function ToolGunMeta:BuildConVarList()
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
-- @treturn String The value of the client convar.
-- @usage
-- local toolSetting = tool:GetClientInfo("setting")
-- print("Tool Setting:", toolSetting)
function ToolGunMeta:GetClientInfo(property)
    return self:GetOwner():GetInfo(self:GetMode() .. "_" .. property)
end

--- Retrieves a numerical value from client-side convars.
-- This method returns the value of a client-side convar as a number, or a default value if the convar does not exist.
-- @realm shared
-- @string property The name of the property to retrieve.
-- @float default The default value to return if the convar does not exist.
-- @treturn Float The numerical value of the client convar.
-- @usage
-- local toolPower = tool:GetClientNumber("power", 10)
-- print("Tool Power:", toolPower)
function ToolGunMeta:GetClientNumber(property, default)
    return self:GetOwner():GetInfoNum(self:GetMode() .. "_" .. property, tonumber(default) or 0)
end

--- Checks if the tool is allowed on the server.
-- This method returns whether the tool is allowed based on the server convar `AllowedCVar`. It always returns true on the client-side.
-- @realm shared
-- @treturn Boolean True if the tool is allowed, false otherwise.
-- @usage
-- if tool:Allowed() then
--     print("Tool is allowed.")
-- else
--     print("Tool is not allowed.")
-- end
function ToolGunMeta:Allowed()
    if CLIENT then return true end
    return self.AllowedCVar:GetBool()
end

--- Placeholder for initializing the tool.
-- This method is intended to be overridden if initialization logic is needed when the tool is created.
-- @realm shared
-- @usage
-- function ToolGunMeta:Init()
--     -- Custom initialization logic here
-- end
function ToolGunMeta:Init()
end

--- Retrieves the mode of the tool.
-- This method returns the current mode of the tool, which is a string representing the specific operation the tool is set to perform.
-- @realm shared
-- @treturn String The current mode of the tool.
-- @usage
-- local mode = tool:GetMode()
-- print("Tool Mode:", mode)
function ToolGunMeta:GetMode()
    return self.Mode
end

--- Retrieves the SWEP (Scripted Weapon) associated with the tool.
-- This method returns the SWEP object, which is typically the weapon the player is holding while using the tool.
-- @realm shared
-- @treturn SWEP The SWEP object associated with the tool.
-- @usage
-- local swep = tool:GetSWEP()
-- print("Tool SWEP:", swep:GetClass())
function ToolGunMeta:GetSWEP()
    return self.SWEP
end

--- Retrieves the owner of the tool.
-- This method returns the player who owns the tool by accessing the SWEP's `Owner` property.
-- @realm shared
-- @treturn Player The player who owns the tool.
-- @usage
-- local owner = tool:GetOwner()
-- print("Tool Owner:", owner:Nick())
function ToolGunMeta:GetOwner()
    return self:GetSWEP().Owner or self:GetOwner()
end

--- Retrieves the weapon associated with the tool.
-- This method returns the weapon associated with the tool by accessing the SWEP's `Weapon` property or the tool's own `Weapon` property.
-- @realm shared
-- @treturn Weapon The weapon object associated with the tool.
-- @usage
-- local weapon = tool:GetWeapon()
-- print("Associated Weapon:", weapon:GetClass())
function ToolGunMeta:GetWeapon()
    return self:GetSWEP().Weapon or self.Weapon
end

--- Handles the left-click action with the tool.
-- This method is intended to be overridden to define what happens when the player left-clicks with the tool. By default, it does nothing and returns false.
-- @realm shared
-- @treturn Boolean False by default, indicating no action was taken.
-- @usage
-- function ToolGunMeta:LeftClick(trace)
--     -- Custom left-click logic here
--     return true
-- end
function ToolGunMeta:LeftClick()
    return false
end

--- Handles the right-click action with the tool.
-- This method is intended to be overridden to define what happens when the player right-clicks with the tool. By default, it does nothing and returns false.
-- @realm shared
-- @treturn Boolean False by default, indicating no action was taken.
-- @usage
-- function ToolGunMeta:RightClick(trace)
--     -- Custom right-click logic here
--     return true
-- end
function ToolGunMeta:RightClick()
    return false
end

--- Handles the reload action with the tool.
-- This method clears the objects that the tool is currently manipulating when the player reloads with the tool.
-- @realm shared
-- @usage
-- function ToolGunMeta:Reload()
--     self:ClearObjects()
-- end
function ToolGunMeta:Reload()
    self:ClearObjects()
end

--- Deploys the tool.
-- This method is called when the player equips the tool. It releases any ghost entities associated with the tool.
-- @realm shared
-- @usage
-- function ToolGunMeta:Deploy()
--     self:ReleaseGhostEntity()
-- end
function ToolGunMeta:Deploy()
    self:ReleaseGhostEntity()
    return
end

--- Holsters the tool.
-- This method is called when the player unequips the tool. It releases any ghost entities associated with the tool.
-- @realm shared
-- @usage
-- function ToolGunMeta:Holster()
--     self:ReleaseGhostEntity()
-- end
function ToolGunMeta:Holster()
    self:ReleaseGhostEntity()
    return
end

--- Handles the tool's "think" logic.
-- This method is called periodically to perform updates. By default, it releases any ghost entities associated with the tool.
-- @realm shared
-- @usage
-- function ToolGunMeta:Think()
--     self:ReleaseGhostEntity()
-- end
function ToolGunMeta:Think()
    self:ReleaseGhostEntity()
end

--- Checks the validity of objects the tool is manipulating.
-- This method iterates over the tool's objects and clears them if they are no longer valid, such as if the entity is no longer part of the world or is invalid.
-- @realm shared
-- @usage
-- tool:CheckObjects()
function ToolGunMeta:CheckObjects()
    for _, v in pairs(self.Objects) do
        if not v.Ent:IsWorld() and not IsValid(v.Ent) then self:ClearObjects() end
    end
end

--- Clears all objects the tool is manipulating.
-- This method removes all objects from the tool's `Objects` table, effectively resetting the tool's state.
-- @realm shared
-- @usage
-- tool:ClearObjects()
function ToolGunMeta:ClearObjects()
    self.Objects = {}
end

--- Releases any ghost entities associated with the tool.
-- This method removes any ghost entities the tool may be holding, ensuring that no visual artifacts remain when the tool is not actively manipulating objects.
-- @realm shared
-- @usage
-- tool:ReleaseGhostEntity()
function ToolGunMeta:ReleaseGhostEntity()
    if IsValid(self.GhostEntity) then
        self.GhostEntity:Remove()
        self.GhostEntity = nil
    end
end

lia.meta.tool = ToolGunMeta

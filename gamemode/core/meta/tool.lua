local ToolGunMeta = lia.meta.tool or {}
--[[
    ToolGunMeta:Create()

    Description:
        Creates a new tool object with default values.

    Realm:
        Shared

    Returns:
        table – The newly created tool object.

    Example Usage:
        local tool = ToolGunMeta:Create()
]]

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
    object.Message = L("start")
    object.LastMessage = 0
    object.AllowedCVar = 0
    return object
end

--[[
    ToolGunMeta:CreateConVars()

    Description:
        Creates client and server ConVars for this tool.

    Realm:
        Shared

    Example Usage:
        tool:CreateConVars()
]]
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

--[[
    ToolGunMeta:GetServerInfo(property)

    Description:
        Returns the server ConVar for the given property.

    Parameters:
        property (string) – Property name.

    Realm:
        Shared

    Returns:
        ConVar – The server ConVar object.

    Example Usage:
        local allow = tool:GetServerInfo("allow_use"):GetBool()
]]
function ToolGunMeta:GetServerInfo(property)
    local mode = self:GetMode()
    return ConVar(mode .. "_" .. property)
end

--[[
    ToolGunMeta:BuildConVarList()

    Description:
        Returns a table of client ConVars prefixed by the tool mode.

    Realm:
        Shared

    Returns:
        table – Table of convars.

    Example Usage:
        local cvars = tool:BuildConVarList()
]]
function ToolGunMeta:BuildConVarList()
    local mode = self:GetMode()
    local convars = {}
    for k, v in pairs(self.ClientConVar) do
        convars[mode .. "_" .. k] = v
    end
    return convars
end

--[[
    ToolGunMeta:GetClientInfo(property)

    Description:
        Retrieves a client ConVar value as a string.

    Parameters:
        property (string) – ConVar name without mode prefix.

    Realm:
        Shared

    Returns:
        string – The value stored in the ConVar.

    Example Usage:
        local val = tool:GetClientInfo("setting")
]]
function ToolGunMeta:GetClientInfo(property)
    return self:GetOwner():GetInfo(self:GetMode() .. "_" .. property)
end

--[[
    ToolGunMeta:GetClientNumber(property, default)

    Description:
        Retrieves a numeric client ConVar value.

    Parameters:
        property (string) – ConVar name without mode prefix.
        default (number) – Value returned if the ConVar doesn't exist.

    Realm:
        Shared

    Returns:
        number – The numeric value of the ConVar.

    Example Usage:
        local power = tool:GetClientNumber("power", 10)
]]
function ToolGunMeta:GetClientNumber(property, default)
    return self:GetOwner():GetInfoNum(self:GetMode() .. "_" .. property, tonumber(default) or 0)
end

--[[
    ToolGunMeta:Allowed()

    Description:
        Determines whether this tool is allowed to be used.

    Realm:
        Shared

    Returns:
        boolean – True if the tool is allowed.

    Example Usage:
        if tool:Allowed() then print("ok") end
]]
function ToolGunMeta:Allowed()
    if CLIENT then return true end
    return self.AllowedCVar:GetBool()
end

--[[
    ToolGunMeta:Init()

    Description:
        Placeholder for tool initialization.

    Realm:
        Shared
]]
function ToolGunMeta:Init()
end

--[[
    ToolGunMeta:GetMode()

    Description:
        Gets the current tool mode string.

    Realm:
        Shared

    Returns:
        string – Tool mode name.
]]
function ToolGunMeta:GetMode()
    return self.Mode
end

--[[
    ToolGunMeta:GetSWEP()

    Description:
        Returns the SWEP associated with this tool.

    Realm:
        Shared

    Returns:
        SWEP – The tool's weapon entity.
]]
function ToolGunMeta:GetSWEP()
    return self.SWEP
end

--[[
    ToolGunMeta:GetOwner()

    Description:
        Retrieves the tool owner's player object.

    Realm:
        Shared

    Returns:
        Player – Owner of the tool.
]]
function ToolGunMeta:GetOwner()
    return self:GetSWEP().Owner or self:GetOwner()
end

--[[
    ToolGunMeta:GetWeapon()

    Description:
        Retrieves the weapon entity this tool is attached to.

    Realm:
        Shared

    Returns:
        Weapon – The weapon object.
]]
function ToolGunMeta:GetWeapon()
    return self:GetSWEP().Weapon or self.Weapon
end

--[[
    ToolGunMeta:LeftClick()

    Description:
        Handles the left-click action. Override for custom behavior.

    Realm:
        Shared

    Returns:
        boolean – False by default.
]]
function ToolGunMeta:LeftClick()
    return false
end

--[[
    ToolGunMeta:RightClick()

    Description:
        Handles the right-click action. Override for custom behavior.

    Realm:
        Shared

    Returns:
        boolean – False by default.
]]
function ToolGunMeta:RightClick()
    return false
end

--[[
    ToolGunMeta:Reload()

    Description:
        Clears stored objects when the tool reloads.

    Realm:
        Shared
]]
function ToolGunMeta:Reload()
    self:ClearObjects()
end

--[[
    ToolGunMeta:Deploy()

    Description:
        Called when the tool is equipped. Releases ghost entity.

    Realm:
        Shared
]]
function ToolGunMeta:Deploy()
    self:ReleaseGhostEntity()
end

--[[
    ToolGunMeta:Holster()

    Description:
        Called when the tool is holstered. Releases ghost entity.

    Realm:
        Shared
]]
function ToolGunMeta:Holster()
    self:ReleaseGhostEntity()
end

--[[
    ToolGunMeta:Think()

    Description:
        Called every tick; releases ghost entities by default.

    Realm:
        Shared
]]
function ToolGunMeta:Think()
    self:ReleaseGhostEntity()
end

--[[
    ToolGunMeta:CheckObjects()

    Description:
        Validates stored objects and clears them if invalid.

    Realm:
        Shared
]]
function ToolGunMeta:CheckObjects()
    for _, v in pairs(self.Objects) do
        if not v.Ent:IsWorld() and not IsValid(v.Ent) then self:ClearObjects() end
    end
end

--[[
    ToolGunMeta:ClearObjects()

    Description:
        Removes all stored objects from the tool.

    Realm:
        Shared
]]
function ToolGunMeta:ClearObjects()
    self.Objects = {}
end

--[[
    ToolGunMeta:ReleaseGhostEntity()

    Description:
        Removes the ghost entity used for previewing placements.

    Realm:
        Shared
]]
function ToolGunMeta:ReleaseGhostEntity()
    if IsValid(self.GhostEntity) then
        SafeRemoveEntity(self.GhostEntity)
        self.GhostEntity = nil
    end
end

lia.meta.tool = ToolGunMeta

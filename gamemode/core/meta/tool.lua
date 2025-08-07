local toolGunMeta = lia.meta.tool or {}
--[[
    Create

    Purpose:
        Creates a new tool object with default properties and metatable.

    Parameters:
        None.

    Returns:
        table - The new tool object.

    Realm:
        Shared.

    Example Usage:
        local tool = toolGunMeta:Create()
]]
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
    object.Message = L("start")
    object.LastMessage = 0
    object.AllowedCVar = 0
    return object
end

--[[
    CreateConVars

    Purpose:
        Creates client and server console variables for the tool mode.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        tool:CreateConVars()
]]
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

--[[
    UpdateData

    Purpose:
        Updates tool data. Intended to be overridden by specific tool implementations.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        tool:UpdateData()
]]
function toolGunMeta:UpdateData()
end

--[[
    FreezeMovement

    Purpose:
        Freezes movement for the tool. Intended to be overridden by specific tool implementations.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        tool:FreezeMovement()
]]
function toolGunMeta:FreezeMovement()
end

--[[
    DrawHUD

    Purpose:
        Draws the tool's HUD. Intended to be overridden by specific tool implementations.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Client.

    Example Usage:
        tool:DrawHUD()
]]
function toolGunMeta:DrawHUD()
end

--[[
    GetServerInfo

    Purpose:
        Retrieves the server convar for the given property and current tool mode.

    Parameters:
        property (string) - The property name.

    Returns:
        ConVar - The server convar object.

    Realm:
        Shared.

    Example Usage:
        local cvar = tool:GetServerInfo("allow")
]]
function toolGunMeta:GetServerInfo(property)
    local mode = self:GetMode()
    return ConVar(mode .. "_" .. property)
end

--[[
    BuildConVarList

    Purpose:
        Builds a table of client convars for the current tool mode.

    Parameters:
        None.

    Returns:
        table - Table of convar names and their default values.

    Realm:
        Shared.

    Example Usage:
        local convars = tool:BuildConVarList()
]]
function toolGunMeta:BuildConVarList()
    local mode = self:GetMode()
    local convars = {}
    for k, v in pairs(self.ClientConVar) do
        convars[mode .. "_" .. k] = v
    end
    return convars
end

--[[
    GetClientInfo

    Purpose:
        Gets the value of a client convar for the tool's owner.

    Parameters:
        property (string) - The property name.

    Returns:
        string - The value of the client convar.

    Realm:
        Shared.

    Example Usage:
        local value = tool:GetClientInfo("someproperty")
]]
function toolGunMeta:GetClientInfo(property)
    return self:GetOwner():GetInfo(self:GetMode() .. "_" .. property)
end

--[[
    GetClientNumber

    Purpose:
        Gets the numeric value of a client convar for the tool's owner.

    Parameters:
        property (string) - The property name.
        default (number) - The default value if the convar is not set.

    Returns:
        number - The numeric value of the client convar.

    Realm:
        Shared.

    Example Usage:
        local num = tool:GetClientNumber("someproperty", 1)
]]
function toolGunMeta:GetClientNumber(property, default)
    return self:GetOwner():GetInfoNum(self:GetMode() .. "_" .. property, tonumber(default) or 0)
end

--[[
    Allowed

    Purpose:
        Checks if the tool mode is allowed on the server.

    Parameters:
        None.

    Returns:
        boolean - True if allowed, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if tool:Allowed() then ... end
]]
function toolGunMeta:Allowed()
    if CLIENT then return true end
    return self.AllowedCVar:GetBool()
end

--[[
    Init

    Purpose:
        Initializes the tool. Intended to be overridden by specific tool implementations.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        tool:Init()
]]
function toolGunMeta:Init()
end

--[[
    GetMode

    Purpose:
        Returns the current tool mode.

    Parameters:
        None.

    Returns:
        string - The tool mode.

    Realm:
        Shared.

    Example Usage:
        local mode = tool:GetMode()
]]
function toolGunMeta:GetMode()
    return self.Mode
end

--[[
    GetSWEP

    Purpose:
        Returns the SWEP (Scripted Weapon) associated with the tool.

    Parameters:
        None.

    Returns:
        SWEP - The SWEP object.

    Realm:
        Shared.

    Example Usage:
        local swep = tool:GetSWEP()
]]
function toolGunMeta:GetSWEP()
    return self.SWEP
end

--[[
    GetOwner

    Purpose:
        Returns the owner of the tool.

    Parameters:
        None.

    Returns:
        Player - The owner of the tool.

    Realm:
        Shared.

    Example Usage:
        local owner = tool:GetOwner()
]]
function toolGunMeta:GetOwner()
    return self:GetSWEP().Owner or self:GetOwner()
end

--[[
    GetWeapon

    Purpose:
        Returns the weapon associated with the tool.

    Parameters:
        None.

    Returns:
        Weapon - The weapon object.

    Realm:
        Shared.

    Example Usage:
        local weapon = tool:GetWeapon()
]]
function toolGunMeta:GetWeapon()
    return self:GetSWEP().Weapon or self.Weapon
end

--[[
    LeftClick

    Purpose:
        Handles the left click action for the tool. Intended to be overridden.

    Parameters:
        None.

    Returns:
        boolean - Whether the action was successful.

    Realm:
        Shared.

    Example Usage:
        tool:LeftClick()
]]
function toolGunMeta:LeftClick()
    return false
end

--[[
    RightClick

    Purpose:
        Handles the right click action for the tool. Intended to be overridden.

    Parameters:
        None.

    Returns:
        boolean - Whether the action was successful.

    Realm:
        Shared.

    Example Usage:
        tool:RightClick()
]]
function toolGunMeta:RightClick()
    return false
end

--[[
    Reload

    Purpose:
        Handles the reload action for the tool, clearing all objects.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        tool:Reload()
]]
function toolGunMeta:Reload()
    self:ClearObjects()
end

--[[
    Deploy

    Purpose:
        Handles the deploy action for the tool, releasing the ghost entity.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        tool:Deploy()
]]
function toolGunMeta:Deploy()
    self:ReleaseGhostEntity()
end

--[[
    Holster

    Purpose:
        Handles the holster action for the tool, releasing the ghost entity.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        tool:Holster()
]]
function toolGunMeta:Holster()
    self:ReleaseGhostEntity()
end

--[[
    Think

    Purpose:
        Called every frame, releases the ghost entity.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        tool:Think()
]]
function toolGunMeta:Think()
    self:ReleaseGhostEntity()
end

--[[
    CheckObjects

    Purpose:
        Checks the validity of objects in the tool's object list and clears them if invalid.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        tool:CheckObjects()
]]
function toolGunMeta:CheckObjects()
    for _, v in pairs(self.Objects) do
        if not v.Ent:IsWorld() and not IsValid(v.Ent) then self:ClearObjects() end
    end
end

--[[
    ClearObjects

    Purpose:
        Clears the tool's object list.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        tool:ClearObjects()
]]
function toolGunMeta:ClearObjects()
    self.Objects = {}
end

--[[
    ReleaseGhostEntity

    Purpose:
        Removes the ghost entity if it exists.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        tool:ReleaseGhostEntity()
]]
function toolGunMeta:ReleaseGhostEntity()
    if IsValid(self.GhostEntity) then
        SafeRemoveEntity(self.GhostEntity)
        self.GhostEntity = nil
    end
end

lia.meta.tool = toolGunMeta

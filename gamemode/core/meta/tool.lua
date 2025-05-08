local ToolGunMeta = lia.meta.tool or {}
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

function ToolGunMeta:GetServerInfo(property)
    local mode = self:GetMode()
    return ConVar(mode .. "_" .. property)
end

function ToolGunMeta:BuildConVarList()
    local mode = self:GetMode()
    local convars = {}
    for k, v in pairs(self.ClientConVar) do
        convars[mode .. "_" .. k] = v
    end
    return convars
end

function ToolGunMeta:GetClientInfo(property)
    return self:GetOwner():GetInfo(self:GetMode() .. "_" .. property)
end

function ToolGunMeta:GetClientNumber(property, default)
    return self:GetOwner():GetInfoNum(self:GetMode() .. "_" .. property, tonumber(default) or 0)
end

function ToolGunMeta:Allowed()
    if CLIENT then return true end
    return self.AllowedCVar:GetBool()
end

function ToolGunMeta:Init()
end

function ToolGunMeta:GetMode()
    return self.Mode
end

function ToolGunMeta:GetSWEP()
    return self.SWEP
end

function ToolGunMeta:GetOwner()
    return self:GetSWEP().Owner or self:GetOwner()
end

function ToolGunMeta:GetWeapon()
    return self:GetSWEP().Weapon or self.Weapon
end

function ToolGunMeta:LeftClick()
    return false
end

function ToolGunMeta:RightClick()
    return false
end

function ToolGunMeta:Reload()
    self:ClearObjects()
end

function ToolGunMeta:Deploy()
    self:ReleaseGhostEntity()
end

function ToolGunMeta:Holster()
    self:ReleaseGhostEntity()
end

function ToolGunMeta:Think()
    self:ReleaseGhostEntity()
end

function ToolGunMeta:CheckObjects()
    for _, v in pairs(self.Objects) do
        if not v.Ent:IsWorld() and not IsValid(v.Ent) then self:ClearObjects() end
    end
end

function ToolGunMeta:ClearObjects()
    self.Objects = {}
end

function ToolGunMeta:ReleaseGhostEntity()
    if IsValid(self.GhostEntity) then
        SafeRemoveEntity(self.GhostEntity)
        self.GhostEntity = nil
    end
end

lia.meta.tool = ToolGunMeta

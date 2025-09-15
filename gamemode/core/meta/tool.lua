local toolGunMeta = lia.meta.tool or {}
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
function toolGunMeta:UpdateData()
end
function toolGunMeta:FreezeMovement()
end
function toolGunMeta:DrawHUD()
end
function toolGunMeta:GetServerInfo(property)
    local mode = self:GetMode()
    return ConVar(mode .. "_" .. property)
end
function toolGunMeta:BuildConVarList()
    local mode = self:GetMode()
    local convars = {}
    for k, v in pairs(self.ClientConVar) do
        convars[mode .. "_" .. k] = v
    end
    return convars
end
function toolGunMeta:GetClientInfo(property)
    return self:GetOwner():GetInfo(self:GetMode() .. "_" .. property)
end
function toolGunMeta:GetClientNumber(property, default)
    return self:GetOwner():GetInfoNum(self:GetMode() .. "_" .. property, tonumber(default) or 0)
end
function toolGunMeta:Allowed()
    if CLIENT then return true end
    return self.AllowedCVar:GetBool()
end
function toolGunMeta:Init()
end
function toolGunMeta:GetMode()
    return self.Mode
end
function toolGunMeta:GetSWEP()
    return self.SWEP
end
function toolGunMeta:GetOwner()
    return self:GetSWEP().Owner or self:GetOwner()
end
function toolGunMeta:GetWeapon()
    return self:GetSWEP().Weapon or self.Weapon
end
function toolGunMeta:LeftClick()
    return false
end
function toolGunMeta:RightClick()
    return false
end
function toolGunMeta:Reload()
    self:ClearObjects()
end
function toolGunMeta:Deploy()
    self:ReleaseGhostEntity()
end
function toolGunMeta:Holster()
    self:ReleaseGhostEntity()
end
function toolGunMeta:Think()
    self:ReleaseGhostEntity()
end
function toolGunMeta:CheckObjects()
    for _, v in pairs(self.Objects) do
        if not v.Ent:IsWorld() and not IsValid(v.Ent) then self:ClearObjects() end
    end
end
function toolGunMeta:ClearObjects()
    self.Objects = {}
end
function toolGunMeta:ReleaseGhostEntity()
    if IsValid(self.GhostEntity) then
        SafeRemoveEntity(self.GhostEntity)
        self.GhostEntity = nil
    end
end
lia.meta.tool = toolGunMeta

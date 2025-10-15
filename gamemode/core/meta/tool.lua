local toolGunMeta = lia.meta.tool or {}
function toolGunMeta:create()
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

function toolGunMeta:createConVars()
    local mode = self:getMode()
    if CLIENT then
        for cvar, default in pairs(self.ClientConVar) do
            CreateClientConVar(mode .. "_" .. cvar, default, true, true)
        end
        return
    else
        self.AllowedCVar = CreateConVar("toolmode_allow_" .. mode, 1, FCVAR_NOTIFY)
    end
end

function toolGunMeta:updateData()
end

function toolGunMeta:freezeMovement()
end

function toolGunMeta:drawHUD()
end

function toolGunMeta:getServerInfo(property)
    local mode = self:getMode()
    return ConVar(mode .. "_" .. property)
end

function toolGunMeta:buildConVarList()
    local mode = self:getMode()
    local convars = {}
    for k, v in pairs(self.ClientConVar) do
        convars[mode .. "_" .. k] = v
    end
    return convars
end

function toolGunMeta:getClientInfo(property)
    return self:getOwner():GetInfo(self:getMode() .. "_" .. property)
end

function toolGunMeta:getClientNumber(property, default)
    return self:getOwner():GetInfoNum(self:getMode() .. "_" .. property, tonumber(default) or 0)
end

function toolGunMeta:allowed()
    if CLIENT then return true end
    return self.AllowedCVar:GetBool()
end

function toolGunMeta:init()
end

function toolGunMeta:getMode()
    return self.Mode
end

function toolGunMeta:getSWEP()
    return self.SWEP
end

function toolGunMeta:GetOwner()
    return self:getSWEP().Owner or self.Owner
end

function toolGunMeta:getWeapon()
    return self:getSWEP().Weapon or self.Weapon
end

function toolGunMeta:leftClick()
    return false
end

function toolGunMeta:rightClick()
    return false
end

function toolGunMeta:reload()
    self:clearObjects()
end

function toolGunMeta:deploy()
    self:releaseGhostEntity()
end

function toolGunMeta:holster()
    self:releaseGhostEntity()
end

function toolGunMeta:think()
    self:releaseGhostEntity()
end

function toolGunMeta:checkObjects()
    for _, v in pairs(self.Objects) do
        if not v.Ent:IsWorld() and not IsValid(v.Ent) then self:clearObjects() end
    end
end

function toolGunMeta:clearObjects()
    self.Objects = {}
end

function toolGunMeta:releaseGhostEntity()
    if IsValid(self.GhostEntity) then
        SafeRemoveEntity(self.GhostEntity)
        self.GhostEntity = nil
    end
end

lia.meta.tool = toolGunMeta

local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")
local validClasses = {
    ["lvs_base"] = true,
    ["gmod_sent_vehicle_fphysics_base"] = true,
    ["gmod_sent_vehicle_fphysics_wheel"] = true,
    ["prop_vehicle_prisoner_pod"] = true,
}

function entityMeta:isProp()
    if not IsValid(self) then return false end
    return self:GetClass() == "prop_physics"
end

function entityMeta:isItem()
    if not IsValid(self) then return false end
    return self:GetClass() == "lia_item"
end

function entityMeta:isMoney()
    if not IsValid(self) then return false end
    return self:GetClass() == "lia_money"
end

function entityMeta:isSimfphysCar()
    if not IsValid(self) then return false end
    return validClasses[self:GetClass()] or self.IsSimfphyscar or self.LVS or validClasses[self.Base]
end

function entityMeta:isLiliaPersistent()
    if not IsValid(self) then return false end
    if self.GetPersistent and self:GetPersistent() then return true end
    return self.IsLeonNPC or self.IsPersistent
end

function entityMeta:checkDoorAccess(client, access)
    if not IsValid(self) then return false end
    if not self:isDoor() then return false end
    access = access or DOOR_GUEST
    if hook.Run("CanPlayerAccessDoor", client, self, access) then return true end
    if self.liaAccess and (self.liaAccess[client] or 0) >= access then return true end
    return false
end

function entityMeta:keysOwn(client)
    if not IsValid(self) then return end
    if self:IsVehicle() then
        self:CPPISetOwner(client)
        self:setNetVar("owner", client:getChar():getID())
        self.ownerID = client:getChar():getID()
        self:setNetVar("ownerName", client:getChar():getName())
    end
end

function entityMeta:keysLock()
    if not IsValid(self) then return end
    if self:IsVehicle() then self:Fire("lock") end
end

function entityMeta:keysUnLock()
    if not IsValid(self) then return end
    if self:IsVehicle() then self:Fire("unlock") end
end

function entityMeta:getDoorOwner()
    if not IsValid(self) then return nil end
    if self:IsVehicle() and self.CPPIGetOwner then return self:CPPIGetOwner() end
end

function entityMeta:isLocked()
    if not IsValid(self) then return false end
    return self:getNetVar("locked", false)
end

function entityMeta:isDoorLocked()
    if not IsValid(self) then return false end
    return self:GetInternalVariable("m_bLocked") or self.locked or false
end

function entityMeta:getEntItemDropPos(offset)
    if not IsValid(self) then return Vector(0, 0, 0), Angle(0, 0, 0) end
    if not offset then offset = 64 end
    local trResult = util.TraceLine({
        start = self:EyePos(),
        endpos = self:EyePos() + self:GetAimVector() * offset,
        mask = MASK_SHOT,
        filter = {self}
    })
    return trResult.HitPos + trResult.HitNormal * 5, trResult.HitNormal:Angle()
end

function entityMeta:isNearEntity(radius, otherEntity)
    if not IsValid(self) then return false end
    if otherEntity == self then return true end
    if not radius then radius = 96 end
    for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius)) do
        if v == self then continue end
        if IsValid(otherEntity) and v == otherEntity or v:GetClass() == self:GetClass() then return true end
    end
    return false
end

function entityMeta:GetCreator()
    if not IsValid(self) then return nil end
    return self:getNetVar("creator", nil)
end

if SERVER then
    function entityMeta:SetCreator(client)
        if not IsValid(self) then return end
        self:setNetVar("creator", client)
    end

    function entityMeta:sendNetVar(key, receiver)
        if not IsValid(self) then return end
        net.Start("nVar")
        net.WriteUInt(self:EntIndex(), 16)
        net.WriteString(key)
        net.WriteType(lia.net[self] and lia.net[self][key])
        if receiver then
            net.Send(receiver)
        else
            net.Broadcast()
        end
    end

    function entityMeta:clearNetVars(receiver)
        if not IsValid(self) then return end
        lia.net[self] = nil
        if lia.shuttingDown then return end
        net.Start("nDel")
        net.WriteUInt(self:EntIndex(), 16)
        if receiver then
            net.Send(receiver)
        else
            net.Broadcast()
        end
    end

    function entityMeta:removeDoorAccessData()
        if IsValid(self) then
            for k, _ in pairs(self.liaAccess or {}) do
                net.Start("doorMenu")
                net.Send(k)
            end

            self.liaAccess = {}
            self:SetDTEntity(0, nil)
        end
    end

    function entityMeta:setLocked(state)
        if not IsValid(self) then return end
        self:setNetVar("locked", state)
    end

    function entityMeta:setKeysNonOwnable(state)
        if not IsValid(self) then return end
        self:setNetVar("noSell", state)
    end

    function entityMeta:isDoor()
        if not IsValid(self) then return false end
        local class = self:GetClass():lower()
        local doorPrefixes = {"prop_door", "func_door", "func_door_rotating", "door_"}
        for _, prefix in ipairs(doorPrefixes) do
            if class:find(prefix) then return true end
        end
        return false
    end

    function entityMeta:getDoorPartner()
        return self.liaPartner
    end

    function entityMeta:setNetVar(key, value, receiver)
        if not IsValid(self) then return end
        if checkBadType(key, value) then return end
        lia.net[self] = lia.net[self] or {}
        local oldValue = lia.net[self][key]
        if oldValue ~= value then lia.net[self][key] = value end
        self:sendNetVar(key, receiver)
        hook.Run("NetVarChanged", self, key, oldValue, value)
    end

    function entityMeta:getNetVar(key, default)
        if not IsValid(self) then return default end
        if lia.net[self] and lia.net[self][key] ~= nil then return lia.net[self][key] end
        return default
    end

    playerMeta.getLocalVar = entityMeta.getNetVar
else
    function entityMeta:isDoor()
        if not IsValid(self) then return false end
        return self:GetClass():find("door")
    end

    function entityMeta:getDoorPartner()
        if not IsValid(self) then return nil end
        local owner = self:GetOwner() or self.liaDoorOwner
        if IsValid(owner) and owner:isDoor() then return owner end
        for _, v in ipairs(ents.FindByClass("prop_door_rotating")) do
            if v:GetOwner() == self then
                self.liaDoorOwner = v
                return v
            end
        end
    end

    function entityMeta:getNetVar(key, default)
        if not IsValid(self) then return default end
        local index = self:EntIndex()
        if lia.net[index] and lia.net[index][key] ~= nil then return lia.net[index][key] end
        return default
    end

    playerMeta.getLocalVar = entityMeta.getNetVar
end

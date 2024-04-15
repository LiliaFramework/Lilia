--[[--
Physical object in the game world.

Entities are physical representations of objects in the game world. Lilia extends the functionality of entities to interface
between Lilia's own classes, and to reduce boilerplate code.

See the [Garry's Mod Wiki](https://wiki.garrysmod.com/page/Category:Entity) for all other methods that the `Player` class has.
]]
-- @classmod Entity
local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")
local ChairCache = {}

function entityMeta:isProp()
    return self:GetClass() == "prop_physics"
end
function entityMeta:isItem()
    return self:GetClass() == "lia_item"
end
function entityMeta:isMoney()
    return self:GetClass() == "lia_money"
end

function entityMeta:isSimfphysCar()
    if not simfphys or not IsValid(self) then return false end
    return self:GetClass() == "gmod_sent_vehicle_fphysics_base" or self.IsSimfphyscar or self:GetClass() == "gmod_sent_vehicle_fphysics_wheel" or self.Base == "gmod_sent_vehicle_fphysics_base" or self.Base == "gmod_sent_vehicle_fphysics_wheel"
end

function entityMeta:getEntItemDropPos()
    local offset = Vector(-50, 0, 0)
    return self:GetPos() + offset
end

function entityMeta:nearEntity(radius)
    for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius or 96)) do
        if v:GetClass() == self then return true end
    end
    return false
end

function entityMeta:isDoorLocked()
    return self:GetSaveTable().m_bLocked or self.locked or false
end

function entityMeta:getViewAngle(pos)
    local diff = pos - self:EyePos()
    diff:Normalize()
    return math.abs(math.deg(math.acos(self:EyeAngles():Forward():Dot(diff))))
end

function entityMeta:inFov(entity, fov)
    return self:GetViewAngle(entity:EyePos()) < (fov or 88)
end

function entityMeta:isInRoom(target)
    local tracedata = {}
    tracedata.start = self:GetPos()
    tracedata.endpos = target:GetPos()
    local trace = util.TraceLine(tracedata)
    return not trace.HitWorld
end

function entityMeta:inTrace(entity)
    return util.TraceLine({
        start = entity:EyePos(),
        endpos = self:EyePos()
    }).Entity == self
end

function entityMeta:isScreenVisible(entity, maxDist, fov)
    return self:EyePos():DistToSqr(entity:EyePos()) < (maxDist or 512 * 512) and self:IsLineOfSightClear(entity:EyePos()) and self:InFov(entity, fov)
end

function entityMeta:isChair()
    return ChairCache[self:GetModel()]
end

function entityMeta:canSeeEntity(entity)
    if not (IsValid(self) and IsValid(entity)) then return false end
    if not (self:IsPlayer() or self:IsNPC()) then return false end
    if not self:IsLineOfSightClear(entity) then return false end
    local diff = entity:GetPos() - self:GetShootPos()
    if self:GetAimVector():Dot(diff) / diff:Length() < 0.455 then return false end
    return true
end

function entityMeta:isLocked()
    if self:IsVehicle() then
        local datatable = self:GetSaveTable()
        if datatable then return datatable.VehicleLocked end
    else
        local datatable = self:GetSaveTable()
        if datatable then return datatable.m_bLocked end
    end
    return nil
end

for _, v in pairs(list.Get("Vehicles")) do
    if v.Category == "Chairs" then ChairCache[v.Model] = true end
end

if SERVER then
    function entityMeta:isDoor()
        local class = self:GetClass():lower()
        local doorPrefixes = {"prop_door", "func_door", "func_door_rotating", "door_",}
        for _, prefix in ipairs(doorPrefixes) do
            if class:find(prefix) then return true end
        end
        return false
    end

    function entityMeta:getDoorPartner()
        return self.liaPartner
    end
    entityMeta.GetDoorPartner = entityMeta.getDoorPartner

    function entityMeta:assignCreator(client)
        self:SetCreator(client)
    end

    --- Sends a networked variable.
    -- @realm server
    -- @internal
    -- @string key Identifier of the networked variable
    -- @tab[opt=nil] receiver The players to send the networked variable to
    function entityMeta:sendNetVar(key, receiver)
        netstream.Start(receiver, "nVar", self:EntIndex(), key, lia.net[self] and lia.net[self][key])
    end
    entityMeta.SendNetVar = entityMeta.sendNetVar

    --- Clears all of the networked variables.
    -- @realm server
    -- @internal
    -- @tab[opt=nil] receiver The players to clear the networked variable for
    function entityMeta:clearNetVars(receiver)
        lia.net[self] = nil
        netstream.Start(receiver, "nDel", self:EntIndex())
    end
entityMeta.ClearNetVars = entityMeta.clearNetVars

    --- Sets the value of a networked variable.
    -- @realm server
    -- @string key Identifier of the networked variable
    -- @param value New value to assign to the networked variable
    -- @tab[opt=nil] receiver The players to send the networked variable to
    -- @usage client:setNetVar("example", "Hello World!")
    -- @see getNetVar
    function entityMeta:setNetVar(key, value, receiver)
        if checkBadType(key, value) then return end
        lia.net[self] = lia.net[self] or {}
        if lia.net[self][key] ~= value then lia.net[self][key] = value end
        self:sendNetVar(key, receiver)
    end
    entityMeta.SetNetVar = entityMeta.setNetVar

    --- Retrieves a networked variable. If it is not set, it'll return the default that you've specified.
    -- @realm shared
    -- @string key Identifier of the networked variable
    -- @param default Default value to return if the networked variable is not set
    -- @return Value associated with the key, or the default that was given if it doesn't exist
    -- @usage print(client:getNetVar("example"))
    -- > Hello World!
    -- @see setNetVar
    function entityMeta:getNetVar(key, default)
        if lia.net[self] and lia.net[self][key] ~= nil then return lia.net[self][key] end
        return default
    end

    playerMeta.getLocalVar = entityMeta.getNetVar
    entityMeta.GetNetVar = entityMeta.getNetVar
else
    function entityMeta:isDoor()
        return self:GetClass():find("door")
    end
    entityMeta.IsDoor = entityMeta.isDoor

    function entityMeta:getDoorPartner()
        local owner = self:GetOwner() or self.liaDoorOwner
        if IsValid(owner) and owner:isDoor() then return owner end
        for _, v in ipairs(ents.FindByClass("prop_door_rotating")) do
            if v:GetOwner() == self then
                self.liaDoorOwner = v
                return v
            end
        end
    end
    entityMeta.GetDoorPartner = entityMeta.getDoorPartner

    function entityMeta:getNetVar(key, default)
        local index = self:EntIndex()
        if lia.net[index] and lia.net[index][key] ~= nil then return lia.net[index][key] end
        return default
    end

    playerMeta.getLocalVar = entityMeta.getNetVar
    entityMeta.GetNetVar = entityMeta.getNetVar
end

entityMeta.IsProp = entityMeta.isProp
entityMeta.IsItem = entityMeta.isItem
entityMeta.IsMoney = entityMeta.isMoney
entityMeta.IsSimfphysCar = entityMeta.isSimfphysCar
entityMeta.GetEntItemDropPos = entityMeta.getEntItemDropPos
entityMeta.NearEntity = entityMeta.nearEntity
entityMeta.IsDoorLocked = entityMeta.isDoorLocked
entityMeta.GetViewAngle = entityMeta.getViewAngle
entityMeta.InFov = entityMeta.inFov
entityMeta.IsInRoom = entityMeta.isInRoom
entityMeta.InTrace = entityMeta.inTrace
entityMeta.IsScreenVisible = entityMeta.isScreenVisible
entityMeta.IsChair = entityMeta.isChair
entityMeta.CanSeeEntity = entityMeta.canSeeEntity
entityMeta.AssignCreator = entityMeta.assignCreator
entityMeta.IsLocked = entityMeta.isLocked

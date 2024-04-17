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
--- Checks if the entity is a physics prop.
-- @realm shared
-- @treturn bool True if the entity is a physics prop, false otherwise.
function entityMeta:isProp()
    return self:GetClass() == "prop_physics"
end

--- Checks if the entity is an item entity.
-- @realm shared
-- @treturn bool True if the entity is an item entity, false otherwise.
function entityMeta:isItem()
    return self:GetClass() == "lia_item"
end

--- Checks if the entity is a money entity.
-- @realm shared
-- @treturn bool True if the entity is a money entity, false otherwise.
function entityMeta:isMoney()
    return self:GetClass() == "lia_money"
end

--- Checks if the entity is a simfphys car.
-- @realm shared
-- @treturn bool True if the entity is a simfphys car, false otherwise.
function entityMeta:isSimfphysCar()
    return simfphys and (self:GetClass() == "gmod_sent_vehicle_fphysics_base" or self.IsSimfphyscar or self:GetClass() == "gmod_sent_vehicle_fphysics_wheel" or self.Base == "gmod_sent_vehicle_fphysics_base" or self.Base == "gmod_sent_vehicle_fphysics_wheel")
end

--- Retrieves the drop position for an item associated with the entity.
-- @realm shared
-- @treturn Vector The drop position for the item.
function entityMeta:getEntItemDropPos()
    if not IsValid(self) then return false end
    local offset = Vector(-50, 0, 0)
    return self:GetPos() + offset
end

--- Checks if there is an entity near the current entity within a specified radius.
-- @realm shared
-- @tparam[opt=96] number radius The radius within which to check for nearby entities.
-- @treturn bool True if there is an entity nearby, false otherwise.
function entityMeta:nearEntity(radius)
    for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius or 96)) do
        if v:GetClass() == self then return true end
    end
    return false
end

--- Checks if the entity is locked (pertaining to doors).
-- @realm shared
-- @treturn bool True if the entity is locked, false otherwise.
function entityMeta:isDoorLocked()
    return self:GetSaveTable().m_bLocked or self.locked or false
end

--- Gets the view angle between the entity and a specified position.
-- @realm shared
-- @tparam Vector pos The position to calculate the view angle towards.
-- @treturn number The view angle in degrees.
function entityMeta:getViewAngle(pos)
    local diff = pos - self:EyePos()
    diff:Normalize()
    return math.abs(math.deg(math.acos(self:EyeAngles():Forward():Dot(diff))))
end

--- Checks if the entity is within the field of view of another entity.
-- @realm shared
-- @tparam Entity entity The entity to check the field of view against.
-- @tparam[opt=88] number fov The field of view angle in degrees.
-- @treturn bool True if the entity is within the field of view, false otherwise.
function entityMeta:inFov(entity, fov)
    return self:GetViewAngle(entity:EyePos()) < (fov or 88)
end

--- Checks if the entity is inside a room (i.e., not blocked by world geometry) with another target entity.
-- @realm shared
-- @tparam Entity target The target entity to check for room visibility.
-- @treturn bool True if the entity is in the same room as the target entity, false otherwise.
function entityMeta:isInRoom(target)
    local tracedata = {}
    tracedata.start = self:GetPos()
    tracedata.endpos = target:GetPos()
    local trace = util.TraceLine(tracedata)
    return not trace.HitWorld
end

--- Checks if the entity is in line of sight of another entity.
-- @realm shared
-- @tparam Entity entity The entity to check line of sight against.
-- @treturn bool True if the entity is in line of sight, false otherwise.
function entityMeta:inTrace(entity)
    return util.TraceLine({
        start = entity:EyePos(),
        endpos = self:EyePos()
    }).Entity == self
end

--- Checks if the entity has a clear line of sight to another entity and is within a specified distance and field of view angle.
-- @realm shared
-- @tparam Entity entity The entity to check visibility against.
-- @tparam[opt=512^2] number maxDist The maximum distance squared within which the entity can see the other entity.
-- @tparam[opt=88] number fov The field of view angle in degrees.
-- @treturn bool True if the entity has a clear line of sight to the other entity within the specified distance and field of view angle, false otherwise.
function entityMeta:isScreenVisible(entity, maxDist, fov)
    return self:EyePos():DistToSqr(entity:EyePos()) < (maxDist or 512 * 512) and self:IsLineOfSightClear(entity:EyePos()) and self:InFov(entity, fov)
end

--- Checks if the entity is a chair.
-- @realm shared
-- @treturn bool True if the entity is a chair, false otherwise.
function entityMeta:isChair()
    return ChairCache[self:GetModel()]
end

--- Checks if the entity can see another entity.
-- @realm shared
-- @tparam Entity entity The entity to check visibility against.
-- @treturn bool True if the entity can see the target entity, false otherwise.
function entityMeta:canSeeEntity(entity)
    if not (IsValid(self) and IsValid(entity)) then return false end
    if not (self:IsPlayer() or self:IsNPC()) then return false end
    if not self:IsLineOfSightClear(entity) then return false end
    local diff = entity:GetPos() - self:GetShootPos()
    if self:GetAimVector():Dot(diff) / diff:Length() < 0.455 then return false end
    return true
end

--- Checks if the entity is locked.
-- @realm shared
-- @treturn[1] bool True if the entity is locked, false if it is not locked, or nil if the lock status cannot be determined.
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
    --- Checks if the entity is a door.
    -- @realm server
    -- @internal
    -- @treturn bool True if the entity is a door, false otherwise.
    function entityMeta:isDoor()
        local class = self:GetClass():lower()
        local doorPrefixes = {"prop_door", "func_door", "func_door_rotating", "door_",}
        for _, prefix in ipairs(doorPrefixes) do
            if class:find(prefix) then return true end
        end
        return false
    end

    --- Retrieves the partner entity of the door.
    -- @realm server
    -- @treturn Entity The partner entity of the door, if any.
    function entityMeta:getDoorPartner()
        return self.liaPartner
    end

    entityMeta.GetDoorPartner = entityMeta.getDoorPartner
    --- Assigns a creator to the entity.
    -- @realm server
    -- @tparam Player client The player to assign as the creator of the entity.
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
    -- @realm server
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
    --- Checks if the entity is a door.
    -- @realm client
    -- @treturn bool True if the entity is a door, false otherwise.
    function entityMeta:isDoor()
        return self:GetClass():find("door")
    end

    entityMeta.IsDoor = entityMeta.isDoor
    --- Retrieves the partner door entity associated with this entity.
    -- @realm client
    -- @treturn Entity The partner door entity, if any.
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
    --- Retrieves the value of a networked variable associated with the entity.
    -- @realm client
    -- @tparam string key The identifier of the networked variable.
    -- @param default The default value to return if the networked variable does not exist.
    -- @treturn any The value of the networked variable, or the default value if it doesn't exist.
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

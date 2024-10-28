--[[--
Physical object in the game world.

Entities are physical representations of objects in the game world. Lilia extends the functionality of entities to interface
between Lilia's own classes and to reduce boilerplate code.

See the [Garry's Mod Wiki](https://wiki.garrysmod.com/page/Category:Entity) for all other methods that the `Player` class has.
]]
-- @entitymeta Framework
local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")
local ChairCache = {}
--- Checks if the entity is a physics prop.
-- @realm shared
-- @treturn Boolean True if the entity is a physics prop, false otherwise.
-- @usage
-- if entity:isProp() then
--     print("Entity is a physics prop.")
-- else
--     print("Entity is not a physics prop.")
-- end
function entityMeta:isProp()
    return self:GetClass() == "prop_physics"
end

--- Checks if the entity is an item entity.
-- @realm shared
-- @treturn Boolean True if the entity is an item entity, false otherwise.
-- @usage
-- if entity:isItem() then
--     print("Entity is an item.")
-- end
function entityMeta:isItem()
    return self:GetClass() == "lia_item"
end

--- Checks if the entity is a money entity.
-- @realm shared
-- @treturn Boolean True if the entity is a money entity, false otherwise.
-- @usage
-- if entity:isMoney() then
--     print("Entity is money.")
-- end
function entityMeta:isMoney()
    return self:GetClass() == "lia_money"
end

--- Checks if the entity is a simfphys car.
-- @realm shared
-- @treturn Boolean True if the entity is a simfphys car, false otherwise.
-- @usage
-- if entity:isSimfphysCar() then
--     print("Entity is a simfphys car.")
-- end
function entityMeta:isSimfphysCar()
    local validClasses = {"lvs_base", "gmod_sent_vehicle_fphysics_base", "gmod_sent_vehicle_fphysics_wheel", "prop_vehicle_prisoner_pod",}
    if not IsValid(self) then return false end
    local base = self.Base
    local class = self:GetClass()
    return table.HasValue(validClasses, class) or self.IsSimfphyscar or self.LVS or table.HasValue(validClasses, base)
end

--- Retrieves the drop position for an item associated with the entity.
-- @realm shared
-- @treturn Vector The drop position for the item.
-- @usage
-- local dropPos = entity:getEntItemDropPos()
-- print("Item drop position:", dropPos)
function entityMeta:getEntItemDropPos()
    if not IsValid(self) then return false end
    local offset = Vector(-50, 0, 0)
    return self:GetPos() + offset
end

--- Checks if there is an entity near the current entity within a specified radius.
-- @realm shared
-- @float radius The radius within which to check for nearby entities.
-- @treturn Boolean True if there is an entity nearby, false otherwise.
-- @usage
-- if entity:isNearEntity(150) then
--     print("There is an entity nearby.")
-- else
--     print("No entities within the specified radius.")
-- end
function entityMeta:isNearEntity(radius)
    for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius or 96)) do
        if v:GetClass() == self:GetClass() then return true end
    end
    return false
end

--- Gets the view angle between the entity and a specified position.
-- @realm shared
-- @vector pos The position to calculate the view angle towards.
-- @treturn The view angle in degrees.
-- @usage
-- local angle = entity:getViewAngle(targetPos)
-- print("View angle:", angle)
function entityMeta:getViewAngle(pos)
    local diff = pos - self:EyePos()
    diff:Normalize()
    return math.abs(math.deg(math.acos(self:EyeAngles():Forward():Dot(diff))))
end

--- Checks if the entity is within the field of view of another entity.
-- @realm shared
-- @entity entity to check the field of view against.
-- @float fov The field of view angle in degrees.
-- @treturn Boolean True if the entity is within the field of view, false otherwise.
-- @usage
-- if entity:inFov(playerEntity, 90) then
--     print("Entity is within the player's field of view.")
-- end
function entityMeta:inFov(entity, fov)
    return self:getViewAngle(entity:EyePos()) < (fov or 88)
end

--- Checks if the entity is inside a room (i.e., not blocked by world geometry) with another target entity.
-- @realm shared
-- @entity target The target entity to check for room visibility.
-- @treturn Boolean True if the entity is in the same room as the target entity, false otherwise.
-- @usage
-- if entity:isInRoom(targetEntity) then
--     print("Entities are in the same room.")
-- else
--     print("Entities are not in the same room.")
-- end
function entityMeta:isInRoom(target)
    local tracedata = {}
    tracedata.start = self:GetPos()
    tracedata.endpos = target:GetPos()
    local trace = util.TraceLine(tracedata)
    return not trace.HitWorld
end

--- Checks if the entity is in line of sight of another entity.
-- @realm shared
-- @entity entity The entity to check line of sight against.
-- @treturn Boolean True if the entity is in line of sight, false otherwise.
-- @usage
-- if entity:inTrace(targetEntity) then
--     print("Entity is in line of sight of the target.")
-- else
--     print("Entity is not in line of sight of the target.")
-- end
function entityMeta:inTrace(entity)
    return util.TraceLine({
        start = entity:EyePos(),
        endpos = self:EyePos()
    }).Entity == self
end

--- Checks if the entity has a clear line of sight to another entity and is within a specified distance and field of view angle.
-- @realm shared
-- @entity entity The entity to check visibility against.
-- @float maxDist The maximum distance squared within which the entity can see the other entity.
-- @float fov The field of view angle in degrees.
-- @treturn Boolean True if the entity has a clear line of sight to the other entity within the specified distance and field of view angle, false otherwise.
-- @usage
-- if entity:isScreenVisible(targetEntity, 300000, 90) then
--     print("Entity is visible on the screen.")
-- end
function entityMeta:isScreenVisible(entity, maxDist, fov)
    return self:EyePos():DistToSqr(entity:EyePos()) < (maxDist or 512 * 512) and self:IsLineOfSightClear(entity:EyePos()) and self:inFov(entity, fov)
end

--- Checks if the entity is a chair.
-- @realm shared
-- @treturn Boolean True if the entity is a chair, false otherwise.
-- @usage
-- if entity:isChair() then
--     print("Entity is a chair.")
-- end
function entityMeta:isChair()
    return ChairCache[self:GetModel()]
end

--- Checks if the entity can see another entity.
-- @realm shared
-- @entity entity The entity to check visibility against.
-- @treturn Boolean True if the entity can see the target entity, false otherwise.
-- @usage
-- if entity:canSeeEntity(targetEntity) then
--     print("Entity can see the target entity.")
-- else
--     print("Entity cannot see the target entity.")
-- end
function entityMeta:canSeeEntity(entity)
    if not (IsValid(self) and IsValid(entity)) then return false end
    if not (self:IsPlayer() or self:IsNPC()) then return false end
    if not self:IsLineOfSightClear(entity) then return false end
    local diff = entity:GetPos() - self:GetShootPos()
    if self:GetAimVector():Dot(diff) / diff:Length() < 0.455 then return false end
    return true
end

for _, v in pairs(list.Get("Vehicles")) do
    if v.Category == "Chairs" then ChairCache[v.Model] = true end
end

if SERVER then
    --- Assigns a creator to the entity.
    -- @realm server
    -- @client client The player to assign as the creator of the entity.
    -- @usage
    -- entity:assignCreator(player)
    function entityMeta:assignCreator(client)
        self:SetCreator(client)
        self:SetNW2Entity("creator", client)
    end

    --- Sends a networked variable.
    -- @realm server
    -- @internal
    -- @string key Identifier of the networked variable
    -- @client receiver The players to send the networked variable to
    -- @usage
    -- entity:sendNetVar("health", player)
    function entityMeta:sendNetVar(key, receiver)
        netstream.Start(receiver, "nVar", self:EntIndex(), key, lia.net[self] and lia.net[self][key])
    end

    entityMeta.SendNetVar = entityMeta.sendNetVar
    --- Clears all of the networked variables.
    -- @realm server
    -- @internal
    -- @client receiver The players to clear the networked variable for
    -- @usage
    -- entity:clearNetVars(player)
    function entityMeta:clearNetVars(receiver)
        lia.net[self] = nil
        netstream.Start(receiver, "nDel", self:EntIndex())
    end

    entityMeta.ClearNetVars = entityMeta.clearNetVars
    --- Sets the value of a networked variable.
    -- @realm server
    -- @string key Identifier of the networked variable
    -- @tparam any value New value to assign to the networked variable
    -- @client receiver The players to send the networked variable to
    -- @usage
    -- entity:setNetVar("example", "Hello World!", player)
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
    -- @tparam any default Default value to return if the networked variable is not set
    -- @treturn any The value associated with the key, or the default that was given if it doesn't exist
    -- @usage
    -- local example = entity:getNetVar("example", "Default Value")
    -- print(example) -- Output: "Hello World!" or "Default Value"
    -- @see setNetVar
    function entityMeta:getNetVar(key, default)
        if lia.net[self] and lia.net[self][key] ~= nil then return lia.net[self][key] end
        return default
    end

    playerMeta.getLocalVar = entityMeta.getNetVar
    entityMeta.GetNetVar = entityMeta.getNetVar
else
    --- Retrieves the value of a networked variable associated with the entity.
    -- @realm client
    -- @string key The identifier of the networked variable.
    -- @tparam any default The default value to return if the networked variable does not exist.
    -- @treturn any The value of the networked variable, or the default value if it doesn't exist.
    -- @usage
    -- local example = entity:getNetVar("example", "Default Value")
    -- print(example) -- Output: "Hello World!" or "Default Value"
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
entityMeta.GetEntItemDropPos = entityMeta.getEntItemDropPos
entityMeta.NearEntity = entityMeta.isNearEntity
entityMeta.GetViewAngle = entityMeta.getViewAngle
entityMeta.InFov = entityMeta.inFov
entityMeta.IsInRoom = entityMeta.isInRoom
entityMeta.InTrace = entityMeta.inTrace
entityMeta.IsScreenVisible = entityMeta.isScreenVisible
entityMeta.IsChair = entityMeta.isChair
entityMeta.CanSeeEntity = entityMeta.canSeeEntity
entityMeta.AssignCreator = entityMeta.assignCreator
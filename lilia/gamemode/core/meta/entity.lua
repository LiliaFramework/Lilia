--[[--
Physical object in the game world.

Entities are physical representations of objects in the game world. Lilia extends the functionality of entities to interface
between Lilia's own classes and to reduce boilerplate code.

See the [Garry's Mod Wiki](https://wiki.garrysmod.com/page/Category:Entity) for all other methods that the `Player` class has.
]]
-- @entitymeta Framework
local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")
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

entityMeta.IsProp = entityMeta.isProp
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

entityMeta.IsItem = entityMeta.isItem
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

entityMeta.IsMoney = entityMeta.isMoney
--- Checks if the entity is a simfphys car.
-- @realm shared
-- @treturn Boolean True if the entity is a simfphys car, false otherwise.
-- @usage
-- if entity:isSimfphysCar() then
--     print("Entity is a simfphys car.")
-- end
function entityMeta:isSimfphysCar()
    local validClasses = {"lvs_base", "gmod_sent_vehicle_fphysics_base", "gmod_sent_vehicle_fphysics_wheel", "prop_vehicle_prisoner_pod"}
    if not IsValid(self) then return false end
    local base = self.Base
    local class = self:GetClass()
    return table.HasValue(validClasses, class) or self.IsSimfphyscar or self.LVS or table.HasValue(validClasses, base)
end

entityMeta.IsSimfphysCar = entityMeta.isSimfphysCar
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

entityMeta.GetEntItemDropPos = entityMeta.getEntItemDropPos
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

entityMeta.IsNearEntity = entityMeta.isNearEntity
function entityMeta:GetCreator()
    local creator = self:GetNW2Entity("creator")
    if IsValid(creator) then return creator end
    return nil
end

if SERVER then
    --- Assigns a creator to the entity.
    -- @realm server
    -- @client client The player to assign as the creator of the entity.
    -- @usage
    -- entity:SetCreator(player)
    function entityMeta:SetCreator(client)
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
local entityMeta = FindMetaTable("Entity")
function entityMeta:isDoor()
    return self:GetClass():find("door")
end

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

---
-- Returns the networked variable of the entity.
--
-- @function Entity:getNetVar
-- @realm shared
-- @classmod Entity
-- @param key The key of the networked variable.
-- @param default The default value to return if the networked variable is not set.
-- @treturn any The networked variable.
--
function entityMeta:getNetVar(key, default)
    local index = self:EntIndex()
    if lia.net[index] and lia.net[index][key] ~= nil then return lia.net[index][key] end
    return default
end

---
-- Returns the networked variable of a player.
--
-- @function Entity:getLocalVar
-- @realm shared
-- @classmod Player
-- @param key The key of the networked variable.
-- @param default The default value to return if the networked variable is not set.
-- @treturn any The networked variable.
--
FindMetaTable("Player").getLocalVar = entityMeta.getNetVar
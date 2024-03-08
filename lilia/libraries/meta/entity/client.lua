-- @module Entity
-- @moduleCommentStart
-- Entity meta functions.
-- @moduleCommentEnd
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

-- @type method Entity:getNetVar(key, default)
-- @typeCommentStart
-- Returns the networked variable of the entity.
-- @typeCommentEnd
-- @realm shared
-- @classmod Entity
-- @string key The key of the networked variable.
-- @string default The default value to return if the networked variable is not set.
-- @treturn any The networked variable.
function entityMeta:getNetVar(key, default)
    local index = self:EntIndex()
    if lia.net[index] and lia.net[index][key] ~= nil then return lia.net[index][key] end
    return default
end

-- @type method Entity:getLocalVar(key, value)
-- @typeCommentStart
-- Returns the networked variable of a player.
-- @typeCommentEnd
-- @realm shared
-- @classmod Player
-- @string key The key of the networked variable.
-- @string default The default value to return if the networked variable is not set.
-- @treturn any The networked variable.
FindMetaTable("Player").getLocalVar = entityMeta.getNetVar
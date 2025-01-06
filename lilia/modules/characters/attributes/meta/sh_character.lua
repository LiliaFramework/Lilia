--- The Character Meta for the Attributes Module.
-- @charactermeta Attributes
local MODULE = MODULE
local characterMeta = lia.meta.character
--- Retrieves the maximum stamina for a character.
-- This function determines the maximum stamina a character can have, either from a hook or a default value.
-- @realm shared
-- @treturn integer The maximum stamina value.
function characterMeta:getMaxStamina()
    local maxStamina = hook.Run("CharMaxStamina", self) or MODULE.DefaultStamina
    return maxStamina
end

--- Retrieves the current stamina for a character.
-- This function returns the character's current stamina, using either a local variable or a default value.
-- @realm shared
-- @treturn integer The current stamina value.
function characterMeta:getStamina()
    local stamina = self:getPlayer():getLocalVar("stamina", 100) or MODULE.DefaultStamina
    return stamina
end

--- Retrieves the value of a character attribute, including applied boosts.
-- @realm shared
-- @string key The key of the attribute to retrieve.
-- @int[opt=0] default The default value to return if the attribute is not found.
-- @return number The value of the specified attribute, including applied boosts.
-- @usage local attributeValue = character:getAttrib("some_attribute_key")
function characterMeta:getAttrib(key, default)
    local att = self:getAttribs()[key] or default or 0
    local boosts = self:getBoosts()[key]
    if boosts then
        for _, v in pairs(boosts) do
            att = att + v
        end
    end
    return att
end

--- Retrieves the boost value for a specific attribute.
-- @realm shared
-- @int attribID The ID of the attribute for which to retrieve the boost.
-- @return number|nil The boost value for the specified attribute, or nil if no boost is found.
-- @usage local boostValue = character:getBoost("some_attribute_id")
function characterMeta:getBoost(attribID)
    local boosts = self:getBoosts()
    return boosts[attribID]
end

--- Retrieves all boosts applied to the character's attributes.
-- @realm shared
-- @return table A table containing all boosts applied to the character's attributes.
-- @usage local boostsTable = character:getBoosts()
function characterMeta:getBoosts()
    return self:getVar("boosts", {})
end

if SERVER then
    --- Updates the value of a character attribute by adding a specified value to it.
    -- @string key The key of the attribute to update.
    -- @int value The value to add to the attribute.
    -- @realm server
    -- @usage character:updateAttrib("some_attribute_key", 10)
    function characterMeta:updateAttrib(key, value)
        local client = self:getPlayer()
        local attribute = lia.attribs.list[key]
        if attribute then
            local attrib = self:getAttribs()
            attrib[key] = math.min((attrib[key] or 0) + value, hook.Run("GetAttributeMax", client, key))
            if IsValid(client) then
                netstream.Start(client, "attrib", self:getID(), key, attrib[key])
                if attribute.setup then attribute.setup(attrib[key]) end
            end
        end

        hook.Run("OnCharAttribUpdated", client, self, key, value)
    end

    --- Sets the value of a character attribute.
    -- @string key The key of the attribute to set.
    -- @int value The value to set for the attribute.
    -- @realm server
    -- @usage character:setAttrib("some_attribute_key", 10)
    function characterMeta:setAttrib(key, value)
        local client = self:getPlayer()
        local attribute = lia.attribs.list[key]
        if attribute then
            local attrib = self:getAttribs()
            attrib[key] = value
            if IsValid(client) then
                netstream.Start(client, "attrib", self:getID(), key, attrib[key])
                if attribute.setup then attribute.setup(attrib[key]) end
            end
        end

        hook.Run("OnCharAttribUpdated", client, self, key, value)
    end

    --- Adds a boost to the character's attributes.
    -- @realm server
    -- @string boostID The ID of the boost to add.
    -- @string attribID The ID of the attribute to which the boost should be added.
    -- @int boostAmount The amount of boost to add to the attribute.
    -- @usage character:removeBoost("some_boost_id", "some_attribute_id", 10)
    function characterMeta:addBoost(boostID, attribID, boostAmount)
        local boosts = self:getVar("boosts", {})
        boosts[attribID] = boosts[attribID] or {}
        boosts[attribID][boostID] = boostAmount
        hook.Run("OnCharAttribBoosted", self:getPlayer(), self, attribID, boostID, boostAmount)
        return self:setVar("boosts", boosts, nil, self:getPlayer())
    end

    --- Removes a boost from the character's attributes.
    -- @realm server
    -- @string boostID The ID of the boost to remove.
    -- @string attribID The ID of the attribute from which the boost should be removed.
    -- @usage character:removeBoost("some_boost_id", "some_attribute_id")
    function characterMeta:removeBoost(boostID, attribID)
        local boosts = self:getVar("boosts", {})
        boosts[attribID] = boosts[attribID] or {}
        boosts[attribID][boostID] = nil
        hook.Run("OnCharAttribBoosted", self:getPlayer(), self, attribID, boostID, true)
        return self:setVar("boosts", boosts, nil, self:getPlayer())
    end
end

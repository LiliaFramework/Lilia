--- Checks if the player belongs to the specified faction.
-- @realm shared
-- @string faction The faction to check against.
-- @treturn bool Whether the player belongs to the specified faction.
function playerMeta:isFaction(faction)
    return self:getChar():getFaction() == faction
end

--- Checks if the player belongs to the specified class.
-- @realm shared
-- @string class The class to check against.
-- @treturn bool Whether the player belongs to the specified class.
function playerMeta:isClass(class)
    return self:getChar():getClass() == class
end

--- Checks if the player has whitelisted access to a faction.
-- @realm shared
-- @int faction The faction to check for whitelisting.
-- @treturn bool Whether the player has whitelisted access to the specified faction.
function playerMeta:hasWhitelist(faction)
    local data = lia.faction.indices[faction]
    if data then
        if data.isDefault then return true end
        local liaData = self:getLiliaData("whitelists", {})
        return liaData[SCHEMA.folder] and liaData[SCHEMA.folder][data.uniqueID] == true or false
    end
    return false
end

--- Retrieves the class of the player's character.
-- @realm shared
-- @treturn string|nil The class of the player's character, or nil if not found.
function playerMeta:getClass()
    local character = self:getChar()
    if character then return character:getClass() end
end

--- Checks if the player has whitelisted access to a class.
-- @realm shared
-- @int class The class to check for whitelisting.
-- @treturn bool Whether the player has whitelisted access to the specified faction.
function playerMeta:hasClassWhitelist(class)
    local char = self:getChar()
    if not char then return false end
    local wl = char:getData("whitelist", {})
    return wl[class] ~= nil
end

--- Retrieves the data of the player's character class.
-- @realm shared
-- @treturn table|nil A table containing the data of the player's character class, or nil if not found.
function playerMeta:getClassData()
    local character = self:getChar()
    if character then
        local class = character:getClass()
        if class then
            local classData = lia.class.list[class]
            return classData
        end
    end
end

if SERVER then
    --- Whitelists all classes for the player.
    -- @realm shared
    function playerMeta:WhitelistAllClasses()
        for class, _ in pairs(lia.class.list) do
            if lia.class.hasWhitelist(class) then self:classWhitelist(class) end
        end
    end

    --- Whitelists all factions for the player.
    -- @realm shared
    function playerMeta:WhitelistAllFactions()
        for faction, _ in pairs(lia.faction.indices) do
            self:setWhitelisted(faction, true)
        end
    end

    --- Whitelists everything (all classes and factions) for the player.
    -- @realm shared
    function playerMeta:WhitelistEverything()
        self:WhitelistAllFactions()
        self:WhitelistAllClasses()
    end

    --- Whitelists the player for a specific class.
    -- @realm shared
    -- @int class The class to whitelist the player for.
    function playerMeta:classWhitelist(class)
        local wl = self:getChar():getData("whitelist", {})
        wl[class] = true
        self:getChar():setData("whitelist", wl)
    end

    --- Removes the whitelist status for a specific class from the player.
    -- @realm shared
    -- @int class The class to remove the whitelist status for.
    function playerMeta:classUnWhitelist(class)
        local wl = self:getChar():getData("whitelist", {})
        wl[class] = false
        self:getChar():setData("whitelist", wl)
    end

    --- Sets whether the player is whitelisted for a faction.
    -- @realm server
    -- @int faction The faction ID.
    -- @bool whitelisted Whether the player should be whitelisted for the faction.
    -- @treturn bool Whether the operation was successful.
    function playerMeta:setWhitelisted(faction, whitelisted)
        if not whitelisted then whitelisted = nil end
        local data = lia.faction.indices[faction]
        if data then
            local whitelists = self:getLiliaData("whitelists", {})
            whitelists[SCHEMA.folder] = whitelists[SCHEMA.folder] or {}
            whitelists[SCHEMA.folder][data.uniqueID] = whitelisted and true or nil
            self:setLiliaData("whitelists", whitelists)
            self:saveLiliaData()
            return true
        end
        return false
    end

    playerMeta.SetWhitelisted = playerMeta.setWhitelisted
    playerMeta.ClassWhitelist = playerMeta.classWhitelist
    playerMeta.ClassUnWhitelist = playerMeta.classUnWhitelist
end

playerMeta.GetClassData = playerMeta.getClassData
playerMeta.HasWhitelist = playerMeta.hasWhitelist
playerMeta.HasClassWhitelist = playerMeta.hasClassWhitelist

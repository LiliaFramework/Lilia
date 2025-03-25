local playerMeta = FindMetaTable("Player")
function playerMeta:isFaction(faction)
    local character = self:getChar()
    if not character then return end
    local pFaction = self:getChar():getFaction()
    return pFaction and pFaction == faction
end

function playerMeta:isClass(class)
    local character = self:getChar()
    if not character then return end
    local pClass = character:getClass()
    return pClass and pClass == class
end

function playerMeta:hasWhitelist(faction)
    local data = lia.faction.indices[faction]
    if data then
        if data.isDefault then return true end
        if not data.uniqueID then return false end
        local liaData = self:getLiliaData("whitelists", {})
        return liaData[SCHEMA.folder] and liaData[SCHEMA.folder][data.uniqueID] or false
    end
    return false
end

function playerMeta:getClass()
    local character = self:getChar()
    if character then return character:getClass() end
end

function playerMeta:hasClassWhitelist(class)
    local char = self:getChar()
    if not char then return false end
    local wl = char:getData("whitelist", {})
    return wl[class] ~= nil
end

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
    function playerMeta:WhitelistAllClasses()
        for class, _ in pairs(lia.class.list) do
            if lia.class.hasWhitelist(class) then self:classWhitelist(class) end
        end
    end

    function playerMeta:WhitelistAllFactions()
        for faction, _ in pairs(lia.faction.indices) do
            self:setWhitelisted(faction, true)
        end
    end

    function playerMeta:WhitelistEverything()
        self:WhitelistAllFactions()
        self:WhitelistAllClasses()
    end

    function playerMeta:classWhitelist(class)
        local wl = self:getChar():getData("whitelist", {})
        wl[class] = true
        self:getChar():setData("whitelist", wl)
    end

    function playerMeta:classUnWhitelist(class)
        local wl = self:getChar():getData("whitelist", {})
        wl[class] = false
        self:getChar():setData("whitelist", wl)
    end

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
end

--- The Character Meta for the Teams Module.
-- @charactermeta Teams
local MODULE = MODULE
local characterMeta = lia.meta.character or {}
--- Checks if the player has whitelisted access to a class.
-- @realm shared
-- @int class The class to check for whitelisting.
-- @treturn bool Whether the player has whitelisted access to the specified faction.
function characterMeta:hasClassWhitelist(class)
    local wl = self:getData("whitelist", {})
    return wl[class] ~= nil
end

--- Checks if the player belongs to the specified faction.
-- @realm shared
-- @string faction The faction to check against.
-- @treturn bool Whether the player belongs to the specified faction.
function characterMeta:isFaction(faction)
    return self:getChar():getFaction() == faction
end

--- Checks if the player belongs to the specified class.
-- @realm shared
-- @string class The class to check against.
-- @treturn bool Whether the player belongs to the specified class.
function characterMeta:isClass(class)
    return self:getChar():getClass() == class
end

if SERVER then
    --- Whitelists all classes for the character.
    -- @realm shared
    function characterMeta:WhitelistAllClasses()
        for class, _ in pairs(lia.class.list) do
            if not lia.class.hasWhitelist(class) then self:classWhitelist(class) end
        end
    end

    --- Whitelists all factions for the character.
    -- @realm shared
    function characterMeta:WhitelistAllFactions()
        for faction, _ in pairs(lia.faction.indices) do
            self:setWhitelisted(faction, true)
        end
    end

    --- Whitelists everything (all classes and factions) for the character.
    -- @realm shared
    function characterMeta:WhitelistEverything()
        self:WhitelistAllFactions()
        self:WhitelistAllClasses()
    end

    --- Whitelists the character for a specific class.
    -- @realm shared
    -- @int class The class to whitelist the character for.
    function characterMeta:classWhitelist(class)
        local wl = self:getData("whitelist", {})
        wl[class] = true
        self:setData("whitelist", wl)
    end

    --- Removes the whitelist for a specific class from the character.
    -- @realm shared
    -- @int class The class to remove the whitelist status for.
    function characterMeta:classUnWhitelist(class)
        local wl = self:getData("whitelist", {})
        wl[class] = false
        self:setData("whitelist", wl)
    end

    --- Sets the character's class to the specified class.
    -- @realm shared
    -- @string class The class to join.
    -- @bool[opt=false] isForced Whether to force the character to join the class even if conditions are not met.
    -- @return bool Whether the character successfully joined the class.
    -- @usage local success = character:joinClass("some_class")
    function characterMeta:joinClass(class, isForced)
        if not class then
            self:kickClass()
            return
        end

        local oldClass = self:getClass()
        local client = self:getPlayer()
        local hadOldClass = oldClass and oldClass ~= -1
        if isForced or lia.class.canBe(client, class) then
            self:setClass(class)
            if MODULE.PermaClass then self:setData("pclass", class) end
            if hadOldClass then
                hook.Run("OnPlayerSwitchClass", client, class, oldClass)
            else
                hook.Run("OnPlayerJoinClass", client, class, oldClass)
            end
            return true
        else
            return false
        end
    end

    --- Kicks the character from their current class and joins them to the default class of their faction.
    -- @realm shared
    function characterMeta:kickClass()
        local client = self:getPlayer()
        if not client then return end
        local goClass
        for k, v in pairs(lia.class.list) do
            if v.faction == client:Team() and v.isDefault then
                goClass = k
                break
            end
        end

        if not goClass then
            ErrorNoHaltWithStack("[Lilia] No default class set for faction '" .. team.GetName(client:Team()) .. "'")
            return
        end

        self:joinClass(goClass)
        hook.Run("OnPlayerJoinClass", client, goClass)
    end
end

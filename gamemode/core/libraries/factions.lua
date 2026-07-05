--[[
    Folder: Developer - Libraries
    File: lia.faction.md
]]
--[[
    Faction

    Faction helpers for registering factions, loading faction definitions, resolving models, validating character customization, and querying faction membership data.
]]
--[[
    Overview:
        The faction library centralizes shared faction behavior under `lia.faction`. It stores factions by index and unique ID, registers Garry's Mod teams, resolves localized names and descriptions, prepares faction models, validates skin and bodygroup restrictions, and exposes helpers used during character creation and faction lookups.
]]
--[[
    Hooks:
        OverrideFactionName(string uniqueID, string name)

    Purpose:
        Allows plugins or modules to override a faction's resolved display name while it is registered or loaded from disk.

    Category:
        Factions

    Parameters:
        uniqueID (string)
            The faction unique ID being registered or loaded.

        name (string)
            The resolved faction name before the override is applied.

    Example Usage:
        ```lua
        hook.Add("OverrideFactionName", "liaExampleOverrideFactionName", function(uniqueID, name)
            return "MyModule Override"
        end)
        ```

    Returns:
        string|nil
            Return a string to replace the faction name. Return nil to keep the current name.

    Realm:
        Shared
]]
--[[
    Hooks:
        OverrideFactionDesc(string uniqueID, string desc)

    Purpose:
        Allows plugins or modules to override a faction's resolved description while it is registered or loaded from disk.

    Category:
        Factions

    Parameters:
        uniqueID (string)
            The faction unique ID being registered or loaded.

        desc (string)
            The resolved faction description before the override is applied.

    Example Usage:
        ```lua
        hook.Add("OverrideFactionDesc", "liaExampleOverrideFactionDesc", function(uniqueID, desc)
            return "MyModule Override"
        end)
        ```

    Returns:
        string|nil
            Return a string to replace the faction description. Return nil to keep the current description.

    Realm:
        Shared
]]
--[[
    Hooks:
        OverrideFactionModels(string uniqueID, table models)

    Purpose:
        Allows plugins or modules to override the model list assigned to a faction while it is registered or loaded from disk.

    Category:
        Factions

    Parameters:
        uniqueID (string)
            The faction unique ID being registered or loaded.

        models (table)
            The faction model table before the override is applied.

    Example Usage:
        ```lua
        hook.Add("OverrideFactionModels", "liaExampleOverrideFactionModels", function(uniqueID, models)
            return {
                {name = "Example", value = 1}
            }
        end)
        ```

    Returns:
        table|nil
            Return a model table to replace the faction models. Return nil to keep the current models.

    Realm:
        Shared
]]
--[[
    Hooks:
        OverrideFactionModelCustomization(Player client, table faction, any context, boolean skinAllowed, boolean bodygroupsAllowed)

    Purpose:
        Allows plugins or modules to override whether skins and bodygroups can be customized for a faction model selection context.

    Category:
        Factions

    Parameters:
        client (Player)
            The player whose customization permissions are being checked.

        faction (table)
            The faction data being checked.

        context (any)
            Optional caller-provided context for the customization check.

        skinAllowed (boolean)
            Whether skin customization is currently allowed by faction data.

        bodygroupsAllowed (boolean)
            Whether bodygroup customization is currently allowed by faction data.

    Example Usage:
        ```lua
        hook.Add("OverrideFactionModelCustomization", "liaExampleOverrideFactionModelCustomization", function(client, faction, context, skinAllowed, bodygroupsAllowed)
            if faction and faction.uniqueID == "staff" then
                return false, true
            end
        end)
        ```

    Returns:
        table|boolean|nil, boolean|nil
            Return a table with `skinAllowed` and/or `bodygroupsAllowed` fields, or return two booleans to override each value separately. Return nil values to keep the current permissions.

    Realm:
        Shared
]]
lia.faction = lia.faction or {}
lia.faction.indices = lia.faction.indices or {}
lia.faction.teams = lia.faction.teams or {}
local DefaultModels = {"models/player/group01/male_01.mdl", "models/player/group01/male_02.mdl", "models/player/group01/male_03.mdl", "models/player/group01/male_04.mdl", "models/player/group01/male_05.mdl", "models/player/group01/male_06.mdl", "models/player/group01/female_01.mdl", "models/player/group01/female_02.mdl", "models/player/group01/female_03.mdl", "models/player/group01/female_04.mdl", "models/player/group01/female_05.mdl", "models/player/group01/female_06.mdl"}
--[[
    Purpose:
        Registers or updates a faction and creates its team entry.

    Parameters:
        uniqueID (string)
            Stable identifier used to store the faction and create the global FACTION_* constant.

        data (table)
            Faction data such as name, description, color, models, weapons, index, and customization settings.

    Returns:
        number, table
            The faction index and registered faction table.

    Example Usage:
        ```lua
        local index, faction = lia.faction.register("citizen", {
            name = "@citizen",
            desc = "@citizenDesc",
            color = Color(150, 150, 150),
            models = {"models/player/group01/male_01.mdl"}
        })
        ```

    Realm:
        Shared
]]
function lia.faction.register(uniqueID, data)
    assert(isstring(uniqueID), L("factionUniqueIDString"))
    assert(istable(data), L("dataMustBeTable"))
    local existing = lia.faction.teams[uniqueID]
    local constantName = "FACTION_" .. string.upper(uniqueID)
    local providedIndex = tonumber(data.index)
    local constantIndex = tonumber(_G[constantName])
    local index = providedIndex or constantIndex or existing and existing.index or table.Count(lia.faction.teams) + 1
    assert(not lia.faction.indices[index] or lia.faction.indices[index] == existing, L("factionIndexInUse"))
    local faction = existing or {
        index = index,
        isDefault = true
    }

    for k, v in pairs(data) do
        faction[k] = v
    end

    faction.index = index
    faction.uniqueID = uniqueID
    faction.name = lia.lang.resolveToken(faction.name) or lia.lang.resolveToken("@unknown")
    faction.desc = lia.lang.resolveToken(faction.desc) or lia.lang.resolveToken("@noDesc")
    faction.color = faction.color or Color(150, 150, 150)
    faction.models = faction.models or DefaultModels
    if faction.skinAllowed == nil then faction.skinAllowed = false end
    if faction.bodygroupsAllowed == nil then faction.bodygroupsAllowed = false end
    local overrideName = hook.Run("OverrideFactionName", uniqueID, faction.name)
    if overrideName then faction.name = overrideName end
    local overrideDesc = hook.Run("OverrideFactionDesc", uniqueID, faction.desc)
    if overrideDesc then faction.desc = overrideDesc end
    local overrideModels = hook.Run("OverrideFactionModels", uniqueID, faction.models)
    if overrideModels then faction.models = overrideModels end
    team.SetUp(faction.index, faction.name or L and L("unknown") or "unknown", faction.color or Color(125, 125, 125))
    lia.faction.cacheModels(faction.models)
    lia.faction.indices[faction.index] = faction
    lia.faction.teams[uniqueID] = faction
    _G[constantName] = faction.index
    return faction.index, faction
end

--[[
    Purpose:
        Precaches every usable model found in a faction model table.

    Parameters:
        models (table|nil)
            Model table containing string entries or structured model data.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.faction.cacheModels(faction.models)
        ```

    Realm:
        Shared
]]
function lia.faction.cacheModels(models)
    for modelKey, modelData in pairs(models or {}) do
        local parsed = lia.faction.getModelData and lia.faction.getModelData(modelKey, modelData)
        if parsed and isstring(parsed.model) and parsed.model ~= "" and lia.faction.isModelUsable(parsed.model) then util.PrecacheModel(parsed.model) end
    end
end

--[[
    Purpose:
        Checks whether a model path is usable for faction model handling.

    Parameters:
        modelPath (string)
            Model path to validate.

    Returns:
        boolean
            True when the value is a non-empty string and passes `util.IsValidModel` when available, otherwise false.

    Example Usage:
        ```lua
        if lia.faction.isModelUsable(modelPath) then
            util.PrecacheModel(modelPath)
        end
        ```

    Realm:
        Shared
]]
function lia.faction.isModelUsable(modelPath)
    return isstring(modelPath) and modelPath ~= "" and (not util or not util.IsValidModel or util.IsValidModel(modelPath))
end

--[[
    Purpose:
        Converts a skin value into a numeric skin index with a fallback.

    Parameters:
        skin (number|string|nil)
            Skin value to normalize.

        fallback (number|string|nil)
            Fallback skin index used when the provided value is empty, default, or invalid.

    Returns:
        number
            The normalized skin index.

    Example Usage:
        ```lua
        local skin = lia.faction.normalizeSkinValue(data.skin, 0)
        ```

    Realm:
        Shared
]]
function lia.faction.normalizeSkinValue(skin, fallback)
    local defaultSkin = tonumber(fallback) or 0
    if isnumber(skin) then return skin end
    local numericSkin = tonumber(skin)
    if numericSkin ~= nil then return numericSkin end
    if isstring(skin) then
        local lowered = string.Trim(skin):lower()
        if lowered == "" or lowered == "default" then return defaultSkin end
    end
    return defaultSkin
end

--[[
    Purpose:
        Parses supported faction model entry formats into a consistent model data table.

    Parameters:
        modelKey (any)
            Model table key, which may also be the model path for keyed model definitions.

        modelData (string|table)
            Raw model entry data to parse.

    Returns:
        table|nil
            Parsed model data containing `model`, `skin`, `bodygroups`, `allowedSkins`, and `allowedBodygroups`, or nil when the entry is not a model definition.

    Example Usage:
        ```lua
        local parsed = lia.faction.getModelData(modelKey, modelData)
        if parsed then
            print(parsed.model)
        end
        ```

    Realm:
        Shared
]]
function lia.faction.getModelData(modelKey, modelData)
    if isstring(modelData) then
        return {
            model = modelData,
            skin = 0,
            bodygroups = {},
            allowedSkins = nil,
            allowedBodygroups = nil
        }
    end

    if not istable(modelData) then return nil end
    local parsed = {
        model = nil,
        skin = 0,
        bodygroups = {},
        allowedSkins = modelData.allowedSkins,
        allowedBodygroups = modelData.allowedBodygroups
    }

    if isstring(modelData[1]) then
        parsed.model = modelData[1]
        parsed.skin = lia.faction.normalizeSkinValue(modelData[2], 0)
        parsed.bodygroups = modelData[3] or {}
        return parsed
    end

    if isstring(modelKey) and (modelData.allowedSkins ~= nil or modelData.allowedBodygroups ~= nil or modelData.skin ~= nil or modelData.defaultSkin ~= nil or modelData.bodygroups ~= nil or modelData.defaultBodygroups ~= nil or modelData.groups ~= nil or modelData.model ~= nil) then
        parsed.model = modelData.model or modelKey
        parsed.skin = lia.faction.normalizeSkinValue(modelData.skin ~= nil and modelData.skin or modelData.defaultSkin, 0)
        parsed.bodygroups = modelData.bodygroups or modelData.defaultBodygroups or modelData.groups or {}
        return parsed
    end
    return nil
end

--[[
    Purpose:
        Loads faction definition files from a directory and registers them into the faction caches.

    Parameters:
        directory (string)
            Directory path searched for Lua faction files.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.faction.loadFromDir("schema/factions")
        ```

    Realm:
        Shared
]]
function lia.faction.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName
        if v:sub(1, 3) == "sh_" then
            niceName = v:sub(4, -5):lower()
        else
            niceName = v:sub(1, -5)
        end

        FACTION = lia.faction.teams[niceName] or {
            index = table.Count(lia.faction.teams) + 1,
            isDefault = true
        }

        lia.loader.include(directory .. "/" .. v, "shared")
        if not FACTION.name then
            FACTION.name = "@unknown"
            lia.error(L("factionMissingName", niceName))
        end

        if not FACTION.desc then
            FACTION.desc = "@noDesc"
            lia.error(L("factionMissingDesc", niceName))
        end

        FACTION.name = lia.lang.resolveToken(FACTION.name)
        FACTION.desc = lia.lang.resolveToken(FACTION.desc)
        local overrideName = hook.Run("OverrideFactionName", niceName, FACTION.name)
        if overrideName then FACTION.name = overrideName end
        local overrideDesc = hook.Run("OverrideFactionDesc", niceName, FACTION.desc)
        if overrideDesc then FACTION.desc = overrideDesc end
        local overrideModels = hook.Run("OverrideFactionModels", niceName, FACTION.models)
        if overrideModels then FACTION.models = overrideModels end
        if not FACTION.color then FACTION.color = Color(150, 150, 150) end
        team.SetUp(FACTION.index, FACTION.name or L("unknown"), FACTION.color or Color(125, 125, 125))
        FACTION.models = FACTION.models or DefaultModels
        FACTION.uniqueID = FACTION.uniqueID or niceName
        if FACTION.skinAllowed == nil then FACTION.skinAllowed = false end
        if FACTION.bodygroupsAllowed == nil then FACTION.bodygroupsAllowed = false end
        lia.faction.cacheModels(FACTION.models)
        lia.faction.indices[FACTION.index] = FACTION
        lia.faction.teams[niceName] = FACTION
        FACTION = nil
    end
end

--[[
    Purpose:
        Returns every registered faction as an array.

    Parameters:
        None

    Returns:
        table
            Sequential table containing all registered faction tables.

    Example Usage:
        ```lua
        for _, faction in ipairs(lia.faction.getAll()) do
            print(faction.name)
        end
        ```

    Realm:
        Shared
]]
function lia.faction.getAll()
    local allFactions = {}
    for _, faction in pairs(lia.faction.teams) do
        table.insert(allFactions, faction)
    end
    return allFactions
end

--[[
    Purpose:
        Finds a registered faction by numeric index or unique ID.

    Parameters:
        identifier (number|string)
            Faction index or unique ID.

    Returns:
        table|nil
            The matching faction table, or nil when no faction exists for the identifier.

    Example Usage:
        ```lua
        local faction = lia.faction.get(FACTION_CITIZEN)
        ```

    Realm:
        Shared
]]
function lia.faction.get(identifier)
    return lia.faction.indices[identifier] or lia.faction.teams[identifier]
end

--[[
    Purpose:
        Determines whether skin and bodygroup customization are allowed for a faction.

    Parameters:
        client (Player)
            Player whose customization permissions are being checked.

        faction (number|string|table)
            Faction index, unique ID, or faction table.

        context (any)
            Optional caller-provided context passed to customization override hooks.

    Returns:
        boolean, boolean
            Whether skin customization and bodygroup customization are allowed.

    Example Usage:
        ```lua
        local canSkin, canBodygroups = lia.faction.getModelCustomizationAllowed(client, faction, "creation")
        ```

    Realm:
        Shared
]]
function lia.faction.getModelCustomizationAllowed(client, faction, context)
    if isnumber(faction) or isstring(faction) then faction = lia.faction.get(faction) end
    if not faction then return false, false end
    local skinAllowed = faction.skinAllowed == true
    local bodygroupsAllowed = faction.bodygroupsAllowed == true
    local a, b = hook.Run("OverrideFactionModelCustomization", client, faction, context, skinAllowed, bodygroupsAllowed)
    if istable(a) then
        if a.skinAllowed ~= nil then skinAllowed = a.skinAllowed == true end
        if a.bodygroupsAllowed ~= nil then bodygroupsAllowed = a.bodygroupsAllowed == true end
    else
        if a ~= nil then skinAllowed = a == true end
        if b ~= nil then bodygroupsAllowed = b == true end
    end
    return skinAllowed, bodygroupsAllowed
end

--[[
    Purpose:
        Builds and caches a lowercase bodygroup-name-to-index map for a model.

    Parameters:
        modelPath (string)
            Model path whose bodygroups should be inspected.

    Returns:
        table
            Table mapping lowercase bodygroup names to numeric bodygroup indexes. Returns an empty table when the model is unusable.

    Example Usage:
        ```lua
        local map = lia.faction.getBodygroupNameToIndex(modelPath)
        local headIndex = map.head
        ```

    Realm:
        Shared
]]
function lia.faction.getBodygroupNameToIndex(modelPath)
    if not lia.faction.isModelUsable(modelPath) then return {} end
    if lia.faction._bodygroupNameIndexCache[modelPath] then return lia.faction._bodygroupNameIndexCache[modelPath] end
    local map = {}
    if CLIENT then
        local ent = ClientsideModel(modelPath, RENDERGROUP_OPAQUE)
        if IsValid(ent) then
            for i = 0, ent:GetNumBodyGroups() - 1 do
                map[string.lower(ent:GetBodygroupName(i) or "")] = i
            end

            ent:Remove()
        end
    else
        local ent = ents.Create("prop_dynamic")
        if IsValid(ent) then
            ent:SetModel(modelPath)
            ent:SetPos(Vector(0, 0, 0))
            ent:SetAngles(angle_zero)
            ent:Spawn()
            for i = 0, ent:GetNumBodyGroups() - 1 do
                map[string.lower(ent:GetBodygroupName(i) or "")] = i
            end

            ent:Remove()
        end
    end

    lia.faction._bodygroupNameIndexCache[modelPath] = map
    return map
end

--[[
    Purpose:
        Gets the skin whitelist for a model entry or its owning faction.

    Parameters:
        faction (number|string|table)
            Faction index, unique ID, or faction table.

        modelData (string|table|nil)
            Optional model entry data that may define `allowedSkins`.

        modelKey (any)
            Optional model entry key used when parsing model data.

    Returns:
        table|nil
            Allowed skin values from the model entry or faction, or nil when no skin whitelist exists.

    Example Usage:
        ```lua
        local allowedSkins = lia.faction.getAllowedSkins(faction, modelData, modelKey)
        ```

    Realm:
        Shared
]]
function lia.faction.getAllowedSkins(faction, modelData, modelKey)
    if isnumber(faction) or isstring(faction) then faction = lia.faction.get(faction) end
    local parsed = lia.faction.getModelData(modelKey, modelData)
    if parsed and istable(parsed.allowedSkins) then return parsed.allowedSkins end
    return faction and faction.allowedSkins or nil
end

--[[
    Purpose:
        Gets the bodygroup whitelist rules for a model entry or its owning faction.

    Parameters:
        faction (number|string|table)
            Faction index, unique ID, or faction table.

        modelData (string|table|nil)
            Optional model entry data that may define `allowedBodygroups`.

        modelKey (any)
            Optional model entry key used when parsing model data.

    Returns:
        table|nil
            Allowed bodygroup rules from the model entry or faction, or nil when no bodygroup whitelist exists.

    Example Usage:
        ```lua
        local allowedBodygroups = lia.faction.getAllowedBodygroups(faction, modelData, modelKey)
        ```

    Realm:
        Shared
]]
function lia.faction.getAllowedBodygroups(faction, modelData, modelKey)
    if isnumber(faction) or isstring(faction) then faction = lia.faction.get(faction) end
    local parsed = lia.faction.getModelData(modelKey, modelData)
    if parsed and istable(parsed.allowedBodygroups) then return parsed.allowedBodygroups end
    return faction and faction.allowedBodygroups or nil
end

--[[
    Purpose:
        Checks whether a skin value is permitted by a faction or model skin whitelist.

    Parameters:
        faction (number|string|table)
            Faction index, unique ID, or faction table.

        skin (number|string)
            Skin value being checked.

        modelData (string|table|nil)
            Optional model entry data that may define `allowedSkins`.

        modelKey (any)
            Optional model entry key used when parsing model data.

    Returns:
        boolean
            True when the skin is allowed or no whitelist exists, otherwise false.

    Example Usage:
        ```lua
        if lia.faction.isSkinAllowedForFaction(faction, skin, modelData, modelKey) then
            character:setData("skin", skin)
        end
        ```

    Realm:
        Shared
]]
function lia.faction.isSkinAllowedForFaction(faction, skin, modelData, modelKey)
    if isnumber(faction) or isstring(faction) then faction = lia.faction.get(faction) end
    if not faction then return false end
    local whitelist = lia.faction.getAllowedSkins(faction, modelData, modelKey)
    if not istable(whitelist) then return true end
    if next(whitelist) == nil then return true end
    skin = tonumber(skin)
    if skin == nil then return false end
    for _, v in pairs(whitelist) do
        if tonumber(v) == skin then return true end
    end
    return false
end

--[[
    Purpose:
        Returns the first allowed skin for a faction or model, falling back when no usable whitelist value exists.

    Parameters:
        faction (number|string|table)
            Faction index, unique ID, or faction table.

        fallback (number)
            Skin value returned when no whitelist value is available.

        modelData (string|table|nil)
            Optional model entry data that may define `allowedSkins`.

        modelKey (any)
            Optional model entry key used when parsing model data.

    Returns:
        number
            First numeric allowed skin value, or the fallback value.

    Example Usage:
        ```lua
        local skin = lia.faction.getDefaultAllowedSkinForFaction(faction, 0, modelData, modelKey)
        ```

    Realm:
        Shared
]]
function lia.faction.getDefaultAllowedSkinForFaction(faction, fallback, modelData, modelKey)
    if isnumber(faction) or isstring(faction) then faction = lia.faction.get(faction) end
    if not faction then return fallback end
    local allowedSkins = lia.faction.getAllowedSkins(faction, modelData, modelKey)
    if istable(allowedSkins) then
        for _, v in pairs(allowedSkins) do
            local n = tonumber(v)
            if n ~= nil then return n end
        end
    end
    return fallback
end

--[[
    Purpose:
        Finds the whitelist rule that applies to a bodygroup by index or name.

    Parameters:
        faction (number|string|table)
            Faction index, unique ID, or faction table.

        modelPath (string)
            Model path used to resolve bodygroup names when needed.

        bodygroupIndex (number|string|nil)
            Bodygroup index being checked.

        bodygroupName (string|nil)
            Optional bodygroup name being checked.

        modelData (string|table|nil)
            Optional model entry data that may define `allowedBodygroups`.

        modelKey (any)
            Optional model entry key used when parsing model data.

    Returns:
        table|boolean|nil
            Whitelist rule for the bodygroup, true or false for unconditional allow or deny, or nil when no rule applies.

    Example Usage:
        ```lua
        local rule = lia.faction.getBodygroupWhitelistRule(faction, modelPath, bodygroupIndex, bodygroupName, modelData, modelKey)
        ```

    Realm:
        Shared
]]
function lia.faction.getBodygroupWhitelistRule(faction, modelPath, bodygroupIndex, bodygroupName, modelData, modelKey)
    if isnumber(faction) or isstring(faction) then faction = lia.faction.get(faction) end
    if not faction then return nil end
    local rules = lia.faction.getAllowedBodygroups(faction, modelData, modelKey)
    if not istable(rules) then return nil end
    if next(rules) == nil then return nil end
    local idx = tonumber(bodygroupIndex)
    if idx ~= nil then
        local rule = rules[idx]
        if rule ~= nil then return rule end
        rule = rules[tostring(idx)]
        if rule ~= nil then return rule end
    end

    local name = bodygroupName
    if name == nil and isstring(modelPath) and modelPath ~= "" then
        local map = lia.faction.getBodygroupNameToIndex(modelPath)
        local i = idx ~= nil and idx or nil
        if i ~= nil then
            for n, mappedIndex in pairs(map) do
                if mappedIndex == i then
                    name = n
                    break
                end
            end
        end
    end

    if isstring(name) and name ~= "" then
        local rule = rules[name]
        if rule ~= nil then return rule end
        rule = rules[string.lower(name)]
        if rule ~= nil then return rule end
    end
    return nil
end

--[[
    Purpose:
        Checks whether a bodygroup value is permitted by the applicable whitelist rule.

    Parameters:
        faction (number|string|table)
            Faction index, unique ID, or faction table.

        modelPath (string)
            Model path used to resolve bodygroup names when needed.

        bodygroupIndex (number|string|nil)
            Bodygroup index being checked.

        value (number|string)
            Bodygroup value being checked.

        bodygroupName (string|nil)
            Optional bodygroup name being checked.

        modelData (string|table|nil)
            Optional model entry data that may define `allowedBodygroups`.

        modelKey (any)
            Optional model entry key used when parsing model data.

    Returns:
        boolean
            True when the value is allowed or no rule applies, otherwise false.

    Example Usage:
        ```lua
        if lia.faction.isBodygroupValueAllowed(faction, modelPath, index, value, name, modelData, modelKey) then
            entity:SetBodygroup(index, value)
        end
        ```

    Realm:
        Shared
]]
function lia.faction.isBodygroupValueAllowed(faction, modelPath, bodygroupIndex, value, bodygroupName, modelData, modelKey)
    local rule = lia.faction.getBodygroupWhitelistRule(faction, modelPath, bodygroupIndex, bodygroupName, modelData, modelKey)
    if rule == nil then return true end
    if rule == true then return true end
    if rule == false then return false end
    if istable(rule) then
        local v = tonumber(value)
        if v == nil then return false end
        for _, allowed in pairs(rule) do
            if tonumber(allowed) == v then return true end
        end
        return false
    end
    return false
end

--[[
    Purpose:
        Gets a faction index from its unique ID.

    Parameters:
        uniqueID (string)
            Faction unique ID.

    Returns:
        number|nil
            Faction index, or nil when the unique ID is not registered.

    Example Usage:
        ```lua
        local index = lia.faction.getIndex("citizen")
        ```

    Realm:
        Shared
]]
function lia.faction.getIndex(uniqueID)
    return lia.faction.teams[uniqueID] and lia.faction.teams[uniqueID].index
end

--[[
    Purpose:
        Returns all classes assigned to a faction index.

    Parameters:
        faction (number)
            Faction index used by class definitions.

    Returns:
        table
            Sequential table containing class tables that belong to the faction.

    Example Usage:
        ```lua
        local classes = lia.faction.getClasses(FACTION_CITIZEN)
        ```

    Realm:
        Shared
]]
function lia.faction.getClasses(faction)
    local classes = {}
    for _, class in pairs(lia.class.list) do
        if class.faction == faction then table.insert(classes, class) end
    end
    return classes
end

--[[
    Purpose:
        Returns all connected players whose current character belongs to a faction.

    Parameters:
        faction (number)
            Faction index to match against character faction data.

    Returns:
        table
            Sequential table containing matching Player objects.

    Example Usage:
        ```lua
        for _, ply in ipairs(lia.faction.getPlayers(FACTION_CITIZEN)) do
            print(ply:Name())
        end
        ```

    Realm:
        Shared
]]
function lia.faction.getPlayers(faction)
    local players = {}
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getFaction() == faction then table.insert(players, v) end
    end
    return players
end

--[[
    Purpose:
        Counts connected players whose current character belongs to a faction.

    Parameters:
        faction (number)
            Faction index to match against character faction data.

    Returns:
        number
            Number of connected players in the faction.

    Example Usage:
        ```lua
        local count = lia.faction.getPlayerCount(FACTION_CITIZEN)
        ```

    Realm:
        Shared
]]
function lia.faction.getPlayerCount(faction)
    local count = 0
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getFaction() == faction then count = count + 1 end
    end
    return count
end

--[[
    Purpose:
        Checks whether a faction value is included in a faction category list.

    Parameters:
        faction (any)
            Faction value being searched for.

        categoryFactions (table)
            Table of faction values that make up the category.

    Returns:
        boolean
            True when the faction exists in the category table, otherwise false.

    Example Usage:
        ```lua
        if lia.faction.isFactionCategory(faction, categoryFactions) then
            return true
        end
        ```

    Realm:
        Shared
]]
function lia.faction.isFactionCategory(faction, categoryFactions)
    if table.HasValue(categoryFactions, faction) then return true end
    return false
end

--[[
    Purpose:
        Resolves the class used for character creation and verifies it belongs to the selected faction.

    Parameters:
        faction (number|string|table)
            Faction index, unique ID, or faction table.

        class (number|string|table|nil)
            Class identifier or class table. When omitted or invalid, the faction default class is used when available.

    Returns:
        table|nil
            Resolved class table, or nil when no valid class exists for the faction.

    Example Usage:
        ```lua
        local classData = lia.faction.getCharacterCreationClass(faction, selectedClass)
        ```

    Realm:
        Shared
]]
function lia.faction.getCharacterCreationClass(faction, class)
    local factionData = istable(faction) and faction or lia.faction.get(faction)
    local classData = istable(class) and class or lia.class.get(class)
    if not classData and factionData then classData = lia.faction.getDefaultClass(factionData.index) end
    if not classData then return nil end
    if factionData and classData.faction ~= factionData.index then return nil end
    return classData
end

--[[
    Purpose:
        Finds the model source used during character creation from class data, faction data, or defaults.

    Parameters:
        faction (number|string|table)
            Faction index, unique ID, or faction table.

        class (number|string|table|nil)
            Optional class identifier or class table.

    Returns:
        string|table, table|nil, boolean
            Model path or model table, the owner table that provided it, and whether the source is a forced single model.

    Example Usage:
        ```lua
        local source, owner, forced = lia.faction.getCharacterCreationModelSource(faction, class)
        ```

    Realm:
        Shared
]]
function lia.faction.getCharacterCreationModelSource(faction, class)
    local factionData = istable(faction) and faction or lia.faction.get(faction)
    local classData = lia.faction.getCharacterCreationClass(factionData, class)
    if classData then
        if classData.model ~= nil then return classData.model, classData, true end
        if classData.models ~= nil then return classData.models, classData, false end
    end

    if factionData then
        if factionData.model ~= nil then return factionData.model, factionData, true end
        if factionData.models ~= nil then return factionData.models, factionData, false end
    end
    return DefaultModels, factionData, false
end

--[[
    Purpose:
        Returns the selectable model choices for character creation.

    Parameters:
        faction (number|string|table)
            Faction index, unique ID, or faction table.

        class (number|string|table|nil)
            Optional class identifier or class table.

    Returns:
        table, table|nil, boolean
            Model choices table, the owner table that provided the models, and whether the choice is a forced single model.

    Example Usage:
        ```lua
        local choices, owner, forced = lia.faction.getCharacterCreationModelChoices(faction, class)
        ```

    Realm:
        Shared
]]
function lia.faction.getCharacterCreationModelChoices(faction, class)
    local source, owner, forced = lia.faction.getCharacterCreationModelSource(faction, class)
    if forced then
        return {
            [1] = source
        }, owner, true
    end
    return source or {}, owner, false
end

--[[
    Purpose:
        Returns the selected character creation model entry and its source owner.

    Parameters:
        faction (number|string|table)
            Faction index, unique ID, or faction table.

        class (number|string|table|nil)
            Optional class identifier or class table.

        selectedModel (number|nil)
            Selected model index. Defaults to 1 when omitted.

    Returns:
        string|table|nil, table|nil, boolean
            Selected model entry, the owner table that provided it, and whether the source is a forced single model.

    Example Usage:
        ```lua
        local modelData, owner, forced = lia.faction.getCharacterCreationModelInfo(faction, class, selectedModel)
        ```

    Realm:
        Shared
]]
function lia.faction.getCharacterCreationModelInfo(faction, class, selectedModel)
    local source, owner, forced = lia.faction.getCharacterCreationModelSource(faction, class)
    if forced then return source, owner, true end
    if not istable(source) then return nil, owner, false end
    return source[selectedModel or 1], owner, false
end

--[[
    Purpose:
        Creates and registers a faction table from job-style data.

    Parameters:
        index (number)
            Faction index to assign.

        name (string)
            Faction name and storage key.

        color (Color)
            Team color for the faction.

        default (boolean)
            Whether the faction should be treated as default.

        models (table|nil)
            Optional model list. Defaults to the library default models when omitted.

    Returns:
        table
            Generated faction table.

    Example Usage:
        ```lua
        local faction = lia.faction.jobGenerate(10, "Worker", Color(125, 125, 125), true, models)
        ```

    Realm:
        Shared
]]
function lia.faction.jobGenerate(index, name, color, default, models)
    local FACTION = {}
    FACTION.index = index
    FACTION.isDefault = default
    FACTION.name = name
    FACTION.desc = ""
    FACTION.color = color
    FACTION.models = models or DefaultModels
    FACTION.uniqueID = FACTION.uniqueID or name
    lia.faction.cacheModels(FACTION.models)
    lia.faction.indices[FACTION.index] = FACTION
    lia.faction.teams[name] = FACTION
    team.SetUp(FACTION.index, FACTION.name, FACTION.color)
    return FACTION
end

local function formatModelDataEntry(name, faction, modelIndex, modelData, category)
    local newGroups
    local parsed = lia.faction.getModelData(modelIndex, modelData)
    if parsed and parsed.bodygroups and lia.faction.isModelUsable(parsed.model) then
        local groups = {}
        if istable(parsed.bodygroups) then
            local dummy
            if CLIENT then dummy = ClientsideModel(parsed.model) end
            if IsValid(dummy) then
                local groupData = dummy:GetBodyGroups()
                for _, group in ipairs(groupData) do
                    if group.id > 0 then
                        if parsed.bodygroups[group.id] then
                            groups[group.id] = parsed.bodygroups[group.id]
                        elseif parsed.bodygroups[group.name] then
                            groups[group.id] = parsed.bodygroups[group.name]
                        end
                    end
                end

                dummy:Remove()
            end

            newGroups = groups
        elseif isstring(parsed.bodygroups) then
            newGroups = string.Explode("", parsed.bodygroups)
        end
    end

    if newGroups then
        if category then
            local teamEntry = lia.faction.teams[name].models[category][modelIndex]
            local indexEntry = lia.faction.indices[faction.index].models[category][modelIndex]
            if istable(teamEntry) then
                if teamEntry[1] then
                    teamEntry[3] = newGroups
                else
                    teamEntry.bodygroups = newGroups
                end
            end

            if istable(indexEntry) then
                if indexEntry[1] then
                    indexEntry[3] = newGroups
                else
                    indexEntry.bodygroups = newGroups
                end
            end
        else
            local teamEntry = lia.faction.teams[name].models[modelIndex]
            local indexEntry = lia.faction.indices[faction.index].models[modelIndex]
            if istable(teamEntry) then
                if teamEntry[1] then
                    teamEntry[3] = newGroups
                else
                    teamEntry.bodygroups = newGroups
                end
            end

            if istable(indexEntry) then
                if indexEntry[1] then
                    indexEntry[3] = newGroups
                else
                    indexEntry.bodygroups = newGroups
                end
            end
        end
    end
end

--[[
    Purpose:
        Normalizes bodygroup data for every registered faction model entry where bodygroup names must be converted to indexes.

    Parameters:
        None

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.faction.formatModelData()
        ```

    Realm:
        Shared
]]
function lia.faction.formatModelData()
    for name, faction in pairs(lia.faction.teams) do
        if faction.models then
            for modelIndex, modelData in pairs(faction.models) do
                if isstring(modelIndex) then
                    if lia.faction.getModelData(modelIndex, modelData) then
                        formatModelDataEntry(name, faction, modelIndex, modelData)
                    elseif istable(modelData) then
                        for subIndex, subData in pairs(modelData) do
                            formatModelDataEntry(name, faction, subIndex, subData, modelIndex)
                        end
                    else
                        continue
                    end
                else
                    formatModelDataEntry(name, faction, modelIndex, modelData)
                end
            end
        end
    end
end

--[[
    Purpose:
        Returns model category names defined for a faction team.

    Parameters:
        teamName (string)
            Faction storage key used in `lia.faction.teams`.

    Returns:
        table
            Sequential table containing category names.

    Example Usage:
        ```lua
        local categories = lia.faction.getCategories("citizen")
        ```

    Realm:
        Shared
]]
function lia.faction.getCategories(teamName)
    local categories = {}
    local faction = lia.faction.teams[teamName]
    if faction and faction.models then
        for key, _ in pairs(faction.models) do
            if isstring(key) and not lia.faction.getModelData(key, faction.models[key]) then table.insert(categories, key) end
        end
    end
    return categories
end

--[[
    Purpose:
        Returns all model entries from a named faction model category.

    Parameters:
        teamName (string)
            Faction storage key used in `lia.faction.teams`.

        category (string)
            Model category name to read.

    Returns:
        table
            Table containing model entries from the requested category.

    Example Usage:
        ```lua
        local models = lia.faction.getModelsFromCategory("citizen", "male")
        ```

    Realm:
        Shared
]]
function lia.faction.getModelsFromCategory(teamName, category)
    local models = {}
    local faction = lia.faction.teams[teamName]
    if faction and faction.models and faction.models[category] then
        for index, model in pairs(faction.models[category]) do
            models[index] = model
        end
    end
    return models
end

--[[
    Purpose:
        Finds the default class assigned to a faction index.

    Parameters:
        id (number)
            Faction index used by class definitions.

    Returns:
        table|nil
            Default class table, or nil when none is registered for the faction.

    Example Usage:
        ```lua
        local defaultClass = lia.faction.getDefaultClass(FACTION_CITIZEN)
        ```

    Realm:
        Shared
]]
function lia.faction.getDefaultClass(id)
    local defaultClass = nil
    for _, class in ipairs(lia.class.list) do
        if class.faction == id and class.isDefault then
            defaultClass = class
            break
        end
    end
    return defaultClass
end

FACTION_STAFF = lia.faction.register("staff", {
    name = "@factionStaffName",
    desc = "@factionStaffDesc",
    color = Color(255, 56, 252),
    isDefault = false,
    models = {"models/player/police.mdl"},
    weapons = {"weapon_physgun", "gmod_tool", "weapon_physcannon"}
})

if CLIENT then
    --[[
        Purpose:
            Checks whether the local player is allowed to create or use a faction.

        Parameters:
            faction (number)
                Faction index to check.

        Returns:
            boolean
                True when the faction is default, when the local player has staff character creation privilege for the staff faction, or when local whitelist data contains the faction.

        Example Usage:
            ```lua
            if lia.faction.hasWhitelist(FACTION_CITIZEN) then
                print("allowed")
            end
            ```

        Realm:
            Client
    ]]
    function lia.faction.hasWhitelist(faction)
        local data = lia.faction.indices[faction]
        if data then
            if data.isDefault then return true end
            if faction == FACTION_STAFF then
                local hasPriv = IsValid(LocalPlayer()) and LocalPlayer():hasPrivilege("createStaffCharacter") or false
                return hasPriv
            end

            local liaData = lia.localData and lia.localData.whitelists or {}
            return liaData[SCHEMA.folder] and liaData[SCHEMA.folder][data.uniqueID] or false
        end
        return false
    end
else
    --[[
        Purpose:
            Checks whether a faction is available by default on the server.

        Parameters:
            faction (number)
                Faction index to check.

        Returns:
            boolean
                True only for default factions in this implementation, otherwise false.

        Example Usage:
            ```lua
            if lia.faction.hasWhitelist(FACTION_CITIZEN) then
                print("default faction")
            end
            ```

        Realm:
            Server
    ]]
    function lia.faction.hasWhitelist(faction)
        local data = lia.faction.indices[faction]
        if data then
            if data.isDefault then return true end
            if faction == FACTION_STAFF then return false end
            return false
        end
        return false
    end
end

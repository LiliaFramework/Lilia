--[[
    Folder: Libraries
    File: faction.md
]]
--[[
    Faction

    Comprehensive faction (team) management and registration system for the Lilia framework.
]]
--[[
    Overview:
        The faction library provides comprehensive functionality for managing factions (teams) in the Lilia framework. It handles registration, loading, and management of faction data including models, colors, descriptions, and team setup. The library operates on both server and client sides, with server handling faction registration and client handling whitelist checks. It includes functionality for loading factions from directories, managing faction models with bodygroup support, and providing utilities for faction categorization and player management. The library ensures proper team setup and model precaching for all registered factions, supporting both simple string models and complex model data with bodygroup configurations.
]]
lia.faction = lia.faction or {}
lia.faction.indices = lia.faction.indices or {}
lia.faction.teams = lia.faction.teams or {}
local DefaultModels = {"models/player/group01/male_01.mdl", "models/player/group01/male_02.mdl", "models/player/group01/male_03.mdl", "models/player/group01/male_04.mdl", "models/player/group01/male_05.mdl", "models/player/group01/male_06.mdl", "models/player/group01/female_01.mdl", "models/player/group01/female_02.mdl", "models/player/group01/female_03.mdl", "models/player/group01/female_04.mdl", "models/player/group01/female_05.mdl", "models/player/group01/female_06.mdl"}
--[[
    Purpose:
        Registers a new faction with the specified unique ID and data table, setting up team configuration and model caching.

    When Called:
        Called during gamemode initialization to register factions programmatically, typically in shared files or during faction loading.

    Parameters:
        uniqueID (string)
            The unique identifier for the faction.
        data (table)
            A table containing faction configuration data including name, description, color, models, etc.

    Returns:
        number, table
            Returns the faction index and the faction data table.

    Realm:
        Shared

    Example Usage:
        ```lua
        local index, faction = lia.faction.register("citizen", {
            name = "Citizen",
            desc = "A regular citizen",
            color = Color(100, 150, 200),
            models = {"models/player/group01/male_01.mdl"}
        })
        ```
]]
function lia.faction.register(uniqueID, data)
    assert(isstring(uniqueID), L("factionUniqueIDString"))
    assert(istable(data), L("factionDataTable"))
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
    faction.name = L(faction.name) or "unknown"
    faction.desc = L(faction.desc) or "noDesc"
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
        Precaches model files to ensure they load quickly when needed, handling both string model paths and table-based model data.

    When Called:
        Called automatically during faction registration to precache all models associated with a faction.

    Parameters:
        models (table)
            A table of model data, where each entry can be a string path or a table with model information.
            This function does not return a value.

    Realm:
        Shared

    Example Usage:
        ```lua
        local models = {"models/player/group01/male_01.mdl", "models/player/group01/female_01.mdl"}
        lia.faction.cacheModels(models)
        ```
]]
function lia.faction.cacheModels(models)
    for _, modelData in pairs(models or {}) do
        if isstring(modelData) then
            util.PrecacheModel(modelData)
        elseif istable(modelData) then
            util.PrecacheModel(modelData[1])
        end
    end
end

--[[
    Purpose:
        Loads faction definitions from Lua files in a specified directory, registering each faction found.

    When Called:
        Called during gamemode initialization to load faction definitions from organized directory structures.

    Parameters:
        directory (string)
            The path to the directory containing faction definition files.
            This function does not return a value.

    Realm:
        Shared

    Example Usage:
        ```lua
        lia.faction.loadFromDir("gamemode/factions")
        ```
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
            FACTION.name = "unknown"
            lia.error(L("factionMissingName", niceName))
        end

        if not FACTION.desc then
            FACTION.desc = "noDesc"
            lia.error(L("factionMissingDesc", niceName))
        end

        FACTION.name = L(FACTION.name)
        FACTION.desc = L(FACTION.desc)
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
        for _, modelData in pairs(FACTION.models) do
            if isstring(modelData) then
                util.PrecacheModel(modelData)
            elseif istable(modelData) then
                util.PrecacheModel(modelData[1])
            end
        end

        lia.faction.indices[FACTION.index] = FACTION
        lia.faction.teams[niceName] = FACTION
        FACTION = nil
    end
end

--[[
    Purpose:
        Retrieves all registered factions as a table.

    When Called:
        Called whenever all faction information needs to be accessed by other systems or scripts.

    Parameters:
        None

    Returns:
        table
            A table containing all faction data tables.

    Realm:
        Shared

    Example Usage:
        ```lua
        local allFactions = lia.faction.getAll()
        for _, faction in ipairs(allFactions) do
            print("Faction: " .. faction.name)
        end
        ```
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
        Retrieves faction data by either its unique ID or index number.

    When Called:
        Called whenever faction information needs to be accessed by other systems or scripts.

    Parameters:
        identifier (string|number)
            The faction's unique ID string or numeric index.

    Returns:
        table
            The faction data table, or nil if not found.

    Realm:
        Shared

    Example Usage:
        ```lua
        local faction = lia.faction.get("citizen")
        -- or
        local faction = lia.faction.get(1)
        ```
]]
function lia.faction.get(identifier)
    return lia.faction.indices[identifier] or lia.faction.teams[identifier]
end

--[[
    Purpose:
        Determines whether a faction allows skin and bodygroup customization for a given client.

    When Called:
        Called when checking if a player can customize their character model with skins and bodygroups,
        typically during character creation or model selection.

    Parameters:
        client (Player)
            The player whose customization permissions are being checked.
        faction (number/string/table)
            The faction identifier - can be a faction ID, unique ID, or faction table.
        context (any)
            Additional context data that might be used by hooks to determine permissions.

    Returns:
        boolean, boolean
            First value: Whether skin customization is allowed.
            Second value: Whether bodygroup customization is allowed.

    Realm:
        Shared

    Example Usage:
        ```lua
        local skinAllowed, bodygroupsAllowed = lia.faction.getModelCustomizationAllowed(client, faction, "character_creation")
        ```
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
        Builds a lookup table of bodygroup name -> bodygroup index for a specific model path.

    When Called:
        Called when bodygroup whitelist rules are defined by bodygroup name, and we need to resolve
        those names to numeric indices for a given model.

    Parameters:
        modelPath (string)
            The model path to inspect.

    Returns:
        table
            A map where keys are lowercase bodygroup names and values are numeric bodygroup indices.
            Returns an empty table if the model is invalid or cannot be inspected.

    Realm:
        Shared

    Example Usage:
        ```lua
        local map = lia.faction.getBodygroupNameToIndex("models/player/group01/male_01.mdl")
        local headgearIndex = map.headgear
        ```
]]
function lia.faction.getBodygroupNameToIndex(modelPath)
    if not isstring(modelPath) or modelPath == "" then return {} end
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
        Checks if a skin ID is allowed for a faction when a skin whitelist is defined.
        If the whitelist is missing or empty, this function treats it as unrestricted.

    When Called:
        Called during character creation/adjustment when `skinAllowed` is enabled and the player
        attempts to pick a specific skin.

    Parameters:
        faction (table|string|number)
            The faction table, uniqueID, or numeric index.
        skin (number)
            The desired skin ID.

    Returns:
        boolean
            True if allowed, false otherwise.

    Realm:
        Shared

    Example Usage:
        ```lua
        if lia.faction.isSkinAllowedForFaction("citizen", 0) then
            print("Allowed")
        end
        ```
]]
function lia.faction.isSkinAllowedForFaction(faction, skin)
    if isnumber(faction) or isstring(faction) then faction = lia.faction.get(faction) end
    if not faction then return false end
    local whitelist = faction.allowedSkins
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
        Returns the first allowed skin from a faction whitelist to use as a fallback.

    When Called:
        Called when a player-selected skin is not allowed and we need to clamp it back to a valid
        value. If no whitelist exists (or it has no numeric entries), the provided fallback is used.

    Parameters:
        faction (table|string|number)
            The faction table, uniqueID, or numeric index.
        fallback (number)
            The fallback skin to use if there is no usable whitelist value.

    Returns:
        number
            A valid skin ID.

    Realm:
        Shared

    Example Usage:
        ```lua
        local skin = lia.faction.getDefaultAllowedSkinForFaction("citizen", 0)
        ```
]]
function lia.faction.getDefaultAllowedSkinForFaction(faction, fallback)
    if isnumber(faction) or isstring(faction) then faction = lia.faction.get(faction) end
    if not faction then return fallback end
    if istable(faction.allowedSkins) then
        for _, v in pairs(faction.allowedSkins) do
            local n = tonumber(v)
            if n ~= nil then return n end
        end
    end
    return fallback
end

--[[
    Purpose:
        Resolves the whitelist rule for a specific bodygroup for a faction.
        Supports looking up rules by numeric bodygroup index or by bodygroup name.

    When Called:
        Called when validating a requested bodygroup change during character creation/adjustment.

    Parameters:
        faction (table|string|number)
            The faction table, uniqueID, or numeric index.
        modelPath (string)
            The model used to resolve bodygroup name to index when needed.
        bodygroupIndex (number)
            The numeric bodygroup index.
        bodygroupName (string|nil)
            Optional bodygroup name override.

    Returns:
        any
            The rule value stored in `FACTION.allowedBodygroups` for this bodygroup.
            - nil means no restriction.
            - table means a whitelist of allowed numeric values.
            - true/false explicitly allows/denies.

    Realm:
        Shared

    Example Usage:
        ```lua
        local rule = lia.faction.getBodygroupWhitelistRule("citizen", mdl, 1)
        ```
]]
function lia.faction.getBodygroupWhitelistRule(faction, modelPath, bodygroupIndex, bodygroupName)
    if isnumber(faction) or isstring(faction) then faction = lia.faction.get(faction) end
    if not faction then return nil end
    local rules = faction.allowedBodygroups
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
        Checks if a specific bodygroup value is allowed for a faction.
        If there is no rule (or the allowedBodygroups table is missing/empty), this is unrestricted.

    When Called:
        Called during character creation/adjustment when `bodygroupsAllowed` is enabled and the
        player attempts to pick bodygroup values.

    Parameters:
        faction (table|string|number)
            The faction table, uniqueID, or numeric index.
        modelPath (string)
            The model path used to resolve bodygroup names when needed.
        bodygroupIndex (number)
            The numeric bodygroup index.
        value (number)
            The requested bodygroup value.
        bodygroupName (string|nil)
            Optional bodygroup name override.

    Returns:
        boolean
            True if allowed, false otherwise.

    Realm:
        Shared

    Example Usage:
        ```lua
        if lia.faction.isBodygroupValueAllowed("citizen", mdl, 0, 1) then
            print("Allowed")
        end
        ```
]]
function lia.faction.isBodygroupValueAllowed(faction, modelPath, bodygroupIndex, value, bodygroupName)
    local rule = lia.faction.getBodygroupWhitelistRule(faction, modelPath, bodygroupIndex, bodygroupName)
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
        Retrieves the numeric team index for a faction given its unique ID.

    When Called:
        Called when the numeric team index is needed for GMod team functions or comparisons.

    Parameters:
        uniqueID (string)
            The unique identifier of the faction.

    Returns:
        number
            The faction's team index, or nil if the faction doesn't exist.

    Realm:
        Shared

    Example Usage:
        ```lua
        local index = lia.faction.getIndex("citizen")
        if index then
            print("Citizen faction index: " .. index)
        end
        ```
]]
function lia.faction.getIndex(uniqueID)
    return lia.faction.teams[uniqueID] and lia.faction.teams[uniqueID].index
end

--[[
    Purpose:
        Retrieves all character classes that belong to a specific faction.

    When Called:
        Called when needing to display or work with all classes available to a faction.

    Parameters:
        faction (string|number)
            The faction identifier (unique ID or index).

    Returns:
        table
            An array of class data tables that belong to the specified faction.

    Realm:
        Shared

    Example Usage:
        ```lua
        local classes = lia.faction.getClasses("citizen")
        for _, class in ipairs(classes) do
            print("Class: " .. class.name)
        end
        ```
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
        Retrieves all players who are currently playing characters in the specified faction.

    When Called:
        Called when needing to iterate over or work with all players belonging to a specific faction.

    Parameters:
        faction (string|number)
            The faction identifier (unique ID or index).

    Returns:
        table
            An array of player entities who belong to the specified faction.

    Realm:
        Shared

    Example Usage:
        ```lua
        local players = lia.faction.getPlayers("citizen")
        for _, player in ipairs(players) do
            player:ChatPrint("Hello citizens!")
        end
        ```
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
        Counts the number of players currently playing characters in the specified faction.

    When Called:
        Called when needing to know how many players are in a faction for UI display, limits, or statistics.

    Parameters:
        faction (string|number)
            The faction identifier (unique ID or index).

    Returns:
        number
            The number of players in the specified faction.

    Realm:
        Shared

    Example Usage:
        ```lua
        local count = lia.faction.getPlayerCount("citizen")
        print("There are " .. count .. " citizens online")
        ```
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
        Checks if a faction belongs to a specific category of factions.

    When Called:
        Called when determining if a faction is part of a group or category for organizational purposes.

    Parameters:
        faction (string|number)
            The faction identifier to check.
        categoryFactions (table)
            An array of faction identifiers that define the category.

    Returns:
        boolean
            True if the faction is in the category, false otherwise.

    Realm:
        Shared

    Example Usage:
        ```lua
        local lawFactions = {"police", "sheriff"}
        if lia.faction.isFactionCategory("police", lawFactions) then
            print("This is a law enforcement faction")
        end
        ```
]]
function lia.faction.isFactionCategory(faction, categoryFactions)
    if table.HasValue(categoryFactions, faction) then return true end
    return false
end

--[[
    Purpose:
        Generates a basic faction configuration programmatically with minimal required parameters.

    When Called:
        Called for quick faction creation during development or for compatibility with other systems.

    Parameters:
        index (number)
            The numeric team index for the faction.
        name (string)
            The display name of the faction.
        color (Color)
            The color associated with the faction.
        default (boolean)
            Whether this is a default faction that doesn't require whitelisting.
        models (table)
            Array of model paths for the faction (optional, uses defaults if not provided).

    Returns:
        table
            The created faction data table.

    Realm:
        Shared

    Example Usage:
        ```lua
        local faction = lia.faction.jobGenerate(5, "Visitor", Color(200, 200, 200), true)
        ```
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
    for _, v in pairs(FACTION.models) do
        if isstring(v) then
            util.PrecacheModel(v)
        elseif istable(v) then
            util.PrecacheModel(v[1])
        end
    end

    lia.faction.indices[FACTION.index] = FACTION
    lia.faction.teams[name] = FACTION
    team.SetUp(FACTION.index, FACTION.name, FACTION.color)
    return FACTION
end

local function formatModelDataEntry(name, faction, modelIndex, modelData, category)
    local newGroups
    if istable(modelData) and modelData[3] then
        local groups = {}
        if istable(modelData[3]) then
            local dummy
            if SERVER then
                dummy = ents.Create("prop_physics")
                dummy:SetModel(modelData[1])
            else
                dummy = ClientsideModel(modelData[1])
            end

            local groupData = dummy:GetBodyGroups()
            for _, group in ipairs(groupData) do
                if group.id > 0 then
                    if modelData[3][group.id] then
                        groups[group.id] = modelData[3][group.id]
                    elseif modelData[3][group.name] then
                        groups[group.id] = modelData[3][group.name]
                    end
                end
            end

            dummy:Remove()
            newGroups = groups
        elseif isstring(modelData[3]) then
            newGroups = string.Explode("", modelData[3])
        end
    end

    if newGroups then
        if category then
            lia.faction.teams[name].models[category][modelIndex][3] = newGroups
            lia.faction.indices[faction.index].models[category][modelIndex][3] = newGroups
        else
            lia.faction.teams[name].models[modelIndex][3] = newGroups
            lia.faction.indices[faction.index].models[modelIndex][3] = newGroups
        end
    end
end

--[[
    Purpose:
        Formats and standardizes model data across all factions, converting bodygroup configurations to proper format.

    When Called:
        Called after faction loading to ensure all model data is properly formatted for use.

    Parameters:
        None
            This function does not return a value.

    Realm:
        Shared

    Example Usage:
        ```lua
        -- Called automatically during faction initialization
        lia.faction.formatModelData()
        ```
]]
function lia.faction.formatModelData()
    for name, faction in pairs(lia.faction.teams) do
        if faction.models then
            for modelIndex, modelData in pairs(faction.models) do
                if isstring(modelIndex) then
                    if istable(modelData) then
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
        Retrieves all model categories defined for a faction (string keys in the models table).

    When Called:
        Called when needing to display or work with faction model categories in UI or selection systems.

    Parameters:
        teamName (string)
            The unique ID of the faction.

    Returns:
        table
            An array of category names (strings) defined for the faction's models.

    Realm:
        Shared

    Example Usage:
        ```lua
        local categories = lia.faction.getCategories("citizen")
        for _, category in ipairs(categories) do
            print("Category: " .. category)
        end
        ```
]]
function lia.faction.getCategories(teamName)
    local categories = {}
    local faction = lia.faction.teams[teamName]
    if faction and faction.models then
        for key, _ in pairs(faction.models) do
            if isstring(key) then table.insert(categories, key) end
        end
    end
    return categories
end

--[[
    Purpose:
        Retrieves all models belonging to a specific category within a faction.

    When Called:
        Called when needing to display or select models from a particular category for character creation.

    Parameters:
        teamName (string)
            The unique ID of the faction.
        category (string)
            The name of the model category to retrieve.

    Returns:
        table
            A table of models in the specified category, indexed by their position.

    Realm:
        Shared

    Example Usage:
        ```lua
        local models = lia.faction.getModelsFromCategory("citizen", "male")
        for index, model in pairs(models) do
            print("Model " .. index .. ": " .. (istable(model) and model[1] or model))
        end
        ```
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
        Retrieves the default character class for a faction (marked with isDefault = true).

    When Called:
        Called when automatically assigning a class to new characters or when needing the primary class for a faction.

    Parameters:
        id (string|number)
            The faction identifier (unique ID or index).

    Returns:
        table
            The default class data table for the faction, or nil if no default class exists.

    Realm:
        Shared

    Example Usage:
        ```lua
        local defaultClass = lia.faction.getDefaultClass("citizen")
        if defaultClass then
            print("Default class: " .. defaultClass.name)
        end
        ```
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
    name = "factionStaffName",
    desc = "factionStaffDesc",
    color = Color(255, 56, 252),
    isDefault = false,
    models = {"models/player/police.mdl"},
    weapons = {"weapon_physgun", "gmod_tool", "weapon_physcannon"}
})

if CLIENT then
    --[[
    Purpose:
        Checks if the local player has whitelist access to the specified faction on the client side.

    When Called:
        Called on the client when determining if a faction should be available for character creation.

    Parameters:
        faction (string|number)
            The faction identifier (unique ID or index).

    Returns:
        boolean
            True if the player has access to the faction, false otherwise.

    Realm:
        Client

    Example Usage:
        ```lua
        if lia.faction.hasWhitelist("citizen") then
            -- Show citizen faction in character creation menu
        end
        ```
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
        Checks whitelist access for a faction on the server side (currently simplified implementation).

    When Called:
        Called on the server for faction access validation, though the current implementation is restrictive.

    Parameters:
        faction (string|number)
            The faction identifier (unique ID or index).

    Returns:
        boolean
            True only for default factions, false for all others including staff.

    Realm:
        Server

    Example Usage:
        ```lua
        -- Server-side validation
        if lia.faction.hasWhitelist("citizen") then
            -- Allow character creation
        end
        ```
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

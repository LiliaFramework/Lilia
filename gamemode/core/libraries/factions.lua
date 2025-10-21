--[[
    Faction Library

    Comprehensive faction (team) management and registration system for the Lilia framework.
]]

--[[
    Overview:
    The faction library provides comprehensive functionality for managing factions (teams) in the Lilia framework.
    It handles registration, loading, and management of faction data including models, colors, descriptions,
    and team setup. The library operates on both server and client sides, with server handling faction
    registration and client handling whitelist checks. It includes functionality for loading factions from
    directories, managing faction models with bodygroup support, and providing utilities for faction
    categorization and player management. The library ensures proper team setup and model precaching
    for all registered factions, supporting both simple string models and complex model data with
    bodygroup configurations.
]]
lia.faction = lia.faction or {}
lia.faction.indices = lia.faction.indices or {}
lia.faction.teams = lia.faction.teams or {}
local DefaultModels = {"models/player/group01/male_01.mdl", "models/player/group01/male_02.mdl", "models/player/group01/male_03.mdl", "models/player/group01/male_04.mdl", "models/player/group01/male_05.mdl", "models/player/group01/male_06.mdl", "models/player/group01/female_01.mdl", "models/player/group01/female_02.mdl", "models/player/group01/female_03.mdl", "models/player/group01/female_04.mdl", "models/player/group01/female_05.mdl", "models/player/group01/female_06.mdl"}
--[[
    Purpose: Registers a new faction with the specified unique ID and data
    When Called: During faction initialization, module loading, or when creating custom factions
    Parameters:
        - uniqueID (string): Unique identifier for the faction
        - data (table): Faction data containing name, desc, color, models, etc.
    Returns:
        - index (number): The faction's team index
        - faction (table): The complete faction data table
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Register a basic faction
    lia.faction.register("citizen", {
        name = "Citizen",
        desc = "A regular citizen",
        color = Color(150, 150, 150)
    })
    ```

    Medium Complexity:
    ```lua
    -- Medium: Register faction with custom models and weapons
    lia.faction.register("police", {
        name = "Police Officer",
        desc = "Law enforcement officer",
        color = Color(0, 0, 255),
        models = {"models/player/police.mdl"},
        weapons = {"weapon_pistol", "weapon_stunstick"},
        isDefault = false
    })
    ```

    High Complexity:
    ```lua
    -- High: Register faction with complex model data and bodygroups
    lia.faction.register("medic", {
        name = "Medical Staff",
        desc = "Emergency medical personnel",
        color = Color(255, 0, 0),
        models = {
            "male" = {
                {"models/player/medic_male.mdl", "Male Medic", {1, 2, 3}},
                {"models/player/doctor_male.mdl", "Male Doctor", {0, 1, 2}}
            },
            "female" = {
                {"models/player/medic_female.mdl", "Female Medic", {1, 2}},
                {"models/player/doctor_female.mdl", "Female Doctor", {0, 1}}
            }
        },
        weapons = {"weapon_medkit", "weapon_defibrillator"},
        isDefault = false,
        index = 5
    })
    ```
]]
--
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
    Purpose: Precaches faction models to ensure they are loaded before use
    When Called: Automatically called during faction registration, or manually when adding models
    Parameters:
        - models (table): Table of model data (strings or tables with model paths)
    Returns: None
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Cache basic string models
    lia.faction.cacheModels({"models/player/police.mdl", "models/player/swat.mdl"})
    ```

    Medium Complexity:
    ```lua
    -- Medium: Cache mixed model data types
    local models = {
        "models/player/police.mdl",
        {"models/player/swat.mdl", "SWAT Officer"},
        {"models/player/fbi.mdl", "FBI Agent", {1, 2, 3}}
    }
    lia.faction.cacheModels(models)
    ```

    High Complexity:
    ```lua
    -- High: Cache categorized models with bodygroup data
    local models = {
        "male" = {
            {"models/player/police_male.mdl", "Male Officer", {1, 2}},
            {"models/player/swat_male.mdl", "Male SWAT", {0, 1, 2, 3}}
        },
        "female" = {
            {"models/player/police_female.mdl", "Female Officer", {1}},
            {"models/player/swat_female.mdl", "Female SWAT", {0, 1, 2}}
        }
    }
    lia.faction.cacheModels(models)
    ```
]]
--
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
    Purpose: Loads all faction files from a specified directory
    When Called: During gamemode initialization to load faction files from modules or custom directories
    Parameters:
        - directory (string): Path to the directory containing faction files
    Returns: None
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Load factions from a basic directory
    lia.faction.loadFromDir("gamemode/factions")
    ```

    Medium Complexity:
    ```lua
    -- Medium: Load factions from module directory with error handling
    local factionDir = "gamemode/modules/customfactions/factions"
    if file.Exists(factionDir, "LUA") then
        lia.faction.loadFromDir(factionDir)
    end
    ```

    High Complexity:
    ```lua
    -- High: Load factions from multiple directories with validation
    local factionDirs = {
        "gamemode/factions",
        "gamemode/modules/customfactions/factions",
        "gamemode/schema/factions"
    }

    for _, dir in ipairs(factionDirs) do
        if file.Exists(dir, "LUA") then
            print("Loading factions from: " .. dir)
            lia.faction.loadFromDir(dir)
        end
    end
    ```
]]
--
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
    Purpose: Retrieves a faction by its identifier (index or uniqueID)
    When Called: When you need to get faction data by either team index or unique ID
    Parameters:
        - identifier (number/string): Either the faction's team index or unique ID
    Returns:
        - faction (table): The faction data table, or nil if not found
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Get faction by unique ID
    local faction = lia.faction.get("citizen")
    if faction then
        print("Faction name: " .. faction.name)
    end
    ```

    Medium Complexity:
    ```lua
    -- Medium: Get faction by index with validation
    local factionIndex = 1
    local faction = lia.faction.get(factionIndex)
    if faction then
        print("Faction: " .. faction.name .. " (Index: " .. faction.index .. ")")
    else
        print("Faction not found")
    end
    ```

    High Complexity:
    ```lua
    -- High: Get faction with fallback and error handling
    local function getFactionSafely(identifier)
        local faction = lia.faction.get(identifier)
        if not faction then
            if isnumber(identifier) then
                error("Faction with index " .. identifier .. " not found")
            else
                error("Faction with ID '" .. identifier .. "' not found")
            end
        end
        return faction
    end

    local faction = getFactionSafely("police")
    ```
]]
--
function lia.faction.get(identifier)
    return lia.faction.indices[identifier] or lia.faction.teams[identifier]
end

--[[
    Purpose: Gets the team index of a faction by its unique ID
    When Called: When you need to convert a faction's unique ID to its team index
    Parameters:
        - uniqueID (string): The faction's unique identifier
    Returns:
        - index (number): The faction's team index, or nil if not found
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Get faction index
    local index = lia.faction.getIndex("citizen")
    if index then
        print("Citizen faction index: " .. index)
    end
    ```

    Medium Complexity:
    ```lua
    -- Medium: Get faction index with validation
    local factionID = "police"
    local index = lia.faction.getIndex(factionID)
    if index then
        print("Faction '" .. factionID .. "' has index: " .. index)
    else
        print("Faction '" .. factionID .. "' not found")
    end
    ```

    High Complexity:
    ```lua
    -- High: Get multiple faction indices with error handling
    local factionIDs = {"citizen", "police", "medic", "staff"}
    local indices = {}

    for _, id in ipairs(factionIDs) do
        local index = lia.faction.getIndex(id)
        if index then
            indices[id] = index
        else
            print("Warning: Faction '" .. id .. "' not found")
        end
    end

    return indices
    ```
]]
--
function lia.faction.getIndex(uniqueID)
    return lia.faction.teams[uniqueID] and lia.faction.teams[uniqueID].index
end

--[[
    Purpose: Gets all classes that belong to a specific faction
    When Called: When you need to retrieve all classes associated with a faction
    Parameters:
        - faction (string/number): The faction's unique ID or team index
    Returns:
        - classes (table): Table of class objects belonging to the faction
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Get all classes for a faction
    local classes = lia.faction.getClasses("citizen")
    print("Citizen classes: " .. #classes)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Get classes with validation and display
    local factionID = "police"
    local classes = lia.faction.getClasses(factionID)
    if #classes > 0 then
        print("Classes for " .. factionID .. ":")
        for _, class in ipairs(classes) do
            print("- " .. class.name)
        end
    else
        print("No classes found for " .. factionID)
    end
    ```

    High Complexity:
    ```lua
    -- High: Get classes for multiple factions with filtering
    local function getFactionClasses(factionID)
        local faction = lia.faction.get(factionID)
        if not faction then
            return {}
        end

        local classes = lia.faction.getClasses(factionID)
        local result = {}

        for _, class in ipairs(classes) do
            if class.isDefault or not class.isDefault then -- Include all classes
                table.insert(result, {
                    name = class.name,
                    desc = class.desc,
                    isDefault = class.isDefault
                })
            end
        end

        return result
    end

    local policeClasses = getFactionClasses("police")
    ```
]]
--
function lia.faction.getClasses(faction)
    local classes = {}
    for _, class in pairs(lia.class.list) do
        if class.faction == faction then table.insert(classes, class) end
    end
    return classes
end

--[[
    Purpose: Gets all players currently in a specific faction
    When Called: When you need to retrieve all players belonging to a faction
    Parameters:
        - faction (string/number): The faction's unique ID or team index
    Returns:
        - players (table): Table of player entities in the faction
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Get all players in a faction
    local players = lia.faction.getPlayers("citizen")
    print("Citizen players: " .. #players)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Get players with validation and display
    local factionID = "police"
    local players = lia.faction.getPlayers(factionID)
    if #players > 0 then
        print("Players in " .. factionID .. ":")
        for _, ply in ipairs(players) do
            print("- " .. ply:Name())
        end
    else
        print("No players in " .. factionID)
    end
    ```

    High Complexity:
    ```lua
    -- High: Get players with additional character data
    local function getFactionPlayers(factionID)
        local players = lia.faction.getPlayers(factionID)
        local result = {}

        for _, ply in ipairs(players) do
            local char = ply:getChar()
            if char then
                table.insert(result, {
                    player = ply,
                    name = ply:Name(),
                    charName = char:getName(),
                    steamID = ply:SteamID(),
                    isAlive = ply:Alive()
                })
            end
        end

        return result
    end

    local policePlayers = getFactionPlayers("police")
    ```
]]
--
function lia.faction.getPlayers(faction)
    local players = {}
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getFaction() == faction then table.insert(players, v) end
    end
    return players
end

--[[
    Purpose: Gets the count of players currently in a specific faction
    When Called: When you need to know how many players are in a faction without getting the actual player objects
    Parameters:
        - faction (string/number): The faction's unique ID or team index
    Returns:
        - count (number): Number of players in the faction
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Get player count for a faction
    local count = lia.faction.getPlayerCount("citizen")
    print("Citizen players: " .. count)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Get player count with validation
    local factionID = "police"
    local count = lia.faction.getPlayerCount(factionID)
    if count > 0 then
        print("There are " .. count .. " players in " .. factionID)
    else
        print("No players in " .. factionID)
    end
    ```

    High Complexity:
    ```lua
    -- High: Get player counts for multiple factions with statistics
    local function getFactionStatistics()
        local factions = {"citizen", "police", "medic", "staff"}
        local stats = {}
        local totalPlayers = 0

        for _, factionID in ipairs(factions) do
            local count = lia.faction.getPlayerCount(factionID)
            stats[factionID] = count
            totalPlayers = totalPlayers + count
        end

        stats.total = totalPlayers
        return stats
    end

    local stats = getFactionStatistics()
    print("Total players: " .. stats.total)
    ```
]]
--
function lia.faction.getPlayerCount(faction)
    local count = 0
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getFaction() == faction then count = count + 1 end
    end
    return count
end

--[[
    Purpose: Checks if a faction belongs to a specific category of factions
    When Called: When you need to check if a faction is part of a group of related factions
    Parameters:
        - faction (string/number): The faction's unique ID or team index
        - categoryFactions (table): Table of faction identifiers to check against
    Returns:
        - isCategory (boolean): True if the faction is in the category, false otherwise
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Check if faction is in a category
    local lawEnforcement = {"police", "swat", "fbi"}
    local isLawEnforcement = lia.faction.isFactionCategory("police", lawEnforcement)
    print("Is police law enforcement: " .. tostring(isLawEnforcement))
    ```

    Medium Complexity:
    ```lua
    -- Medium: Check faction category with validation
    local medicalFactions = {"medic", "doctor", "paramedic"}
    local factionID = "medic"

    if lia.faction.isFactionCategory(factionID, medicalFactions) then
        print(factionID .. " is a medical faction")
    else
        print(factionID .. " is not a medical faction")
    end
    ```

    High Complexity:
    ```lua
    -- High: Check multiple factions against multiple categories
    local function categorizeFactions(factionIDs)
        local categories = {
            lawEnforcement = {"police", "swat", "fbi", "security"},
            medical = {"medic", "doctor", "paramedic", "nurse"},
            civilian = {"citizen", "businessman", "unemployed"}
        }

        local results = {}

        for _, factionID in ipairs(factionIDs) do
            local category = "unknown"
            for catName, catFactions in pairs(categories) do
                if lia.faction.isFactionCategory(factionID, catFactions) then
                    category = catName
                    break
                end
            end
            results[factionID] = category
        end

        return results
    end

    local factionCategories = categorizeFactions({"police", "medic", "citizen"})
    ```
]]
--
function lia.faction.isFactionCategory(faction, categoryFactions)
    if table.HasValue(categoryFactions, faction) then return true end
    return false
end

--[[
    Purpose: Generates a faction/job with the specified parameters (legacy compatibility function)
    When Called: For backward compatibility with older faction systems or when creating simple factions
    Parameters:
        - index (number): The team index for the faction
        - name (string): The faction's display name
        - color (Color): The faction's team color
        - default (boolean): Whether this is a default faction
        - models (table): Optional table of models for the faction
    Returns:
        - faction (table): The generated faction data table
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Generate a basic faction
    local faction = lia.faction.jobGenerate(1, "Citizen", Color(150, 150, 150), true)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Generate faction with custom models
    local models = {"models/player/police.mdl", "models/player/swat.mdl"}
    local faction = lia.faction.jobGenerate(2, "Police", Color(0, 0, 255), false, models)
    ```

    High Complexity:
    ```lua
    -- High: Generate faction with complex model data
    local function generateCustomFaction(index, name, color, isDefault)
        local models = {
            {"models/player/police_male.mdl", "Male Officer", {1, 2}},
            {"models/player/police_female.mdl", "Female Officer", {1}},
            {"models/player/swat.mdl", "SWAT Officer", {0, 1, 2, 3}}
        }

        local faction = lia.faction.jobGenerate(index, name, color, isDefault, models)
        faction.uniqueID = string.lower(name:gsub(" ", "_"))
        faction.desc = "A " .. name .. " faction"

        return faction
    end

    local policeFaction = generateCustomFaction(2, "Police Officer", Color(0, 0, 255), false)
    ```
]]
--
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
    Purpose: Formats and processes model data for all factions, converting bodygroup strings to proper format
    When Called: During faction initialization or when model data needs to be processed
    Parameters: None
    Returns: None
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Format all faction model data
    lia.faction.formatModelData()
    ```

    Medium Complexity:
    ```lua
    -- Medium: Format model data with validation
    if lia.faction.teams and table.Count(lia.faction.teams) > 0 then
        print("Formatting model data for " .. table.Count(lia.faction.teams) .. " factions")
        lia.faction.formatModelData()
        print("Model data formatting complete")
    end
    ```

    High Complexity:
    ```lua
    -- High: Format model data with progress tracking and error handling
    local function formatFactionModels()
        local factionCount = table.Count(lia.faction.teams)
        local processed = 0

        print("Starting model data formatting for " .. factionCount .. " factions")

        local success, err = pcall(lia.faction.formatModelData)

        if success then
            print("Successfully formatted model data for all factions")
        else
            print("Error formatting model data: " .. tostring(err))
        end

        return success
    end

    local success = formatFactionModels()
    ```
]]
--
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
    Purpose: Gets all model categories for a specific faction
    When Called: When you need to retrieve the model categories available for a faction
    Parameters:
        - teamName (string): The faction's unique ID
    Returns:
        - categories (table): Table of category names for the faction's models
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Get categories for a faction
    local categories = lia.faction.getCategories("police")
    print("Police categories: " .. table.concat(categories, ", "))
    ```

    Medium Complexity:
    ```lua
    -- Medium: Get categories with validation
    local factionID = "medic"
    local categories = lia.faction.getCategories(factionID)

    if #categories > 0 then
        print("Categories for " .. factionID .. ":")
        for _, category in ipairs(categories) do
            print("- " .. category)
        end
    else
        print("No categories found for " .. factionID)
    end
    ```

    High Complexity:
    ```lua
    -- High: Get categories for multiple factions with detailed info
    local function getFactionCategories(factionIDs)
        local results = {}

        for _, factionID in ipairs(factionIDs) do
            local faction = lia.faction.get(factionID)
            if faction then
                local categories = lia.faction.getCategories(factionID)
                results[factionID] = {
                    name = faction.name,
                    categories = categories,
                    categoryCount = #categories
                }
            end
        end

        return results
    end

    local factionData = getFactionCategories({"police", "medic", "citizen"})
    ```
]]
--
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
    Purpose: Gets all models from a specific category within a faction
    When Called: When you need to retrieve models from a specific category of a faction
    Parameters:
        - teamName (string): The faction's unique ID
        - category (string): The category name to get models from
    Returns:
        - models (table): Table of models in the specified category
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Get models from a category
    local models = lia.faction.getModelsFromCategory("police", "male")
    print("Male police models: " .. table.Count(models))
    ```

    Medium Complexity:
    ```lua
    -- Medium: Get models with validation
    local factionID = "medic"
    local category = "female"
    local models = lia.faction.getModelsFromCategory(factionID, category)

    if table.Count(models) > 0 then
        print("Female medic models:")
        for index, model in pairs(models) do
            print("- " .. index .. ": " .. tostring(model))
        end
    else
        print("No models found in " .. category .. " category for " .. factionID)
    end
    ```

    High Complexity:
    ```lua
    -- High: Get models from multiple categories with detailed processing
    local function getFactionModelsByCategory(factionID, categories)
        local results = {}

        for _, category in ipairs(categories) do
            local models = lia.faction.getModelsFromCategory(factionID, category)
            if table.Count(models) > 0 then
                results[category] = {}
                for index, model in pairs(models) do
                    table.insert(results[category], {
                        index = index,
                        model = model,
                        modelPath = istable(model) and model[1] or model
                    })
                end
            end
        end

        return results
    end

    local modelData = getFactionModelsByCategory("police", {"male", "female", "special"})
    ```
]]
--
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
    Purpose: Gets the default class for a specific faction
    When Called: When you need to find the default class that players spawn as in a faction
    Parameters:
        - id (string/number): The faction's unique ID or team index
    Returns:
        - defaultClass (table): The default class object, or nil if not found
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Get default class for a faction
    local defaultClass = lia.faction.getDefaultClass("citizen")
    if defaultClass then
        print("Default citizen class: " .. defaultClass.name)
    end
    ```

    Medium Complexity:
    ```lua
    -- Medium: Get default class with validation
    local factionID = "police"
    local defaultClass = lia.faction.getDefaultClass(factionID)

    if defaultClass then
        print("Default class for " .. factionID .. ": " .. defaultClass.name)
        print("Description: " .. defaultClass.desc)
    else
        print("No default class found for " .. factionID)
    end
    ```

    High Complexity:
    ```lua
    -- High: Get default classes for multiple factions with fallback handling
    local function getDefaultClasses(factionIDs)
        local results = {}

        for _, factionID in ipairs(factionIDs) do
            local defaultClass = lia.faction.getDefaultClass(factionID)
            if defaultClass then
                results[factionID] = {
                    name = defaultClass.name,
                    desc = defaultClass.desc,
                    class = defaultClass
                }
            else
                -- Fallback to first available class
                local classes = lia.faction.getClasses(factionID)
                if #classes > 0 then
                    results[factionID] = {
                        name = classes[1].name,
                        desc = classes[1].desc,
                        class = classes[1],
                        isFallback = true
                    }
                end
            end
        end

        return results
    end

    local defaultClasses = getDefaultClasses({"citizen", "police", "medic"})
    ```
]]
--
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

--[[
    Purpose: Checks if a faction has whitelist restrictions (client-side implementation)
    When Called: When checking if a player can access a faction based on whitelist status
    Parameters:
        - faction (string/number): The faction's unique ID or team index
    Returns:
        - hasWhitelist (boolean): True if the faction has whitelist restrictions, false otherwise
    Realm: Client
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Check if faction has whitelist
    local hasWhitelist = lia.faction.hasWhitelist("police")
    print("Police has whitelist: " .. tostring(hasWhitelist))
    ```

    Medium Complexity:
    ```lua
    -- Medium: Check whitelist with validation
    local factionID = "medic"
    local hasWhitelist = lia.faction.hasWhitelist(factionID)

    if hasWhitelist then
        print("Faction " .. factionID .. " requires whitelist")
    else
        print("Faction " .. factionID .. " is open to all players")
    end
    ```

    High Complexity:
    ```lua
    -- High: Check whitelist for multiple factions with detailed info
    local function checkFactionWhitelists(factionIDs)
        local results = {}

        for _, factionID in ipairs(factionIDs) do
            local faction = lia.faction.get(factionID)
            if faction then
                local hasWhitelist = lia.faction.hasWhitelist(factionID)
                results[factionID] = {
                    name = faction.name,
                    hasWhitelist = hasWhitelist,
                    isDefault = faction.isDefault,
                    canAccess = not hasWhitelist or faction.isDefault
                }
            end
        end

        return results
    end

    local whitelistInfo = checkFactionWhitelists({"citizen", "police", "medic", "staff"})
    ```
]]
--
if CLIENT then
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
    --[[
    Purpose: Checks if a faction has whitelist restrictions (server-side implementation)
    When Called: When checking if a faction has whitelist restrictions on the server
    Parameters:
        - faction (string/number): The faction's unique ID or team index
    Returns:
        - hasWhitelist (boolean): True if the faction has whitelist restrictions, false otherwise
    Realm: Server
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Check if faction has whitelist
    local hasWhitelist = lia.faction.hasWhitelist("police")
    print("Police has whitelist: " .. tostring(hasWhitelist))
    ```

    Medium Complexity:
    ```lua
    -- Medium: Check whitelist with validation
    local factionID = "medic"
    local hasWhitelist = lia.faction.hasWhitelist(factionID)

    if hasWhitelist then
        print("Faction " .. factionID .. " requires whitelist")
    else
        print("Faction " .. factionID .. " is open to all players")
    end
    ```

    High Complexity:
    ```lua
    -- High: Check whitelist for multiple factions with detailed info
    local function checkFactionWhitelists(factionIDs)
        local results = {}

        for _, factionID in ipairs(factionIDs) do
            local faction = lia.faction.get(factionID)
            if faction then
                local hasWhitelist = lia.faction.hasWhitelist(factionID)
                results[factionID] = {
                    name = faction.name,
                    hasWhitelist = hasWhitelist,
                    isDefault = faction.isDefault,
                    canAccess = not hasWhitelist or faction.isDefault
                }
            end
        end

        return results
    end

    local whitelistInfo = checkFactionWhitelists({"citizen", "police", "medic", "staff"})
    ```
]]
    --
else
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

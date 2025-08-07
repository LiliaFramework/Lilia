--[[
# Factions Library

This page documents the functions for working with faction management and team systems.

---

## Overview

The factions library provides a system for managing player factions, teams, and group affiliations within the Lilia framework. It handles faction registration, team setup, model management, and provides utilities for working with faction data. The library supports faction-specific colors, models, and metadata, and integrates with Garry's Mod's team system.
]]
lia.faction = lia.faction or {}
lia.faction.indices = lia.faction.indices or {}
lia.faction.teams = lia.faction.teams or {}
local DefaultModels = {"models/player/group01/male_01.mdl", "models/player/group01/male_02.mdl", "models/player/group01/male_03.mdl", "models/player/group01/male_04.mdl", "models/player/group01/male_05.mdl", "models/player/group01/male_06.mdl", "models/player/group01/female_01.mdl", "models/player/group01/female_02.mdl", "models/player/group01/female_03.mdl", "models/player/group01/female_04.mdl", "models/player/group01/female_05.mdl", "models/player/group01/female_06.mdl"}
--[[
    lia.faction.register

    Purpose:
        Registers a new faction with the given unique ID and data table. Handles localization, color, models, and sets up the team.
        Also precaches all faction models and stores the faction in the global indices and teams tables.

    Parameters:
        uniqueID (string) - The unique identifier for the faction.
        data (table)      - The data table containing faction properties (name, desc, color, models, etc).

    Returns:
        index (number)    - The index assigned to the faction.
        faction (table)   - The faction table that was registered.

    Realm:
        Shared.

    Example Usage:
        -- Register a new faction called "citizen"
        local index, faction = lia.faction.register("citizen", {
            name = "Citizen",
            desc = "The common people of the city.",
            color = Color(100, 150, 200),
            isDefault = true,
            models = {"models/player/group01/male_01.mdl", "models/player/group01/female_01.mdl"}
        })
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
    local overrideName = hook.Run("OverrideFactionName", uniqueID, faction.name)
    if overrideName then faction.name = overrideName end
    local overrideDesc = hook.Run("OverrideFactionDesc", uniqueID, faction.desc)
    if overrideDesc then faction.desc = overrideDesc end
    local overrideModels = hook.Run("OverrideFactionModels", uniqueID, faction.models)
    if overrideModels then faction.models = overrideModels end
    team.SetUp(faction.index, faction.name or L and L("unknown") or "unknown", faction.color or Color(125, 125, 125))
    for _, modelData in pairs(faction.models) do
        if isstring(modelData) then
            util.PrecacheModel(modelData)
        elseif istable(modelData) then
            util.PrecacheModel(modelData[1])
        end
    end

    lia.faction.indices[faction.index] = faction
    lia.faction.teams[uniqueID] = faction
    _G[constantName] = faction.index
    return faction.index, faction
end

--[[
    lia.faction.loadFromDir

    Purpose:
        Loads all faction definition files from the specified directory, registering them into lia.faction.teams and lia.faction.indices.
        Each faction file should define a FACTION table. This function ensures the faction's name, description, and color are set and localized,
        and precaches all models.

    Parameters:
        directory (string) - The directory path to search for faction files (should be relative to the gamemode).

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Load all factions from the "factions" directory
        lia.faction.loadFromDir("gamemode/schema/factions")
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

        lia.include(directory .. "/" .. v, "shared")
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
        if not FACTION.color then
            FACTION.color = Color(150, 150, 150)
            lia.error(L("factionMissingColor", niceName))
        end

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
    lia.faction.get

    Purpose:
        Retrieves a faction table by its index or unique ID.

    Parameters:
        identifier (number|string) - The faction index or unique ID.

    Returns:
        faction (table|none) - The faction table if found, or none.

    Realm:
        Shared.

    Example Usage:
        -- Get the faction table for the "staff" faction
        local staffFaction = lia.faction.get("staff")
        -- Get the faction table by index
        local factionByIndex = lia.faction.get(1)
]]
function lia.faction.get(identifier)
    return lia.faction.indices[identifier] or lia.faction.teams[identifier]
end

--[[
    lia.faction.getIndex

    Purpose:
        Retrieves the index of a faction by its unique ID.

    Parameters:
        uniqueID (string) - The unique ID of the faction.

    Returns:
        index (number|none) - The index of the faction, or nil if not found.

    Realm:
        Shared.

    Example Usage:
        -- Get the index of the "staff" faction
        local staffIndex = lia.faction.getIndex("staff")
]]
function lia.faction.getIndex(uniqueID)
    return lia.faction.teams[uniqueID] and lia.faction.teams[uniqueID].index
end

--[[
    lia.faction.getClasses

    Purpose:
        Retrieves all classes associated with a given faction.

    Parameters:
        faction (number|string) - The faction index or unique ID.

    Returns:
        classes (table) - A table of class tables belonging to the faction.

    Realm:
        Shared.

    Example Usage:
        -- Get all classes for the "staff" faction
        local staffClasses = lia.faction.getClasses("staff")
]]
function lia.faction.getClasses(faction)
    local classes = {}
    for _, class in pairs(lia.class.list) do
        if class.faction == faction then table.insert(classes, class) end
    end
    return classes
end

--[[
    lia.faction.getPlayers

    Purpose:
        Retrieves all players currently in the specified faction.

    Parameters:
        faction (number|string) - The faction index or unique ID.

    Returns:
        players (table) - A table of player objects in the faction.

    Realm:
        Shared.

    Example Usage:
        -- Get all players in the "staff" faction
        local staffPlayers = lia.faction.getPlayers("staff")
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
    lia.faction.getPlayerCount

    Purpose:
        Counts the number of players currently in the specified faction.

    Parameters:
        faction (number|string) - The faction index or unique ID.

    Returns:
        count (number) - The number of players in the faction.

    Realm:
        Shared.

    Example Usage:
        -- Get the number of players in the "staff" faction
        local staffCount = lia.faction.getPlayerCount("staff")
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
    lia.faction.isFactionCategory

    Purpose:
        Checks if a given faction is part of a specified category (list of factions).

    Parameters:
        faction (number|string)     - The faction index or unique ID.
        categoryFactions (table)    - Table of faction indices or unique IDs representing the category.

    Returns:
        isCategory (boolean)        - True if the faction is in the category, false otherwise.

    Realm:
        Shared.

    Example Usage:
        -- Check if "staff" is in the admin category
        local isAdmin = lia.faction.isFactionCategory("staff", {"staff", "admin", "superadmin"})
]]
function lia.faction.isFactionCategory(faction, categoryFactions)
    if table.HasValue(categoryFactions, faction) then return true end
    return false
end

--[[
    lia.faction.jobGenerate

    Purpose:
        Generates and registers a simple faction/job with the specified properties.

    Parameters:
        index (number)         - The index to assign to the faction.
        name (string)          - The name of the faction.
        color (Color)          - The color of the faction.
        default (boolean)      - Whether the faction is default.
        models (table|none)     - Table of model paths for the faction (optional).

    Returns:
        FACTION (table)        - The created faction table.

    Realm:
        Shared.

    Example Usage:
        -- Generate a new job/faction called "Guard"
        local guardFaction = lia.faction.jobGenerate(2, "Guard", Color(0, 100, 255), false, {"models/player/police.mdl"})
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
    lia.faction.formatModelData

    Purpose:
        Processes and formats the model data for all factions, ensuring bodygroup data is properly set up for each model.
        This is useful for advanced model customization and bodygroup support.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Format all faction model data after loading factions
        lia.faction.formatModelData()
]]
function lia.faction.formatModelData()
    for name, faction in pairs(lia.faction.teams) do
        if faction.models then
            for modelIndex, modelData in pairs(faction.models) do
                if isstring(modelIndex) then
                    for subIndex, subData in pairs(modelData) do
                        formatModelDataEntry(name, faction, subIndex, subData, modelIndex)
                    end
                else
                    formatModelDataEntry(name, faction, modelIndex, modelData)
                end
            end
        end
    end
end

--[[
    lia.faction.getCategories

    Purpose:
        Retrieves all model categories for a given faction/team name.

    Parameters:
        teamName (string) - The unique ID of the faction/team.

    Returns:
        categories (table) - A table of category names (strings).

    Realm:
        Shared.

    Example Usage:
        -- Get all model categories for the "staff" faction
        local categories = lia.faction.getCategories("staff")
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
    lia.faction.getModelsFromCategory

    Purpose:
        Retrieves all models from a specific category for a given faction/team.

    Parameters:
        teamName (string)   - The unique ID of the faction/team.
        category (string)   - The category name.

    Returns:
        models (table)      - A table of models in the specified category.

    Realm:
        Shared.

    Example Usage:
        -- Get all "male" models for the "citizen" faction
        local maleModels = lia.faction.getModelsFromCategory("citizen", "male")
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
    lia.faction.getDefaultClass

    Purpose:
        Retrieves the default class for a given faction.

    Parameters:
        id (number|string) - The faction index or unique ID.

    Returns:
        defaultClass (table|none) - The default class table, or nil if not found.

    Realm:
        Shared.

    Example Usage:
        -- Get the default class for the "staff" faction
        local defaultClass = lia.faction.getDefaultClass("staff")
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
    models = {"models/Humans/Group02/male_07.mdl", "models/Humans/Group02/male_07.mdl", "models/Humans/Group02/male_07.mdl", "models/Humans/Group02/male_07.mdl", "models/Humans/Group02/male_07.mdl",},
    weapons = {"weapon_physgun", "gmod_tool"}
})

if CLIENT then
    --[[
        lia.faction.hasWhitelist

        Purpose:
            Checks if the local player has a whitelist for the specified faction.

        Parameters:
            faction (number|string) - The faction index or unique ID.

        Returns:
            hasWhitelist (boolean)  - True if the player has a whitelist or the faction is default, false otherwise.

        Realm:
            Client.

        Example Usage:
            -- Check if the local player has access to the "staff" faction
            if lia.faction.hasWhitelist("staff") then
                print("You are whitelisted for staff!")
            end
    ]]
    function lia.faction.hasWhitelist(faction)
        local data = lia.faction.indices[faction]
        if data then
            if data.isDefault then return true end
            local liaData = lia.localData and lia.localData.whitelists or {}
            return liaData[SCHEMA.folder] and liaData[SCHEMA.folder][data.uniqueID] or false
        end
        return false
    end
end

--[[--
Helper library for loading/getting faction information.

If you are looking for the faction structure, you can find it [here](https://liliaframework.github.io/manual/structure_faction).
]]
-- @library lia.faction
lia.faction = lia.faction or {}
lia.faction.indices = lia.faction.indices or {}
lia.faction.teams = lia.faction.teams or {}
lia.faction.DefaultModels = {"models/humans/group01/male_01.mdl", "models/humans/group01/male_02.mdl", "models/humans/group01/male_04.mdl", "models/humans/group01/male_05.mdl", "models/humans/group01/male_06.mdl", "models/humans/group01/male_07.mdl", "models/humans/group01/male_08.mdl", "models/humans/group01/male_09.mdl", "models/humans/group02/male_01.mdl", "models/humans/group02/male_03.mdl", "models/humans/group02/male_05.mdl", "models/humans/group02/male_07.mdl", "models/humans/group02/male_09.mdl", "models/humans/group01/female_01.mdl", "models/humans/group01/female_02.mdl", "models/humans/group01/female_03.mdl", "models/humans/group01/female_06.mdl", "models/humans/group01/female_07.mdl", "models/humans/group02/female_01.mdl", "models/humans/group02/female_03.mdl", "models/humans/group02/female_06.mdl", "models/humans/group01/female_04.mdl"}
--- Loads factions from a directory.
-- @realm shared
-- @string directory The path to the factions files.
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

        if MODULE then FACTION.module = MODULE.uniqueID end
        lia.include(directory .. "/" .. v, "shared")
        if not FACTION.name then
            FACTION.name = "Unknown"
            ErrorNoHalt("Faction '" .. niceName .. "' is missing a name. You need to add a FACTION.name = \"Name\"\n")
        end

        if not FACTION.desc then
            FACTION.desc = "noDesc"
            ErrorNoHalt("Faction '" .. niceName .. "' is missing a description. You need to add a FACTION.desc = \"Description\"\n")
        end

        if not FACTION.color then
            FACTION.color = Color(150, 150, 150)
            ErrorNoHalt("Faction '" .. niceName .. "' is missing a color. You need to add FACTION.color = Color(1, 2, 3)\n")
        end

        team.SetUp(FACTION.index, FACTION.name or "Unknown", FACTION.color or Color(125, 125, 125))
        FACTION.models = FACTION.models or lia.faction.DefaultModels
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

--- Retrieves a faction table.
-- @realm shared
-- @int identifier Index or name of the faction
-- @treturn table Faction table
-- @usage print(lia.faction.get(Entity(1):Team()).name)
-- > "Citizen"
function lia.faction.get(identifier)
    return lia.faction.indices[identifier] or lia.faction.teams[identifier]
end

--- Retrieves a faction index.
-- @realm shared
-- @string uniqueID Unique ID of the faction
-- @treturn number Faction index
function lia.faction.getIndex(uniqueID)
    return lia.faction.teams[uniqueID] and lia.faction.teams[uniqueID].index
end

--- Returns a table containing the classes associated with a faction.
-- @realm shared
-- @int faction number The index of the faction
-- @treturn table A table containing the indices of the classes associated with the faction
function lia.faction.getClasses(faction)
    local classes = {}
    for _, class in pairs(lia.class.list) do
        if class.faction == faction then table.insert(classes, class) end
    end
    return classes
end

--- Returns a table containing the players belonging to a specific faction.
-- @realm shared
-- @int faction number The index of the faction
-- @treturn table A table containing the players belonging to the specified faction
function lia.faction.getPlayers(faction)
    local players = {}
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getFaction() == faction then table.insert(players, v) end
    end
    return players
end

--- Returns the number of players belonging to a specific faction.
-- @realm shared
-- @int faction number The index of the faction
-- @treturn number The number of players belonging to the specified faction
function lia.faction.getPlayerCount(faction)
    local count = 0
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getFaction() == faction then count = count + 1 end
    end
    return count
end

--- Checks if a given faction is part of a specified category of factions.
-- @realm shared
-- @int faction The index of the faction to check.
-- @tab categoryFactions A table containing faction indices that define the category.
-- @treturn bool True if the faction is in the category, false otherwise.
function lia.faction.isFactionCategory(faction, categoryFactions)
    if table.HasValue(categoryFactions, faction) then return true end
    return false
end

--- This function is an example of how to create a custom faction using `lia.faction.jobGenerate`. It is not recommended to use this method directly as it may lead to unexpected behavior. Instead, consider using more appropriate methods provided by the framework, such as faction files.
-- @realm shared
-- @int index The index of the faction. This should be a unique numerical identifier for the faction.
-- @string name The name of the faction.
-- @tab color The color of the faction.
-- @bool default Whether the faction is default or not.
-- @tab models The models associated with the faction.
-- @usage
-- 	lia.faction.jobGenerate(9, "Custom Faction", Color(255, 0, 0), false, {"models/player/custom_model.mdl", "models/player/custom_accessory.mdl"})
-- 	lia.faction.jobGenerate(10, "Another Custom Faction", Color(255, 255, 0), false, lia.faction.DefaultModels)
function lia.faction.jobGenerate(index, name, color, default, models)
    local FACTION = {}
    FACTION.index = index
    FACTION.isDefault = default
    FACTION.name = name
    FACTION.desc = ""
    FACTION.color = color
    FACTION.models = models or lia.faction.DefaultModels
    FACTION.uniqueID = name
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

--- Iterates through faction model data and formats the model groups.
-- This function is used to ensure consistency and correctness in model group data.
-- @realm shared
-- @internal
function lia.faction.formatModelData()
    for name, faction in pairs(lia.faction.teams) do
        if faction.models then
            for modelIndex, modelData in pairs(faction.models) do
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
                    lia.faction.teams[name].models[modelIndex][3] = newGroups
                    lia.faction.indices[faction.index].models[modelIndex][3] = newGroups
                end
            end
        end
    end
end

--- Retrieves the default class of a specified faction.
-- The default class is determined based on the faction index and the 'isDefault' flag set for each class.
-- @realm shared
-- @int id The index of the faction for which to retrieve the default class.
-- @return tab|nil Information about the default class if found, nil otherwise.
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

if CLIENT then
    --- Returns true if a faction requires a whitelist.
    -- @realm client
    -- @int faction Index of the faction
    -- @treturn bool Whether or not the faction requires a whitelist
    function lia.faction.hasWhitelist(faction)
        local data = lia.faction.indices[faction]
        if data then
            if data.isDefault then return true end
            local liaData = lia.localData and lia.localData.whitelists or {}
            return liaData[SCHEMA.folder] and liaData[SCHEMA.folder][data.uniqueID] == true or false
        end
        return false
    end
end

lia.faction = lia.faction or {}
lia.faction.indices = lia.faction.indices or {}
lia.faction.teams = lia.faction.teams or {}
lia.faction.groups = lia.faction.groups or {}
local DefaultModels = {"models/player/group01/male_01.mdl", "models/player/group01/male_02.mdl", "models/player/group01/male_03.mdl", "models/player/group01/male_04.mdl", "models/player/group01/male_05.mdl", "models/player/group01/male_06.mdl", "models/player/group01/female_01.mdl", "models/player/group01/female_02.mdl", "models/player/group01/female_03.mdl", "models/player/group01/female_04.mdl", "models/player/group01/female_05.mdl", "models/player/group01/female_06.mdl"}
local function validateFactionSpawns(spawns)
    if not spawns then return true end
    if not istable(spawns) then
        lia.log.add("Faction spawns must be a table")
        return false
    end

    for mapName, mapSpawns in pairs(spawns) do
        if not isstring(mapName) then
            lia.log.add("Map name must be a string in faction spawns")
            return false
        end

        if not istable(mapSpawns) then
            lia.log.add("Map spawns must be a table for map: " .. mapName)
            return false
        end

        for spawnIndex, spawnData in pairs(mapSpawns) do
            if not istable(spawnData) then
                lia.log.add("Spawn data must be a table for spawn " .. spawnIndex .. " on map " .. mapName)
                return false
            end

            if not spawnData.position and not spawnData.pos then
                lia.log.add("Spawn must have 'position' or 'pos' field for spawn " .. spawnIndex .. " on map " .. mapName)
                return false
            end

            local pos = spawnData.position or spawnData.pos
            if not isvector(pos) then
                lia.log.add("Spawn position must be a Vector for spawn " .. spawnIndex .. " on map " .. mapName)
                return false
            end

            if spawnData.angle or spawnData.ang then
                local ang = spawnData.angle or spawnData.ang
                if not isangle(ang) then
                    lia.log.add("Spawn angle must be an Angle for spawn " .. spawnIndex .. " on map " .. mapName)
                    return false
                end
            end
        end
    end
    return true
end

function lia.faction.register(uniqueID, data)
    assert(isstring(uniqueID), L("factionUniqueIDString"))
    assert(istable(data), L("factionDataTable"))
    if data.spawns and not validateFactionSpawns(data.spawns) then
        lia.log.add("Invalid faction spawns format for faction: " .. uniqueID .. ". Skipping spawn registration.")
        data.spawns = nil
    end

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
    team.SetUp(faction.index, faction.name or L("unknown") or "unknown", faction.color or Color(125, 125, 125))
    lia.faction.cacheModels(faction.models)
    lia.faction.indices[faction.index] = faction
    lia.faction.teams[uniqueID] = faction
    _G[constantName] = faction.index
    return faction.index, faction
end

function lia.faction.cacheModels(models)
    for _, modelData in pairs(models or {}) do
        if isstring(modelData) then
            util.PrecacheModel(modelData)
        elseif istable(modelData) then
            util.PrecacheModel(modelData[1])
        end
    end
end

function lia.faction.getBodygroupsForModel(faction, model)
    if not faction or not faction.bodygroups then return {} end
    if faction.bodygroups[model] then return faction.bodygroups[model] end
    return {}
end

function lia.faction.applyBodygroups(client, faction, model)
    if not IsValid(client) or not faction or not model then return end
    local bodygroups = lia.faction.getBodygroupsForModel(faction, model)
    if not bodygroups or table.IsEmpty(bodygroups) then return end
    for bodygroupIndex, bodygroupValue in pairs(bodygroups) do
        if isnumber(bodygroupIndex) and isnumber(bodygroupValue) then client:SetBodygroup(bodygroupIndex, bodygroupValue) end
    end
end

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

        if FACTION.spawns and not validateFactionSpawns(FACTION.spawns) then
            lia.log.add("Invalid faction spawns format for faction: " .. niceName .. ". Skipping spawn registration.")
            FACTION.spawns = nil
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

function lia.faction.get(identifier)
    return lia.faction.indices[identifier] or lia.faction.teams[identifier]
end

function lia.faction.getIndex(uniqueID)
    return lia.faction.teams[uniqueID] and lia.faction.teams[uniqueID].index
end

function lia.faction.getClasses(faction)
    local classes = {}
    for _, class in pairs(lia.class.list) do
        if class.faction == faction then table.insert(classes, class) end
    end
    return classes
end

function lia.faction.getPlayers(faction)
    local players = {}
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getFaction() == faction then table.insert(players, v) end
    end
    return players
end

function lia.faction.getPlayerCount(faction)
    local count = 0
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getFaction() == faction then count = count + 1 end
    end
    return count
end

function lia.faction.isFactionCategory(faction, categoryFactions)
    if table.HasValue(categoryFactions, faction) then return true end
    return false
end

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

function lia.faction.registerGroup(groupName, factionIDs)
    assert(isstring(groupName), "groupName must be a string")
    assert(istable(factionIDs), "factionIDs must be a table")
    if not lia.faction.groups[groupName] then lia.faction.groups[groupName] = {} end
    lia.faction.groups[groupName] = {}
    for _, factionID in ipairs(factionIDs) do
        if isstring(factionID) then
            table.insert(lia.faction.groups[groupName], factionID)
        elseif isnumber(factionID) then
            local faction = lia.faction.indices[factionID]
            if faction then table.insert(lia.faction.groups[groupName], faction.uniqueID) end
        end
    end
end

function lia.faction.getGroup(factionID)
    local factionUniqueID
    if isnumber(factionID) then
        local faction = lia.faction.indices[factionID]
        if not faction then return nil end
        factionUniqueID = faction.uniqueID
    elseif isstring(factionID) then
        factionUniqueID = factionID
    else
        return nil
    end

    for groupName, factions in pairs(lia.faction.groups) do
        for _, factionInGroup in ipairs(factions) do
            if factionInGroup == factionUniqueID then return groupName end
        end
    end
    return nil
end

function lia.faction.getFactionsInGroup(groupName)
    if not isstring(groupName) then return {} end
    return lia.faction.groups[groupName] or {}
end

FACTION_STAFF = lia.faction.register("staff", {
    name = "factionStaffName",
    desc = "factionStaffDesc",
    color = Color(255, 56, 252),
    isDefault = false,
    models = {"models/player/police.mdl"},
    weapons = {"weapon_physgun", "gmod_tool", "weapon_physcannon"}
})

FACTION_TEST = lia.faction.register("test", {
    name = "Test Faction",
    desc = "A test faction with hardcoded spawns",
    color = Color(100, 150, 200),
    isDefault = false,
    models = {"models/player/group01/male_01.mdl"},
    spawns = {
        ["rp_downtown_v4c_v2"] = {
            [1] = {
                ["position"] = Vector(100, 200, 50),
                ["angle"] = Angle(0, 90, 0),
            },
            [2] = {
                ["position"] = Vector(150, 250, 55),
                ["angle"] = Angle(0, 180, 0),
            },
        },
        ["gm_construct"] = {
            [1] = {
                ["position"] = Vector(0, 0, 0),
                ["angle"] = Angle(0, 0, 0),
            },
        },
    },
})

if CLIENT then
    function lia.faction.hasWhitelist(faction)
        local data = lia.faction.indices[faction]
        if data then
            if data.isDefault then return true end
            if faction == FACTION_STAFF then
                local hasPriv = LocalPlayer():hasPrivilege("createStaffCharacter")
                return hasPriv
            end

            local liaData = lia.localData and lia.localData.whitelists or {}
            return liaData[SCHEMA.folder] and liaData[SCHEMA.folder][data.uniqueID] or false
        end
        return false
    end
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

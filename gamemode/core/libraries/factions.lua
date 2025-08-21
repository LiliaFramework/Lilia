lia.faction = lia.faction or {}
lia.faction.indices = lia.faction.indices or {}
lia.faction.teams = lia.faction.teams or {}
local DefaultModels = {"models/player/group01/male_01.mdl", "models/player/group01/male_02.mdl", "models/player/group01/male_03.mdl", "models/player/group01/male_04.mdl", "models/player/group01/male_05.mdl", "models/player/group01/male_06.mdl", "models/player/group01/female_01.mdl", "models/player/group01/female_02.mdl", "models/player/group01/female_03.mdl", "models/player/group01/female_04.mdl", "models/player/group01/female_05.mdl", "models/player/group01/female_06.mdl"}
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

function lia.faction.cacheModels(models)
    for _, modelData in pairs(models or {}) do
        if isstring(modelData) then
            util.PrecacheModel(modelData)
        elseif istable(modelData) then
            util.PrecacheModel(modelData[1])
        end
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

FACTION_STAFF = lia.faction.register("staff", {
    name = "factionStaffName",
    desc = "factionStaffDesc",
    color = Color(255, 56, 252),
    isDefault = false,
    models = {"models/player/police.mdl",},
    weapons = {"weapon_physgun", "gmod_tool", "weapon_physcannon"}
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
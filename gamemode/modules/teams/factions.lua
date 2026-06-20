lia.faction = lia.faction or {}
lia.faction.indices = lia.faction.indices or {}
lia.faction.teams = lia.faction.teams or {}
local DefaultModels = {"models/player/group01/male_01.mdl", "models/player/group01/male_02.mdl", "models/player/group01/male_03.mdl", "models/player/group01/male_04.mdl", "models/player/group01/male_05.mdl", "models/player/group01/male_06.mdl", "models/player/group01/female_01.mdl", "models/player/group01/female_02.mdl", "models/player/group01/female_03.mdl", "models/player/group01/female_04.mdl", "models/player/group01/female_05.mdl", "models/player/group01/female_06.mdl"}
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

function lia.faction.cacheModels(models)
    for modelKey, modelData in pairs(models or {}) do
        local parsed = lia.faction.getModelData and lia.faction.getModelData(modelKey, modelData)
        if parsed and isstring(parsed.model) and parsed.model ~= "" and lia.faction.isModelUsable(parsed.model) then util.PrecacheModel(parsed.model) end
    end
end

function lia.faction.isModelUsable(modelPath)
    return isstring(modelPath) and modelPath ~= "" and (not util or not util.IsValidModel or util.IsValidModel(modelPath))
end

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

function lia.faction.getAll()
    local allFactions = {}
    for _, faction in pairs(lia.faction.teams) do
        table.insert(allFactions, faction)
    end
    return allFactions
end

function lia.faction.get(identifier)
    return lia.faction.indices[identifier] or lia.faction.teams[identifier]
end

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

function lia.faction.getAllowedSkins(faction, modelData, modelKey)
    if isnumber(faction) or isstring(faction) then faction = lia.faction.get(faction) end
    local parsed = lia.faction.getModelData(modelKey, modelData)
    if parsed and istable(parsed.allowedSkins) then return parsed.allowedSkins end
    return faction and faction.allowedSkins or nil
end

function lia.faction.getAllowedBodygroups(faction, modelData, modelKey)
    if isnumber(faction) or isstring(faction) then faction = lia.faction.get(faction) end
    local parsed = lia.faction.getModelData(modelKey, modelData)
    if parsed and istable(parsed.allowedBodygroups) then return parsed.allowedBodygroups end
    return faction and faction.allowedBodygroups or nil
end

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

function lia.faction.getCharacterCreationClass(faction, class)
    local factionData = istable(faction) and faction or lia.faction.get(faction)
    local classData = istable(class) and class or lia.class and lia.class.get and lia.class.get(class)
    if not classData and factionData then classData = lia.faction.getDefaultClass(factionData.index) end
    if not classData then return nil end
    if factionData and classData.faction ~= factionData.index then return nil end
    return classData
end

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

function lia.faction.getCharacterCreationModelChoices(faction, class)
    local source, owner, forced = lia.faction.getCharacterCreationModelSource(faction, class)
    if forced then
        return {
            [1] = source
        }, owner, true
    end
    return source or {}, owner, false
end

function lia.faction.getCharacterCreationModelInfo(faction, class, selectedModel)
    local source, owner, forced = lia.faction.getCharacterCreationModelSource(faction, class)
    if forced then return source, owner, true end
    if not istable(source) then return nil, owner, false end
    return source[selectedModel or 1], owner, false
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
    name = "@factionStaffName",
    desc = "@factionStaffDesc",
    color = Color(255, 56, 252),
    isDefault = false,
    models = {"models/player/police.mdl"},
    weapons = {"weapon_physgun", "gmod_tool", "weapon_physcannon"}
})

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

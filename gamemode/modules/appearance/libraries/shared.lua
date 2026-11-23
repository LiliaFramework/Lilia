lia.appearance = lia.appearance or {}

function lia.util.normalizeBodygroupKey(key)
    local numericKey = tonumber(key)
    if numericKey ~= nil then return numericKey end
    if isstring(key) and key ~= "" then return string.Trim(key) end
end

function lia.util.resolveBodygroupIndex(target, identifier)
    local numericIdentifier = tonumber(identifier)
    if numericIdentifier ~= nil then return numericIdentifier end
    if not IsValid(target) or not isstring(identifier) then return nil end
    local trimmedIdentifier = string.Trim(identifier)
    if trimmedIdentifier == "" then return nil end
    local directMatch = target:FindBodygroupByName(trimmedIdentifier)
    if isnumber(directMatch) and directMatch > -1 then return directMatch end
    local loweredIdentifier = string.lower(trimmedIdentifier)
    for _, groupData in ipairs(target:GetBodyGroups() or {}) do
        if isstring(groupData.name) and string.lower(groupData.name) == loweredIdentifier then return groupData.id end
    end
end

function lia.util.normalizeBodygroups(bodygroups)
    local normalized = {}
    if not istable(bodygroups) then return normalized end
    for _, entry in ipairs(bodygroups) do
        if istable(entry) then
            local index = lia.util.normalizeBodygroupKey(entry.id or entry.index or entry.bodygroup or entry.bodygroupID or entry.name or entry[1])
            local value = tonumber(entry.value or entry.val or entry[2] or 0) or 0
            if index ~= nil then normalized[index] = value end
        end
    end

    for key, value in pairs(bodygroups) do
        local index = lia.util.normalizeBodygroupKey(key)
        if index ~= nil and not istable(value) then normalized[index] = tonumber(value) or 0 end
    end
    return normalized
end

function lia.util.resolveBodygroups(target, bodygroups)
    local resolved = {}
    for identifier, value in pairs(lia.util.normalizeBodygroups(bodygroups)) do
        local index = lia.util.resolveBodygroupIndex(target, identifier)
        if index ~= nil then resolved[index] = tonumber(value) or 0 end
    end
    return resolved
end

function lia.util.applyBodygroups(target, bodygroups)
    if not IsValid(target) then return {} end
    local resolved = lia.util.resolveBodygroups(target, bodygroups)
    for index, value in pairs(resolved) do
        target:SetBodygroup(index, value)
    end
    return resolved
end

function lia.appearance.appendWardrobeModels(models, seen, source)
    if not istable(source) then return end
    for modelKey, modelData in pairs(source) do
        local parsed = lia.faction.getModelData(modelKey, modelData)
        if parsed and lia.faction.isModelUsable(parsed.model) then
            local lowered = string.lower(parsed.model)
            if not seen[lowered] then
                seen[lowered] = true
                models[#models + 1] = parsed.model
            end
        elseif istable(modelData) then
            lia.appearance.appendWardrobeModels(models, seen, modelData)
        end
    end
end

function lia.appearance.getWardrobeModels(character)
    local models = {}
    local seen = {}
    if not character then return models end
    if lia.config.get("WardrobeEnableFactionModels", true) then
        local factionData = lia.faction.indices[character:getFaction()]
        lia.appearance.appendWardrobeModels(models, seen, factionData and factionData.models)
    end

    if lia.config.get("WardrobeEnableClassModels", true) then
        local classData = lia.class.list[character:getClass()]
        lia.appearance.appendWardrobeModels(models, seen, classData and classData.models)
    end
    return models
end

function lia.appearance.isWardrobeModelAllowed(character, model)
    if not character or not isstring(model) or model == "" or not lia.faction.isModelUsable(model) then return false end
    local lowered = string.lower(model)
    for _, modelPath in ipairs(lia.appearance.getWardrobeModels(character)) do
        if string.lower(modelPath) == lowered then return true, modelPath end
    end
    return false
end

function lia.appearance.removeUser(client)
    for _, entity in ipairs(ents.FindByClass("lia_wardrobe")) do
        if IsValid(entity) and entity:HasUser(client) then entity:RemoveUser(client) end
    end
end

function lia.appearance.canAccess(client)
    if not IsValid(client) or not client:IsPlayer() then return false end
    if client:hasPrivilege("manageBodygroups") then return true end
    for _, entity in ipairs(ents.FindByClass("lia_wardrobe")) do
        if IsValid(entity) and entity:HasUser(client) and entity:GetPos():DistToSqr(client:GetPos()) <= 16384 then return true end
    end
    return false
end

function lia.appearance.openMenu(client, target, allowModelChange)
    if not IsValid(client) or not client:IsPlayer() or not IsValid(target) or not target:IsPlayer() then return end
    local character = target:getChar()
    if not character then return end
    local models = {}
    if allowModelChange and client == target then models = lia.appearance.getWardrobeModels(character) end
    net.Start("AppearanceMenuOpen")
    net.WriteEntity(target)
    net.WriteBool(allowModelChange == true and client == target)
    net.WriteTable(models)
    net.Send(client)
end

function lia.appearance.validateBodygroups(target, bodygroups)
    if not IsValid(target) or not istable(bodygroups) then return nil end
    local normalized = lia.util.normalizeBodygroups(bodygroups)
    local resolved = {}
    local count = 0
    for identifier, rawValue in pairs(normalized) do
        count = count + 1
        if count > target:GetNumBodyGroups() then return nil end
        local index = lia.util.resolveBodygroupIndex(target, identifier)
        local value = tonumber(rawValue)
        if index == nil or value == nil or value ~= math.floor(value) then return nil end
        if index < 0 or index >= target:GetNumBodyGroups() then return nil end
        local optionCount = target:GetBodygroupCount(index)
        if optionCount <= 0 or value < 0 or value >= optionCount then return nil end
        resolved[index] = value
    end
    return resolved
end

function lia.appearance.validateSelection(target, model, skin, bodygroups)
    if not IsValid(target) or not isstring(model) or model == "" then return nil end
    local validator = target
    local temporary = false
    if string.lower(target:GetModel() or "") ~= string.lower(model) then
        validator = ents.Create("prop_dynamic")
        if not IsValid(validator) then return nil end
        temporary = true
        validator:SetModel(model)
        validator:SetNoDraw(true)
        validator:SetNotSolid(true)
        validator:Spawn()
    end

    local skinCount = validator:SkinCount() or 0
    local validSkin = isnumber(skin) and skin == math.floor(skin) and skin >= 0 and ((skinCount > 0 and skin < skinCount) or (skinCount <= 0 and skin == 0))
    local validatedBodygroups = validSkin and lia.appearance.validateBodygroups(validator, bodygroups) or nil
    if temporary and IsValid(validator) then validator:Remove() end
    if not validSkin or not validatedBodygroups then return nil end
    return validatedBodygroups
end

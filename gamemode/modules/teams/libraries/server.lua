function MODULE:OnPlayerJoinClass(client, class, oldClass)
    local info = lia.class.list[class]
    local info2 = lia.class.list[oldClass]
    if info then
        if info.OnSet then info:OnSet(client) end
        if oldClass ~= class and info.OnTransferred then info:OnTransferred(client, oldClass) end
    else
        lia.error(L("invalidClassError", tostring(class)))
    end

    if info2 and info2.OnLeave then info2:OnLeave(client) end
    net.Start("classUpdate")
    net.WriteEntity(client)
    net.Broadcast()
end

function MODULE:OnTransferred(client)
    local char = client:getChar()
    if char then
        local currentClass = char:getClass()
        if currentClass then
            local classData = lia.class.list[currentClass]
            if not classData or classData.faction ~= client:Team() then char:kickClass() end
        end
    end
end

function MODULE:CanPlayerJoinClass(client, class)
    if lia.class.hasWhitelist(class) and not client:hasClassWhitelist(class) then return false end
    return true
end

function MODULE:OnCharCreated(_, character)
    local faction = lia.faction.get(character:getFaction())
    local items = faction.items or {}
    for _, item in pairs(items) do
        character:getInv():add(item, 1)
    end

    local defaultClass = lia.faction.getDefaultClass(character:getFaction())
    if defaultClass then
        character:setClass(defaultClass.index)
    else
        character:setClass(0)
    end
end

function MODULE:PlayerLoadedChar(client, character)
    if character:getData("factionKickWarn") then
        client:notifyLocalized("kickedFromFaction")
        hook.Run("OnTransferred", client)
        local faction = lia.faction.indices[client:Team()]
        if faction and faction.OnTransferred then faction:OnTransferred(client) end
        character:setData("factionKickWarn", nil)
    end

    local class = lia.class.list[character:getClass()]
    if character then
        if class and client:Team() == class.faction then
            local oldClass = character:getClass()
            timer.Simple(.3, function()
                if IsValid(client) then
                    character:setClass(class.index)
                    hook.Run("OnPlayerJoinClass", client, class.index, oldClass)
                end
            end)
        end

        if not lia.class.list[character:getClass()] then
            local defClass = lia.faction.getDefaultClass(client:Team())
            if defClass then
                character:setClass(defClass.index)
            else
                character:setClass(0)
            end
        end
    end
end

local function applyAttributes(client, attr)
    if not attr then return end
    if attr.scale then
        local offset = Vector(0, 0, 64)
        local offsetDuck = Vector(0, 0, 28)
        client:SetViewOffset(offset * attr.scale)
        client:SetViewOffsetDucked(offsetDuck * attr.scale)
        client:SetModelScale(attr.scale)
    else
        client:SetViewOffset(Vector(0, 0, 64))
        client:SetViewOffsetDucked(Vector(0, 0, 28))
        client:SetModelScale(1)
    end

    if attr.runSpeed then
        if attr.runSpeedMultiplier then
            client:SetRunSpeed(math.Round(lia.config.get("RunSpeed") * attr.runSpeed))
        else
            client:SetRunSpeed(attr.runSpeed)
        end
    end

    if attr.walkSpeed then
        if attr.walkSpeedMultiplier then
            client:SetWalkSpeed(math.Round(lia.config.get("WalkSpeed") * attr.walkSpeed))
        else
            client:SetWalkSpeed(attr.walkSpeed)
        end
    end

    if attr.jumpPower then
        if attr.jumpPowerMultiplier then
            client:SetJumpPower(math.Round(client:GetJumpPower() * attr.jumpPower))
        else
            client:SetJumpPower(attr.jumpPower)
        end
    end

    client:SetBloodColor(attr.bloodcolor or BLOOD_COLOR_RED)
    if attr.health then
        client:SetMaxHealth(attr.health)
        client:SetHealth(attr.health)
    end

    if attr.armor then client:SetArmor(attr.armor) end
    if attr.OnSpawn then attr:OnSpawn(client) end
    if attr.weapons then
        if istable(attr.weapons) then
            for _, weapon in ipairs(attr.weapons) do
                client:Give(weapon, true)
            end
        else
            client:Give(attr.weapons, true)
        end
    end
end

local function applyBodyGroups(client, bodyGroups)
    if not bodyGroups or not istable(bodyGroups) then return end
    for name, value in pairs(bodyGroups) do
        local index = client:FindBodygroupByName(name)
        if index > -1 then client:SetBodygroup(index, value) end
    end
end

function MODULE:FactionOnLoadout(client)
    local faction = lia.faction.indices[client:Team()]
    if not faction then return end
    applyAttributes(client, faction)
end

function MODULE:FactionPostLoadout(client)
    local faction = lia.faction.indices[client:Team()]
    if faction and faction.bodyGroups then applyBodyGroups(client, faction.bodyGroups) end
end

function MODULE:CanCharBeTransfered(character, faction)
    if faction.oneCharOnly then
        for _, otherCharacter in next, lia.char.loaded do
            if otherCharacter.steamID == character.steamID and faction.index == otherCharacter:getFaction() then return false, L("charAlreadyInFaction") end
        end
    end
end

function MODULE:OnEntityCreated(entity)
    if entity:IsNPC() then
        for _, client in player.Iterator() do
            local character = client:getChar()
            if not character then return end
            local faction = lia.faction.indices[character:getFaction()]
            if faction and faction.NPCRelations then entity:AddEntityRelationship(client, faction.NPCRelations[entity:GetClass()] or D_HT, 0) end
        end
    end
end

function MODULE:PlayerSpawn(client)
    local character = client:getChar()
    if not character then return end
    local faction = lia.faction.indices[character:getFaction()]
    local relations = faction and faction.NPCRelations
    if relations then
        for _, entity in ents.Iterator() do
            if entity:IsNPC() and relations[entity:GetClass()] then entity:AddEntityRelationship(client, relations[entity:GetClass()], 0) end
        end
    else
        for _, entity in ents.Iterator() do
            if entity:IsNPC() then entity:AddEntityRelationship(client, D_HT, 0) end
        end
    end
end

function MODULE:ClassOnLoadout(client)
    local character = client:getChar()
    local class = lia.class.list[character:getClass()]
    if not class then return end
    applyAttributes(client, class)
    if class.model then client:SetModel(class.model) end
end

function MODULE:ClassPostLoadout(client)
    local character = client:getChar()
    local class = lia.class.list[character:getClass()]
    if class and class.bodyGroups then applyBodyGroups(client, class.bodyGroups) end
end

function MODULE:CanPlayerUseChar(client, character)
    local faction = lia.faction.indices[character:getFaction()]
    if faction and hook.Run("CheckFactionLimitReached", faction, character, client) then return false, L("limitFaction") end
end

function MODULE:CanPlayerSwitchChar(client, _, newCharacter)
    local faction = lia.faction.indices[newCharacter:getFaction()]
    if self:CheckFactionLimitReached(faction, newCharacter, client) then return false, L("limitFaction") end
end

net.Receive("KickCharacter", function(_, client)
    local char = client:getChar()
    local canManageAny = client:hasPrivilege(L("canManageFactions"))
    local canKick = char and char:hasFlags("K")
    if not canKick and not canManageAny then return end
    local defaultFaction
    for _, fac in pairs(lia.faction.teams) do
        if fac.isDefault then
            defaultFaction = fac
            break
        end
    end

    if not defaultFaction then
        local _, fac = next(lia.faction.teams)
        defaultFaction = fac
    end

    local characterID = net.ReadUInt(32)
    local isOnline = false
    for _, target in player.Iterator() do
        local targetChar = target:getChar()
        if targetChar and targetChar:getID() == characterID and (canManageAny or canKick and char and targetChar:getFaction() == char:getFaction()) then
            isOnline = true
            local oldFaction = targetChar:getFaction()
            local oldFactionData = lia.faction.indices[oldFaction]
            if oldFactionData and oldFactionData.isDefault then return end
            target:notifyLocalized("kickedFromFaction")
            targetChar.vars.faction = defaultFaction.uniqueID
            targetChar:setFaction(defaultFaction.index)
            hook.Run("OnTransferred", target)
            if defaultFaction.OnTransferred then defaultFaction:OnTransferred(target, oldFaction) end
            hook.Run("PlayerLoadout", target)
            targetChar:save()
        end
    end

    if not isOnline then
        lia.db.query("SELECT faction FROM lia_characters WHERE id = " .. characterID, function(data)
            if not data or not data[1] then return end
            local oldFactionID = data[1].faction
            local oldFactionData = lia.faction.teams[oldFactionID]
            if oldFactionData and oldFactionData.isDefault then return end
            lia.db.updateTable({
                faction = defaultFaction.uniqueID
            }, nil, "characters", "id = " .. characterID)

            lia.char.setCharData(characterID, "factionKickWarn", true)
        end)
    end
end)
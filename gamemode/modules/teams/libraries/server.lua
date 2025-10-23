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
    net.Start("liaClassUpdate")
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
    if lia.class.hasWhitelist(class) and not client:getChar():getClasswhitelists()[class] then return false end
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
        client:notifyWarningLocalized("kickedFromFaction")
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
    if attr.NPCRelations then
        for _, entity in ents.Iterator() do
            if entity:IsNPC() and relations[entity:GetClass()] then entity:AddEntityRelationship(client, relations[entity:GetClass()], 0) end
        end
    else
        for _, entity in ents.Iterator() do
            if entity:IsNPC() then entity:AddEntityRelationship(client, D_HT, 0) end
        end
    end

    if attr.scale then
        local offset = Vector(0, 0, 64)
        local offsetDuck = Vector(0, 0, 28)
        client:SetViewOffset(offset * attr.scale)
        client:SetViewOffsetDucked(offsetDuck * attr.scale)
        client:SetModelScale(attr.scale)
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

function MODULE:CanCharBeTransfered(character, faction)
    if faction.oneCharOnly then
        for _, otherCharacter in next, lia.char.getAll() do
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

function MODULE:PlayerLoadout(client)
    local character = client:getChar()
    if not character then return end
    local faction = lia.faction.indices[character:getFaction()]
    timer.Simple(0.2, function()
        if IsValid(client) then applyAttributes(client, faction) end
        timer.Simple(0.1, function()
            if IsValid(client) then
                local class = lia.class.list[character:getClass()]
                if class then
                    applyAttributes(client, class)
                    if class.model and isstring(class.model) then client:SetModel(class.model) end
                end
            end
        end)
    end)
end

function MODULE:CanPlayerUseChar(client, character)
    local faction = lia.faction.indices[character:getFaction()]
    if faction and hook.Run("CheckFactionLimitReached", faction, character, client) then return false, L("limitFaction") end
end

function MODULE:CanPlayerSwitchChar(client, _, newCharacter)
    local faction = lia.faction.indices[newCharacter:getFaction()]
    if self:CheckFactionLimitReached(faction, newCharacter, client) then return false, L("limitFaction") end
end
function MODULE:OnPlayerJoinClass(client, class, oldClass)
    local info = lia.class.list[class]
    local info2 = lia.class.list[oldClass]
    if info then
        if info.OnSet then info:OnSet(client) end
        if oldClass ~= class and info.OnTransferred then info:OnTransferred(client, oldClass) end
    else
        print(L("invalidClassError", tostring(class)))
    end

    if info2 and info2.OnLeave then info2:OnLeave(client) end
    netstream.Start(nil, "classUpdate", client)
end

function MODULE:CanPlayerJoinClass(client, class)
    if lia.class.hasWhitelist(class) and not client:hasClassWhitelist(class) then return false end
    return true
end

function MODULE:PlayerLoadedChar(client, character)
    local data = character:getData("pclass")
    local class = data and lia.class.list[data]
    if character then
        if class and data then
            local oldClass = character:getClass()
            if client:Team() == class.faction then
                timer.Simple(.3, function()
                    character:setClass(class.index)
                    hook.Run("OnPlayerJoinClass", client, class.index, oldClass)
                    return
                end)
            end
        end

        for _, v in pairs(lia.class.list) do
            if v.faction == client:Team() and v.isDefault then
                character:setClass(v.index)
                break
            end
        end
    end
end

function MODULE:FactionOnLoadout(client)
    local faction = lia.faction.indices[client:Team()]
    if not faction then return end
    if faction.scale then
        local scaleViewFix = faction.scale
        local scaleViewFixOffset = Vector(0, 0, 64)
        local scaleViewFixOffsetDuck = Vector(0, 0, 28)
        client:SetViewOffset(scaleViewFixOffset * faction.scale)
        client:SetViewOffsetDucked(scaleViewFixOffsetDuck * faction.scale)
        client:SetModelScale(scaleViewFix)
    else
        client:SetViewOffset(Vector(0, 0, 64))
        client:SetViewOffsetDucked(Vector(0, 0, 28))
        client:SetModelScale(1)
    end

    if faction.runSpeed then
        if faction.runSpeedMultiplier then
            client:SetRunSpeed(math.Round(lia.config.get("RunSpeed") * faction.runSpeed))
        else
            client:SetRunSpeed(faction.runSpeed)
        end
    end

    if faction.walkSpeed then
        if faction.walkSpeedMultiplier then
            client:SetWalkSpeed(math.Round(lia.config.get("WalkSpeed") * faction.walkSpeed))
        else
            client:SetWalkSpeed(faction.walkSpeed)
        end
    end

    if faction.jumpPower then
        if faction.jumpPowerMultiplier then
            client:SetJumpPower(math.Round(client:GetJumpPower() * faction.jumpPower))
        else
            client:SetJumpPower(faction.jumpPower)
        end
    end

    if faction.bloodcolor then
        client:SetBloodColor(faction.bloodcolor)
    else
        client:SetBloodColor(BLOOD_COLOR_RED)
    end

    if faction.health then
        client:SetMaxHealth(faction.health)
        client:SetHealth(faction.health)
    end

    if faction.armor then client:SetArmor(faction.armor) end
    if faction.OnSpawn then faction:OnSpawn(client) end
    if faction.weapons then
        if istable(faction.weapons) then
            for _, v in ipairs(faction.weapons) do
                client:Give(v, true)
            end
        else
            client:Give(faction.weapons, true)
        end
    end
end

function MODULE:FactionPostLoadout(client)
    local faction = lia.faction.indices[client:Team()]
    if not faction then return end
    if faction.bodyGroups and istable(faction.bodyGroups) then
        local groups = {}
        for k, value in pairs(faction.bodyGroups) do
            local index = client:FindBodygroupByName(k)
            if index > -1 then groups[index] = value end
        end

        for index, value in pairs(groups) do
            client:SetBodygroup(index, value)
        end
    end
end

function MODULE:CanCharBeTransfered(character, faction)
    if faction.oneCharOnly then
        for _, otherCharacter in next, lia.char.loaded do
            if otherCharacter.steamID == character.steamID and faction.index == otherCharacter:getFaction() then return false, L("charAlreadyInFaction") end
        end
    end
end

function MODULE:ClassOnLoadout(client)
    local character = client:getChar()
    local class = lia.class.list[character:getClass()]
    if not class then return end
    if class.None then return end
    if class.scale then
        local scaleViewFix = class.scale
        local scaleViewFixOffset = Vector(0, 0, 64)
        local scaleViewFixOffsetDuck = Vector(0, 0, 28)
        client:SetViewOffset(scaleViewFixOffset * class.scale)
        client:SetViewOffsetDucked(scaleViewFixOffsetDuck * class.scale)
        client:SetModelScale(scaleViewFix)
    else
        client:SetViewOffset(Vector(0, 0, 64))
        client:SetViewOffsetDucked(Vector(0, 0, 28))
        client:SetModelScale(1)
    end

    if class.runSpeed then
        if class.runSpeedMultiplier then
            client:SetRunSpeed(math.Round(lia.config.get("RunSpeed") * class.runSpeed))
        else
            client:SetRunSpeed(class.runSpeed)
        end
    end

    if class.walkSpeed then
        if class.walkSpeedMultiplier then
            client:SetWalkSpeed(math.Round(lia.config.get("WalkSpeed") * class.walkSpeed))
        else
            client:SetWalkSpeed(class.walkSpeed)
        end
    end

    if class.jumpPower then
        if class.jumpPowerMultiplier then
            client:SetJumpPower(math.Round(client:GetJumpPower() * class.jumpPower))
        else
            client:SetJumpPower(class.jumpPower)
        end
    end

    if class.bloodcolor then
        client:SetBloodColor(class.bloodcolor)
    else
        client:SetBloodColor(BLOOD_COLOR_RED)
    end

    if class.health then
        client:SetMaxHealth(class.health)
        client:SetHealth(class.health)
    end

    if class.model then client:SetModel(class.model) end
    if class.armor then client:SetArmor(class.armor) end
    if class.OnSpawn then class:OnSpawn(client) end
    if class.weapons then
        if istable(class.weapons) then
            for _, v in ipairs(class.weapons) do
                client:Give(v, true)
            end
        else
            client:Give(class.weapons, true)
        end
    end
end

function MODULE:ClassPostLoadout(client)
    local character = client:getChar()
    local class = lia.class.list[character:getClass()]
    if class and class.bodyGroups and istable(class.bodyGroups) then
        local groups = {}
        for k, value in pairs(class.bodyGroups) do
            local index = client:FindBodygroupByName(k)
            if index > -1 then groups[index] = value end
        end

        for index, value in pairs(groups) do
            client:SetBodygroup(index, value)
        end
    end
end

function MODULE:CanPlayerUseChar(client, character)
    local faction = lia.faction.indices[character:getFaction()]
    if faction and hook.Run("CheckFactionLimitReached", faction, character, client) then return false, L("limitFaction") end
end

function MODULE:CanPlayerSwitchChar(client, _, newCharacter)
    local faction = lia.faction.indices[newCharacter:getFaction()]
    if self:CheckFactionLimitReached(faction, newCharacter, client) then return false, L("limitFaction") end
end

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
    if not char then return end
    local isLeader = client:IsSuperAdmin() or char:getData("factionOwner") or char:getData("factionAdmin") or char:hasFlags("V")
    if not isLeader then return end
    local citizen = lia.faction.teams["citizen"]
    local characterID = net.ReadUInt(32)
    local IsOnline = false
    for _, target in player.Iterator() do
        local targetChar = target:getChar()
        if targetChar and targetChar:getID() == characterID and targetChar:getFaction() == char:getFaction() then
            IsOnline = true
            target:notify("You were kicked from your faction!")
            targetChar.vars.faction = citizen.uniqueID
            targetChar:setFaction(citizen.index)
        end
    end

    if not IsOnline then lia.char.setCharData(characterID, "kickedFromFaction", true) end
end)
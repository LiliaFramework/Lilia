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
    local offset = Vector(0, 0, 64)
    local offsetDuck = Vector(0, 0, 28)
    client:SetViewOffset(offset)
    client:SetViewOffsetDucked(offsetDuck)
    client:SetModelScale(1)
    if attr.NPCRelations then
        for _, entity in ents.Iterator() do
            if entity:IsNPC() and attr.NPCRelations[entity:GetClass()] then entity:AddEntityRelationship(client, attr.NPCRelations[entity:GetClass()], 0) end
        end
    else
        for _, entity in ents.Iterator() do
            if entity:IsNPC() then entity:AddEntityRelationship(client, D_HT, 0) end
        end
    end

    if attr.scale and attr.scale ~= 1 then
        client:SetViewOffset(offset * attr.scale)
        client:SetViewOffsetDucked(offsetDuck * attr.scale)
        client:SetModelScale(attr.scale)
    end

    local configRunSpeed = lia.config.get("RunSpeed")
    local configWalkSpeed = lia.config.get("WalkSpeed")
    if attr.runSpeed then
        if attr.runSpeedMultiplier then
            client:SetRunSpeed(math.Round(configRunSpeed * attr.runSpeed))
        else
            client:SetRunSpeed(attr.runSpeed)
        end
    else
        client:SetRunSpeed(configRunSpeed)
    end

    if attr.walkSpeed then
        if attr.walkSpeedMultiplier then
            client:SetWalkSpeed(math.Round(configWalkSpeed * attr.walkSpeed))
        else
            client:SetWalkSpeed(attr.walkSpeed)
        end
    else
        client:SetWalkSpeed(configWalkSpeed)
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

function MODULE:PostPlayerLoadout(client)
    local character = client:getChar()
    if not character then return end
    local faction = lia.faction.indices[character:getFaction()]
    local class = lia.class.list[character:getClass()]
    timer.Simple(0.2, function()
        if IsValid(client) then
            local mergedAttr = {}
            if faction then
                for k, v in pairs(faction) do
                    mergedAttr[k] = v
                end
            end

            if class then
                for k, v in pairs(class) do
                    mergedAttr[k] = v
                end

                if class.model and isstring(class.model) then client:SetModel(class.model) end
            end

            applyAttributes(client, mergedAttr)
        end
    end)
end

function MODULE:CanPlayerUseChar(client, character)
    local faction = lia.faction.indices[character:getFaction()]
    if faction and hook.Run("CheckFactionLimitReached", faction, character, client) then return false, L("limitFaction") end
end

function MODULE:CanPlayerSwitchChar(client, currentCharacter, newCharacter)
    local faction = lia.faction.indices[newCharacter:getFaction()]
    if self:CheckFactionLimitReached(faction, newCharacter, client) then return false, L("limitFaction") end
end

net.Receive("liaRequestFactionMembers", function(_, client)
    if not client:hasPrivilege("listCharacters") then return end
    local factionUniqueID = net.ReadString()
    if not factionUniqueID or factionUniqueID == "" then return end
    local faction = lia.faction.get(factionUniqueID)
    if not faction then return end
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local query = string.format([[
        SELECT c.id, c.name, c.lastJoinTime, c.steamID
        FROM lia_characters AS c
        WHERE c.faction = %s AND c.schema = %s
        ORDER BY c.lastJoinTime DESC
    ]], lia.db.convertDataType(factionUniqueID), lia.db.convertDataType(gamemode))
    lia.db.query(query, function(data)
        local members = {}
        for _, row in ipairs(data or {}) do
            local lastOnlineText
            local owner = lia.char.getOwnerByID(row.id)
            if not IsValid(owner) and row.steamID then
                local ply = player.GetBySteamID(tostring(row.steamID))
                if IsValid(ply) and ply:getChar() and ply:getChar():getID() == row.id then owner = ply end
            end

            if IsValid(owner) and owner:getChar() and owner:getChar():getID() == row.id then
                lastOnlineText = L("onlineNow")
            else
                lastOnlineText = row.lastJoinTime or L("unknown")
            end

            table.insert(members, {
                name = row.name or L("unknown"),
                lastOnline = lastOnlineText,
                charID = row.id,
                steamID = row.steamID
            })
        end

        lia.net.writeBigTable(client, "liaFactionMembers", {
            faction = factionUniqueID,
            members = members
        })
    end)
end)

net.Receive("liaKickCharacterToBase", function(_, client)
    if not client:hasPrivilege("canManageFactions") then return end
    local characterID = net.ReadUInt(32)
    local defaultFaction
    for _, fac in pairs(lia.faction.teams) do
        if fac.isDefault and fac.uniqueID ~= "staff" then
            defaultFaction = fac
            break
        end
    end

    if not defaultFaction then
        for _, fac in pairs(lia.faction.teams) do
            if fac.uniqueID ~= "staff" then
                defaultFaction = fac
                break
            end
        end
    end

    if not defaultFaction then
        local _, fac = next(lia.faction.teams)
        defaultFaction = fac
    end

    if not defaultFaction then
        client:notifyErrorLocalized("invalidFaction")
        return
    end

    local isOnline = false
    for _, target in player.Iterator() do
        local targetChar = target:getChar()
        if targetChar and targetChar:getID() == characterID then
            isOnline = true
            local oldFaction = targetChar:getFaction()
            local oldFactionData = lia.faction.indices[oldFaction]
            if oldFactionData and oldFactionData.isDefault then
                client:notifyErrorLocalized("alreadyInBaseFaction")
                return
            end

            if hook.Run("CanCharBeTransfered", targetChar, defaultFaction, oldFaction) == false then return end
            target:notifyWarningLocalized("kickedFromFaction")
            targetChar.vars.faction = defaultFaction.uniqueID
            targetChar:setFaction(defaultFaction.index)
            hook.Run("OnTransferred", target)
            if defaultFaction.OnTransferred then defaultFaction:OnTransferred(target, oldFaction) end
            hook.Run("PlayerLoadout", target)
            targetChar:save()
            client:notifySuccessLocalized("transferSuccess", target:Name(), L(defaultFaction.name))
            lia.log.add(client, "kickToBaseFaction", target:Name(), oldFactionData and oldFactionData.name or tostring(oldFaction), defaultFaction.name)
        end
    end

    if not isOnline then
        lia.db.query("SELECT faction FROM lia_characters WHERE id = " .. characterID):next(function(data)
            if not data or not data[1] then
                client:notifyErrorLocalized("characterNotFound")
                return
            end

            local currentFaction = data[1].faction
            local currentFactionData = lia.faction.get(currentFaction)
            if currentFactionData and currentFactionData.isDefault then
                client:notifyErrorLocalized("alreadyInBaseFaction")
                return
            end

            lia.db.updateTable({
                faction = defaultFaction.uniqueID
            }, nil, "characters", "id = " .. characterID)

            client:notifySuccessLocalized("transferSuccess", L("character"), L(defaultFaction.name))
            lia.log.add(client, "kickToBaseFaction", L("character"), currentFactionData and currentFactionData.name or tostring(currentFaction), defaultFaction.name)
        end)
    end
end)

lia.command.add("speed", {
    desc = "Check your current movement speeds.",
    onRun = function(client)
        client:notify(string.format("Current speeds - Run: %d, Walk: %d", client:GetRunSpeed(), client:GetWalkSpeed()))
        return ""
    end
})

local MODULE = MODULE
net.Receive("liaRequestFactionMembers", function(_, client)
    local factionUniqueID = net.ReadString()
    if not factionUniqueID or factionUniqueID == "" then return end
    lia.debug("[Permissions]", "Permission Check for net.Receive liaRequestFactionMembers", "hasFactionRosterAccess=", tostring(MODULE:CanAccessFactionRoster(client, factionUniqueID)))
    if not MODULE:CanAccessFactionRoster(client, factionUniqueID) then return end
    MODULE:SendFactionMembers(client, factionUniqueID)
end)

net.Receive("liaRequestFactionMemberDetails", function(_, client)
    local factionUniqueID = net.ReadString()
    local charID = net.ReadUInt(32)
    if not factionUniqueID or factionUniqueID == "" or not charID or charID == 0 then return end
    if not MODULE:CanAccessFactionRoster(client, factionUniqueID) then return end
    MODULE:SendFactionMemberDetails(client, factionUniqueID, charID)
end)

net.Receive("liaKickCharacterToBase", function(_, client)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaKickCharacterToBase", "hasPrivilege(canManageFactions)=", tostring(client:hasPrivilege("canManageFactions")), "finalResult=", tostring(client:hasPrivilege("canManageFactions")))
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
            MODULE:TrackFactionTransfer(targetChar, oldFaction, defaultFaction, client, "kickToBase")
            targetChar.vars.faction = defaultFaction.uniqueID
            targetChar:setFaction(defaultFaction.index)
            hook.Run("OnTransferred", target)
            if defaultFaction.OnTransferred then defaultFaction:OnTransferred(target, oldFaction) end
            hook.Run("PlayerLoadout", target)
            targetChar:save()
            client:notifySuccessLocalized("transferSuccess", target:Name(), defaultFaction.name)
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

            MODULE:TrackOfflineFactionTransfer(characterID, currentFaction, defaultFaction, client, "kickToBase")
            lia.db.updateTable({
                faction = defaultFaction.uniqueID
            }, nil, "characters", "id = " .. characterID)

            client:notifySuccessLocalized("transferSuccess", L("character"), defaultFaction.name)
            lia.log.add(client, "kickToBaseFaction", L("character"), currentFactionData and currentFactionData.name or tostring(currentFaction), defaultFaction.name)
        end)
    end
end)

net.Receive("liaSaveFactionNote", function(_, client)
    local charID = tonumber(net.ReadUInt(32))
    local factionUniqueID = net.ReadString()
    local noteText = string.Trim(net.ReadString() or "")
    if not charID or not factionUniqueID or factionUniqueID == "" then return end
    if not MODULE:CanEditFactionNotes(client, factionUniqueID) then return end
    if #noteText > 4096 then noteText = noteText:sub(1, 4096) end
    local faction = lia.faction.get(factionUniqueID)
    if not faction then return end
    local loadedCharacter = lia.char.loaded[charID]
    local function saveNote()
        local noteData = noteText ~= "" and {
            text = noteText,
            updatedAt = os.time(),
            updatedBy = client:Name(),
            updatedBySteamID = client:SteamID()
        } or nil

        if loadedCharacter then
            local notesByFaction = loadedCharacter:getData("factionNotes", {})
            if not istable(notesByFaction) then notesByFaction = {} end
            notesByFaction[factionUniqueID] = noteData
            if noteData == nil and table.IsEmpty(notesByFaction) then
                loadedCharacter:setData("factionNotes", nil)
            else
                loadedCharacter:setData("factionNotes", notesByFaction)
            end
        else
            local notesByFaction = lia.char.getCharData(charID, "factionNotes")
            if not istable(notesByFaction) then notesByFaction = {} end
            notesByFaction[factionUniqueID] = noteData
            if noteData == nil and table.IsEmpty(notesByFaction) then
                lia.char.setCharDatabase(charID, "factionNotes", nil)
            else
                lia.char.setCharDatabase(charID, "factionNotes", notesByFaction)
            end
        end

        MODULE:SendFactionMemberDetails(client, factionUniqueID, charID)
    end

    if loadedCharacter then
        if loadedCharacter:getFaction() ~= faction.index then return end
        saveNote()
        return
    end

    lia.db.query("SELECT faction FROM lia_characters WHERE id = " .. charID, function(data)
        if not data or not data[1] or data[1].faction ~= faction.uniqueID then return end
        saveNote()
    end)
end)

function MODULE:PlayerLiliaDataLoaded(client)
    lia.char.restore(client, function(charList)
        if not IsValid(client) then return end
        lia.information(L("loadedCharacters", table.concat(charList, ", "), client:Name()))
        for _, v in ipairs(charList) do
            lia.char.getCharacter(v, client, function(character) if character then character:sync(client) end end)
        end

        for _, v in player.Iterator() do
            if v:getChar() then v:getChar():sync(client) end
        end

        client.liaCharList = charList
        self:SyncCharList(client)
        client.liaLoaded = true
    end)
end

function MODULE:CanPlayerUseChar(_, character)
    if character:isBanned() then return false, L("permaKilledCharacter") end
    return true
end

function MODULE:CanPlayerSwitchChar(client, character, newCharacter)
    if character:getID() == newCharacter:getID() then return false, L("alreadyUsingCharacter") end
    if character:isBanned() then return false, L("permaKilledCharacter") end
    if not client:Alive() then return false, L("youAreDead") end
    if IsValid(client:getNetVar("ragdoll")) then return false, L("youAreRagdolled") end
    if IsValid(client:GetVehicle()) then return false, L("cannotSwitchInVehicle") end
    return true
end

function MODULE:PlayerLoadedChar(client, character)
    local charID = character:getID()
    lia.db.query("SELECT key, value FROM lia_chardata WHERE charID = " .. charID, function(data)
        data = data or {}
        if not character.dataVars then character.dataVars = {} end
        for _, row in ipairs(data) do
            local decodedValue = pon.decode(row.value)
            character.dataVars[row.key] = decodedValue[1]
            character:setData(row.key, decodedValue[1])
        end

        local characterData = character:getData()
        local keysToNetwork = table.GetKeys(characterData)
        net.Start("liaCharacterData")
        net.WriteUInt(charID, 32)
        net.WriteUInt(#keysToNetwork, 32)
        for _, key in ipairs(keysToNetwork) do
            local value = characterData[key]
            net.WriteString(key)
            net.WriteType(value)
        end

        net.Send(client)
    end)

    client:Spawn()
end
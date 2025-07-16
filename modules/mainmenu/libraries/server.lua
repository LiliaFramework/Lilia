function MODULE:PlayerLiliaDataLoaded(client)
    lia.char.restore(client, function(charList)
        if not IsValid(client) then return end
        MsgN(L("loadedCharacters", table.concat(charList, ", "), client:Name()))
        for _, v in ipairs(charList) do
            if lia.char.loaded[v] then lia.char.loaded[v]:sync(client) end
        end

        for _, v in player.Iterator() do
            if v:getChar() then v:getChar():sync(client) end
        end

        client.liaCharList = charList
        self:syncCharList(client)
        client.liaLoaded = true
    end)
end

function MODULE:CanPlayerUseChar(_, character)
    local banned = character:getData("banned")
    if banned and isnumber(banned) and banned > os.time() then return false, L("bannedCharacter") end
    return true
end

function MODULE:CanPlayerSwitchChar(client, character, newCharacter)
    local banned = character:getData("banned")
    if character:getID() == newCharacter:getID() then return false, L("alreadyUsingCharacter") end
    if banned and isnumber(banned) and banned > os.time() then return false, L("bannedCharacter") end
    if not client:Alive() then return false, L("youAreDead") end
    if client:hasRagdoll() then return false, L("youAreRagdolled") end
    if client:hasValidVehicle() then return false, L("cannotSwitchInVehicle") end
    return true
end

function MODULE:PlayerLoadedChar(client)
    client:Spawn()
end

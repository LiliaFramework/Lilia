net.Receive("liaCharChoose", function(_, client)
    local function response(message)
        net.Start("liaCharChoose")
        net.WriteString(L(message or "", client))
        net.Send(client)
    end

    local id = net.ReadUInt(32)
    local currentChar = client:getChar()
    if not lia.char.isLoaded(id) then
        if not table.HasValue(client.liaCharList or {}, id) then return response(false, "invalidChar") end
        lia.char.loadSingleCharacter(id, client, function(character)
            if not character then return response(false, "invalidChar") end
            local status, result = hook.Run("CanPlayerUseChar", client, character)
            if status == false then
                if result[1] == "@" then result = result:sub(2) end
                return response(result)
            end

            if currentChar then
                status, result = hook.Run("CanPlayerSwitchChar", client, currentChar, character)
                if status == false then
                    if result[1] == "@" then result = result:sub(2) end
                    return response(result)
                end

                currentChar:save()
            end

            local unloadedCount = lia.char.unloadUnusedCharacters(client, id)
            if unloadedCount > 0 then lia.information(L("unloadedUnusedCharacters", unloadedCount, client:Name())) end
            hook.Run("PrePlayerLoadedChar", client, character, currentChar)
            character:setup()
            hook.Run("PlayerLoadedChar", client, character, currentChar)
            response()
            hook.Run("PostPlayerLoadedChar", client, character, currentChar)
        end)
        return
    end

    local character = lia.char.getCharacter(id, client)
    if not character or character:getPlayer() ~= client then return response(false, "invalidChar") end
    local status, result = hook.Run("CanPlayerUseChar", client, character)
    if status == false then
        if result[1] == "@" then result = result:sub(2) end
        return response(result)
    end

    if currentChar then
        status, result = hook.Run("CanPlayerSwitchChar", client, currentChar, character)
        if status == false then
            if result[1] == "@" then result = result:sub(2) end
            return response(result)
        end

        currentChar:save()
    end

    local unloadedCount = lia.char.unloadUnusedCharacters(client, id)
    if unloadedCount > 0 then lia.information(L("unloadedUnusedCharacters", unloadedCount, client:Name())) end
    hook.Run("PrePlayerLoadedChar", client, character, currentChar)
    character:setup()
    hook.Run("PlayerLoadedChar", client, character, currentChar)
    response()
    hook.Run("PostPlayerLoadedChar", client, character, currentChar)
end)

net.Receive("liaCharCreate", function(_, client)
    local function response(id, message, ...)
        net.Start("liaCharCreate")
        net.WriteUInt(id or 0, 32)
        net.WriteString(L(message or "", client, ...))
        net.Send(client)
    end

    local numValues = net.ReadUInt(32)
    local data = {}
    for _ = 1, numValues do
        data[net.ReadString()] = net.ReadType()
    end

    if hook.Run("CanPlayerCreateChar", client, data) == false then return response(nil, "maxCharactersReached") end
    local originalData = table.Copy(data)
    local newData = {}
    for key in pairs(data) do
        if not lia.char.vars[key] then data[key] = nil end
    end

    for key, charVar in pairs(lia.char.vars) do
        local value = data[key]
        if not isfunction(charVar.onValidate) and charVar.noDisplay then
            data[key] = nil
            continue
        end

        if isfunction(charVar.onValidate) then
            local result = {charVar.onValidate(value, data, client)}
            if result[1] == false then
                result[2] = result[2] or "validationError"
                return response(nil, unpack(result, 2))
            end
        end

        if isfunction(charVar.onAdjust) then charVar.onAdjust(client, data, value, newData) end
    end

    hook.Run("AdjustCreationData", client, data, newData, originalData)
    data = table.Merge(data, newData)
    data.steamID = client:SteamID()
    lia.char.create(data, function(id)
        if IsValid(client) then
            lia.char.getCharacter(id, client, function(character)
                if not character then return end
                character:sync(client)
                table.insert(client.liaCharList, id)
                lia.module.list["mainmenu"]:syncCharList(client)
                hook.Run("OnCharCreated", client, character, originalData)
                response(id)
            end)
        end
    end)
end)

net.Receive("liaCharDelete", function(_, client)
    local id = net.ReadUInt(32)
    local character = lia.char.getCharacter(id)
    local steamID = client:SteamID()
    if character and character.steamID == steamID then
        hook.Run("CharDeleted", client, character)
        character:delete()
        timer.Simple(.5, function() lia.module.list["mainmenu"]:syncCharList(client) end)
    end
end)

hook.Add("PlayerLoadedChar", "StaffCharacterDiscordPrompt", function(client, character)
    if character:getFaction() ~= FACTION_STAFF then return end
    local storedDiscord = client:getLiliaData("staffDiscord")
    if storedDiscord and storedDiscord ~= "" then
        local description = L("staffCharacterDiscord") .. storedDiscord .. ", SteamID: " .. client:SteamID()
        character:setDesc(description)
        return
    end

    if character:getDesc() == "" or character:getDesc():find("^A Staff Character") then
        timer.Simple(2, function()
            if IsValid(client) and client:getChar() == character then
                net.Start("liaStaffDiscordPrompt")
                net.Send(client)
            end
        end)
    end
end)

net.Receive("liaStaffDiscordResponse", function(_, client)
    local discord = net.ReadString()
    local character = client:getChar()
    if not character or character:getFaction() ~= FACTION_STAFF then return end
    client:setLiliaData("staffDiscord", discord)
    local steamID = client:SteamID()
    local description = L("staffCharacterDiscord") .. discord .. ", SteamID: " .. steamID
    character:setDesc(description)
    client:notifySuccessLocalized("staffDescUpdated")
end)

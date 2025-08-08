net.Receive("liaCharChoose", function(_, client)
    local function response(message)
        net.Start("liaCharChoose")
        net.WriteString(L(message or "", client))
        net.Send(client)
    end

    local id = net.ReadUInt(32)
    local character = lia.char.loaded[id]
    if not character or character:getPlayer() ~= client then return response(false, "invalidChar") end
    local status, result = hook.Run("CanPlayerUseChar", client, character)
    if status == false then
        if result[1] == "@" then result = result:sub(2) end
        return response(result)
    end

    local currentChar = client:getChar()
    if currentChar then
        status, result = hook.Run("CanPlayerSwitchChar", client, currentChar, character)
        if status == false then
            if result[1] == "@" then result = result:sub(2) end
            return response(result)
        end

        currentChar:save()
    end

    hook.Run("PrePlayerLoadedChar", client, character, currentChar)
    net.Start("prePlayerLoadedChar")
    net.WriteUInt(character:getID(), 32)
    net.WriteType(currentChar and currentChar:getID() or nil)
    net.Send(client)
    character:setup()
    hook.Run("PlayerLoadedChar", client, character, currentChar)
    net.Start("playerLoadedChar")
    net.WriteUInt(character:getID(), 32)
    net.WriteType(currentChar and currentChar:getID() or nil)
    net.Send(client)
    response()
    hook.Run("PostPlayerLoadedChar", client, character, currentChar)
    net.Start("postPlayerLoadedChar")
    net.WriteUInt(character:getID(), 32)
    net.WriteType(currentChar and currentChar:getID() or nil)
    net.Send(client)
end)

net.Receive("liaCharCreate", function(_, client)
    if hook.Run("CanPlayerCreateChar", client) == false then return end
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
            lia.char.loaded[id]:sync(client)
            table.insert(client.liaCharList, id)
            lia.module.list["mainmenu"]:syncCharList(client)
            hook.Run("OnCharCreated", client, lia.char.loaded[id], originalData)
            response(id)
        end
    end)
end)

net.Receive("liaCharDelete", function(_, client)
    local id = net.ReadUInt(32)
    local character = lia.char.loaded[id]
    local steamID = client:SteamID()
    if character and character.steamID == steamID then
        hook.Run("CharDeleted", client, character)
        character:delete()
        timer.Simple(.5, function() lia.module.list["mainmenu"]:syncCharList(client) end)
    end
end)
--------------------------------------------------------------------------------------------------------
util.AddNetworkString("liaCharacterInvList")
util.AddNetworkString("liaItemDelete")
util.AddNetworkString("liaItemInstance")
util.AddNetworkString("liaInventoryInit")
util.AddNetworkString("liaInventoryData")
util.AddNetworkString("liaInventoryDelete")
util.AddNetworkString("liaInventoryAdd")
util.AddNetworkString("liaInventoryRemove")
util.AddNetworkString("liaNotify")
util.AddNetworkString("liaNotifyL")
util.AddNetworkString("liaStringReq")
util.AddNetworkString("liaTypeStatus")
util.AddNetworkString("liaCharChoose")
util.AddNetworkString("liaCharCreate")
util.AddNetworkString("liaCharDelete")
util.AddNetworkString("liaCharList")
util.AddNetworkString("liaCharMenu")
util.AddNetworkString("liaTransferItem")
util.AddNetworkString("cleanup_inbound")
util.AddNetworkString("worlditem_cleanup_inbound")
util.AddNetworkString("worlditem_cleanup_inbound_final")
util.AddNetworkString("map_cleanup_inbound")
util.AddNetworkString("map_cleanup_inbound_final")
--------------------------------------------------------------------------------------------------------
net.Receive("liaStringReq", function(_, client)
    local id = net.ReadUInt(32)
    local value = net.ReadString()

    if client.liaStrReqs and client.liaStrReqs[id] then
        client.liaStrReqs[id](value)
        client.liaStrReqs[id] = nil
    end
end)
--------------------------------------------------------------------------------------------------------
net.Receive("liaTransferItem", function(_, client)
    local itemID = net.ReadUInt(32)
    local x = net.ReadUInt(32)
    local y = net.ReadUInt(32)
    local invID = net.ReadType()
    hook.Run("HandleItemTransferRequest", client, itemID, x, y, invID)
end)
--------------------------------------------------------------------------------------------------------
netstream.Hook("invAct", function(client, action, item, invID, data)
    local character = client:getChar()
    if not character then return end
    local entity

    if isentity(item) then
        if not IsValid(item) then return end
        if item:GetPos():Distance(client:GetPos()) > 96 then return end
        if not item.liaItemID then return end
        entity = item
        item = lia.item.instances[item.liaItemID]
    else
        item = lia.item.instances[item]
    end

    if not item then return end
    local inventory = lia.inventory.instances[item.invID]

    local context = {
        client = client,
        item = item,
        entity = entity,
        action = action
    }

    if inventory and not inventory:canAccess("item", context) then return end
    item:interact(action, client, entity, data)
end)
--------------------------------------------------------------------------------------------------------
netstream.Hook("liaCharFetchNames", function(client)
    netstream.Start(client, "liaCharFetchNames", lia.char.names)
end)
--------------------------------------------------------------------------------------------------------
netstream.Hook("cmd", function(client, command, arguments)
    if (client.liaNextCmd or 0) < CurTime() then
        local arguments2 = {}

        for _, v in ipairs(arguments) do
            if isstring(v) or isnumber(v) then
                arguments2[#arguments2 + 1] = tostring(v)
            end
        end

        lia.command.parse(client, nil, command, arguments2)
        client.liaNextCmd = CurTime() + 0.2
    end
end)
--------------------------------------------------------------------------------------------------------
net.Receive("liaTypeStatus", function(_, client)
    client:setNetVar("typing", net.ReadBool())
end)
--------------------------------------------------------------------------------------------------------
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
        if result[1] == "@" then
            result = result:sub(2)
        end

        return response(result)
    end

    local currentChar = client:getChar()

    if currentChar then
        currentChar:save()
    end

    hook.Run("PrePlayerLoadedChar", client, character, currentChar)
    character:setup()
    hook.Run("PlayerLoadedChar", client, character, currentChar)
    response()
end)
--------------------------------------------------------------------------------------------------------
net.Receive("liaCharCreate", function(_, client)
    if hook.Run("CanPlayerCreateCharacter", client) == false then return end

    local function response(id, message, ...)
        net.Start("liaCharCreate")
        net.WriteUInt(id or 0, 32)
        net.WriteString(L(message or "", client, ...))
        net.Send(client)
    end

    local numValues = net.ReadUInt(32)
    local data = {}

    for i = 1, numValues do
        data[net.ReadString()] = net.ReadType()
    end

    local originalData = table.Copy(data)
    local newData = {}

    for key in pairs(data) do
        if not lia.char.vars[key] then
            data[key] = nil
        end
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
                result[2] = result[2] or "Validation error"

                return response(nil, unpack(result, 2))
            end
        end

        if isfunction(charVar.onAdjust) then
            charVar.onAdjust(client, data, value, newData)
        end
    end

    hook.Run("AdjustCreationData", client, data, newData, originalData)
    data = table.Merge(data, newData)
    data.steamID = client:SteamID64()

    lia.char.create(data, function(id)
        if IsValid(client) then
            lia.char.loaded[id]:sync(client)
            table.insert(client.liaCharList, id)
            hook.Run("MultiCharSyncCharList", client)
            hook.Run("OnCharCreated", client, lia.char.loaded[id], originalData)
            response(id)
        end
    end)
end)
--------------------------------------------------------------------------------------------------------
net.Receive("liaCharDelete", function(_, client)
    local id = net.ReadUInt(32)
    local character = lia.char.loaded[id]
    local steamID = client:SteamID64()

    if character and character.steamID == steamID then
        hook.Run("liaCharDeleted", client, character)
        character:delete()

        timer.Simple(.5, function()
            hook.Run("MultiCharSyncCharList", client)
        end)
    end
end)
--------------------------------------------------------------------------------------------------------
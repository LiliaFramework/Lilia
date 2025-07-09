net.Receive("StringRequest", function(_, client)
    local id = net.ReadUInt(32)
    local value = net.ReadString()
    if client.liaStrReqs and client.liaStrReqs[id] then
        client.liaStrReqs[id](value)
        client.liaStrReqs[id] = nil
    end
end)

net.Receive("ArgumentsRequest", function(_, client)
    local id = net.ReadUInt(32)
    local data = net.ReadTable()
    if client.liaArgReqs and client.liaArgReqs[id] then
        client.liaArgReqs[id](data)
        client.liaArgReqs[id] = nil
    end
end)

net.Receive("RequestDropdown", function(_, client)
    local selectedOption = net.ReadString()
    if client.dropdownCallback then
        client.dropdownCallback(selectedOption)
        client.dropdownCallback = nil
    end
end)

net.Receive("OptionsRequest", function(_, client)
    local selectedOptions = net.ReadTable()
    if client.optionsCallback then
        client.optionsCallback(selectedOptions)
        client.optionsCallback = nil
    end
end)

net.Receive("BinaryQuestionRequest", function(_, client)
    local choice = net.ReadUInt(1)
    if client.binaryQuestionCallback then
        local callback = client.binaryQuestionCallback
        callback(choice)
        client.binaryQuestionCallback = nil
    end
end)

net.Receive("liaTransferItem", function(_, client)
    local itemID = net.ReadUInt(32)
    local x = net.ReadUInt(32)
    local y = net.ReadUInt(32)
    local invID = net.ReadType()
    hook.Run("HandleItemTransferRequest", client, itemID, x, y, invID)
end)

net.Receive("invAct", function(_, client)
    local action = net.ReadString()
    local rawItem = net.ReadType()
    local data = net.ReadType()
    print("[invAct] Received:", action, rawItem, data)
    local character = client:getChar()
    if not character then
        print("[invAct] No character for client", client)
        return
    end

    local entity
    local item
    if isentity(rawItem) then
        if not IsValid(rawItem) then
            print("[invAct] Invalid entity", rawItem)
            return
        end

        local dist = rawItem:GetPos():Distance(client:GetPos())
        if dist > 96 then
            print("[invAct] Entity too far (distance):", dist)
            return
        end

        if not rawItem.liaItemID then
            print("[invAct] Entity missing liaItemID")
            return
        end

        entity = rawItem
        item = lia.item.instances[rawItem.liaItemID]
        if item then print("[invAct] Loaded item from entity ID:", rawItem.liaItemID) end
    else
        item = lia.item.instances[rawItem]
        if item then print("[invAct] Loaded item by index:", rawItem) end
    end

    if not item then
        print("[invAct] Item not found for", rawItem)
        return
    end

    local inventory = lia.inventory.instances[item.invID]
    if inventory then
        print("[invAct] Found inventory for item.invID:", item.invID)
        local ok = inventory:canAccess("item", {
            client = client,
            item = item,
            entity = entity,
            action = action
        })

        print("[invAct] Access check result:", ok)
        if not ok then
            print("[invAct] Access denied")
            return
        end
    else
        print("[invAct] No inventory instance for item.invID:", item.invID)
    end

    print("[invAct] Calling item:interact")
    item:interact(action, client, entity, data)
end)

net.Receive("cmd", function(_, client)
    local command = net.ReadString()
    local arguments = net.ReadTable()
    if (client.liaNextCmd or 0) < CurTime() then
        local arguments2 = {}
        for _, v in ipairs(arguments) do
            if isstring(v) or isnumber(v) then arguments2[#arguments2 + 1] = tostring(v) end
        end

        lia.command.parse(client, nil, command, arguments2)
        client.liaNextCmd = CurTime() + 0.2
    end
end)

net.Receive("liaCharFetchNames", function(_, client)
    net.Start("liaCharFetchNames")
    net.WriteTable(lia.char.names)
    net.Send(client)
end)
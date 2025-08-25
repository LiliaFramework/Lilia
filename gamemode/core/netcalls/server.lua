net.Receive("StringRequest", function(_, client)
    local id = net.ReadUInt(32)
    local value = net.ReadString()
    if client.liaStrReqs and client.liaStrReqs[id] then
        client.liaStrReqs[id](value)
        client.liaStrReqs[id] = nil
    end
end)

net.Receive("liaCharRequest", function(_, client)
    local charID = net.ReadUInt(32)
    lia.char.getCharacter(charID, client, function(character) if character then character:sync(client) end end)
end)

net.Receive("ArgumentsRequest", function(_, client)
    local id = net.ReadUInt(32)
    local data = net.ReadTable()
    if client.liaArgReqs and client.liaArgReqs[id] then
        client.liaArgReqs[id](data)
        client.liaArgReqs[id] = nil
    end
end)

net.Receive("liaKeybindServer", function(_, ply)
    if not IsValid(ply) then return end
    local action = net.ReadString()
    local player = net.ReadEntity()
    if not IsValid(player) or player ~= ply then return end
    if not lia.keybind.stored[action] then return end
    local data = lia.keybind.stored[action]
    local isRelease = action:find("_release$")
    if isRelease then
        if data.release and data.serverOnly then
            local success, err = pcall(data.release, player)
            if not success then print("Keybind release error for " .. tostring(player) .. ": " .. tostring(err)) end
        end
    else
        if data.callback and data.serverOnly then
            local success, err = pcall(data.callback, player)
            if not success then print("Keybind press error for " .. tostring(player) .. ": " .. tostring(err)) end
        end
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

net.Receive("ButtonRequest", function(_, client)
    local id = net.ReadUInt(32)
    local choice = net.ReadUInt(8)
    local data = client.buttonRequests and client.buttonRequests[id]
    if data and data[choice] then
        data[choice](client)
        client.buttonRequests[id] = nil
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
    local character = client:getChar()
    if not character then return end
    local entity
    local item
    if isentity(rawItem) then
        if not IsValid(rawItem) then return end
        if rawItem:GetPos():Distance(client:GetPos()) > 96 then return end
        if not rawItem.liaItemID then return end
        entity = rawItem
        item = lia.item.instances[rawItem.liaItemID]
    else
        item = lia.item.instances[rawItem]
    end

    if not item then return end
    local inventory = lia.inventory.instances[item.invID]
    if inventory then
        local ok = inventory:canAccess("item", {
            client = client,
            item = item,
            entity = entity,
            action = action
        })

        if not ok then return end
    end

    item:interact(action, client, entity, data)
end)

net.Receive("RunInteraction", function(_, ply)
    if lia.config.get("DisableCheaterActions", true) and ply:getNetVar("cheater", false) then
        lia.log.add(ply, "cheaterAction", L("cheaterActionUseInteractionMenu"))
        ply:notifyLocalized("maybeYouShouldntHaveCheated")
        return
    end

    local name = net.ReadString()
    local hasEntity = net.ReadBool()
    local tracedEntity = hasEntity and net.ReadEntity() or nil
    local opt = lia.playerinteract.stored[name]
    if opt and opt.type == "interaction" and opt.serverOnly and IsValid(tracedEntity) and lia.playerinteract.isWithinRange(ply, tracedEntity, opt.range) then
        local targetType = opt.target or "player"
        local isPlayerTarget = tracedEntity:IsPlayer()
        local targetMatches = targetType == "any" or targetType == "player" and isPlayerTarget or targetType == "entity" and not isPlayerTarget
        if not targetMatches then return end
        if isPlayerTarget then
            local target = tracedEntity
            if tracedEntity:IsBot() and ply:Team() == FACTION_STAFF then target = ply end
            opt.onRun(ply, target)
        else
            opt.onRun(ply, tracedEntity)
        end
        return
    end

    if opt and opt.type == "action" and opt.serverOnly then
        if hasEntity and IsValid(tracedEntity) then
            opt.onRun(ply, tracedEntity)
        else
            opt.onRun(ply)
        end
    end
end)

net.Receive("liaRequestInteractOptions", function(_, ply)
    if not IsValid(ply) then return end
    local requestType = net.ReadString()
    local options = {}
    if requestType == "interaction" then
        local ent = ply:getTracedEntity()
        if not IsValid(ent) then
            net.Start("liaProvideInteractOptions")
            net.WriteString(requestType)
            net.WriteUInt(0, 16)
            net.Send(ply)
            return
        end

        for name, opt in pairs(lia.playerinteract.stored or {}) do
            if opt.type == "interaction" and lia.playerinteract.isWithinRange(ply, ent, opt.range) then
                local targetType = opt.target or "player"
                local isPlayerTarget = ent:IsPlayer()
                local targetMatches = targetType == "any" or targetType == "player" and isPlayerTarget or targetType == "entity" and not isPlayerTarget
                if targetMatches then
                    local canShow = true
                    if opt.shouldShow then
                        local ok, res = pcall(opt.shouldShow, ply, ent)
                        canShow = ok and res ~= false
                    end

                    if canShow then
                        options[#options + 1] = {
                            name = name,
                            opt = {
                                type = opt.type,
                                serverOnly = opt.serverOnly and true or false,
                                range = opt.range,
                                category = opt.category or "",
                                target = opt.target,
                                timeToComplete = opt.timeToComplete,
                                actionText = opt.actionText,
                                targetActionText = opt.targetActionText
                            }
                        }
                    end
                end
            end
        end
    else
        if not ply:getChar() then
            net.Start("liaProvideInteractOptions")
            net.WriteString("action")
            net.WriteUInt(0, 16)
            net.Send(ply)
            return
        end

        for name, opt in pairs(lia.playerinteract.stored or {}) do
            if opt.type == "action" then
                local canShow = true
                if opt.shouldShow then
                    local ok, res = pcall(opt.shouldShow, ply)
                    canShow = ok and res ~= false
                end

                if canShow then
                    options[#options + 1] = {
                        name = name,
                        opt = {
                            type = opt.type,
                            serverOnly = opt.serverOnly and true or false,
                            range = opt.range,
                            category = opt.category or "",
                            timeToComplete = opt.timeToComplete,
                            actionText = opt.actionText,
                            targetActionText = opt.targetActionText
                        }
                    }
                end
            end
        end
    end

    net.Start("liaProvideInteractOptions")
    net.WriteString(requestType == "interaction" and "interaction" or "action")
    net.WriteUInt(#options, 16)
    for _, entry in ipairs(options) do
        net.WriteString(entry.name)
        net.WriteString(entry.opt.type)
        net.WriteBool(entry.opt.serverOnly)
        net.WriteUInt(entry.opt.range or 0, 16)
        net.WriteString(entry.opt.category or "")
        net.WriteBool(entry.opt.target ~= nil)
        if entry.opt.target ~= nil then net.WriteString(entry.opt.target) end
        net.WriteBool(entry.opt.timeToComplete ~= nil)
        if entry.opt.timeToComplete ~= nil then net.WriteFloat(entry.opt.timeToComplete) end
        net.WriteBool(entry.opt.actionText ~= nil)
        if entry.opt.actionText ~= nil then net.WriteString(entry.opt.actionText) end
        net.WriteBool(entry.opt.targetActionText ~= nil)
        if entry.opt.targetActionText ~= nil then net.WriteString(entry.opt.targetActionText) end
    end

    net.Send(ply)
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

net.Receive("liaNetMessage", function(_, client)
    local name = net.ReadString()
    local args = net.ReadTable()
    if lia.net.registry[name] then
        local success, err = pcall(lia.net.registry[name], client, unpack(args))
        if not success then lia.error("Error in net message callback '" .. name .. "': " .. tostring(err)) end
    else
        lia.error("Received unregistered net message: " .. name)
    end
end)

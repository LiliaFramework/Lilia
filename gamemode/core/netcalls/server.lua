﻿net.Receive("liaStringRequest", function(_, client)
    local id = net.ReadUInt(32)
    local value = net.ReadString()
    if client.liaStrReqs and client.liaStrReqs[id] then
        client.liaStrReqs[id](value)
        client.liaStrReqs[id] = nil
    end
end)

net.Receive("liaStorageSyncRequest", function(_, client)
    net.Start("liaStorageSync")
    net.WriteTable(lia.inventory.storage)
    net.Send(client)
end)

net.Receive("liaStringRequestCancel", function(_, client)
    local id = net.ReadUInt(32)
    if client.liaStrReqs and client.liaStrReqs[id] then client.liaStrReqs[id] = nil end
end)

net.Receive("liaNPCWeaponChange", function(_, ply)
    local ent = net.ReadEntity()
    local wep = net.ReadString()
    if not IsValid(ent) or not ent:IsNPC() then return end
    if not IsValid(ply) or not ply:hasPrivilege("canSpawnSWEPs") then return end
    if IsValid(ent:GetActiveWeapon()) then ent:GetActiveWeapon():Remove() end
    ent:Give(wep)
end)

net.Receive("liaCharRequest", function(_, client)
    local charID = net.ReadUInt(32)
    lia.char.getCharacter(charID, client, function(character) if character then character:sync(client) end end)
end)

net.Receive("liaArgumentsRequest", function(_, client)
    local id = net.ReadUInt(32)
    local data = net.ReadTable()
    local req = client.liaArgReqs and client.liaArgReqs[id]
    if not req then return end
    local spec = req.spec or {}
    for name, typeInfo in pairs(spec) do
        local expectedType = typeInfo
        if istable(typeInfo) then expectedType = typeInfo[1] end
        local val = data and data[name]
        if expectedType == "boolean" then
            if val == nil then
                client.liaArgReqs[id] = nil
                return
            end
        elseif expectedType == "table" then
            if val == nil then
                client.liaArgReqs[id] = nil
                return
            end
        else
            if val == nil then
                client:notify("Please fill in all required fields.")
                client.liaArgReqs[id] = nil
                return
            end
        end
    end

    if isfunction(req.callback) then req.callback(true, data) end
    client.liaArgReqs[id] = nil
end)

net.Receive("liaArgumentsRequestCancel", function(_, client)
    local id = net.ReadUInt(32)
    if client.liaArgReqs and client.liaArgReqs[id] then client.liaArgReqs[id] = nil end
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
            if not success then lia.error("Keybind release callback error: " .. tostring(err)) end
        end
    else
        if data.callback and data.serverOnly then
            local success, err = pcall(data.callback, player)
            if not success then lia.error("Keybind callback error: " .. tostring(err)) end
        end
    end
end)

net.Receive("liaRequestDropdown", function(_, client)
    local id = net.ReadUInt(32)
    local selectedOption = net.ReadString()
    local selectedData = net.ReadString()
    if selectedData == "" then selectedData = nil end
    local req = client.liaDropdownReqs and client.liaDropdownReqs[id]
    if not req then return end
    local allowed = req.allowed or {}
    local isValid = false
    for _, opt in ipairs(allowed) do
        local optionText = opt
        if istable(opt) then optionText = opt[1] end
        if string.lower(tostring(optionText)) == string.lower(tostring(selectedOption)) then
            isValid = true
            break
        end
    end

    if not isValid then
        client.liaDropdownReqs[id] = nil
        return
    end

    if isfunction(req.callback) then
        if selectedData ~= nil then
            req.callback(selectedOption, selectedData)
        else
            req.callback(selectedOption)
        end
    end

    client.liaDropdownReqs[id] = nil
end)

net.Receive("liaRequestDropdownCancel", function(_, client)
    local id = net.ReadUInt(32)
    if client.liaDropdownReqs then client.liaDropdownReqs[id] = nil end
end)

net.Receive("liaOptionsRequest", function(_, client)
    local id = net.ReadUInt(32)
    local selectedOptions = net.ReadTable()
    local req = client.liaOptionsReqs and client.liaOptionsReqs[id]
    if not req then return end
    local allowed, limit = req.allowed or {}, tonumber(req.limit) or 1
    if not istable(selectedOptions) or #selectedOptions == 0 or #selectedOptions > limit then
        client.liaOptionsReqs[id] = nil
        return
    end

    for _, opt in ipairs(selectedOptions) do
        local ok = false
        for _, a in ipairs(allowed) do
            local allowedText = a
            if istable(a) then allowedText = a[1] end
            if string.lower(tostring(allowedText)) == string.lower(tostring(opt)) then
                ok = true
                break
            end
        end

        if not ok then
            client.liaOptionsReqs[id] = nil
            return
        end
    end

    if isfunction(req.callback) then req.callback(selectedOptions) end
    client.liaOptionsReqs[id] = nil
end)

net.Receive("liaOptionsRequestCancel", function(_, client)
    local id = net.ReadUInt(32)
    if client.liaOptionsReqs then client.liaOptionsReqs[id] = nil end
end)

net.Receive("liaBinaryQuestionRequest", function(_, client)
    local id = net.ReadUInt(32)
    local choice = net.ReadUInt(1)
    local cb = client.liaBinaryReqs and client.liaBinaryReqs[id]
    if not cb then return end
    if isfunction(cb) then cb(choice) end
    client.liaBinaryReqs[id] = nil
end)

net.Receive("liaBinaryQuestionRequestCancel", function(_, client)
    local id = net.ReadUInt(32)
    if client.liaBinaryReqs then client.liaBinaryReqs[id] = nil end
end)

net.Receive("liaButtonRequest", function(_, client)
    local id = net.ReadUInt(32)
    local choice = net.ReadUInt(8)
    local data = client.buttonRequests and client.buttonRequests[id]
    if data and data[choice] then
        data[choice](client)
        client.buttonRequests[id] = nil
    end
end)

net.Receive("liaButtonRequestCancel", function(_, client)
    local id = net.ReadUInt(32)
    if client.buttonRequests and client.buttonRequests[id] then client.buttonRequests[id] = nil end
end)

net.Receive("liaTransferItem", function(_, client)
    local itemID = net.ReadUInt(32)
    local x = net.ReadUInt(32)
    local y = net.ReadUInt(32)
    local invID = net.ReadType()
    hook.Run("HandleItemTransferRequest", client, itemID, x, y, invID)
end)

net.Receive("liaInvAct", function(_, client)
    local action = net.ReadString()
    local rawItem = net.ReadType()
    local data = net.ReadType()
    local character = client:getChar()
    if not character then return end
    local entity
    local item
    if isentity(rawItem) then
        if not IsValid(rawItem) then return end
        if rawItem:GetPos():distance(client:GetPos()) > 96 then return end
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

net.Receive("liaRunInteraction", function(_, ply)
    if lia.config.get("DisableCheaterActions", true) and ply:getNetVar("cheater", false) then
        lia.log.add(ply, "cheaterAction", L("cheaterActionUseInteractionMenu"))
        ply:notifyWarningLocalized("maybeYouShouldntHaveCheated")
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

net.Receive("liaCommandData", function(_, client)
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

net.Receive("liaAdminSetCharProperty", function(_, client)
    if not client:hasPrivilege("listCharacters") then return end
    local charID = net.ReadInt(32)
    local property = net.ReadString()
    local value = net.ReadType()
    local charIDsafe = tonumber(charID)
    if not charIDsafe then
        client:notifyErrorLocalized("invalidCharID")
        return
    end

    lia.db.query("SELECT name, money, model FROM lia_characters WHERE id = " .. charIDsafe, function(data)
        if not data or #data == 0 then
            client:notifyErrorLocalized("characterNotFound")
            return
        end

        local charData = data[1]
        if property == "money" then
            local moneyValue = tonumber(value) or 0
            if lia.char.setCharDatabase(charID, "money", moneyValue) then
                local target = lia.char.getCharacter(charID)
                if IsValid(target) then
                    client:notifySuccessLocalized("setMoney", target:Name(), lia.currency.get(moneyValue))
                else
                    client:notifySuccessLocalized("offlineCharMoneySet", charID, lia.currency.get(moneyValue))
                end

                lia.log.add(client, "adminSetCharMoney", charID, moneyValue)
            else
                client:notifyErrorLocalized("failedToUpdateChar")
            end
        elseif property == "name" then
            local nameValue = tostring(value)
            if lia.char.setCharDatabase(charID, "name", nameValue) then
                local target = lia.char.getCharacter(charID)
                if IsValid(target) then
                    client:notifySuccessLocalized("changeName", client:Name(), charData.name, nameValue)
                else
                    client:notifySuccessLocalized("offlineCharNameSet", charID, nameValue)
                end

                lia.log.add(client, "adminSetCharName", charID, nameValue)
            else
                client:notifyErrorLocalized("failedToUpdateChar")
            end
        elseif property == "model" then
            local modelValue = tostring(value)
            if lia.char.setCharDatabase(charID, "model", modelValue) then
                local target = lia.char.getCharacter(charID)
                if IsValid(target) then
                    client:notifySuccessLocalized("changeModel", client:Name(), target:Name(), modelValue)
                else
                    client:notifySuccessLocalized("offlineCharModelSet", charID, modelValue)
                end

                lia.log.add(client, "adminSetCharModel", charID, modelValue)
            else
                client:notifyErrorLocalized("failedToUpdateChar")
            end
        else
            client:notifyErrorLocalized("invalidArg")
            return
        end
    end)
end)

net.Receive("liaNetMessage", function(_, client)
    local name = net.ReadString()
    local args = net.ReadTable()
    if lia.net.registry[name] then
        local success, err = pcall(lia.net.registry[name], client, unpack(args))
        if not success then lia.error(L("netMessageCallbackError", name, tostring(err))) end
    else
        lia.error(L("unregisteredNetMessage", name))
    end
end)

net.Receive("liaWaypointReached", function(_, client)
    if client.waypointOnReach and isfunction(client.waypointOnReach) then
        client.waypointOnReach(client)
        client.waypointOnReach = nil
    end
end)

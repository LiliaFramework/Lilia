net.Receive("liaPlayerRespawn", function(_, client)
    if not IsValid(client) or client:Alive() then return end
    local char = client:getChar()
    if not char then return end
    local baseTime = lia.config.get("SpawnTime", 5)
    baseTime = hook.Run("OverrideSpawnTime", client, baseTime) or baseTime
    local lastDeath = client:getNetVar("lastDeathTime", os.time())
    local timePassed = os.time() - lastDeath
    if timePassed >= baseTime then client:Spawn() end
end)

net.Receive("liaStringRequest", function(_, client)
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

net.Receive("liaKickCharacter", function(_, client)
    local char = client:getChar()
    local canManageAny = client:hasPrivilege("canManageFactions")
    local canKick = char and char:hasFlags("K")
    if not canKick and not canManageAny then return end
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

    local characterID = net.ReadUInt(32)
    local isOnline = false
    for _, target in player.Iterator() do
        local targetChar = target:getChar()
        if targetChar and targetChar:getID() == characterID and (canManageAny or canKick and char and targetChar:getFaction() == char:getFaction()) then
            isOnline = true
            local oldFaction = targetChar:getFaction()
            local oldFactionData = lia.faction.indices[oldFaction]
            if oldFactionData and oldFactionData.isDefault then return end
            target:notifyWarningLocalized("kickedFromFaction")
            targetChar.vars.faction = defaultFaction.uniqueID
            targetChar:setFaction(defaultFaction.index)
            hook.Run("OnTransferred", target)
            if defaultFaction.OnTransferred then defaultFaction:OnTransferred(target, oldFaction) end
            hook.Run("PlayerLoadout", target)
            targetChar:save()
        end
    end

    if not isOnline then
        lia.db.query("SELECT faction FROM lia_characters WHERE id = " .. characterID):next(function(data)
            if not data or not data[1] then return end
            local oldFactionID = data[1].faction
            local oldFactionData = lia.faction.teams[oldFactionID]
            if oldFactionData and oldFactionData.isDefault then return end
            lia.db.updateTable({
                faction = defaultFaction.uniqueID
            }, nil, "characters", "id = " .. characterID):next(function() lia.char.setCharDatabase(characterID, "factionKickWarn", true) end):catch(function(err) lia.error(L("failedToUpdateCharacterFaction") .. " " .. tostring(err)) end)
        end):catch(function(err) lia.error(L("failedToQueryCharacterFaction") .. " " .. tostring(err)) end)
    end
end)

net.Receive("liaCheckSeed", function(_, client)
    local sentSteamID = net.ReadString()
    if not sentSteamID or sentSteamID == "" then
        lia.adminstrator.notifyAdmin(L("steamIDMissing", client:Name(), client:SteamID()))
        lia.log.add(client, "steamIDMissing", client:Name(), client:SteamID())
        return
    end

    if client:SteamID() ~= sentSteamID then
        lia.adminstrator.notifyAdmin(L("steamIDMismatch", client:Name(), client:SteamID(), sentSteamID))
        lia.log.add(client, "steamIDMismatch", client:Name(), client:SteamID(), sentSteamID)
    end
end)

net.Receive("liaCheckHack", function(_, client)
    lia.log.add(client, "hackAttempt", "CheckHack")
    local override = hook.Run("PlayerCheatDetected", client)
    client:setNetVar("cheater", true)
    client:setLiliaData("cheater", true)
    hook.Run("OnCheaterCaught", client)
    if override ~= true then lia.adminstrator.applyPunishment(client, L("hackingInfraction"), true, true, 0, "kickedForInfractionPeriod", "bannedForInfractionPeriod") end
end)

net.Receive("liaVerifyCheatsResponse", function(_, client)
    lia.log.add(client, "verifyCheatsOK")
    client.VerifyCheatsPending = nil
    if client.VerifyCheatsTimer then
        timer.Remove(client.VerifyCheatsTimer)
        client.VerifyCheatsTimer = nil
    end
end)

local function getEntityDisplayName(ent)
    if not IsValid(ent) then return L("unknownEntity") end
    if ent:GetClass() == "lia_item" and ent.getItemTable then
        local item = ent:getItemTable()
        if item and item.getName then
            return item:getName()
        elseif item and item.name then
            return item.name
        end
    end

    if ent:GetClass() == "lia_vendor" then
        local vendorName = ent:getNetVar("name")
        if vendorName and vendorName ~= "" then return vendorName end
    end

    if ent:GetClass() == "lia_storage" then
        local storageInfo = ent:getStorageInfo()
        if storageInfo and storageInfo.name then return storageInfo.name end
    end

    if ent:IsPlayer() and ent:getChar() then return ent:getChar():getName() end
    if ent:IsVehicle() then
        local vehicleName = ent:GetVehicleClass()
        if vehicleName and vehicleName ~= "" then return vehicleName end
    end

    if ent.PrintName and ent.PrintName ~= "" then return ent.PrintName end
    local className = ent:GetClass()
    if className:StartWith("lia_") then return className:sub(5):gsub("_", " "):gsub("^%l", string.upper) end
    return className
end

net.Receive("liaTeleportToEntity", function(_, client)
    if not client:hasPrivilege("teleportToEntity") then
        client:notifyErrorLocalized("noPrivilege")
        return
    end

    local entity = net.ReadEntity()
    if not IsValid(entity) then
        client:notifyErrorLocalized("invalidEntity")
        return
    end

    client.previousPosition = client:GetPos()
    local entityPos = entity:GetPos()
    local trace = util.TraceLine({
        start = entityPos,
        endpos = entityPos + Vector(0, 0, 100),
        mask = MASK_SOLID
    })

    if trace.Hit then
        client:SetPos(trace.HitPos + Vector(0, 0, 10))
    else
        client:SetPos(entityPos + Vector(0, 0, 50))
    end

    client:notifySuccessLocalized("teleportedToEntity")
    lia.log.add(client, "entityTeleport", client:Name(), getEntityDisplayName(entity), tostring(entity:GetPos()))
end)

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
            if unloadedCount > 0 then lia.information(L("unloadedUnusedCharacters") .. " " .. unloadedCount .. " " .. L("forPlayer") .. " " .. client:Name()) end
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
    if unloadedCount > 0 then lia.information(L("unloadedUnusedCharacters") .. " " .. unloadedCount .. " " .. L("forPlayer") .. " " .. client:Name()) end
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
                lia.module.get("mainmenu"):SyncCharList(client)
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
        timer.Simple(.5, function() lia.module.get("mainmenu"):SyncCharList(client) end)
    end
end)

net.Receive("liaMessageData", function(_, client)
    local text = net.ReadString()
    local charlimit = lia.config.get("MaxChatLength")
    if charlimit > 0 then
        if (client.liaNextChat or 0) < CurTime() and text:find("%S") then
            hook.Run("PlayerSay", client, text)
            client.liaNextChat = CurTime() + math.max(#text / 250, 0.4)
        end
    else
        if utf8.len(text) > charlimit then
            client:notifyErrorLocalized("messageTooLong", charlimit)
        else
            if (client.liaNextChat or 0) < CurTime() and text:find("%S") then
                hook.Run("PlayerSay", client, text)
                client.liaNextChat = CurTime() + math.max(#text / 250, 0.4)
            end
        end
    end
end)

net.Receive("liaDoorPerm", function(_, client)
    local door = net.ReadEntity()
    local target = net.ReadEntity()
    local access = net.ReadUInt(2)
    if IsValid(target) and target:getChar() and door.liaAccess and door:GetDTEntity(0) == client and target ~= client then
        access = math.Clamp(access or 0, DOOR_NONE, DOOR_TENANT)
        if access == door.liaAccess[target] then return end
        door.liaAccess[target] = access
        local recipient = {}
        for k, v in pairs(door.liaAccess) do
            if v > DOOR_GUEST then recipient[#recipient + 1] = k end
        end

        if #recipient > 0 then
            net.Start("liaDoorPerm")
            net.WriteEntity(door)
            net.WriteEntity(target)
            net.WriteUInt(access, 2)
            net.Send(recipient)
        end
    end
end)

net.Receive("liaStaffDiscordResponse", function(_, client)
    local discord = net.ReadString()
    local character = client:getChar()
    if not character or character:getFaction() ~= FACTION_STAFF then return end
    client:setLiliaData("staffDiscord", discord)
    local steamID = client:SteamID()
    local description = L("staffCharacterDiscordSteamID", discord, steamID)
    character:setDesc(description)
    client:notifySuccessLocalized("staffDescUpdated")
end)

net.Receive("liaReturnFromEntity", function(_, client)
    if not client.previousPosition then
        client:notifyErrorLocalized("noPreviousPosition")
        return
    end

    local returnPos = client.previousPosition
    client:SetPos(returnPos)
    client.previousPosition = nil
    client:notifySuccessLocalized("returnedFromEntity")
    lia.log.add(client, "entityReturn", client:Name(), tostring(returnPos))
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
                client:notifyErrorLocalized("requiredFieldsMissing")
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
            if not success then lia.error(L("keybindReleaseCallbackError") .. tostring(err)) end
        end
    else
        if data.callback and data.serverOnly then
            local success, err = pcall(data.callback, player)
            if not success then lia.error(L("keybindCallbackError") .. tostring(err)) end
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

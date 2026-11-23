net.Receive("liaPlayerRespawn", function(_, client)
    if not IsValid(client) or client:Alive() then return end
    if not client:getChar() then return end
    local baseTime = lia.config.get("SpawnTime", 5)
    baseTime = hook.Run("OverrideSpawnTime", client, baseTime) or baseTime
    local lastDeath = client:getLocalVar("lastDeathTime")
    local timePassed = lastDeath and lastDeath ~= 0 and os.time() - lastDeath or nil
    local canRespawn = hook.Run("CanPlayerRespawn", client, timePassed, baseTime, lastDeath)
    if canRespawn == false then
        return
    elseif canRespawn == true then
        client.liaIsRespawning = true
        client:Spawn()
        return
    end

    if not lastDeath or lastDeath == 0 then
        client.liaIsRespawning = true
        client:Spawn()
        return
    end

    timePassed = os.time() - lastDeath
    if timePassed >= baseTime then
        client.liaIsRespawning = true
        client:Spawn()
    end
end)

local function getWeaponItemDefaults(className)
    local wep = weapons.Get(className)
    if not wep then return nil end
    local holdType = wep.HoldType or "normal"
    local isGrenade = holdType == "grenade"
    local size = lia.item.holdTypeSizeMapping[holdType] or {
        width = 2,
        height = 1
    }
    return {
        name = hook.Run("GetWeaponName", wep) or className,
        desc = "A Weapon.",
        category = isGrenade and "Grenades" or "Weapons",
        model = wep.WorldModel or wep.WM or "models/props_c17/suitcase_passenger_physics.mdl",
        class = className,
        width = size.width,
        height = size.height,
        price = 500
    }
end

net.Receive("liaWeaponOverrideUpdate", function(len, ply)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaWeaponOverrideUpdate", "hasPrivilege(ManageWeaponOverrides)=", tostring(ply:hasPrivilege("ManageWeaponOverrides")), "finalResult=", tostring(ply:hasPrivilege("ManageWeaponOverrides")))
    if not ply:hasPrivilege("ManageWeaponOverrides") then return end
    local className = net.ReadString()
    local key = net.ReadString()
    local value = net.ReadType()
    lia.item.WeaponOverrides[className] = lia.item.WeaponOverrides[className] or {}
    lia.item.WeaponOverrides[className][key] = value
    for classID, data in pairs(lia.item.WeaponOverrides) do
        if not istable(data) then
            lia.item.WeaponOverrides[classID] = nil
            continue
        end

        local defaults = getWeaponItemDefaults(classID)
        if defaults then
            for k, v in pairs(data) do
                if defaults[k] ~= nil and v == defaults[k] then data[k] = nil end
            end
        end

        if table.IsEmpty(data) then lia.item.WeaponOverrides[classID] = nil end
    end

    lia.data.set("weaponOverrides", lia.item.WeaponOverrides, true, true)
    local itemDef = lia.item.list[className]
    if itemDef then itemDef[key] = value end
    ply:notify(string.format("Successfully updated %s for %s", key, className))
    net.Start("liaWeaponOverrideSync")
    net.WriteBool(false)
    net.WriteString(className)
    net.WriteString(key)
    net.WriteType(value)
    net.Broadcast()
    hook.Run("OnWeaponOverrideUpdated", className, key, value)
end)

local function sanitizeRuntimePath(path)
    if not isstring(path) or path == "" then return nil end
    if not path:match("^[%a_][%w_]*%.[%a_][%w_]*$") then return nil end
    return path
end

local function coerceRuntimeValue(raw)
    local n = tonumber(raw)
    if n ~= nil then return n end
    if raw == "true" then return true end
    if raw == "false" then return false end
    return raw
end

local function refreshWeaponHolders(className)
    for _, ply in player.Iterator() do
        if ply:HasWeapon(className) then
            ply:StripWeapon(className)
            ply:Give(className)
            ply:SelectWeapon(className)
        end
    end
end

net.Receive("liaWeaponRuntimeOverrideUpdate", function(_, ply)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaWeaponRuntimeOverrideUpdate", "hasPrivilege(ManageWeaponOverrides)=", tostring(ply:hasPrivilege("ManageWeaponOverrides")), "finalResult=", tostring(ply:hasPrivilege("ManageWeaponOverrides")))
    if not ply:hasPrivilege("ManageWeaponOverrides") then return end
    local className = net.ReadString()
    local dotPath = sanitizeRuntimePath(net.ReadString())
    local rawValue = net.ReadString()
    if not dotPath then return end
    local value = coerceRuntimeValue(rawValue)
    local wep = weapons.GetStored(className)
    if not wep then return end
    if not lia.item.applyRuntimeOverridePath(wep, dotPath, value) then return end
    lia.item.WeaponRuntimeOverrides[className] = lia.item.WeaponRuntimeOverrides[className] or {}
    lia.item.WeaponRuntimeOverrides[className][dotPath] = value
    lia.data.set("weaponRuntimeOverrides", lia.item.WeaponRuntimeOverrides, true, true)
    refreshWeaponHolders(className)
    ply:notify(string.format("Successfully updated %s for %s", dotPath, className))
    net.Start("liaWeaponRuntimeOverrideSync")
    net.WriteBool(false)
    net.WriteString(className)
    net.WriteString(dotPath)
    net.WriteType(value)
    net.Broadcast()
    hook.Run("OnWeaponRuntimeOverrideUpdated", className, dotPath, value)
end)

net.Receive("liaWeaponRuntimeOverrideReset", function(_, ply)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaWeaponRuntimeOverrideReset", "hasPrivilege(ManageWeaponOverrides)=", tostring(ply:hasPrivilege("ManageWeaponOverrides")), "finalResult=", tostring(ply:hasPrivilege("ManageWeaponOverrides")))
    if not ply:hasPrivilege("ManageWeaponOverrides") then return end
    local className = net.ReadString()
    local wep = weapons.GetStored(className)
    if not wep then return end
    local defaults = lia.item.defaultRuntimeValues and lia.item.defaultRuntimeValues[className] or {}
    for dotPath, originalValue in pairs(defaults) do
        lia.item.applyRuntimeOverridePath(wep, dotPath, originalValue)
    end

    lia.item.WeaponRuntimeOverrides[className] = nil
    lia.data.set("weaponRuntimeOverrides", lia.item.WeaponRuntimeOverrides, true, true)
    refreshWeaponHolders(className)
    ply:notify(string.format("Successfully updated %s for %s", "reset", className))
    net.Start("liaWeaponRuntimeOverrideSync")
    net.WriteBool(false)
    net.WriteString(className)
    net.WriteString("")
    net.WriteType(false)
    net.Broadcast()
end)

net.Receive("liaInsertKeyPressed", function(_, client)
    if not IsValid(client) then return end
    local char = client:getChar()
    if not char then return end
    local message = client:Name() .. " (" .. client:SteamID() .. ") pressed INSERT (common cheat-menu key)."
    StaffAddTextShadowed(Color(255, 0, 0), "ALERT", Color(255, 255, 255), message, function(staff)
        local permission = staff:hasPrivilege("seeInsertNotifications")
        lia.debug("[Permissions]", "Permission Check for net.Receive liaInsertKeyPressed staff recipient", "targetPlayer=", tostring(staff:Name()), "hasPrivilege(seeInsertNotifications)=", tostring(permission), "finalResult=", tostring(permission))
        return permission
    end)
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

net.Receive("liaCheckSeed", function(_, client)
    local sentSteamID = net.ReadString()
    if not sentSteamID or sentSteamID == "" then
        lia.adminstrator.notifyAdmin(string.format("The SteamID of player %s (%s) wasn't received properly. This can signify tampering with net messages.", client:Name(), client:SteamID()))
        return
    end

    if client:SteamID() ~= sentSteamID then lia.adminstrator.notifyAdmin(string.format("The SteamID of player %s (%s) is different than the saved one (%s).", client:Name(), client:SteamID(), sentSteamID)) end
end)

net.Receive("liaCheckHack", function(_, client)
    hook.Run("PlayerCheatDetected", client)
    if IsValid(client) then
        client:notifyError(string.format("Cheating detected. Staff have been notified."))
        for _, p in player.Iterator() do
            local isStaffOnDuty = p:isStaffOnDuty()
            local hasReceiveCheaterNotifications = p:hasPrivilege("receiveCheaterNotifications")
            local permission = isStaffOnDuty or hasReceiveCheaterNotifications
            lia.debug("[Permissions]", "Permission Check for net.Receive liaCheckHack cheater recipient", "targetPlayer=", tostring(p:Name()), "isStaffOnDuty=", tostring(isStaffOnDuty), "hasPrivilege(receiveCheaterNotifications)=", tostring(hasReceiveCheaterNotifications), "finalResult=", tostring(permission))
            if permission then p:notifyWarning(string.format("%s (%s) was flagged for cheating.", client:Name(), client:SteamID())) end
        end

        if client:getChar() then
            local timestamp = os.date("%Y-%m-%d %H:%M:%S")
            local severity = "High"
            hook.Run("AddWarning", client:getChar():getID(), client:Nick(), client:SteamID(), timestamp, "Cheating or exploiting", "System", "SYSTEM", severity)
            local charID = client:getChar():getID()
            local message = string.format("%s (Character %s | Steam64ID: %s) was flagged for cheating. Severity: %s.", client:Name(), charID, client:SteamID64(), severity)
            StaffAddTextShadowed(Color(255, 0, 0), "CHEAT", Color(255, 255, 255), message, function(staff)
                local permission = staff:hasPrivilege("receiveCheaterNotifications")
                lia.debug("[Permissions]", "Permission Check for net.Receive liaCheckHack StaffAddTextShadowed recipient", "targetPlayer=", tostring(staff:Name()), "hasPrivilege(receiveCheaterNotifications)=", tostring(permission), "finalResult=", tostring(permission))
                return permission
            end)
        end
    end

    hook.Run("OnCheaterCaught", client)
end)

net.Receive("liaVerifyCheatsResponse", function(_, client)
    client.VerifyCheatsPending = nil
    if client.VerifyCheatsTimer then
        timer.Remove(client.VerifyCheatsTimer)
        client.VerifyCheatsTimer = nil
    end
end)

net.Receive("liaTeleportToEntity", function(_, client)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaTeleportToEntity", "hasPrivilege(teleportToEntity)=", tostring(client:hasPrivilege("teleportToEntity")), "finalResult=", tostring(client:hasPrivilege("teleportToEntity")))
    if not client:hasPrivilege("teleportToEntity") then
        client:notifyError(string.format("No privilege"))
        return
    end

    local entity = net.ReadEntity()
    if not IsValid(entity) then
        client:notifyError(string.format("Invalid entity selected."))
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

    client:notifySuccess(string.format("Teleported to entity"))
end)

net.Receive("liaCharChoose", function(_, client)
    local function response(message)
        net.Start("liaCharChoose")
        net.WriteString(string.format(tostring(message or ""), client))
        net.Send(client)
    end

    local id = net.ReadUInt(32)
    local currentChar = client:getChar()
    if currentChar and currentChar:getID() == id then
        response()
        return
    end

    if not lia.char.isLoaded(id) then
        if not table.HasValue(client.liaCharList or {}, id) then
            lia.db.selectOne("faction", "characters", "id = " .. id):next(function(result)
                local isStaffFaction = result and (result.faction == "staff" or tonumber(result.faction) == FACTION_STAFF) or false
                local allowStaffChar = isStaffFaction and client:hasPrivilege("createStaffCharacter")
                lia.debug("[Permissions]", "Permission Check for net.Receive liaCharacterChoose staff fallback", "dbResultExists=", tostring(result ~= nil), "targetFactionIsStaff=", tostring(isStaffFaction), "hasPrivilege(createStaffCharacter)=", tostring(client:hasPrivilege("createStaffCharacter")), "finalResult=", tostring(allowStaffChar))
                if not allowStaffChar then return response(false, "Invalid character.") end
                lia.char.loadSingleCharacter(id, client, function(character)
                    if not character then return response(false, "Invalid character.") end
                    local status, reason = hook.Run("CanPlayerUseChar", client, character)
                    if status == false then
                        if reason[1] == "@" then reason = reason:sub(2) end
                        return response(reason)
                    end

                    if currentChar then
                        status, reason = hook.Run("CanPlayerSwitchChar", client, currentChar, character)
                        if status == false then
                            if reason[1] == "@" then reason = reason:sub(2) end
                            return response(reason)
                        end

                        currentChar:save()
                    end

                    local unloadedCount = lia.char.unloadUnusedCharacters(client, id)
                    if unloadedCount > 0 then lia.information("Unloaded" .. " " .. unloadedCount .. " " .. "unused characters for" .. " " .. client:Name()) end
                    hook.Run("PrePlayerLoadedChar", client, character, currentChar)
                    character:setup()
                    hook.Run("PlayerLoadedChar", client, character, currentChar)
                    response()
                    hook.Run("PostPlayerLoadedChar", client, character, currentChar)
                end)
            end)
            return
        end

        lia.char.loadSingleCharacter(id, client, function(character)
            if not character then return response(false, "Invalid character.") end
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
            if unloadedCount > 0 then lia.information("Unloaded" .. " " .. unloadedCount .. " " .. "unused characters for" .. " " .. client:Name()) end
            hook.Run("PrePlayerLoadedChar", client, character, currentChar)
            character:setup()
            hook.Run("PlayerLoadedChar", client, character, currentChar)
            response()
            hook.Run("PostPlayerLoadedChar", client, character, currentChar)
        end)
        return
    end

    local character = lia.char.getCharacter(id, client)
    if not character or character:getPlayer() ~= client then return response(false, "Invalid character.") end
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
    if unloadedCount > 0 then lia.information("Unloaded" .. " " .. unloadedCount .. " " .. "unused characters for" .. " " .. client:Name()) end
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
        net.WriteString(string.format(tostring(message or ""), client, ...))
        net.Send(client)
    end

    local numValues = net.ReadUInt(32)
    local data = {}
    for _ = 1, numValues do
        data[net.ReadString()] = net.ReadType()
    end

    if not (istable(data) and data.faction == FACTION_STAFF) and hook.Run("CanPlayerCreateChar", client, data) == false then return response(nil, "You have reached the maximum number of characters.") end
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
                result[2] = result[2] or "Validation error."
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
                hook.Run("SyncCharList", client)
                hook.Run("OnCharCreated", client, character, originalData)
                local currentChar = client:getChar()
                if currentChar then currentChar:save() end
                local unloadedCount = lia.char.unloadUnusedCharacters(client, id)
                if unloadedCount > 0 then lia.information("Unloaded" .. " " .. unloadedCount .. " " .. "unused characters for" .. " " .. client:Name()) end
                hook.Run("PrePlayerLoadedChar", client, character, currentChar)
                character:setup()
                hook.Run("PlayerLoadedChar", client, character, currentChar)
                hook.Run("PostPlayerLoadedChar", client, character, currentChar)
                response(id)
            end)
        end
    end)
end)

net.Receive("liaCharDelete", function(_, client)
    local id = net.ReadUInt(32)
    local steamID = client:SteamID()
    local character = lia.char.loaded[id]
    if character then
        if character.steamID == steamID then
            hook.Run("CharDeleted", client, character)
            character:delete()
            timer.Simple(.5, function() hook.Run("SyncCharList", client) end)
        end
        return
    end

    lia.db.selectOne("*", "characters", "id = " .. id):next(function(result)
        if not result then return end
        if result.steamID ~= steamID then return end
        if not table.HasValue(client.liaCharList or {}, id) then return end
        lia.char.getCharacter(id, client, function(loadedChar)
            if not loadedChar then return end
            hook.Run("CharDeleted", client, loadedChar)
            loadedChar:delete()
            timer.Simple(.5, function() hook.Run("SyncCharList", client) end)
        end)
    end)
end)

net.Receive("liaMessageData", function(_, client)
    local text = net.ReadString()
    if not text then return end
    local charlimit = lia.config.get("MaxChatLength")
    if charlimit > 0 then
        if (client.liaNextChat or 0) < CurTime() and text:find("%S") then
            hook.Run("PlayerSay", client, text)
            client.liaNextChat = CurTime() + math.max(#text / 250, 0.4)
        end
    else
        if utf8.len(text) > charlimit then
            client:notifyError(string.format("Your message has been shortened due to being longer than %s characters!", charlimit))
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
    local description = string.format("Staff Character - Discord: %s, SteamID: %s", discord, steamID)
    character:setDesc(description)
    client:notifySuccess(string.format("Staff character description updated!"))
end)

net.Receive("liaReturnFromEntity", function(_, client)
    if not client.previousPosition then
        client:notifyError(string.format("No previous position"))
        return
    end

    local returnPos = client.previousPosition
    client:SetPos(returnPos)
    client.previousPosition = nil
    client:notifySuccess(string.format("Returned from entity"))
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
    local isOrdered = istable(spec) and #spec > 0 and istable(spec[1])
    if isOrdered then
        for _, argInfo in ipairs(spec) do
            local name, typeInfo = argInfo[1], argInfo[2]
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
                    client:notifyError(string.format("Please fill in all required fields."))
                    client.liaArgReqs[id] = nil
                    return
                end
            end
        end
    else
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
                    client:notifyError(string.format("Please fill in all required fields."))
                    client.liaArgReqs[id] = nil
                    return
                end
            end
        end
    end

    if isfunction(req.callback) then req.callback(true, data) end
    client.liaArgReqs[id] = nil
end)

net.Receive("liaArgumentsRequestCancel", function(_, client)
    local id = net.ReadUInt(32)
    local req = client.liaArgReqs and client.liaArgReqs[id]
    if req and isfunction(req.callback) then req.callback(false) end
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
        if isstring(optionText) and optionText:sub(1, 1) == "@" then optionText = tostring(optionText:sub(2)) end
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
            if isstring(allowedText) and allowedText:sub(1, 1) == "@" then allowedText = tostring(allowedText:sub(2)) end
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

net.Receive("liaPopupQuestionRequest", function(_, client)
    local id = net.ReadUInt(32)
    local buttonIndex = net.ReadUInt(8)
    local callbacks = client.liaPopupReqs and client.liaPopupReqs[id]
    if not callbacks or not callbacks[buttonIndex] then return end
    if isfunction(callbacks[buttonIndex]) then callbacks[buttonIndex]() end
    client.liaPopupReqs[id] = nil
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

net.Receive("liaTransferItem", function(_, client)
    local itemID = net.ReadUInt(32)
    local x = net.ReadUInt(32)
    local y = net.ReadUInt(32)
    local invID = net.ReadType()
    local hasRotatedOverride = net.ReadBool()
    local rotated = hasRotatedOverride and net.ReadBool() or nil
    hook.Run("HandleItemTransferRequest", client, itemID, x, y, invID, rotated)
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
        local ent = ply:getTracedEntity(100)
        if not IsValid(ent) then
            net.Start("liaProvideInteractOptions")
            net.WriteString(requestType)
            net.WriteUInt(0, 16)
            net.Send(ply)
            return
        end

        for name, opt in pairs(lia.playerinteract.stored or {}) do
            if opt.type == "interaction" then
                local maxRange = opt.range and math.min(opt.range, 100) or 100
                if lia.playerinteract.isWithinRange(ply, ent, maxRange) then
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

local chunkTime = 0.05
local function getChunkInterval()
    return (lia.reloadInProgress and chunkTime * 2) or chunkTime
end

local function sendChunk(ply, s, sid, idx)
    if not IsValid(ply) then
        if lia.net.sendq[ply] then lia.net.sendq[ply][sid] = nil end
        return
    end

    local part = s.chunks[idx]
    if not part then
        if lia.net.sendq[ply] then lia.net.sendq[ply][sid] = nil end
        return
    end

    s.idx = idx
    net.Start(s.netStr)
    net.WriteUInt(sid, 32)
    net.WriteUInt(s.total, 16)
    net.WriteUInt(idx, 16)
    net.WriteUInt(#part, 16)
    net.WriteData(part, #part)
    net.Send(ply)
    if idx == s.total and lia.net.sendq[ply] then lia.net.sendq[ply][sid] = nil end
end

net.Receive("liaBigTableAck", function(_, ply)
    if not IsValid(ply) then return end
    local sid = net.ReadUInt(32)
    local last = net.ReadUInt(16)
    local q = lia.net.sendq[ply]
    if not q then return end
    local s = q[sid]
    if not s then return end
    if last ~= s.idx then return end
    if s.idx >= s.total then
        q[sid] = nil
        return
    end

    timer.Simple(getChunkInterval(), function()
        if not IsValid(ply) then return end
        local qq = lia.net.sendq[ply]
        if not qq then return end
        local ss = qq[sid]
        if not ss then return end
        sendChunk(ply, ss, sid, ss.idx + 1)
    end)
end)

net.Receive("liaWaypointReached", function(_, client)
    if client.waypointOnReach and isfunction(client.waypointOnReach) then
        client.waypointOnReach(client)
        client.waypointOnReach = nil
    end
end)

net.Receive("liaItemRotate", function(_, client)
    local itemID = net.ReadUInt(32)
    local rotated = net.ReadBool()
    local item = lia.item.instances[itemID]
    if not item then return end
    local inventory = lia.inventory.instances[item.invID]
    if not inventory then return end
    local canAccess = inventory:canAccess("item", {
        client = client,
        item = item,
        action = "rotate"
    })

    if not canAccess then return end
    item:setData("rotated", rotated)
    item.forceRender = true
end)

net.Receive("liaWorkshopDownloaderRequest", function(_, client) lia.workshop.send(client) end)
local function broadcastGroups()
    lia.net.ready = lia.net.ready or setmetatable({}, {
        __mode = "k"
    })

    local players = player.GetHumans()
    for _, ply in ipairs(players) do
        if lia.net.ready[ply] then lia.net.writeBigTable(ply, "liaUpdateAdminGroups", lia.admin.groups or {}) end
    end
end

net.Receive("liaGroupsRequest", function(_, p)
    if not IsValid(p) or not p:hasPrivilege("manageUsergroups") then return end
    lia.net.ready = lia.net.ready or setmetatable({}, {
        __mode = "k"
    })

    lia.net.ready[p] = true
    lia.admin.sync(p)
end)

net.Receive("liaGroupsAdd", function(_, p)
    if not p:hasPrivilege("manageUsergroups") then return end
    local data = net.ReadTable()
    local n = string.Trim(tostring(data.name or ""))
    local icon = string.Trim(tostring(data.icon or ""))
    if n == "" then return end
    lia.admin.groups = lia.admin.groups or {}
    if lia.admin.DefaultGroups and lia.admin.DefaultGroups[n] then
        p:notifyError(string.format("Base usergroups cannot be edited"))
        return
    end

    if lia.admin.groups[n] then return end
    lia.admin.createGroup(n, {
        _info = {
            inheritance = data.inherit or "user",
            types = data.types or {}
        },
        icon = icon ~= "" and icon or nil
    })

    lia.admin.save()
    broadcastGroups()
    p:notifySuccess(string.format("Group '%s' created.", n))
end)

net.Receive("liaGroupsRemove", function(_, p)
    if not p:hasPrivilege("manageUsergroups") then return end
    local n = net.ReadString()
    if n == "" then return end
    if lia.admin.DefaultGroups and lia.admin.DefaultGroups[n] then
        p:notifyError(string.format("[Lilia Administration] The base usergroups cannot be removed!"))
        return
    end

    lia.admin.removeGroup(n)
    if lia.admin.groups then lia.admin.groups[n] = nil end
    lia.admin.save()
    broadcastGroups()
    p:notifySuccess(string.format("Group '%s' removed.", n))
end)

net.Receive("liaGroupsRename", function(_, p)
    if not p:hasPrivilege("manageUsergroups") then return end
    local old = string.Trim(net.ReadString() or "")
    local new = string.Trim(net.ReadString() or "")
    if old == "" or new == "" then return end
    if old == new then return end
    if not lia.admin.groups or not lia.admin.groups[old] then return end
    if lia.admin.groups[new] or lia.admin.DefaultGroups and lia.admin.DefaultGroups[new] then
        p:notifyError(string.format("[Lilia Administration] The base usergroups cannot be renamed!"))
        return
    end

    if lia.admin.DefaultGroups and lia.admin.DefaultGroups[old] then
        p:notifyError(string.format("[Lilia Administration] The base usergroups cannot be renamed!"))
        return
    end

    lia.admin.renameGroup(old, new)
    broadcastGroups()
    p:notifySuccess(string.format("Group '%s' renamed to '%s'.", old, new))
end)

local function getGroupLevelForPermissionSummary(groupName, visited)
    visited = visited or {}
    if visited[groupName] then return 1 end
    visited[groupName] = true
    local defaultGroups = lia.admin.DefaultGroups or {}
    if defaultGroups[groupName] then return defaultGroups[groupName] end
    local groupData = lia.admin.groups and lia.admin.groups[groupName]
    if not groupData then return 1 end
    local inheritance = groupData._info and groupData._info.inheritance or "user("
    if inheritance == groupName then return 1 end
    return getGroupLevelForPermissionSummary(inheritance, visited)
end

local function getDefaultPermissionValueForSummary(groupName, privilege, visited)
    visited = visited or {}
    local visitKey = tostring(groupName) .. "):" .. tostring(privilege)
    if visited[visitKey] then return false end
    visited[visitKey] = true
    local privilegeMinAccess = lia.admin.privileges and lia.admin.privileges[privilege]
    local defaultGroups = lia.admin.DefaultGroups or {}
    if privilegeMinAccess and getGroupLevelForPermissionSummary(groupName) >= (defaultGroups[tostring(privilegeMinAccess):lower()] or 1) then return true end
    local groupData = lia.admin.groups and lia.admin.groups[groupName]
    if not groupData then return false end
    local inheritance = groupData._info and groupData._info.inheritance or "user"
    if inheritance and inheritance ~= "" and inheritance ~= groupName then
        local inheritedGroup = lia.admin.groups and lia.admin.groups[inheritance]
        if inheritedGroup and inheritedGroup[privilege] == true then return true end
        return getDefaultPermissionValueForSummary(inheritance, privilege, visited)
    end
    return false
end

local function getGroupPermissionOverrides(groupName)
    local groupData = lia.admin.groups and lia.admin.groups[groupName]
    if not groupData then return {} end
    local overrides = {}
    for permission in pairs(lia.admin.privileges or {}) do
        if permission ~= "_info" and groupData[permission] ~= nil then
            local currentValue = groupData[permission] == true
            local defaultValue = getDefaultPermissionValueForSummary(groupName, permission)
            if currentValue ~= defaultValue then overrides[#overrides + 1] = (currentValue and "+" or "-") .. permission end
        end
    end

    table.sort(overrides)
    return overrides
end

net.Receive("liaGroupsSetPerm", function(_, p)
    if not p:hasPrivilege("manageUsergroups") then return end
    local group = net.ReadString()
    local privilege = net.ReadString()
    local value = net.ReadBool()
    if group == "" or privilege == "" then return end
    if lia.admin.DefaultGroups and lia.admin.DefaultGroups[group] then
        p:notifyError(string.format("Base usergroups cannot be edited"))
        return
    end

    if not lia.admin.groups or not lia.admin.groups[group] then return end
    lia.debug("[Permissions UI]", "Received permission edit request", "editor=", tostring(IsValid(p) and p:Nick() .. " (" .. p:SteamID() .. ")" or "unknown"), "group=", tostring(group), "privilege=", tostring(privilege), "requestedValue=", tostring(value), "previousExplicitValue=", tostring(lia.admin.groups[group][privilege]), "previousEffectiveValue=", tostring(lia.admin.hasAccess(group, privilege)))
    if SERVER then
        if value then
            lia.admin.addPermission(group, privilege, true)
        else
            lia.admin.removePermission(group, privilege, true)
        end
    end

    lia.debug("[Permissions UI]", "Applied permission edit request", "group=", tostring(group), "privilege=", tostring(privilege), "newExplicitValue=", tostring(lia.admin.groups[group] and lia.admin.groups[group][privilege]), "newEffectiveValue=", tostring(lia.admin.hasAccess(group, privilege)))
    local overrides = getGroupPermissionOverrides(group)
    local lines = {"Usergroup " .. string.upper(tostring(group))}
    local changedPrefix = value and "[+] " or "[-] "
    local changedPermissionName = lia.admin.privilegeNames and lia.admin.privilegeNames[privilege] or privilege
    lines[#lines + 1] = changedPrefix .. tostring(changedPermissionName) .. " - " .. privilege
    for _, override in ipairs(overrides) do
        local permissionID = override:sub(2)
        if permissionID ~= privilege then
            local prefix = override:sub(1, 1) == "+" and "[+] " or "[-] "
            local permissionName = lia.admin.privilegeNames and lia.admin.privilegeNames[permissionID] or permissionID
            lines[#lines + 1] = prefix .. tostring(permissionName) .. " - " .. permissionID
        end
    end

    lia.information(table.concat(lines, "\n"))
    net.Start("liaGroupPermChanged")
    net.WriteString(group)
    net.WriteString(privilege)
    net.WriteBool(value)
    net.Broadcast()
    p:notifySuccess(string.format("Group permissions updated."))
end)
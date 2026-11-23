function MODULE:PostLoadData()
    if lia.config.get("DoorsAlwaysDisabled", false) then
        local count = 0
        for _, door in ents.Iterator() do
            if IsValid(door) and door:isDoor() then
                local doorData = lia.doors.getCachedData(door)
                if not doorData or table.IsEmpty(doorData) then
                    lia.doors.setCachedData(door, {
                        disabled = true
                    })

                    count = count + 1
                else
                    doorData.disabled = true
                    lia.doors.setCachedData(door, doorData)
                    count = count + 1
                end
            end
        end

        lia.information("All doors have been disabled.")
    end
end

local function buildCondition(gamemode, map)
    return "gamemode = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map)
end

function MODULE:LoadData()
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local mapName = game.GetMap()
    local condition = buildCondition(gamemode, mapName)
    local _, extraFields = lia.doors.getDoorDefaultValues()
    local query = "SELECT * FROM lia_doors WHERE " .. condition
    lia.db.query(query):next(function(res)
        local rows = res.results or {}
        local loadedCount = 0
        local presetData = lia.doors.getPreset(mapName)
        local doorsWithData = {}
        for _, row in ipairs(rows) do
            local id = tonumber(row.id)
            if id then doorsWithData[id] = true end
        end

        for _, row in ipairs(rows) do
            local id = tonumber(row.id)
            if not id then
                lia.warning("Skipping door record with invalid ID:(" .. "): " .. tostring(row.id))
                continue
            end

            local ent = ents.GetMapCreatedEntity(id)
            if not IsValid(ent) then
                lia.warning(string.format("Door entity %s not found in map, skipping", id))
                continue
            end

            if not ent:isDoor() then
                lia.warning("Entity Is Not A Door, Skipping" .. " " .. id .. " (Class: " .. ent:GetClass() .. ")")
                continue
            end

            local factions
            if row.factions and row.factions ~= "NULL" and row.factions ~= "" then
                if tostring(row.factions):match("^[%d%.%-%s]+$") and not tostring(row.factions):match("[{}%[%]]") then
                    lia.warning("Door Has Coordinate Data In Factions Column" .. " (" .. id .. "): " .. tostring(row.factions))
                    lia.warning("This suggests data corruption. Clearing factions data.")
                    row.factions = ""
                else
                    local success, result = pcall(lia.data.deserialize, row.factions)
                    if success and istable(result) then
                        local isEmpty
                        if table.IsEmpty then
                            isEmpty = table.IsEmpty(result)
                        else
                            isEmpty = next(result) == nil
                        end

                        if not isEmpty then
                            factions = result
                            ent.liaFactions = factions
                        else
                            factions = result
                            ent.liaFactions = factions
                        end
                    else
                        lia.warning(string.format("Failed to deserialize factions for door %s(", id) .. "): " .. tostring(result))
                        lia.warning("Raw factions data:" .. " " .. tostring(row.factions))
                    end
                end
            end

            local classes
            if row.classes and row.classes ~= "NULL" and row.classes ~= "" then
                if tostring(row.classes):match("^[%d%.%-%s]+$") and not tostring(row.classes):match("[{}%[%]]") then
                    lia.warning(string.format("Door %s has coordinate-like data in classes column: %s", id, tostring(row.classes)))
                    lia.warning("This suggests data corruption. Clearing classes data.")
                    row.classes = ""
                else
                    local success, result = pcall(lia.data.deserialize, row.classes)
                    if success and istable(result) then
                        local isEmpty
                        if table.IsEmpty then
                            isEmpty = table.IsEmpty(result)
                        else
                            isEmpty = next(result) == nil
                        end

                        if not isEmpty then
                            classes = result
                            ent.liaClasses = classes
                        else
                            classes = result
                            ent.liaClasses = classes
                        end
                    else
                        lia.warning(string.format("Failed to deserialize classes for door %s(", id) .. "): " .. tostring(result))
                        lia.warning("Raw classes data:" .. " " .. tostring(row.classes))
                    end
                end
            end

            local hasData = false
            local doorData = {}
            if row.name and row.name ~= "NULL" and row.name ~= "" then
                doorData.name = tostring(row.name)
                hasData = true
            end

            local price = tonumber(row.price)
            if price and price > 0 then
                doorData.price = price
                hasData = true
            end

            if tonumber(row.disabled) == 1 then
                doorData.disabled = true
                hasData = true
            end

            if tonumber(row.hidden) == 1 then
                doorData.hidden = true
                hasData = true
            end

            if tonumber(row.ownable) == 0 then
                doorData.noSell = true
                hasData = true
            end

            if factions and #factions > 0 then
                doorData.factions = factions
                doorData.noSell = true
                hasData = true
            end

            if classes and #classes > 0 then
                doorData.classes = classes
                doorData.noSell = true
                hasData = true
            end

            for fieldName, info in pairs(extraFields) do
                local columnName = info and info.column or fieldName
                local value = row[columnName]
                local defaultValue = info and info.default
                if value ~= nil then
                    if info and info.type and string.find(string.lower(info.type), "int", 1, true) then value = tonumber(value) or defaultValue end
                    doorData[fieldName] = value
                    if defaultValue == nil or value ~= defaultValue then hasData = true end
                elseif defaultValue ~= nil then
                    doorData[fieldName] = defaultValue
                end
            end

            if hasData then
                doorData = hook.Run("PostDoorDataLoad", ent, doorData) or doorData
                lia.doors.setCachedData(ent, doorData)
                loadedCount = loadedCount + 1
            end
        end

        if presetData then
            for doorID, doorVars in pairs(presetData) do
                if not doorsWithData[doorID] then
                    local ent = ents.GetMapCreatedEntity(doorID)
                    if IsValid(ent) and ent:isDoor() then
                        local hasPresetData = false
                        local doorData = {}
                        if doorVars.name and tostring(doorVars.name) ~= "" then
                            doorData.name = tostring(doorVars.name)
                            hasPresetData = true
                        end

                        if doorVars.price and doorVars.price > 0 then
                            doorData.price = doorVars.price
                            hasPresetData = true
                        end

                        if doorVars.disabled then
                            doorData.disabled = true
                            hasPresetData = true
                        end

                        if doorVars.hidden then
                            doorData.hidden = true
                            hasPresetData = true
                        end

                        if doorVars.noSell then
                            doorData.noSell = true
                            hasPresetData = true
                        end

                        if doorVars.factions and istable(doorVars.factions) and not table.IsEmpty(doorVars.factions) then
                            doorData.factions = doorVars.factions
                            ent.liaFactions = doorVars.factions
                            doorData.noSell = true
                            hasPresetData = true
                        end

                        if doorVars.classes and istable(doorVars.classes) and not table.IsEmpty(doorVars.classes) then
                            doorData.classes = doorVars.classes
                            ent.liaClasses = doorVars.classes
                            doorData.noSell = true
                            hasPresetData = true
                        end

                        if hasPresetData then
                            doorData = hook.Run("PostDoorDataLoad", ent, doorData) or doorData
                            lia.doors.setCachedData(ent, doorData)
                            lia.information(string.format("Applied preset to door ID %s", doorID))
                            loadedCount = loadedCount + 1
                        end
                    else
                        lia.warning(string.format("Door entity %s not found for preset application", doorID))
                    end
                end
            end
        end
    end):catch(function(err)
        lia.error(string.format("Failed to load door data: %s", tostring(err)))
        lia.error("This may indicate a database connection issue or missing table")
    end)
end

function MODULE:SaveData()
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = game.GetMap()
    local rows = {}
    local doorCount = 0
    local _, extraFields = lia.doors.getDoorDefaultValues()
    for _, door in ents.Iterator() do
        if door:isDoor() then
            local mapID = door:MapCreationID()
            if not mapID or mapID <= 0 then continue end
            local doorData = lia.doors.getCachedData(door)
            if not doorData or table.IsEmpty(doorData) then continue end
            doorData = hook.Run("PreDoorDataSave", door, doorData) or doorData
            local factionsTable = doorData.factions or {}
            local classesTable = doorData.classes or {}
            if not doorData.factions and door.liaFactions then factionsTable = door.liaFactions end
            if not doorData.classes and door.liaClasses then classesTable = door.liaClasses end
            if not istable(factionsTable) then
                lia.warning(string.format("Door %s has invalid factions data type: %s, resetting to empty table", mapID, type(factionsTable)))
                factionsTable = {}
            end

            if not istable(classesTable) then
                lia.warning(string.format("Door %s has invalid classes data type: %s, resetting to empty table", mapID, type(classesTable)))
                classesTable = {}
            end

            local factionsSerialized = lia.data.serialize(factionsTable)
            local classesSerialized = lia.data.serialize(classesTable)
            if factionsSerialized and factionsSerialized:match("^[%d%.%-%s]+$") and not factionsSerialized:match("[{}%[%]]") then
                lia.warning(string.format("Door %s factions would serialize to coordinate-like data, resetting to empty", mapID))
                factionsTable = {}
                factionsSerialized = lia.data.serialize(factionsTable)
            end

            if classesSerialized and classesSerialized:match("^[%d%.%-%s]+$") and not classesSerialized:match("[{}%[%]]") then
                lia.warning(string.format("Door %s classes would serialize to coordinate-like data, resetting to empty", mapID))
                classesTable = {}
                classesSerialized = lia.data.serialize(classesTable)
            end

            local name = doorData.name or ""
            if name and name ~= "" then
                name = tostring(name):sub(1, 255)
            else
                name = ""
            end

            local price = tonumber(doorData.price) or 0
            if price < 0 then price = 0 end
            if price > 999999999 then price = 999999999 end
            local hasFactions = istable(factionsTable) and #factionsTable > 0
            local hasClasses = istable(classesTable) and #classesTable > 0
            local isUnownable = doorData.noSell or hasFactions or hasClasses
            local row = {
                gamemode = gamemode,
                map = map,
                id = mapID,
                factions = factionsSerialized,
                classes = classesSerialized,
                disabled = doorData.disabled and 1 or 0,
                hidden = doorData.hidden and 1 or 0,
                ownable = isUnownable and 0 or 1,
                name = name,
                price = price,
            }

            for fieldName, info in pairs(extraFields) do
                local columnName = info and info.column or fieldName
                local value = doorData[fieldName]
                if value == nil then value = info and info.default end
                if value ~= nil then
                    if info and info.type and string.find(string.lower(info.type), "int", 1, true) then value = math.floor(tonumber(value) or 0) end
                    row[columnName] = value
                end
            end

            rows[#rows + 1] = row
            doorCount = doorCount + 1
        end
    end

    if #rows > 0 then
        lia.db.bulkUpsert("doors", rows):next(function() end):catch(function(err)
            lia.error(string.format("Failed to save door data: %s", tostring(err)))
            lia.error("This may indicate a database connection issue or schema problem")
        end)
    end
end

function MODULE:InitPostEntity()
    local doors = ents.FindByClass("prop_door_rotating")
    for _, v in ipairs(doors) do
        local parent = v:GetOwner()
        if IsValid(parent) then
            v.liaPartner = parent
            parent.liaPartner = v
        else
            for _, v2 in ipairs(doors) do
                if v2:GetOwner() == v then
                    v2.liaPartner = v
                    v.liaPartner = v2
                    break
                end
            end
        end
    end

    timer.Simple(1, function()
        lia.db.waitForTablesToLoad():next(function()
            lia.doors.cleanupCorruptedData()
            lia.doors.verifyDatabaseSchema()
        end)
    end)
end

function MODULE:PlayerUse(client, door)
    if door:IsVehicle() and door:isLocked() then return false end
    if door:isDoor() then
        local result = hook.Run("CanPlayerUseDoor", client, door)
        if result == false then
            return false
        else
            result = hook.Run("PlayerUseDoor", client, door)
            if result ~= nil then return result end
        end
    end
end

function MODULE:CanPlayerUseDoor(client, door)
    local doorData = lia.doors.getData(door)
    if doorData.disabled then return false end
end

function MODULE:CanPlayerAccessDoor(client, door)
    local doorData = lia.doors.getData(door)
    local factions = doorData.factions
    if factions and #factions > 0 then
        local playerFaction = client:getChar():getFaction()
        local factionData = lia.faction.indices[playerFaction]
        local unique = factionData and factionData.uniqueID
        for _, id in ipairs(factions) do
            if id == unique or lia.faction.getIndex(id) == playerFaction then return true end
        end
    end

    local classes = doorData.classes
    local charClass = client:getChar():getClass()
    local charClassData = lia.class.list[charClass]
    if classes and #classes > 0 and charClassData then
        local unique = charClassData.uniqueID
        for _, id in ipairs(classes) do
            local classIndex = lia.class.retrieveClass(id)
            if id == unique or classIndex == charClass then return true end
        end
        return false
    end
end

function MODULE:PostPlayerLoadout(client)
    client:Give("lia_keys")
end

function MODULE:ShowTeam(client)
    local entity = client:getTracedEntity()
    if IsValid(entity) and entity:isDoor() then
        local doorData = lia.doors.getData(entity)
        local factions = doorData.factions
        local classes = doorData.classes
        if (not factions or #factions == 0) and (not classes or #classes == 0) then
            if entity:checkDoorAccess(client, DOOR_TENANT) then
                local door = entity
                net.Start("liaDoorMenu")
                net.WriteEntity(door)
                local access = door.liaAccess or {}
                net.WriteUInt(table.Count(access), 8)
                for ply, perm in pairs(access) do
                    net.WriteEntity(ply)
                    net.WriteUInt(perm or 0, 2)
                end

                net.WriteEntity(entity)
                net.Send(client)
            elseif not IsValid(entity:GetDTEntity(0)) then
                lia.command.run(client, "doorbuy")
            else
                client:notifyError(string.format("You are not allowed to do this right now."))
            end
            return true
        end
    end
end

function MODULE:PlayerDisconnected(client)
    for _, v in ents.Iterator() do
        if v ~= client and v.isDoor and v:isDoor() and v:GetDTEntity(0) == client then v:removeDoorAccessData() end
    end
end

local function ToggleLock(client, door, state)
    if not IsValid(door) then return end
    if door:isDoor() then
        local partner = door:getDoorPartner()
        if state then
            if IsValid(partner) then partner:Fire("lock") end
            door:Fire("lock")
            client:EmitSound("doors/door_latch3.wav")
        else
            if IsValid(partner) then partner:Fire("unlock") end
            door:Fire("unlock")
            client:EmitSound("doors/door_latch1.wav")
        end

        door:setLocked(state)
    elseif (door:GetCreator() == client or client:hasPrivilege("manageDoors") or client:isStaffOnDuty()) and (door:IsVehicle() or door:isSimfphysCar()) then
        lia.debug("[Permissions]", "Permission Check for function ToggleLock vehicle branch", "doorCreatorMatch=", tostring(door:GetCreator() == client), "hasPrivilege(manageDoors)=", tostring(client:hasPrivilege("manageDoors")), "isStaffOnDuty=", tostring(client:isStaffOnDuty()), "isVehicle=", tostring(door:IsVehicle()), "isSimfphysCar=", tostring(door:isSimfphysCar()), "finalResult=", tostring((door:GetCreator() == client or client:hasPrivilege("manageDoors") or client:isStaffOnDuty()) and (door:IsVehicle() or door:isSimfphysCar())))
        if state then
            door:Fire("lock")
            client:EmitSound("doors/door_latch3.wav")
        else
            door:Fire("unlock")
            client:EmitSound("doors/door_latch1.wav")
        end

        door:setLocked(state)
    end

    hook.Run("DoorLockToggled", client, door, state)
end

local function resetKeyCooldown(client)
    if not IsValid(client) then return end
    local wep = client:GetActiveWeapon()
    if IsValid(wep) and wep:GetClass() == "lia_keys" then
        wep:SetNextPrimaryFire(CurTime())
        wep:SetNextSecondaryFire(CurTime())
    end
end

local function isLockableEntity(entity)
    return IsValid(entity) and (entity:isDoor() or entity:IsVehicle() or entity:isSimfphysCar())
end

function MODULE:KeyLock(client, door, time)
    if not IsValid(door) or not IsValid(client) then return end
    if hook.Run("CanPlayerLock", client, door) == false then return end
    local isProperEntity = isLockableEntity(door)
    local distance = client:GetPos():Distance(door:GetPos())
    local hasDoorAccess = isProperEntity and door:checkDoorAccess(client) or false
    local isCreator = door:GetCreator() == client
    local isStaffOnDuty = client:isStaffOnDuty()
    local isLocked = isProperEntity and door:isLocked() or false
    local permission = isProperEntity and not isLocked and distance <= 256 and (hasDoorAccess or isCreator or isStaffOnDuty)
    lia.debug("[Permissions]", "Permission Check for function MODULE:KeyLock", "isProperEntity=", tostring(isProperEntity), "doorIsLocked=", tostring(isLocked), "distanceWithin256=", tostring(distance <= 256), "door:checkDoorAccess=", tostring(hasDoorAccess), "doorCreatorMatch=", tostring(isCreator), "isStaffOnDuty=", tostring(isStaffOnDuty), "finalResult=", tostring(permission))
    if permission then
        client:stopAction()
        client:setAction("Locking this entity...", time, function() end)
        client:doStaredAction(door, function() ToggleLock(client, door, true) end, time, function()
            client:stopAction()
            resetKeyCooldown(client)
        end)

    end
end

function MODULE:KeyUnlock(client, door, time)
    if not IsValid(door) or not IsValid(client) then return end
    if hook.Run("CanPlayerUnlock", client, door) == false then return end
    local isProperEntity = isLockableEntity(door)
    local distance = client:GetPos():Distance(door:GetPos())
    local hasDoorAccess = isProperEntity and door:checkDoorAccess(client) or false
    local isCreator = door:GetCreator() == client
    local isStaffOnDuty = client:isStaffOnDuty()
    local isLocked = isProperEntity and door:isLocked() or false
    local permission = isProperEntity and isLocked and distance <= 256 and (hasDoorAccess or isCreator or isStaffOnDuty)
    lia.debug("[Permissions]", "Permission Check for function MODULE:KeyUnlock", "isProperEntity=", tostring(isProperEntity), "doorIsLocked=", tostring(isLocked), "distanceWithin256=", tostring(distance <= 256), "door:checkDoorAccess=", tostring(hasDoorAccess), "doorCreatorMatch=", tostring(isCreator), "isStaffOnDuty=", tostring(isStaffOnDuty), "finalResult=", tostring(permission))
    if permission then
        client:stopAction()
        client:setAction("Unlocking this entity...", time, function() end)
        client:doStaredAction(door, function() ToggleLock(client, door, false) end, time, function()
            client:stopAction()
            resetKeyCooldown(client)
        end)

    end
end

function MODULE:PostLoadData()
    if lia.config.get("DoorsAlwaysDisabled", false) then
        local count = 0
        for _, door in ents.Iterator() do
            if IsValid(door) and door:isDoor() then
                local doorData = door:getNetVar("doorData", {})
                doorData.disabled = true
                door:setNetVar("doorData", doorData)
                count = count + 1
            end
        end

        lia.information(L("doorDisableAll"))
    end
end

local function buildCondition(gamemode, map)
    return "gamemode = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map)
end

function MODULE:LoadData()
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local mapName = game.GetMap()
    local condition = buildCondition(gamemode, mapName)
    local query = "SELECT * FROM lia_doors WHERE " .. condition
    lia.db.query(query):next(function(res)
        local rows = res.results or {}
        local loadedCount = 0
        local presetData = lia.doors.GetPreset(mapName)
        local doorsWithData = {}
        for _, row in ipairs(rows) do
            local id = tonumber(row.id)
            if id then doorsWithData[id] = true end
        end

        for _, row in ipairs(rows) do
            local id = tonumber(row.id)
            if not id then
                lia.warning("Skipping door record with invalid ID: " .. tostring(row.id))
                continue
            end

            local ent = ents.GetMapCreatedEntity(id)
            if not IsValid(ent) then
                lia.warning("Door entity " .. id .. " not found in map, skipping")
                continue
            end

            if not ent:isDoor() then
                lia.warning("Entity " .. id .. " is not a door, skipping")
                continue
            end

            local factions
            if row.factions and row.factions ~= "NULL" and row.factions ~= "" then
                if tostring(row.factions):match("^[%d%.%-%s]+$") and not tostring(row.factions):match("[{}%[%]]") then
                    lia.warning("Door " .. id .. " has coordinate-like data in factions column: " .. tostring(row.factions))
                    lia.warning(L("dataCorruptionClearingFactions"))
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
                            ent:setNetVar("factions", util.TableToJSON(factions))
                        else
                            factions = result
                            ent.liaFactions = factions
                            ent:setNetVar("factions", util.TableToJSON(factions))
                        end
                    else
                        lia.warning(L("failedDeserializeDoorFactions", id, tostring(result)))
                        lia.warning("Raw factions data: " .. tostring(row.factions))
                    end
                end
            end

            local classes
            if row.classes and row.classes ~= "NULL" and row.classes ~= "" then
                if tostring(row.classes):match("^[%d%.%-%s]+$") and not tostring(row.classes):match("[{}%[%]]") then
                    lia.warning("Door " .. id .. " has coordinate-like data in classes column: " .. tostring(row.classes))
                    lia.warning(L("dataCorruptionClearingClasses"))
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
                            ent:setNetVar("classes", util.TableToJSON(classes))
                        else
                            classes = result
                            ent.liaClasses = classes
                            ent:setNetVar("classes", util.TableToJSON(classes))
                        end
                    else
                        lia.warning(L("failedDeserializeDoorClasses", id, tostring(result)))
                        lia.warning("Raw classes data: " .. tostring(row.classes))
                    end
                end
            end

            local doorData = {
                name = row.name and row.name ~= "NULL" and row.name ~= "" and tostring(row.name) or nil,
                price = tonumber(row.price) and tonumber(row.price) >= 0 and tonumber(row.price) or 0,
                locked = tonumber(row.locked) == 1,
                disabled = tonumber(row.disabled) == 1,
                hidden = tonumber(row.hidden) == 1,
                noSell = tonumber(row.ownable) == 0,
                factions = factions,
                classes = classes
            }

            ent:setNetVar("doorData", doorData)
            loadedCount = loadedCount + 1
        end

        if presetData then
            for doorID, doorVars in pairs(presetData) do
                if not doorsWithData[doorID] then
                    local ent = ents.GetMapCreatedEntity(doorID)
                    if IsValid(ent) and ent:isDoor() then
                        local doorData = {
                            name = doorVars.name and tostring(doorVars.name) or nil,
                            price = doorVars.price and doorVars.price >= 0 and doorVars.price or 0,
                            locked = doorVars.locked and true or false,
                            disabled = doorVars.disabled and true or nil,
                            hidden = doorVars.hidden and true or nil,
                            noSell = doorVars.noSell and true or nil,
                            factions = doorVars.factions and istable(doorVars.factions) and doorVars.factions or nil,
                            classes = doorVars.classes and istable(doorVars.classes) and doorVars.classes or nil
                        }

                        ent:setNetVar("doorData", doorData)
                        if doorVars.factions and istable(doorVars.factions) then ent.liaFactions = doorVars.factions end
                        if doorVars.classes and istable(doorVars.classes) then ent.liaClasses = doorVars.classes end
                        lia.information("Applied preset to door ID " .. doorID)
                        loadedCount = loadedCount + 1
                    else
                        lia.warning("Door entity " .. doorID .. " not found for preset application")
                    end
                end
            end
        end
    end):catch(function(err)
        lia.error(L("failedLoadDoorData", tostring(err)))
        lia.error(L("doorDatabaseConnectionIssue"))
    end)
end

function MODULE:SaveData()
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = game.GetMap()
    local rows = {}
    local doorCount = 0
    for _, door in ents.Iterator() do
        if door:isDoor() then
            local mapID = door:MapCreationID()
            if not mapID or mapID <= 0 then continue end
            local doorData = door:getNetVar("doorData", {})
            local factionsTable = doorData.factions or {}
            local classesTable = doorData.classes or {}
            if not doorData.factions then
                local factions = door:getNetVar("factions")
                if factions and factions ~= "[]" then
                    local success, result = pcall(util.JSONToTable, factions)
                    if success and istable(result) then
                        factionsTable = result
                    else
                        lia.warning(L("failedParseDoorFactionsJSON", mapID))
                    end
                elseif door.liaFactions then
                    factionsTable = door.liaFactions
                end
            end

            if not doorData.classes then
                local classes = door:getNetVar("classes")
                if classes and classes ~= "[]" then
                    local success, result = pcall(util.JSONToTable, classes)
                    if success and istable(result) then
                        classesTable = result
                    else
                        lia.warning(L("failedParseDoorClassesJSON", mapID))
                    end
                elseif door.liaClasses then
                    classesTable = door.liaClasses
                end
            end

            if not istable(factionsTable) then
                lia.warning("Door " .. mapID .. " has invalid factions data type: " .. type(factionsTable) .. ", resetting to empty table")
                factionsTable = {}
            end

            if not istable(classesTable) then
                lia.warning("Door " .. mapID .. " has invalid classes data type: " .. type(classesTable) .. ", resetting to empty table")
                classesTable = {}
            end

            local factionsSerialized = lia.data.serialize(factionsTable)
            local classesSerialized = lia.data.serialize(classesTable)
            if factionsSerialized and factionsSerialized:match("^[%d%.%-%s]+$") and not factionsSerialized:match("[{}%[%]]") then
                lia.warning("Door " .. mapID .. " factions would serialize to coordinate-like data, resetting to empty")
                factionsTable = {}
                factionsSerialized = lia.data.serialize(factionsTable)
            end

            if classesSerialized and classesSerialized:match("^[%d%.%-%s]+$") and not classesSerialized:match("[{}%[%]]") then
                lia.warning("Door " .. mapID .. " classes would serialize to coordinate-like data, resetting to empty")
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
            rows[#rows + 1] = {
                gamemode = gamemode,
                map = map,
                id = mapID,
                factions = factionsSerialized,
                classes = classesSerialized,
                disabled = doorData.disabled and 1 or 0,
                hidden = doorData.hidden and 1 or 0,
                ownable = doorData.noSell and 0 or 1,
                name = name,
                price = price,
                locked = doorData.locked and 1 or 0
            }

            doorCount = doorCount + 1
        end
    end

    if #rows > 0 then
        lia.db.bulkUpsert("doors", rows):next(function() end):catch(function(err)
            lia.error(L("failedSaveDoorData", tostring(err)))
            lia.error(L("doorDatabaseSchemaProblem"))
        end)
    end
end

function lia.doors.AddPreset(mapName, presetData)
    if not mapName or not presetData then
        error("lia.doors.AddPreset: Missing required parameters (mapName, presetData)")
        return
    end

    lia.doors.presets[mapName] = presetData
    lia.information("Added door preset for map: " .. mapName)
end

function lia.doors.GetPreset(mapName)
    return lia.doors.presets[mapName]
end

function lia.doors.VerifyDatabaseSchema()
    if lia.db.module == "sqlite" then
        lia.db.query("PRAGMA table_info(lia_doors)"):next(function(res)
            if not res or not res.results then
                lia.error(L("failedGetDoorTableInfo"))
                return
            end

            local columns = {}
            for _, row in ipairs(res.results) do
                columns[row.name] = row.type
            end

            local expectedColumns = {
                gamemode = "text",
                map = "text",
                id = "integer",
                factions = "text",
                classes = "text",
                disabled = "integer",
                hidden = "integer",
                ownable = "integer",
                name = "text",
                price = "integer",
                locked = "integer",
                door_group = "text"
            }

            for colName, expectedType in pairs(expectedColumns) do
                if not columns[colName] then
                    lia.error(L("missingExpectedDoorColumn", colName))
                elseif columns[colName]:lower() ~= expectedType:lower() then
                    lia.warning("Column " .. colName .. " has type " .. columns[colName] .. ", expected " .. expectedType)
                end
            end
        end):catch(function(err) lia.error("Failed to verify database schema: " .. tostring(err)) end)
    else
        lia.db.query("DESCRIBE lia_doors"):next(function(res)
            if not res or not res.results then
                lia.error(L("failedGetDoorTableInfo"))
                return
            end

            local columns = {}
            for _, row in ipairs(res.results) do
                columns[row.Field] = row.Type
            end

            lia.information("lia_doors table columns: " .. table.concat(table.GetKeys(columns), ", "))
            local expectedColumns = {
                gamemode = "text",
                map = "text",
                id = "int",
                factions = "text",
                classes = "text",
                disabled = "tinyint",
                hidden = "tinyint",
                ownable = "tinyint",
                name = "text",
                price = "int",
                locked = "tinyint",
                door_group = "text"
            }

            for colName, expectedType in pairs(expectedColumns) do
                if not columns[colName] then
                    lia.error(L("missingExpectedDoorColumn", colName))
                elseif not columns[colName]:lower():match(expectedType:lower()) then
                    lia.warning("Column " .. colName .. " has type " .. columns[colName] .. ", expected " .. expectedType)
                end
            end
        end):catch(function(err) lia.error("Failed to verify database schema: " .. tostring(err)) end)
    end
end

function lia.doors.CleanupCorruptedData()
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = game.GetMap()
    local condition = buildCondition(gamemode, map)
    local query = "SELECT id, factions, classes FROM lia_doors WHERE " .. condition
    lia.db.query(query):next(function(res)
        local rows = res.results or {}
        local corruptedCount = 0
        for _, row in ipairs(rows) do
            local id = tonumber(row.id)
            if not id then continue end
            local needsUpdate = false
            local newFactions = row.factions
            local newClasses = row.classes
            if row.factions and row.factions ~= "NULL" and row.factions ~= "" and tostring(row.factions):match("^[%d%.%-%s]+$") and not tostring(row.factions):match("[{}%[%]]") then
                lia.warning("Found corrupted factions data for door " .. id .. ": " .. tostring(row.factions))
                newFactions = ""
                needsUpdate = true
                corruptedCount = corruptedCount + 1
            end

            if row.classes and row.classes ~= "NULL" and row.classes ~= "" and tostring(row.classes):match("^[%d%.%-%s]+$") and not tostring(row.classes):match("[{}%[%]]") then
                lia.warning("Found corrupted classes data for door " .. id .. ": " .. tostring(row.classes))
                newClasses = ""
                needsUpdate = true
                corruptedCount = corruptedCount + 1
            end

            if needsUpdate then
                local updateQuery = "UPDATE lia_doors SET factions = " .. lia.db.convertDataType(newFactions) .. ", classes = " .. lia.db.convertDataType(newClasses) .. " WHERE " .. condition .. " AND id = " .. id
                lia.db.query(updateQuery):next(function() lia.information(L("fixedCorruptedDoorData", id)) end):catch(function(err) lia.error(L("failedFixCorruptedDoorData", id, tostring(err))) end)
            end
        end

        if corruptedCount > 0 then lia.information(L("foundAndFixedCorruptedDoorRecords", corruptedCount)) end
    end):catch(function(err) lia.error(L("failedCheckCorruptedDoorData", tostring(err))) end)
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

    timer.Simple(1, function() lia.doors.CleanupCorruptedData() end)
    timer.Simple(3, function() lia.doors.VerifyDatabaseSchema() end)
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

function MODULE:CanPlayerUseDoor(_, door)
    local doorData = door:getNetVar("doorData", {})
    if doorData.disabled then return false end
end

function MODULE:CanPlayerAccessDoor(client, door)
    local doorData = door:getNetVar("doorData", {})
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
            local classData = lia.class.list[classIndex]
            if id == unique or classIndex == charClass then
                return true
            elseif classData and classData.team and classData.team == charClassData.team then
                return true
            end
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
        local doorData = entity:getNetVar("doorData", {})
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
                client:notifyErrorLocalized("notNow")
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

function MODULE:KeyLock(client, door, time)
    if not IsValid(door) or not IsValid(client) then return end
    if lia.config.get("DisableCheaterActions", true) and client:getNetVar("cheater", false) then
        lia.log.add(client, "cheaterAction", L("cheaterActionLockDoor"))
        return
    end

    if hook.Run("CanPlayerLock", client, door) == false then return end
    local distance = client:GetPos():Distance(door:GetPos())
    local isProperEntity = door:isDoor() or door:IsVehicle() or door:isSimfphysCar()
    if isProperEntity and not door:isLocked() and distance <= 256 and (door:checkDoorAccess(client) or door:GetCreator() == client or client:isStaffOnDuty()) then
        client:setAction("@locking", time, function() end)
        client:doStaredAction(door, function() self:ToggleLock(client, door, true) end, time, function() client:stopAction() end)
        lia.log.add(client, "lockDoor", door)
    end
end

function MODULE:KeyUnlock(client, door, time)
    if not IsValid(door) or not IsValid(client) then return end
    if lia.config.get("DisableCheaterActions", true) and client:getNetVar("cheater", false) then
        lia.log.add(client, "cheaterAction", L("cheaterActionUnlockDoor"))
        return
    end

    if hook.Run("CanPlayerUnlock", client, door) == false then return end
    local distance = client:GetPos():Distance(door:GetPos())
    local isProperEntity = door:isDoor() or door:IsVehicle() or door:isSimfphysCar()
    if isProperEntity and door:isLocked() and distance <= 256 and (door:checkDoorAccess(client) or door:GetCreator() == client or client:isStaffOnDuty()) then
        client:setAction("@unlocking", time, function() end)
        client:doStaredAction(door, function() self:ToggleLock(client, door, false) end, time, function() client:stopAction() end)
        lia.log.add(client, "unlockDoor", door)
    end
end

function MODULE:ToggleLock(client, door, state)
    if not IsValid(door) then return end
    if lia.config.get("DisableCheaterActions", true) and IsValid(client) and client:getNetVar("cheater", false) then
        lia.log.add(client, "cheaterAction", state and L("cheaterActionLockDoor") or L("cheaterActionUnlockDoor"))
        return
    end

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
    lia.log.add(client, "toggleLock", door, state and L("locked") or L("unlocked"))
end

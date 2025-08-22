function MODULE:PostLoadData()
    if self.DoorsAlwaysDisabled then
        local count = 0
        for _, door in ents.Iterator() do
            if IsValid(door) and door:isDoor() then
                door:setNetVar("disabled", true)
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
                            ent:setNetVar("factions", util.TableToJSON(factions))
                        else
                            factions = result
                            ent.liaFactions = factions
                            ent:setNetVar("factions", util.TableToJSON(factions))
                        end
                    else
                        lia.warning("Failed to deserialize factions for door " .. id .. ": " .. tostring(result))
                        lia.warning("Raw factions data: " .. tostring(row.factions))
                    end
                end
            end

            local classes
            if row.classes and row.classes ~= "NULL" and row.classes ~= "" then
                if tostring(row.classes):match("^[%d%.%-%s]+$") and not tostring(row.classes):match("[{}%[%]]") then
                    lia.warning("Door " .. id .. " has coordinate-like data in classes column: " .. tostring(row.classes))
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
                            ent:setNetVar("classes", util.TableToJSON(classes))
                        else
                            classes = result
                            ent.liaClasses = classes
                            ent:setNetVar("classes", util.TableToJSON(classes))
                        end
                    else
                        lia.warning("Failed to deserialize classes for door " .. id .. ": " .. tostring(result))
                        lia.warning("Raw classes data: " .. tostring(row.classes))
                    end
                end
            end

            if row.name and row.name ~= "NULL" and row.name ~= "" then ent:setNetVar("name", tostring(row.name)) end
            local price = tonumber(row.price)
            if price and price >= 0 then
                ent:setNetVar("price", price)
            else
                ent:setNetVar("price", 0)
            end

            local locked = tonumber(row.locked) == 1
            ent:setNetVar("locked", locked)
            local disabled = tonumber(row.disabled) == 1
            ent:setNetVar("disabled", disabled)
            local hidden = tonumber(row.hidden) == 1
            ent:setNetVar("hidden", hidden)
            local noSell = tonumber(row.ownable) == 0
            ent:setNetVar("noSell", noSell)
            loadedCount = loadedCount + 1
        end
    end):catch(function(err)
        lia.error("Failed to load door data: " .. tostring(err))
        lia.error("This may indicate a database connection issue or missing table")
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
            local factions = door:getNetVar("factions")
            local classes = door:getNetVar("classes")
            local factionsTable = {}
            local classesTable = {}
            if factions and factions ~= "[]" then
                local success, result = pcall(util.JSONToTable, factions)
                if success and istable(result) then
                    factionsTable = result
                else
                    lia.warning("Failed to parse factions JSON for door " .. mapID .. ", using empty table")
                end
            elseif door.liaFactions then
                factionsTable = door.liaFactions
            end

            if classes and classes ~= "[]" then
                local success, result = pcall(util.JSONToTable, classes)
                if success and istable(result) then
                    classesTable = result
                else
                    lia.warning("Failed to parse classes JSON for door " .. mapID .. ", using empty table")
                end
            elseif door.liaClasses then
                classesTable = door.liaClasses
            end

            if not istable(factionsTable) or type(factionsTable) ~= "table" then
                lia.warning("Door " .. mapID .. " has invalid factions data type: " .. type(factionsTable) .. ", resetting to empty table")
                factionsTable = {}
            end

            if not istable(classesTable) or type(classesTable) ~= "table" then
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

            local name = door:getNetVar("name")
            if name and name ~= "" then
                name = tostring(name):sub(1, 255)
            else
                name = ""
            end

            local price = tonumber(door:getNetVar("price")) or 0
            if price < 0 then price = 0 end
            if price > 999999999 then price = 999999999 end
            rows[#rows + 1] = {
                gamemode = gamemode,
                map = map,
                id = mapID,
                factions = factionsSerialized,
                classes = classesSerialized,
                disabled = door:getNetVar("disabled") and 1 or 0,
                hidden = door:getNetVar("hidden") and 1 or 0,
                ownable = door:getNetVar("noSell") and 0 or 1,
                name = name,
                price = price,
                locked = door:getNetVar("locked") and 1 or 0
            }

            doorCount = doorCount + 1
        end
    end

    if #rows > 0 then
        lia.db.bulkUpsert("doors", rows):next(function() end):catch(function(err)
            lia.error("Failed to save door data: " .. tostring(err))
            lia.error("This may indicate a database connection issue or schema problem")
        end)
    end
end

function MODULE:VerifyDatabaseSchema()
    if lia.db.module == "sqlite" then
        lia.db.query("PRAGMA table_info(lia_doors)"):next(function(res)
            if not res or not res.results then
                lia.error("Failed to get table info for lia_doors")
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
                locked = "integer"
            }

            for colName, expectedType in pairs(expectedColumns) do
                if not columns[colName] then
                    lia.error("Missing expected column: " .. colName)
                elseif columns[colName] ~= expectedType then
                    lia.warning("Column " .. colName .. " has type " .. columns[colName] .. ", expected " .. expectedType)
                end
            end
        end):catch(function(err) lia.error("Failed to verify database schema: " .. tostring(err)) end)
    else
        lia.db.query("DESCRIBE lia_doors"):next(function(res)
            if not res or not res.results then
                lia.error("Failed to get table info for lia_doors")
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
                locked = "tinyint"
            }

            for colName, expectedType in pairs(expectedColumns) do
                if not columns[colName] then
                    lia.error("Missing expected column: " .. colName)
                elseif not columns[colName]:match(expectedType) then
                    lia.warning("Column " .. colName .. " has type " .. columns[colName] .. ", expected " .. expectedType)
                end
            end
        end):catch(function(err) lia.error("Failed to verify database schema: " .. tostring(err)) end)
    end
end

function MODULE:CleanupCorruptedData()
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
            if row.factions and row.factions ~= "NULL" and row.factions ~= "" then
                if tostring(row.factions):match("^[%d%.%-%s]+$") and not tostring(row.factions):match("[{}%[%]]") then
                    lia.warning("Found corrupted factions data for door " .. id .. ": " .. tostring(row.factions))
                    newFactions = ""
                    needsUpdate = true
                    corruptedCount = corruptedCount + 1
                end
            end

            if row.classes and row.classes ~= "NULL" and row.classes ~= "" then
                if tostring(row.classes):match("^[%d%.%-%s]+$") and not tostring(row.classes):match("[{}%[%]]") then
                    lia.warning("Found corrupted classes data for door " .. id .. ": " .. tostring(row.classes))
                    newClasses = ""
                    needsUpdate = true
                    corruptedCount = corruptedCount + 1
                end
            end

            if needsUpdate then
                local updateQuery = "UPDATE lia_doors SET factions = " .. lia.db.convertDataType(newFactions) .. ", classes = " .. lia.db.convertDataType(newClasses) .. " WHERE " .. condition .. " AND id = " .. id
                lia.db.query(updateQuery):next(function() lia.information("Fixed corrupted data for door " .. id) end):catch(function(err) lia.error("Failed to fix corrupted data for door " .. id .. ": " .. tostring(err)) end)
            end
        end

        if corruptedCount > 0 then lia.information("Found and fixed " .. corruptedCount .. " corrupted door records") end
    end):catch(function(err) lia.error("Failed to check for corrupted door data: " .. tostring(err)) end)
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

    timer.Simple(1, function() self:CleanupCorruptedData() end)
    timer.Simple(3, function() self:VerifyDatabaseSchema() end)
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
    if door:getNetVar("disabled", false) then return false end
end

function MODULE:CanPlayerAccessDoor(client, door)
    local factions = door:getNetVar("factions")
    if factions and factions ~= "[]" then
        local facs = util.JSONToTable(factions)
        if facs then
            local playerFaction = client:getChar():getFaction()
            local factionData = lia.faction.indices[playerFaction]
            local unique = factionData and factionData.uniqueID
            for _, id in ipairs(facs) do
                if id == unique or lia.faction.getIndex(id) == playerFaction then return true end
            end
        end
    end

    local classes = door:getNetVar("classes")
    local charClass = client:getChar():getClass()
    local charClassData = lia.class.list[charClass]
    if classes and classes ~= "[]" and charClassData then
        local classTable = util.JSONToTable(classes)
        if classTable then
            local unique = charClassData.uniqueID
            for _, id in ipairs(classTable) do
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
end

function MODULE:PostPlayerLoadout(client)
    client:Give("lia_keys")
end

function MODULE:ShowTeam(client)
    local entity = client:getTracedEntity()
    if IsValid(entity) and entity:isDoor() then
        local factions = entity:getNetVar("factions")
        local classes = entity:getNetVar("classes")
        if (not factions or factions == "[]") and (not classes or classes == "[]") then
            if entity:checkDoorAccess(client, DOOR_TENANT) then
                local door = entity
                net.Start("doorMenu")
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
                client:notifyLocalized("notNow")
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
        client:setAction(L("locking"), time, function() end)
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
        client:setAction(L("unlocking"), time, function() end)
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

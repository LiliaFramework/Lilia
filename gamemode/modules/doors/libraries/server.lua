--[[
    Doors Library Server

    Server-side door management and configuration system for the Lilia framework.
]]
--[[
    Overview:
        The doors library server component provides comprehensive door management functionality including
        preset configuration, database schema verification, and data cleanup operations. It handles
        door data persistence, loading door configurations from presets, and maintaining database
        integrity. The library manages door ownership, access permissions, faction and class restrictions,
        and provides utilities for door data validation and corruption cleanup. It operates primarily
        on the server side and integrates with the database system to persist door configurations
        across server restarts. The library also handles door locking/unlocking mechanics and
        provides hooks for custom door behavior integration.
]]
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

        lia.information(L("doorDisableAll"))
    end
end

local function buildCondition(gamemode, map)
    return "gamemode = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map)
end

function MODULE:LoadData()
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local mapName = lia.data.getEquivalencyMap(game.GetMap())
    local condition = buildCondition(gamemode, mapName)
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
                lia.warning(L("skippingDoorRecordWithInvalidID") .. ": " .. tostring(row.id))
                continue
            end

            local ent = ents.GetMapCreatedEntity(id)
            if not IsValid(ent) then
                lia.warning(L("doorEntityNotFound", id))
                continue
            end

            if not ent:isDoor() then
                lia.warning(L("entityIsNotADoorSkipping") .. " " .. id)
                continue
            end

            local factions
            if row.factions and row.factions ~= "NULL" and row.factions ~= "" then
                if tostring(row.factions):match("^[%d%.%-%s]+$") and not tostring(row.factions):match("[{}%[%]]") then
                    lia.warning(L("doorHasCoordinateDataInFactionsColumn") .. " " .. id .. ": " .. tostring(row.factions))
                    lia.warning(L("thisSuggestsDataCorruptionClearingFactionsData"))
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
                        lia.warning(L("failedToDeserializeFactionsForDoor", id) .. ": " .. tostring(result))
                        lia.warning(L("rawFactionsData") .. " " .. tostring(row.factions))
                    end
                end
            end

            local classes
            if row.classes and row.classes ~= "NULL" and row.classes ~= "" then
                if tostring(row.classes):match("^[%d%.%-%s]+$") and not tostring(row.classes):match("[{}%[%]]") then
                    lia.warning(L("doorCoordinateDataWarning", id, tostring(row.classes)))
                    lia.warning(L("doorDataCorruptionClearing"))
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
                        lia.warning(L("failedToDeserializeClassesForDoor", id) .. ": " .. tostring(result))
                        lia.warning(L("rawClassesData") .. " " .. tostring(row.classes))
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

            if tonumber(row.locked) == 1 then
                doorData.locked = true
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

            if hasData then
                doorData = hook.Run("PostDoorDataLoad", ent, doorData) or doorData
                lia.doors.setCachedData(ent, doorData)
                loadedCount = loadedCount + 1
                if ent:isDoor() then
                    if doorData.locked then
                        ent:Fire("lock")
                    else
                        ent:Fire("unlock")
                    end
                end
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

                        if doorVars.locked then
                            doorData.locked = true
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
                            lia.information(L("appliedPresetToDoor", doorID))
                            loadedCount = loadedCount + 1
                            if ent:isDoor() then
                                if doorData.locked then
                                    ent:Fire("lock")
                                else
                                    ent:Fire("unlock")
                                end
                            end
                        end
                    else
                        lia.warning(L("doorNotFoundForPreset", doorID))
                    end
                end
            end
        end
    end):catch(function(err)
        lia.error(L("failedToLoadDoorData", tostring(err)))
        lia.error(L("databaseConnectionIssue"))
    end)
end

function MODULE:SaveData()
    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = lia.data.getEquivalencyMap(game.GetMap())
    local rows = {}
    local doorCount = 0
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
                lia.warning(L("doorInvalidFactionsType", mapID, type(factionsTable)))
                factionsTable = {}
            end

            if not istable(classesTable) then
                lia.warning(L("doorInvalidClassesType", mapID, type(classesTable)))
                classesTable = {}
            end

            local factionsSerialized = lia.data.serialize(factionsTable)
            local classesSerialized = lia.data.serialize(classesTable)
            if factionsSerialized and factionsSerialized:match("^[%d%.%-%s]+$") and not factionsSerialized:match("[{}%[%]]") then
                lia.warning(L("doorFactionsCoordinateReset", mapID))
                factionsTable = {}
                factionsSerialized = lia.data.serialize(factionsTable)
            end

            if classesSerialized and classesSerialized:match("^[%d%.%-%s]+$") and not classesSerialized:match("[{}%[%]]") then
                lia.warning(L("doorClassesCoordinateReset", mapID))
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
            rows[#rows + 1] = {
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
                locked = doorData.locked and 1 or 0
            }

            doorCount = doorCount + 1
        end
    end

    if #rows > 0 then
        lia.db.bulkUpsert("doors", rows):next(function() end):catch(function(err)
            lia.error(L("failedToSaveDoorData", tostring(err)))
            lia.error(L("schemaProblem"))
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

    timer.Simple(1, function() lia.doors.cleanupCorruptedData() end)
    timer.Simple(3, function() lia.doors.verifyDatabaseSchema() end)
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

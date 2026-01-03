--[[
    Doors Library

    Door management system for the Lilia framework providing preset configuration,
    database schema verification, data cleanup, and door access control functionality.
]]
--[[
    Overview:
        The doors library provides comprehensive door management functionality including
        preset configuration, database schema verification, and data cleanup operations.
        It handles door data persistence, loading door configurations from presets,
        and maintaining database integrity. The library manages door ownership, access
        permissions, faction and class restrictions, and provides utilities for door
        data validation and corruption cleanup. It operates primarily on the server side
        and integrates with the database system to persist door configurations across
        server restarts. The library also handles door locking/unlocking mechanics and
        provides hooks for custom door behavior integration.
]]
lia.doors = lia.doors or {}
lia.doors.presets = lia.doors.presets or {}
lia.doors.stored = lia.doors.stored or {}
DOOR_OWNER, DOOR_TENANT, DOOR_GUEST, DOOR_NONE = 3, 2, 1, 0
lia.doors.AccessLabels = {
    [DOOR_NONE] = "doorAccessNone",
    [DOOR_GUEST] = "doorAccessGuest",
    [DOOR_TENANT] = "doorAccessTenant",
    [DOOR_OWNER] = "doorAccessOwner"
}

lia.doors.defaultValues = {
    name = "",
    title = "",
    price = 0,
    disabled = false,
    locked = false,
    hidden = false,
    noSell = false,
    factions = {},
    classes = {},
    useCount = 0,
    lastUsed = 0
}

if SERVER then
    function lia.doors.setCachedData(door, data)
        local doorID = door:MapCreationID()
        if not doorID or doorID <= 0 then return end
        local filteredData = {}
        local hasData = false
        for key, value in pairs(data or {}) do
            local defaultValue = lia.doors.defaultValues[key]
            if defaultValue ~= nil then
                if istable(value) and istable(defaultValue) then
                    if not table.IsEmpty(value) then
                        filteredData[key] = value
                        hasData = true
                    end
                elseif value ~= defaultValue then
                    filteredData[key] = value
                    hasData = true
                end
            end
        end

        if hasData then
            lia.doors.stored[doorID] = filteredData
        else
            lia.doors.stored[doorID] = nil
        end

        lia.doors.syncDoorData(door)
    end

    function lia.doors.getCachedData(door)
        local doorID = door:MapCreationID()
        if not doorID or doorID <= 0 then return {} end
        local cachedData = lia.doors.stored[doorID] or {}
        local fullData = {}
        for key, defaultValue in pairs(lia.doors.defaultValues) do
            if cachedData[key] ~= nil then
                fullData[key] = cachedData[key]
            else
                if istable(defaultValue) then
                    fullData[key] = table.Copy(defaultValue)
                else
                    fullData[key] = defaultValue
                end
            end
        end
        return fullData
    end

    function lia.doors.syncDoorData(door)
        local doorID = door:MapCreationID()
        if not doorID or doorID <= 0 then return end
        local data = lia.doors.stored[doorID]
        net.Start("liaDoorDataUpdate")
        net.WriteUInt(doorID, 16)
        if data then
            net.WriteBool(true)
            net.WriteTable(data)
        else
            net.WriteBool(false)
        end

        net.Broadcast()
    end

    function lia.doors.syncAllDoorsToClient(client)
        if not IsValid(client) then return end
        net.Start("liaDoorDataBulk")
        net.WriteUInt(table.Count(lia.doors.stored), 16)
        for doorID, data in pairs(lia.doors.stored) do
            net.WriteUInt(doorID, 16)
            net.WriteTable(data)
        end

        net.Send(client)
    end

    function lia.doors.setData(door, data)
        lia.doors.setCachedData(door, data)
    end

    function lia.doors.addPreset(mapName, presetData)
        if not mapName or not presetData then
            error("lia.doors.addPreset: Missing required parameters (mapName, presetData)")
            return
        end

        lia.doors.presets[mapName] = presetData
        lia.information(L("addedDoorPresetForMap") .. ": " .. mapName)
    end

    function lia.doors.getPreset(mapName)
        return lia.doors.presets[mapName]
    end

    function lia.doors.verifyDatabaseSchema()
        lia.db.query("PRAGMA table_info(lia_doors)"):next(function(res)
            if not res or not res.results then
                lia.error(L("failedToGetTableInfo"))
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
                    lia.error(L("missingExpectedColumn") .. " " .. colName)
                elseif columns[colName]:lower() ~= expectedType:lower() then
                    lia.warning(L("column") .. " " .. colName .. " " .. L("hasType") .. " " .. columns[colName] .. ", " .. L("expected") .. " " .. expectedType)
                end
            end
        end):catch(function(err) lia.error(L("failedToVerifyDatabaseSchema") .. " " .. tostring(err)) end)
    end

    function lia.doors.cleanupCorruptedData()
        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = lia.data.getEquivalencyMap(game.GetMap())
        local condition = "gamemode = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map)
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
                    lia.warning(L("corruptedFactionsData", id, tostring(row.factions)))
                    newFactions = ""
                    needsUpdate = true
                    corruptedCount = corruptedCount + 1
                end

                if row.classes and row.classes ~= "NULL" and row.classes ~= "" and tostring(row.classes):match("^[%d%.%-%s]+$") and not tostring(row.classes):match("[{}%[%]]") then
                    lia.warning(L("corruptedClassesData", id, tostring(row.classes)))
                    newClasses = ""
                    needsUpdate = true
                    corruptedCount = corruptedCount + 1
                end

                if needsUpdate then
                    local updateQuery = "UPDATE lia_doors SET factions = " .. lia.db.convertDataType(newFactions) .. ", classes = " .. lia.db.convertDataType(newClasses) .. " WHERE " .. condition .. " AND id = " .. id
                    lia.db.query(updateQuery):next(function() lia.information(L("fixedCorruptedDoorData", id)) end):catch(function(err) lia.error(L("failedToFixCorruptedDoorData", id, tostring(err))) end)
                end
            end

            if corruptedCount > 0 then lia.information(L("foundAndFixedCorruptedDoors", corruptedCount)) end
        end):catch(function(err) lia.error(L("failedToCheckCorruptedDoorData", tostring(err))) end)
    end
end

function lia.doors.getData(door)
    if SERVER then
        return lia.doors.getCachedData(door)
    else
        return lia.doors.getCachedData(door)
    end
end

if CLIENT then
    lia.doors.stored = lia.doors.stored or {}
    function lia.doors.getCachedData(door)
        local doorID = door:MapCreationID()
        if not doorID or doorID <= 0 then return {} end
        local cachedData = lia.doors.stored[doorID] or {}
        local fullData = {}
        for key, defaultValue in pairs(lia.doors.defaultValues) do
            if cachedData[key] ~= nil then
                fullData[key] = cachedData[key]
            else
                if istable(defaultValue) then
                    fullData[key] = table.Copy(defaultValue)
                else
                    fullData[key] = defaultValue
                end
            end
        end
        return fullData
    end

    function lia.doors.updateCachedData(doorID, data)
        if data then
            lia.doors.stored[doorID] = data
        else
            lia.doors.stored[doorID] = nil
        end
    end
end

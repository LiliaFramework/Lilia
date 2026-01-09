--[[
    Folder: Libraries
    File: doors.md
]]
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
--[[
    Purpose:
        Store door data overrides in memory and sync to clients, omitting defaults.

    When Called:
        After editing door settings (price, access, flags) server-side.

    Parameters:
        door (Entity)
            Door entity.
        data (table)
            Door data overrides.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
        lia.doors.setCachedData(door, {
            name = "Police HQ",
            price = 0,
            factions = {FACTION_POLICE}
        })
        ```
]]
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

--[[
    Purpose:
        Retrieve cached door data merged with defaults.

    When Called:
        Before saving/loading or when building UI state for a door.

    Parameters:
        door (Entity)

    Returns:
        table
            Complete door data with defaults filled.

    Realm:
        Server

    Example Usage:
        ```lua
        local data = lia.doors.getCachedData(door)
        print("Door price:", data.price)
        ```
]]
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

--[[
    Purpose:
        Net-sync a single door's cached data to all clients.

    When Called:
        After updating a door's data.

    Parameters:
        door (Entity)

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
        lia.doors.syncDoorData(door)
        ```
]]
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

--[[
    Purpose:
        Bulk-sync all cached doors to a single client.

    When Called:
        On player spawn/join or after admin refresh.

    Parameters:
        client (Player)

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
        hook.Add("PlayerInitialSpawn", "SyncDoorsOnJoin", function(ply)
            lia.doors.syncAllDoorsToClient(ply)
        end)
        ```
]]
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

--[[
    Purpose:
        Set data for a door (alias to setCachedData).

    When Called:
        Convenience wrapper used by other systems.

    Parameters:
        door (Entity)
        data (table)

    Returns:
        nil

    Realm:
        Server
    Example Usage:
        ```lua
        lia.doors.setData(door, {locked = true})
        ```
]]
    function lia.doors.setData(door, data)
        lia.doors.setCachedData(door, data)
    end

--[[
    Purpose:
        Register a preset of door data for a specific map.

    When Called:
        During map setup to predefine door ownership/prices.

    Parameters:
        mapName (string)
        presetData (table)

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
        lia.doors.addPreset("rp_downtown", {
            [1234] = {name = "Bank", price = 0, factions = {FACTION_POLICE}},
            [5678] = {locked = true, hidden = true}
        })
        ```
]]
    function lia.doors.addPreset(mapName, presetData)
        if not mapName or not presetData then
            error("lia.doors.addPreset: Missing required parameters (mapName, presetData)")
            return
        end

        lia.doors.presets[mapName] = presetData
        lia.information(L("addedDoorPresetForMap") .. ": " .. mapName)
    end

--[[
    Purpose:
        Retrieve a door preset table for a map.

    When Called:
        During map load or admin inspection of presets.

    Parameters:
        mapName (string)

    Returns:
        table|nil

    Realm:
        Server

    Example Usage:
        ```lua
        local preset = lia.doors.getPreset(game.GetMap())
        if preset then PrintTable(preset) end
        ```
]]
    function lia.doors.getPreset(mapName)
        return lia.doors.presets[mapName]
    end

--[[
    Purpose:
        Validate the doors database schema against expected columns.

    When Called:
        On startup or after migrations to detect missing/mismatched columns.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
        hook.Add("DatabaseConnected", "VerifyDoorSchema", lia.doors.verifyDatabaseSchema)
        ```
]]
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

--[[
    Purpose:
        Detect and repair corrupted faction/class door data in the database.

    When Called:
        Maintenance task to clean malformed data entries.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
        concommand.Add("lia_fix_doors", function(admin)
            if not IsValid(admin) or not admin:IsAdmin() then return end
            lia.doors.cleanupCorruptedData()
        end)
        ```
]]
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

--[[
    Purpose:
        Access cached door data (server/client wrapper).

    When Called:
        Anywhere door data is needed without hitting DB.

    Parameters:
        door (Entity)

    Returns:
        table

    Realm:
        Shared

    Example Usage:
        ```lua
        local data = lia.doors.getData(ent)
        if data.locked then
            -- show locked icon
        end
        ```
]]
function lia.doors.getData(door)
    if SERVER then
        return lia.doors.getCachedData(door)
    else
        return lia.doors.getCachedData(door)
    end
end

if CLIENT then
    lia.doors.stored = lia.doors.stored or {}
--[[
    Purpose:
        Client helper to build full door data from cached entries.

    When Called:
        For HUD/tooltips when interacting with doors.

    Parameters:
        door (Entity)

    Returns:
        table

    Realm:
        Client

    Example Usage:
        ```lua
        local info = lia.doors.getCachedData(door)
        draw.SimpleText(info.name or "Door", "LiliaFont.18", x, y, color_white)
        ```
]]
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

--[[
    Purpose:
        Update the client-side cache for a door ID (or clear it).

    When Called:
        After receiving sync updates from the server.

    Parameters:
        doorID (number)
        data (table|nil)
            nil clears the cache entry.

    Returns:
        nil

    Realm:
        Client

    Example Usage:
        ```lua
        lia.doors.updateCachedData(doorID, net.ReadTable())
        ```
]]
    function lia.doors.updateCachedData(doorID, data)
        if data then
            lia.doors.stored[doorID] = data
        else
            lia.doors.stored[doorID] = nil
        end
    end
end

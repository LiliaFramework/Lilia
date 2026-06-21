--[[
    Folder: Developer - Libraries
    File: lia.doors.md
]]
--[[
    Doors

    Door data helpers for storing, syncing, validating, and extending map door configuration.
]]
--[[
    Overview:
        The door library centralizes shared and networked door metadata under `lia.doors`. It stores only values that differ from defaults, merges custom door fields collected by hooks, synchronizes cached door data to clients, manages map presets, and verifies or repairs persisted door database data on the server.
]]
lia.doors = lia.doors or {}
lia.doors.presets = lia.doors.presets or {}
lia.doors.stored = lia.doors.stored or {}
DOOR_OWNER, DOOR_TENANT, DOOR_GUEST, DOOR_NONE = 3, 2, 1, 0
lia.doors.AccessLabels = {
    [DOOR_NONE] = "none",
    [DOOR_GUEST] = "guest",
    [DOOR_TENANT] = "tenant",
    [DOOR_OWNER] = "owner"
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

--[[
    Purpose:
        Builds the complete default door data table, including custom fields collected from plugins or modules.

    Parameters:
        None

    Returns:
        table
            A copy of the base door defaults with collected custom field defaults merged in.

        table
            The collected custom field definitions keyed by field name.

    Example Usage:
        ```lua
        local defaults, extras = lia.doors.getDoorDefaultValues()
        print(defaults.price, extras.customField)
        ```

    Realm:
        Shared
]]
function lia.doors.getDoorDefaultValues()
    local extras = {}
    hook.Run("CollectDoorDataFields", extras)
    local defaults = table.Copy(lia.doors.defaultValues)
    for key, info in pairs(extras) do
        defaults[key] = info and info.default
    end
    return defaults, extras
end

if SERVER then
    --[[
    Purpose:
        Stores filtered door data in the server cache and synchronizes the result to clients.

    Parameters:
        door (Entity)
            The door entity whose cached data should be updated.

        data (table|nil)
            Door data to cache. Values matching defaults are omitted, and empty table values are ignored.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.doors.setCachedData(door, {
            name = "Apartment 1A",
            price = 250
        })
        ```

    Realm:
        Server
]]
    function lia.doors.setCachedData(door, data)
        local doorID = door:MapCreationID()
        if not doorID or doorID <= 0 then return end
        local defaults = lia.doors.getDoorDefaultValues()
        local filteredData = {}
        local hasData = false
        for key, value in pairs(data or {}) do
            local defaultValue = defaults[key]
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
        Returns complete door data for a server-side door by merging cached values with defaults.

    Parameters:
        door (Entity)
            The door entity whose data should be retrieved.

    Returns:
        table
            Complete door data for the entity. Returns an empty table when the entity has no valid map creation ID.

    Example Usage:
        ```lua
        local data = lia.doors.getCachedData(door)
        print(data.name, data.price)
        ```

    Realm:
        Server
]]
    function lia.doors.getCachedData(door)
        local doorID = door:MapCreationID()
        if not doorID or doorID <= 0 then return {} end
        local cachedData = lia.doors.stored[doorID] or {}
        local defaults = select(1, lia.doors.getDoorDefaultValues())
        local fullData = {}
        for key, defaultValue in pairs(defaults) do
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
        Sends the current cached data for a single door to all connected clients.

    Parameters:
        door (Entity)
            The door entity whose cached data should be synchronized.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.doors.syncDoorData(door)
        ```

    Realm:
        Server
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
        Sends the complete server-side door cache to a specific client.

    Parameters:
        client (Player)
            The player who should receive the full cached door data table.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.doors.syncAllDoorsToClient(client)
        ```

    Realm:
        Server
]]
    function lia.doors.syncAllDoorsToClient(client)
        if not IsValid(client) then return end
        lia.net.writeBigTable(client, "liaDoorDataBulk", lia.doors.stored, 2048)
    end

    --[[
    Purpose:
        Updates server-side door data through the cached data setter.

    Parameters:
        door (Entity)
            The door entity whose data should be updated.

        data (table|nil)
            Door data to apply to the entity.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.doors.setData(door, {
            locked = true,
            hidden = false
        })
        ```

    Realm:
        Server
]]
    function lia.doors.setData(door, data)
        lia.doors.setCachedData(door, data)
    end

    --[[
    Purpose:
        Registers a named door preset for a map.

    Parameters:
        mapName (string)
            The map name or map equivalency name used as the preset key.

        presetData (table)
            The preset door data to associate with the map.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.doors.addPreset("rp_city", presetData)
        ```

    Realm:
        Server
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
        Retrieves the registered door preset for a map.

    Parameters:
        mapName (string)
            The map name or map equivalency name used as the preset key.

    Returns:
        table|nil
            The preset data registered for the map, or nil when no preset exists.

    Example Usage:
        ```lua
        local preset = lia.doors.getPreset(game.GetMap())
        ```

    Realm:
        Server
]]
    function lia.doors.getPreset(mapName)
        return lia.doors.presets[mapName]
    end

    --[[
    Purpose:
        Verifies the persisted door database table against expected columns and adds missing custom field columns.

    Parameters:
        None

    Returns:
        nil

    Example Usage:
        ```lua
        lia.doors.verifyDatabaseSchema()
        ```

    Realm:
        Server
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

            local _, extraFields = lia.doors.getDoorDefaultValues()
            for colName, info in pairs(extraFields) do
                expectedColumns[colName] = info and info.type or "text"
            end

            for colName, expectedType in pairs(expectedColumns) do
                if not columns[colName] then
                    lia.error(L("missingExpectedColumn") .. " " .. colName)
                elseif columns[colName]:lower() ~= expectedType:lower() then
                    lia.warning(L("column") .. " " .. colName .. " " .. L("hasType") .. " " .. columns[colName] .. ", " .. L("expected") .. " " .. expectedType)
                end
            end

            for colName, info in pairs(extraFields) do
                if not columns[colName] then
                    local columnType = info and info.type or "text"
                    local defaultValue = info and info.default
                    local defaultSQL = defaultValue ~= nil and " DEFAULT " .. lia.db.convertDataType(defaultValue) or ""
                    lia.db.query("ALTER TABLE lia_doors ADD COLUMN " .. colName .. " " .. columnType .. defaultSQL):catch(function(err) lia.error(L("failedToVerifyDatabaseSchema") .. " " .. tostring(err)) end)
                end
            end
        end):catch(function(err) lia.error(L("failedToVerifyDatabaseSchema") .. " " .. tostring(err)) end)
    end

    --[[
    Purpose:
        Searches persisted door records for corrupted faction or class data and clears invalid values.

    Parameters:
        None

    Returns:
        nil

    Example Usage:
        ```lua
        lia.doors.cleanupCorruptedData()
        ```

    Realm:
        Server
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
        Retrieves complete door data for the current realm.

    Parameters:
        door (Entity)
            The door entity whose merged data should be returned.

    Returns:
        table
            Complete door data for the entity, with cached values merged over defaults.

    Example Usage:
        ```lua
        local data = lia.doors.getData(door)
        print(data.title)
        ```

    Realm:
        Shared
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
        Returns complete door data for a client-side door by merging synced cached values with defaults.

    Parameters:
        door (Entity)
            The door entity whose synced data should be retrieved.

    Returns:
        table
            Complete door data for the entity. Returns an empty table when the entity has no valid map creation ID.

    Example Usage:
        ```lua
        local data = lia.doors.getCachedData(door)
        print(data.hidden)
        ```

    Realm:
        Client
]]
    function lia.doors.getCachedData(door)
        local doorID = door:MapCreationID()
        if not doorID or doorID <= 0 then return {} end
        local cachedData = lia.doors.stored[doorID] or {}
        local defaults = select(1, lia.doors.getDoorDefaultValues())
        local fullData = {}
        for key, defaultValue in pairs(defaults) do
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
        Updates or clears the client-side cached data for a door ID after receiving synchronized server data.

    Parameters:
        doorID (number)
            The map creation ID of the door whose cached data should be changed.

        data (table|nil)
            The synced cached data to store. Passing nil clears the stored data for the door ID.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.doors.updateCachedData(doorID, data)
        ```

    Realm:
        Client
]]
    function lia.doors.updateCachedData(doorID, data)
        if data then
            lia.doors.stored[doorID] = data
        else
            lia.doors.stored[doorID] = nil
        end
    end
end

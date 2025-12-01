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
DOOR_OWNER, DOOR_TENANT, DOOR_GUEST, DOOR_NONE = 3, 2, 1, 0
lia.doors.AccessLabels = {
    [DOOR_NONE] = "doorAccessNone",
    [DOOR_GUEST] = "doorAccessGuest",
    [DOOR_TENANT] = "doorAccessTenant",
    [DOOR_OWNER] = "doorAccessOwner"
}

if SERVER then
    function lia.doors.setData(door, data)
        door:setNetVar("doorData", data)
    end

    --[[
        Purpose:
            Adds a door preset configuration for a specific map

        When Called:
            When setting up predefined door configurations for maps

        Parameters:
            mapName (string)
                The name of the map to apply the preset to
            presetData (table)
                Table containing door configuration data with the following structure:
                [doorID] = {
                    name (string, optional)
                        Custom name for the door
                    price (number, optional)
                        Price to purchase the door
                    locked (boolean, optional)
                        Whether the door starts locked
                    disabled (boolean, optional)
                        Whether the door is disabled
                    hidden (boolean, optional)
                        Whether the door info is hidden
                    noSell (boolean, optional)
                        Whether the door cannot be sold
                    factions (table, optional)
                        Array of faction uniqueIDs that can access the door
                    classes (table, optional)
                        Array of class uniqueIDs that can access the door
                }

        Returns:
            nil

        Realm:
            Server

        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Add basic door preset for a map
        lia.doors.addPreset("rp_downtown_v4c_v2", {
            [123] = {
                name = "Police Station Door",
                price = 1000,
                locked = true
            }
        })
        ```

        Medium Complexity:
        ```lua
        -- Medium: Add preset with faction restrictions
        lia.doors.addPreset("rp_downtown_v4c_v2", {
            [123] = {
                name = "Police Station",
                price = 5000,
                locked = false,
                factions = {"police", "mayor"}
            },
            [124] = {
                name = "Evidence Room",
                price = 0,
                locked = true,
                factions = {"police"}
            }
        })
        ```

        High Complexity:
        ```lua
        -- High: Complex preset with multiple doors and restrictions
        local policeDoors = {
            [123] = {
                name = "Police Station Main",
                price = 10000,
                locked = false,
                factions = {"police", "mayor", "chief"}
            },
            [124] = {
                name = "Evidence Room",
                price = 0,
                locked = true,
                factions = {"police"},
                classes = {"detective", "chief"}
            },
            [125] = {
                name = "Interrogation Room",
                price = 0,
                locked = true,
                factions = {"police"},
                classes = {"detective", "chief", "officer"}
            }
        }
        lia.doors.addPreset("rp_downtown_v4c_v2", policeDoors)
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
            Retrieves a door preset configuration for a specific map

        When Called:
            When loading door data or checking for existing presets

        Parameters:
            mapName (string)
                The name of the map to get the preset for

        Returns:
            Table or nil - The preset data table if found, nil otherwise

        Realm:
            Server

        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Get preset for current map
        local preset = lia.doors.getPreset(game.GetMap())
        if preset then
            print("Found preset for map")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Check and use preset data
        local mapName = lia.data.getEquivalencyMap(game.GetMap())
        local preset = lia.doors.getPreset(mapName)
        if preset then
            for doorID, doorData in pairs(preset) do
                print("Door " .. doorID .. " has preset: " .. (doorData.name or "Unnamed"))
            end
        end
        ```

        High Complexity:
        ```lua
        -- High: Dynamic preset loading with validation
        local function loadMapPresets(mapName)
            local preset = lia.doors.getPreset(mapName)
            if not preset then
                lia.warning("No door preset found for map: " .. mapName)
                return false
            end

            local validDoors = 0
            for doorID, doorData in pairs(preset) do
                local ent = ents.GetMapCreatedEntity(doorID)
                if IsValid(ent) and ent:isDoor() then
                    validDoors = validDoors + 1
                    -- Apply preset data to door
                    ent:setNetVar("doorData", doorData)
                end
            end

            lia.information("Loaded " .. validDoors .. " doors from preset for " .. mapName)
            return true
        end
        ```
    ]]
    function lia.doors.getPreset(mapName)
        return lia.doors.presets[mapName]
    end

    --[[
        Purpose:
            Verifies the database schema for the doors table matches expected structure

        When Called:
            During server initialization or when checking database integrity

        Parameters:
            None

        Returns:
            nil

        Realm:
            Server

        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Verify schema on server start
        lia.doors.verifyDatabaseSchema()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Verify schema with custom handling
        hook.Add("InitPostEntity", "VerifyDoorSchema", function()
            timer.Simple(5, function()
                lia.doors.verifyDatabaseSchema()
            end)
        end)
        ```

        High Complexity:
        ```lua
        -- High: Custom schema verification with migration
        function customSchemaCheck()
            lia.doors.verifyDatabaseSchema()

            -- Check for missing columns and add them
            local missingColumns = {
                -- Add any missing columns here
            }

            for column, type in pairs(missingColumns) do
                lia.db.query("ALTER TABLE lia_doors ADD COLUMN " .. column .. " " .. type)
            end
        end
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
            Cleans up corrupted door data in the database by removing invalid faction/class data

        When Called:
            During server initialization or when data corruption is detected

        Parameters:
            None

        Returns:
            nil

        Realm:
            Server

        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Run cleanup on server start
        lia.doors.cleanupCorruptedData()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Schedule cleanup with delay
        hook.Add("InitPostEntity", "CleanupDoorData", function()
            timer.Simple(2, function()
                lia.doors.cleanupCorruptedData()
            end)
        end)
        ```

        High Complexity:
        ```lua
        -- High: Custom cleanup with logging and validation
        function advancedDoorCleanup()
            lia.information("Starting door data cleanup...")

            lia.doors.cleanupCorruptedData()

            -- Additional validation
            local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
            local map = lia.data.getEquivalencyMap(game.GetMap())
            local condition = "gamemode = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map)

            lia.db.query("SELECT COUNT(*) as count FROM lia_doors WHERE " .. condition):next(function(res)
                local count = res.results[1].count
                lia.information("Door cleanup completed. Total doors in database: " .. count)
            end)
        end
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

function lia.doors.getData(door)
    return door:getNetVar("doorData", {}) or {}
end

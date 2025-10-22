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
                local doorData = door:getNetVar("doorData", {})
                if not doorData or table.IsEmpty(doorData) then
                    door:setNetVar("doorData", {
                        disabled = true
                    })

                    count = count + 1
                else
                    doorData.disabled = true
                    door:setNetVar("doorData", doorData)
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
    local mapName = game.GetMap()
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
                            ent:setNetVar("factions", util.TableToJSON(factions))
                        else
                            factions = result
                            ent.liaFactions = factions
                            ent:setNetVar("factions", util.TableToJSON(factions))
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
                            ent:setNetVar("classes", util.TableToJSON(classes))
                        else
                            classes = result
                            ent.liaClasses = classes
                            ent:setNetVar("classes", util.TableToJSON(classes))
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
                hasData = true
            end

            if classes and #classes > 0 then
                doorData.classes = classes
                hasData = true
            end

            if hasData then
                doorData = hook.Run("PostDoorDataLoad", ent, doorData) or doorData
                ent:setNetVar("doorData", doorData)
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
                            hasPresetData = true
                        end

                        if doorVars.classes and istable(doorVars.classes) and not table.IsEmpty(doorVars.classes) then
                            doorData.classes = doorVars.classes
                            ent.liaClasses = doorVars.classes
                            hasPresetData = true
                        end

                        if hasPresetData then
                            doorData = hook.Run("PostDoorDataLoad", ent, doorData) or doorData
                            ent:setNetVar("doorData", doorData)
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
    local map = game.GetMap()
    local rows = {}
    local doorCount = 0
    for _, door in ents.Iterator() do
        if door:isDoor() then
            local mapID = door:MapCreationID()
            if not mapID or mapID <= 0 then continue end
            local doorData = door:getNetVar("doorData", {})
            if not doorData or table.IsEmpty(doorData) then continue end
            doorData = hook.Run("PreDoorDataSave", door, doorData) or doorData
            local factionsTable = doorData.factions or {}
            local classesTable = doorData.classes or {}
            if not doorData.factions then
                local factions = door:getNetVar("factions")
                if factions and factions ~= "[]" then
                    local success, result = pcall(util.JSONToTable, factions)
                    if success and istable(result) then
                        factionsTable = result
                    else
                        lia.warning(L("failedToParseFactionsJSON", mapID))
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
                        lia.warning(L("failedToParseClassesJSON", mapID))
                    end
                elseif door.liaClasses then
                    classesTable = door.liaClasses
                end
            end

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
            lia.error(L("failedToSaveDoorData", tostring(err)))
            lia.error(L("schemaProblem"))
        end)
    end
end

--[[
    Purpose: Adds a door preset configuration for a specific map
    When Called: When setting up predefined door configurations for maps
    Parameters:
        mapName (string) - The name of the map to apply the preset to
        presetData (table) - Table containing door configuration data with the following structure:
            [doorID] = {
                name (string, optional) - Custom name for the door
                price (number, optional) - Price to purchase the door
                locked (boolean, optional) - Whether the door starts locked
                disabled (boolean, optional) - Whether the door is disabled
                hidden (boolean, optional) - Whether the door info is hidden
                noSell (boolean, optional) - Whether the door cannot be sold
                factions (table, optional) - Array of faction uniqueIDs that can access the door
                classes (table, optional) - Array of class uniqueIDs that can access the door
            }
    Returns: None
    Realm: Server
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
    Purpose: Retrieves a door preset configuration for a specific map
    When Called: When loading door data or checking for existing presets
    Parameters:
        mapName (string) - The name of the map to get the preset for
    Returns: Table or nil - The preset data table if found, nil otherwise
    Realm: Server
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
    local mapName = game.GetMap()
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
    Purpose: Verifies the database schema for the doors table matches expected structure
    When Called: During server initialization or when checking database integrity
    Parameters: None
    Returns: None
    Realm: Server
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
            door_group = "text"
        }

        for column, type in pairs(missingColumns) do
            lia.db.query("ALTER TABLE lia_doors ADD COLUMN " .. column .. " " .. type)
        end
    end
    ```
]]
function lia.doors.verifyDatabaseSchema()
    if lia.db.module == "sqlite" then
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
                locked = "integer",
                door_group = "text"
            }

            for colName, expectedType in pairs(expectedColumns) do
                if not columns[colName] then
                    lia.error(L("missingExpectedColumn") .. " " .. colName)
                elseif columns[colName]:lower() ~= expectedType:lower() then
                    lia.warning(L("column") .. " " .. colName .. " " .. L("hasType") .. " " .. columns[colName] .. ", " .. L("expected") .. " " .. expectedType)
                end
            end
        end):catch(function(err) lia.error(L("failedToVerifyDatabaseSchema") .. " " .. tostring(err)) end)
    else
        lia.db.query("DESCRIBE lia_doors"):next(function(res)
            if not res or not res.results then
                lia.error(L("failedToGetTableInfo"))
                return
            end

            local columns = {}
            for _, row in ipairs(res.results) do
                columns[row.Field] = row.Type
            end

            lia.information(L("liaDoorsTableColumns") .. ": " .. table.concat(table.GetKeys(columns), ", "))
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
                    lia.error(L("missingExpectedColumn") .. " " .. colName)
                elseif not columns[colName]:lower():match(expectedType:lower()) then
                    lia.warning(L("column") .. " " .. colName .. " " .. L("hasType") .. " " .. columns[colName] .. ", " .. L("expected") .. " " .. expectedType)
                end
            end
        end):catch(function(err) lia.error(L("failedToVerifyDatabaseSchema") .. " " .. tostring(err)) end)
    end
end

--[[
    Purpose: Cleans up corrupted door data in the database by removing invalid faction/class data
    When Called: During server initialization or when data corruption is detected
    Parameters: None
    Returns: None
    Realm: Server
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
        local map = game.GetMap()
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
    local distance = client:GetPos():distance(door:GetPos())
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
    local distance = client:GetPos():distance(door:GetPos())
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

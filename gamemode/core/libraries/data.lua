file.CreateDir("lilia")
lia.data = lia.data or {}
lia.data.stored = lia.data.stored or {}
if SERVER then
    lia.data.isConverting = lia.data.isConverting or false
    local function buildCondition(folder, map)
        local cond = folder and "_folder = " .. lia.db.convertDataType(folder) or "_folder IS NULL"
        cond = cond .. " AND " .. (map and "_map = " .. lia.db.convertDataType(map) or "_map IS NULL")
        return cond
    end

    local function scanLegacyData()
        local entries = {}
        local paths = {}
        local base = "lilia"
        local function scan(dir)
            local files, dirs = file.Find(dir .. "/*", "DATA")
            for _, f in ipairs(files) do
                if f:sub(-4) == ".txt" then
                    local rel = string.sub(dir .. "/" .. f, #base + 2)
                    if not rel:StartWith("logs/") and rel ~= "config.txt" then
                        local segments = string.Explode("/", rel)
                        local folder
                        local map
                        local keySegments = {}
                        if #segments >= 3 then
                            folder = segments[1]
                            map = segments[2]
                            for i = 3, #segments do
                                keySegments[#keySegments + 1] = segments[i]
                            end
                        elseif #segments == 2 then
                            folder = segments[1]
                            keySegments[1] = segments[2]
                        else
                            keySegments[1] = segments[1]
                        end

                        local last = keySegments[#keySegments]
                        keySegments[#keySegments] = string.StripExtension(last)
                        local key = table.concat(keySegments, "/")
                        local path = dir .. "/" .. f
                        local data = file.Read(path, "DATA")
                        local ok, decoded = pcall(pon.decode, data)
                        if ok and decoded then
                            entries[#entries + 1] = {
                                key = key,
                                folder = folder,
                                map = map,
                                value = decoded[1]
                            }

                            paths[#paths + 1] = path
                        end
                    end
                end
            end

            for _, d in ipairs(dirs) do
                scan(dir .. "/" .. d)
            end
        end

        scan(base)
        return entries, paths
    end

    local function countLegacyDataEntries()
        local ported, total = 0, 0
        local base = "lilia"
        local function scan(dir)
            local files, dirs = file.Find(dir .. "/*", "DATA")
            for _, f in ipairs(files) do
                if f:sub(-4) == ".txt" then
                    local rel = string.sub(dir .. "/" .. f, #base + 2)
                    if not rel:StartWith("logs/") and rel ~= "config.txt" then
                        total = total + 1
                        local data = file.Read(dir .. "/" .. f, "DATA")
                        local ok, decoded = pcall(pon.decode, data)
                        if ok and decoded then ported = ported + 1 end
                    end
                end
            end

            for _, d in ipairs(dirs) do
                scan(dir .. "/" .. d)
            end
        end

        scan(base)
        return ported, total
    end

    local function ensureTable(key)
        local tbl = "lia_data_" .. key
        return lia.db.tableExists(tbl):next(function(exists) if not exists then return lia.db.query("CREATE TABLE IF NOT EXISTS " .. lia.db.escapeIdentifier(tbl) .. [[ (
                    _folder TEXT,
                    _map TEXT,
                    _value TEXT,
                    PRIMARY KEY (_folder, _map)
                );]]) end end)
    end

    function lia.data.set(key, value, global, ignoreMap)
        local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = ignoreMap and nil or game.GetMap()
        if global then
            folder = nil
            map = nil
        end

        lia.data.stored[key] = value
        lia.db.waitForTablesToLoad():next(function() return ensureTable(key) end):next(function()
            return lia.db.upsert({
                _folder = folder,
                _map = map,
                _value = {value}
            }, "data_" .. key)
        end):next(function() hook.Run("OnDataSet", key, value, folder, map) end)
        return "lilia/" .. (folder and folder .. "/" or "") .. (map and map .. "/" or "")
    end

    function lia.data.delete(key, global, ignoreMap)
        local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = ignoreMap and nil or game.GetMap()
        if global then
            folder = nil
            map = nil
        end

        lia.data.stored[key] = nil
        local condition = buildCondition(folder, map)
        lia.db.waitForTablesToLoad():next(function() return ensureTable(key) end):next(function() lia.db.delete("data_" .. key, condition) end)
        return true
    end

    function lia.data.convertToDatabase(changeMap)
        if lia.data.isConverting then return end
        lia.data.isConverting = true
        lia.bootstrap("Database", L("convertDataToDatabase"))
        local dataEntries, paths = scanLegacyData()
        local entryCount = #dataEntries
        local tableData = {}
        local ensurePromises = {}
        for _, entry in ipairs(dataEntries) do
            lia.data.stored[entry.key] = entry.value
            tableData[entry.key] = tableData[entry.key] or {}
            table.insert(tableData[entry.key], entry)
        end

        lia.db.waitForTablesToLoad():next(function()
            for key in pairs(tableData) do
                ensurePromises[#ensurePromises + 1] = ensureTable(key)
            end
            return deferred.all(ensurePromises)
        end):next(function()
            local queries = {}
            for key, entries in pairs(tableData) do
                local tbl = lia.db.escapeIdentifier("lia_data_" .. key)
                queries[#queries + 1] = "DELETE FROM " .. tbl
                for _, entry in ipairs(entries) do
                    queries[#queries + 1] = "INSERT INTO " .. tbl .. " (_folder,_map,_value) VALUES (" .. lia.db.convertDataType(entry.folder or NULL) .. ", " .. lia.db.convertDataType(entry.map or NULL) .. ", " .. lia.db.convertDataType({entry.value}) .. ")"
                end
            end
            return lia.db.transaction(queries)
        end):next(function()
            lia.data.isConverting = false
            lia.bootstrap("Database", L("convertDataToDatabaseDone", entryCount))
            for _, path in ipairs(paths) do
                file.Delete(path)
            end

            if changeMap then game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n") end
        end)
    end

    concommand.Add("lia_data_legacy_count", function(ply)
        if IsValid(ply) then return end
        local ported, total = countLegacyDataEntries()
        print("[Lilia] " .. L("legacyDataEntries", total, ported))
    end)

    function lia.data.loadTables()
        lia.db.waitForTablesToLoad():next(function()
            local query = lia.db.module == "sqlite" and "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'lia_data_%'" or "SHOW TABLES LIKE 'lia_data_%'"
            lia.db.query(query, function(res)
                local tables = {}
                if res then
                    if lia.db.module == "sqlite" then
                        for _, row in ipairs(res) do
                            tables[#tables + 1] = row.name
                        end
                    else
                        local k = next(res[1] or {})
                        for _, row in ipairs(res) do
                            tables[#tables + 1] = row[k]
                        end
                    end
                end

                local function loadNext(i)
                    i = i or 1
                    local tbl = tables[i]
                    if not tbl then return end
                    local key = tbl:match("^lia_data_(.+)$")
                    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
                    local map = game.GetMap()
                    local condition = buildCondition(folder, map)
                    lia.db.select({"_folder", "_map", "_value"}, "data_" .. key, condition):next(function(res2)
                        local rows = res2.results or {}
                        for _, row in ipairs(rows) do
                            local decoded = util.JSONToTable(row._value or "[]")
                            if istable(decoded) then
                                lia.data.stored[key] = decoded[1] or decoded
                            end
                        end

                        loadNext(i + 1)
                    end)
                end

                loadNext()
            end)
        end)
    end

    timer.Create("liaSaveData", lia.config.get("DataSaveInterval", 600), 0, function()
        hook.Run("SaveData")
        hook.Run("PersistenceSave")
    end)
end

function lia.data.get(key, default, _, _, refresh)
    if not refresh then
        local stored = lia.data.stored[key]
        if stored ~= nil then return stored end
    end
    return default
end

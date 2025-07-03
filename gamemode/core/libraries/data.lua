file.CreateDir("lilia")
lia.data = lia.data or {}
lia.data.stored = lia.data.stored or {}

if SERVER then
    lia.data.isConverting = lia.data.isConverting or false

    local function buildCondition(key, folder, map)
        local cond = "_key = " .. lia.db.convertDataType(key)
        cond = cond .. " AND " .. (folder and "_folder = " .. lia.db.convertDataType(folder) or "_folder IS NULL")
        cond = cond .. " AND " .. (map and "_map = " .. lia.db.convertDataType(map) or "_map IS NULL")
        return cond
    end

    local function scanLegacyData()
        local entries = {}
        local base = "lilia"

        local function scan(dir)
            local files, dirs = file.Find(dir .. "/*", "DATA")
            for _, f in ipairs(files) do
                if f:sub(-4) == ".txt" then
                    local rel = string.sub(dir .. "/" .. f, #base + 2)
                    if not rel:StartWith("logs/") then
                        local segments = string.Explode("/", rel)
                        local key = string.StripExtension(segments[#segments])
                        local folder
                        local map
                        if #segments == 2 then
                            folder = segments[1]
                        elseif #segments >= 3 then
                            folder = segments[1]
                            map = segments[2]
                        end
                        local data = file.Read(dir .. "/" .. f, "DATA")
                        local ok, decoded = pcall(pon.decode, data)
                        if ok and decoded then
                            entries[#entries + 1] = {
                                key = key,
                                folder = folder,
                                map = map,
                                value = decoded[1]
                            }
                        end
                    end
                end
            end
            for _, d in ipairs(dirs) do
                scan(dir .. "/" .. d)
            end
        end

        scan(base)
        return entries
    end

    function lia.data.set(key, value, global, ignoreMap)
        local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = ignoreMap and nil or game.GetMap()
        if global then
            folder = nil
            map = nil
        end

        lia.data.stored[key] = value
        lia.db.waitForTablesToLoad():next(function()
            lia.db.upsert({
                _key = key,
                _folder = folder,
                _map = map,
                _value = {value}
            }, "data")
        end)

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
        local condition = buildCondition(key, folder, map)
        lia.db.waitForTablesToLoad():next(function()
            lia.db.delete("data", condition)
        end)
        return true
    end

    function lia.data.convertToDatabase(changeMap)
        if lia.data.isConverting then return end
        lia.data.isConverting = true
        SetGlobalBool("liaDataConverting", true)
        print("[Lilia] Converting lia.data to database...")
        local dataEntries = scanLegacyData()
        local queries = {"DELETE FROM lia_data"}
        for _, entry in ipairs(dataEntries) do
            print("[Lilia]  - " .. entry.key)
            lia.data.stored[entry.key] = entry.value
            queries[#queries + 1] = "INSERT INTO lia_data (_key,_folder,_map,_value) VALUES (" ..
                lia.db.convertDataType(entry.key) .. ", " ..
                lia.db.convertDataType(entry.folder or NULL) .. ", " ..
                lia.db.convertDataType(entry.map or NULL) .. ", " ..
                lia.db.convertDataType({entry.value}) .. ")"
        end

        lia.db.waitForTablesToLoad():next(function()
            lia.db.transaction(queries):next(function()
                lia.data.isConverting = false
                SetGlobalBool("liaDataConverting", false)
                print("[Lilia] Data conversion complete.")
                if changeMap then
                    game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
                end
            end)
        end)
    end

    function lia.data.loadTables()
        lia.db.waitForTablesToLoad():next(function()
            lia.db.select({"_key", "_folder", "_map", "_value"}, "data"):next(function(res)
                local rows = res.results or {}
                for _, row in ipairs(rows) do
                    local decoded = util.JSONToTable(row._value or "[]")
                    lia.data.stored[row._key] = decoded and decoded[1]
                end
                local legacy = scanLegacyData()
                lia.db.count("data"):next(function(n)
                    if n == 0 and #legacy > 0 then
                        lia.data.convertToDatabase(true)
                    end
                end)
            end)
        end)
    end

    hook.Add("CheckPassword", "liaDataConversion", function()
        if lia.data.isConverting then
            return false, "Server is converting data, please retry later"
        end
    end)

    timer.Create("liaSaveData", lia.config.get("DataSaveInterval", 600), 0, function()
        hook.Run("SaveData")
        hook.Run("PersistenceSave")
    end)
end

function lia.data.get(key, default, global, ignoreMap, refresh)
    if not refresh then
        local stored = lia.data.stored[key]
        if stored ~= nil then return stored end
    end

    return default
end

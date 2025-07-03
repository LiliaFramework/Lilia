file.CreateDir("lilia")

lia.data = lia.data or {}
lia.data.stored = lia.data.stored or {}
lia.data.isConverting = lia.data.isConverting or false

local function buildKey(key, global, ignoreMap)
    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local prefix = ""
    if not global then prefix = prefix .. folder .. "/" end
    if not ignoreMap then prefix = prefix .. game.GetMap() .. "/" end
    return prefix .. key, "lilia/" .. prefix, "lilia/" .. prefix .. key .. ".txt"
end

local function loadFromLegacy()
    local function scan(dir, prefix, data)
        local files, dirs = file.Find(dir .. "*", "DATA")
        for _, f in ipairs(files) do
            if f:sub(-4) == ".txt" then
                local path = dir .. f
                local content = file.Read(path, "DATA")
                if content and content ~= "" then
                    local ok, dec = pcall(pon.decode, content)
                    if ok and dec then
                        data[prefix .. f:sub(1, -5)] = dec[1]
                    end
                end
            end
        end
        for _, d in ipairs(dirs) do
            scan(dir .. d .. "/", prefix .. d .. "/", data)
        end
    end
    local legacy = {}
    scan("lilia/", "", legacy)
    return legacy
end

if SERVER then
    function lia.data.set(key, value, global, ignoreMap)
        local dbKey, dir, filePath = buildKey(key, global, ignoreMap)
        file.CreateDir(dir)
        file.Write(filePath, pon.encode({value}))
        lia.data.stored[dbKey] = value
        if lia.db and lia.db.tablesLoaded then
            lia.db.upsert({_key = dbKey, _value = {value}}, "data")
        end
        return dir
    end

    function lia.data.delete(key, global, ignoreMap)
        local dbKey, _, filePath = buildKey(key, global, ignoreMap)
        local contents = file.Read(filePath, "DATA")
        if contents and contents ~= "" then
            file.Delete(filePath)
            lia.data.stored[dbKey] = nil
            if lia.db and lia.db.tablesLoaded then
                lia.db.delete("data", "_key = " .. lia.db.convertDataType(dbKey))
            end
            return true
        else
            if lia.db and lia.db.tablesLoaded then
                lia.db.delete("data", "_key = " .. lia.db.convertDataType(dbKey))
            end
            return false
        end
    end

    function lia.data.load()
        lia.db.waitForTablesToLoad():next(function()
            lia.db.select({"_key", "_value"}, "data"):next(function(res)
                local rows = res.results or {}
                if #rows == 0 then
                    local legacy = loadFromLegacy()
                    if next(legacy) then
                        for k, v in pairs(legacy) do
                            lia.data.stored[k] = v
                        end
                        lia.data.convertToDatabase(false, legacy)
                    end
                else
                    for _, row in ipairs(rows) do
                        local decoded = util.JSONToTable(row._value)
                        lia.data.stored[row._key] = decoded and decoded[1]
                    end
                end
            end)
        end)
    end

    function lia.data.convertToDatabase(changeMap, data)
        if lia.data.isConverting then return end
        lia.data.isConverting = true
        SetGlobalBool("liaDataConverting", true)
        print("[Lilia] Converting lia.data to database...")
        data = data or loadFromLegacy()
        local queries = {"DELETE FROM lia_data"}
        for k, v in pairs(data) do
            print("[Lilia]  - " .. k)
            queries[#queries + 1] = "INSERT INTO lia_data (_key,_value) VALUES (" .. lia.db.convertDataType(k) .. ", " .. lia.db.convertDataType({v}) .. ")"
            lia.data.stored[k] = v
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

    hook.Add("CheckPassword", "liaDataConversion", function()
        if lia.data.isConverting then
            return false, "Server is converting data, please retry later"
        end
    end)

    hook.Add("LiliaTablesLoaded", "liaDataLoad", function()
        lia.data.load()
    end)

    timer.Create("liaSaveData", lia.config.get("DataSaveInterval", 600), 0, function()
        hook.Run("SaveData")
        hook.Run("PersistenceSave")
    end)
end

function lia.data.get(key, default, global, ignoreMap, refresh)
    local dbKey, _, filePath = buildKey(key, global, ignoreMap)
    if not refresh then
        local stored = lia.data.stored[dbKey]
        if stored ~= nil then return stored end
    end
    local contents = file.Read(filePath, "DATA")
    if contents and contents ~= "" then
        local ok, decoded = pcall(pon.decode, contents)
        if ok and decoded then
            local value = decoded[1]
            lia.data.stored[dbKey] = value
            if SERVER and lia.db and lia.db.tablesLoaded then
                lia.db.upsert({_key = dbKey, _value = {value}}, "data")
            end
            if value ~= nil then
                return value
            else
                return default
            end
        else
            return default
        end
    else
        return default
    end
end

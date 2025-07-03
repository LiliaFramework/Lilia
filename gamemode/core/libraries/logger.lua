lia.log = lia.log or {}
lia.log.types = lia.log.types or {}
if SERVER then
    lia.log.isConverting = lia.log.isConverting or false
    local function createLogsTable()
        if lia.db.module == "sqlite" then
            lia.db.query([[CREATE TABLE IF NOT EXISTS lia_logs (
                _id INTEGER PRIMARY KEY AUTOINCREMENT,
                _timestamp DATETIME,
                _gamemode VARCHAR,
                _category VARCHAR,
                _message TEXT,
                _charID INTEGER,
                _steamID VARCHAR
            );]])
        else
            lia.db.query([[CREATE TABLE IF NOT EXISTS `lia_logs` (
                `_id` INT(12) NOT NULL AUTO_INCREMENT,
                `_timestamp` DATETIME NOT NULL,
                `_gamemode` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
                `_category` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
                `_message` TEXT NOT NULL COLLATE 'utf8mb4_general_ci',
                `_charID` INT(12) NULL,
                `_steamID` VARCHAR(20) NULL COLLATE 'utf8mb4_general_ci',
                PRIMARY KEY (`_id`)
            );]])
        end
    end

    local function checkLegacyLogs()
        local baseDir = "lilia/logs"
        local found = false
        local files, dirs = file.Find(baseDir .. "/*", "DATA")
        for _, fileName in ipairs(files) do
            if fileName:sub(-4) == ".txt" then
                found = true
                break
            end
        end
        if not found then
            for _, gm in ipairs(dirs) do
                local f = file.Find(baseDir .. "/" .. gm .. "/*.txt", "DATA")
                if #f > 0 then
                    found = true
                    break
                end
            end
        end
        if not found then return end
        lia.db.count("logs"):next(function(n) if n == 0 then lia.log.convertToDatabase(true) end end)
    end

    function lia.log.loadTables()
        file.CreateDir("lilia/logs/" .. engine.ActiveGamemode())
        lia.db.waitForTablesToLoad():next(function()
            createLogsTable()
            checkLegacyLogs()
        end)
    end

    function lia.log.addType(logType, func, category)
        lia.log.types[logType] = {
            func = func,
            category = category,
        }
    end

    function lia.log.getString(client, logType, ...)
        local logData = lia.log.types[logType]
        if not logData then return end
        if isfunction(logData.func) then
            local success, result = pcall(logData.func, client, ...)
            if success then return result, logData.category end
        end
    end

    function lia.log.add(client, logType, ...)
        local logString, category = lia.log.getString(client, logType, ...)
        if not isstring(category) then category = "Uncategorized" end
        if not isstring(logString) then return end
        hook.Run("OnServerLog", client, logType, logString, category)
        lia.printLog(category, logString)
        local logsDir = "lilia/logs/" .. engine.ActiveGamemode()
        if not file.Exists(logsDir, "DATA") then file.CreateDir(logsDir) end
        local filenameCategory = string.lower(string.gsub(category, "%s+", "_"))
        local logFilePath = logsDir .. "/" .. filenameCategory .. ".txt"
        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
        file.Append(logFilePath, "[" .. timestamp .. "]\t" .. logString .. "\r\n")
        local charID
        local steamID
        if IsValid(client) then
            local char = client:getChar()
            charID = char and char:getID() or nil
            steamID = client:SteamID64()
        end

        lia.db.insertTable({
            _timestamp = timestamp,
            _gamemode = engine.ActiveGamemode(),
            _category = category,
            _message = logString,
            _charID = charID,
            _steamID = steamID
        }, nil, "logs")
    end

    function lia.log.convertToDatabase(changeMap)
        if lia.log.isConverting then return end
        lia.log.isConverting = true
        print("[Lilia] Converting legacy logs to database...")
        local baseDir = "lilia/logs"
        local entries = {}
        local files, dirs = file.Find(baseDir .. "/*", "DATA")

        local function processFile(path, gamemode, category)
            local data = file.Read(path, "DATA")
            if not data then return end
            for line in data:gmatch("[^\r\n]+") do
                local ts, msg = line:match("^%[([^%]]+)%]%s*(.+)")
                if ts and msg then
                    local steamID = msg:match("%[(%d+)%]")
                    local charID = msg:match("CharID:%s*(%d+)")
                    entries[#entries + 1] = {
                        _timestamp = ts,
                        _gamemode = gamemode,
                        _category = category,
                        _message = msg,
                        _charID = charID,
                        _steamID = steamID
                    }
                end
            end
        end

        for _, fileName in ipairs(files) do
            if fileName:sub(-4) == ".txt" then
                local category = string.StripExtension(fileName)
                processFile(baseDir .. "/" .. fileName, engine.ActiveGamemode(), category)
            end
        end

        for _, gm in ipairs(dirs) do
            local gmPath = baseDir .. "/" .. gm
            local gmFiles = file.Find(gmPath .. "/*.txt", "DATA")
            for _, fileName in ipairs(gmFiles) do
                local category = string.StripExtension(fileName)
                processFile(gmPath .. "/" .. fileName, gm, category)
            end
        end

        local entryCount = #entries

        lia.db.waitForTablesToLoad():next(function()
            local function insertNext(i)
                i = i or 1
                if i > #entries then
                    lia.log.isConverting = false
                    print("[Lilia] Log conversion complete. Ported " .. entryCount .. " entries.")
                    if changeMap then game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n") end
                    return
                end

                lia.db.insertTable(entries[i], function() insertNext(i + 1) end, "logs")
            end

            insertNext()
        end)
    end

    local function countLegacyLogEntries()
        local baseDir = "lilia/logs"
        local total, ported = 0, 0
        local files, dirs = file.Find(baseDir .. "/*", "DATA")

        local function scanFile(path)
            local data = file.Read(path, "DATA")
            if not data then return end
            for line in data:gmatch("[^\r\n]+") do
                total = total + 1
                local ts, msg = line:match("^%[([^%]]+)%]%s*(.+)")
                if ts and msg then ported = ported + 1 end
            end
        end

        for _, fileName in ipairs(files) do
            if fileName:sub(-4) == ".txt" then
                scanFile(baseDir .. "/" .. fileName)
            end
        end

        for _, gm in ipairs(dirs) do
            local gmFiles = file.Find(baseDir .. "/" .. gm .. "/*.txt", "DATA")
            for _, fileName in ipairs(gmFiles) do
                scanFile(baseDir .. "/" .. gm .. "/" .. fileName)
            end
        end

        return ported, total
    end

    concommand.Add("lia_log_legacy_count", function(ply)
        if IsValid(ply) then return end
        local ported, total = countLegacyLogEntries()
        print("[Lilia] lia.log legacy files contain " .. total .. " lines; " .. ported .. " can be ported.")
    end)
end
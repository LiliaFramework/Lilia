lia.log = lia.log or {}
lia.log.types = lia.log.types or {}
if SERVER then
    lia.log.isConverting = lia.log.isConverting or false
    local function createLogsTable()
        if lia.db.module == "sqlite" then
            lia.db.query([[CREATE TABLE IF NOT EXISTS lia_logs (
                _id INTEGER PRIMARY KEY AUTOINCREMENT,
                _timestamp DATETIME,
                _category VARCHAR,
                _message TEXT
            );]])
        else
            lia.db.query([[CREATE TABLE IF NOT EXISTS `lia_logs` (
                `_id` INT(12) NOT NULL AUTO_INCREMENT,
                `_timestamp` DATETIME NOT NULL,
                `_category` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
                `_message` TEXT NOT NULL COLLATE 'utf8mb4_general_ci',
                PRIMARY KEY (`_id`)
            );]])
        end
    end

    local function checkLegacyLogs()
        local logsDir = "lilia/logs/" .. engine.ActiveGamemode()
        local files = file.Find(logsDir .. "/*.txt", "DATA")
        if #files == 0 then return end
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
        lia.db.insertTable({
            _timestamp = timestamp,
            _category = category,
            _message = logString
        }, nil, "logs")
    end

    function lia.log.convertToDatabase(changeMap)
        if lia.log.isConverting then return end
        lia.log.isConverting = true
        print("[Lilia] Converting legacy logs to database...")
        local logsDir = "lilia/logs/" .. engine.ActiveGamemode()
        local files = file.Find(logsDir .. "/*.txt", "DATA")
        local entries = {}
        for _, fileName in ipairs(files) do
            local category = string.StripExtension(fileName)
            local data = file.Read(logsDir .. "/" .. fileName, "DATA")
            if data then
                for line in data:gmatch("[^\r\n]+") do
                    local ts, msg = line:match("^%[([^%]]+)%]%s*(.+)")
                    if ts and msg then
                        entries[#entries + 1] = {
                            _timestamp = ts,
                            _category = category,
                            _message = msg
                        }
                    end
                end
            end
        end

        lia.db.waitForTablesToLoad():next(function()
            local function insertNext(i)
                i = i or 1
                if i > #entries then
                    lia.log.isConverting = false
                    print("[Lilia] Log conversion complete.")
                    if changeMap then game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n") end
                    return
                end

                lia.db.insertTable(entries[i], function() insertNext(i + 1) end, "logs")
            end

            insertNext()
        end)
    end
end
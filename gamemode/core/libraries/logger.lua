lia.log = lia.log or {}
lia.log.types = lia.log.types or {}
if SERVER then
    function lia.log.loadTables()
        file.CreateDir("lilia/logs/" .. engine.ActiveGamemode())
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
        file.Append(logFilePath, "[" .. os.date("%Y-%m-%d %H:%M:%S") .. "]\t" .. logString .. "\r\n")
    end
end
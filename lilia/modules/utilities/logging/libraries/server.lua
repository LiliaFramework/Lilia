function MODULE:ReadLogFiles(logtype)
    local logs = {}
    local logFilePath = "lilia/" .. logtype .. "/*.txt"
    local logFiles = file.Find(logFilePath, "DATA")
    for _, fileName in ipairs(logFiles) do
        local strippedName = string.StripExtension(fileName)
        table.insert(logs, strippedName)
    end
    return logs
end

function MODULE:ReadLogsFromFile(logtype, selectedDate)
    local logs = {}
    local logFilePath = "lilia/" .. logtype .. "/" .. selectedDate:gsub("/", "-") .. ".txt"
    if file.Exists(logFilePath, "DATA") then
        local logFileContent = file.Read(logFilePath, "DATA")
        for line in logFileContent:gmatch("[^\r\n]+") do
            local timestamp, message = line:match("%[([^%]]+)%]%s*(.+)")
            if timestamp and message then
                table.insert(logs, {
                    timestamp = timestamp,
                    message = message
                })
            end
        end
    end
    return logs
end

function MODULE:OnServerLog(client, logType, logString, category, color)
    for _, v in pairs(lia.util.getAdmins()) do
        if hook.Run("CanPlayerSeeLog", v, logType) ~= false then lia.log.send(v, lia.log.getString(client, logType, logString, category, color)) end
    end

    local LogEvent = self:addCategory(category, color)
    LogEvent(logString)
end

function MODULE:CanPlayerSeeLog()
    return lia.config.AdminConsoleNetworkLogs
end
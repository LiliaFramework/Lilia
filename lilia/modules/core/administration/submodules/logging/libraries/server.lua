local MODULE = MODULE
util.AddNetworkString("send_logs")
function MODULE:ReadLogFiles(logtype)
    local logs = {}
    local logFilePath = "lilia/logs" .. logtype .. "/*.txt"
    local logFiles = file.Find(logFilePath, "DATA")
    for _, fileName in ipairs(logFiles) do
        local strippedName = string.StripExtension(fileName)
        table.insert(logs, strippedName)
    end
    return logs
end

function MODULE:ReadLogsFromFile(logtype, selectedDate)
    local logs = {}
    local logFilePath = "lilia/logs" .. logtype .. "/" .. selectedDate:gsub("/", "-") .. ".txt"
    if file.Exists(logFilePath, "DATA") then
        local logFileContent = file.Read(logFilePath, "DATA")
        for line in logFileContent:gmatch("[^\r\n]+") do
            local timestamp, message = line:match("^%[([^%]]+)%]%s*(.+)")
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

function MODULE:OnServerLog(_, logType, logString)
    for _, admin in pairs(lia.util.getAdmins()) do
        if hook.Run("CanPlayerSeeLog", admin, logType) ~= false then lia.log.send(admin, logString) end
    end
end

function MODULE:CanPlayerSeeLog()
    return lia.config.AdminConsoleNetworkLogs
end
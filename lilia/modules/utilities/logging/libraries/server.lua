function LoggerCore:ReadLogFiles()
    local logs = {}
    local logFilePath = "lilia/logs/*.txt"
    local logFiles = file.Find(logFilePath, "DATA")
    for _, fileName in ipairs(logFiles) do
        local strippedName = string.StripExtension(fileName)
        table.insert(logs, strippedName)
    end
    return logs
end

function LoggerCore:ReadLogsFromFile(selectedDate)
    local logs = {}
    local logFilePath = "lilia/logs/" .. selectedDate:gsub("/", "-") .. ".txt"
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
local MODULE = MODULE
lia.command.add("logs", {
    privilege = "See Logs",
    adminOnly = true,
    syntax = "<string faction> [string class]",
    onRun = function(client)
        local categorizedLogs = {}
        for logType, logData in pairs(lia.log.types) do
            local category = logData.category
            if not categorizedLogs[category] then categorizedLogs[category] = {} end
            local logFiles = MODULE:ReadLogFiles(logType)
            for _, date in ipairs(logFiles) do
                local logs = MODULE:ReadLogsFromFile(logType, date)
                for _, log in ipairs(logs) do
                    table.insert(categorizedLogs[category], log)
                end
            end
        end

        net.Start("send_logs")
        net.WriteTable(categorizedLogs)
        net.Send(client)
    end
})
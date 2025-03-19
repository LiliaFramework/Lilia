local MODULE = MODULE
lia.command.add("logs", {
    privilege = "See Logs",
    adminOnly = true,
    onRun = function(client)
        local categorizedLogs = {}
        for _, logData in pairs(lia.log.types) do
            local category = logData.category or "Uncategorized"
            if not categorizedLogs[category] then categorizedLogs[category] = {} end
            local logs = MODULE:ReadLogFiles(category)
            for _, log in ipairs(logs) do
                table.insert(categorizedLogs[category], log)
            end
        end

        MODULE:SendLogsInChunks(client, categorizedLogs)
    end
})
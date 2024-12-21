local MODULE = MODULE
lia.command.add("logs", {
    privilege = "See Logs",
    adminOnly = true,
    syntax = "<string faction> [string class]",
    onRun = function(client)
        local categorizedLogs = {}
        for _, logData in pairs(lia.log.types) do
            local category = logData.category
            if not categorizedLogs[category] then categorizedLogs[category] = {} end
            local logs = MODULE:ReadLogFiles(category)
            for _, log in ipairs(logs) do
                table.insert(categorizedLogs[category], log)
            end
        end

        net.Start("send_logs")
        net.WriteTable(categorizedLogs)
        net.Send(client)
    end
})

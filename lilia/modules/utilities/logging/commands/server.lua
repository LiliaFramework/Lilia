﻿lia.command.add("logs", {
    superAdminOnly = true,
    privilege = "View Logs",
    onRun = function(client)
        net.Start("liaRequestLogs")
        net.WriteTable(LoggerCore:ReadLogFiles())
        net.Send(client)
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local MODULE = MODULE
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("logs", {
    AdminOnly = true,
    privilege = "View Logs",
    onRun = function(client)
        net.Start("liaRequestLogsClient")
        net.WriteTable(MODULE:ReadLogFiles("logs"))
        net.WriteString("logs")
        net.Send(client)
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("netlogs", {
    superAdminOnly = true,
    privilege = "View Advanced Logs",
    onRun = function(client)
        net.Start("liaRequestLogsClient")
        net.WriteTable(MODULE:ReadLogFiles("netlogs"))
        net.WriteString("netlogs")
        net.Send(client)
    end
})

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.add("concommandlogs", {
    superAdminOnly = true,
    privilege = "View Advanced Logs",
    onRun = function(client)
        net.Start("liaRequestLogsClient")
        net.WriteTable(MODULE:ReadLogFiles("concommandlogs"))
        net.WriteString("concommandlogs")
        net.Send(client)
    end
})
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------

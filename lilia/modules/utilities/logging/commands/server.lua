local MODULE = MODULE
lia.command.add("legacylogs", {
    adminOnly = true,
    privilege = "View Logs",
    onRun = function(client)
        net.Start("liaRequestLogsClient")
        net.WriteTable(MODULE:ReadLogFiles("logs"))
        net.WriteString("logs")
        net.Send(client)
    end
})

lia.command.add("logger", {
    adminOnly = true,
    privilege = "View Logs",
    onRun = function(client)
        client:ConCommand("logger_retrieve_categories")
        net.Start("OpenLogger")
        net.Send(client)
    end
})

lia.command.add("deletelogs", {
    superAdminOnly = true,
    privilege = "Erase Logs",
    onRun = function(client)
        lia.db.query("DELETE FROM `lilia_logs` WHERE time > 0", function(result)
            if result then
                client:ChatNotify("All logs with time greater than 0 have been erased")
            else
                client:ChatNotify("Failed to erase logs: " .. sql.LastError())
            end
        end)
    end
})
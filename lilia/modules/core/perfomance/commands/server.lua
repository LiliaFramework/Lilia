local MODULE = MODULE
lia.command.add("addrestarttime", {
    superAdminOnly = true,
    privilege = "Modify Auto Restart",
    syntax = "<time>",
    onRun = function(_, arguments)
        local delay = arguments[1] or 60
        MODULE.NextRestart = MODULE.NextRestart + (delay * 60)
        MODULE.NextNotificationTime = MODULE.NextNotificationTime + (delay * 60)
        lia.util.notify(string.format("Added %d minutes to server restart time!", delay))
    end
})

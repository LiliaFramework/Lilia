local CONFIG = CONFIG

lia.command.add("addrestarttime", {
    adminOnly = true,
    onRun = function(client, arguments)
        local delay = arguments[1]
        delay = delay or 60
        CONFIG.NextRestart = CONFIG.NextRestart + (delay * 60)
        CONFIG.NextNotificationTime = CONFIG.NextNotificationTime + (delay * 60)
        lia.util.notify(string.format("Added %d minutes to server restart time!", delay))
    end
})
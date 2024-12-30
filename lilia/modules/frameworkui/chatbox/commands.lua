local MODULE = MODULE
MODULE.OOCBans = MODULE.OOCBans or {}
lia.command.add("banooc", {
    adminOnly = true,
    privilege = "Ban OOC",
    syntax = "[string charname]",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            MODULE.OOCBans[target:SteamID()] = true
            client:notify(target:Name() .. " has been banned from OOC.")
        else
            client:notify("Invalid target.")
        end
    end
})

lia.command.add("unbanooc", {
    adminOnly = true,
    privilege = "Unban OOC",
    syntax = "[string charname]",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            MODULE.OOCBans[target:SteamID()] = nil
            client:notify(target:Name() .. " has been unbanned from OOC.")
        end
    end
})

lia.command.add("blockooc", {
    superAdminOnly = true,
    privilege = "Block OOC",
    syntax = "[string charname]",
    onRun = function(client)
        if GetGlobalBool("oocblocked", false) then
            SetGlobalBool("oocblocked", false)
            client:notify("Unlocked OOC!")
        else
            SetGlobalBool("oocblocked", true)
            client:notify("Blocked OOC!")
        end
    end
})

lia.command.add("refreshfonts", {
    superAdminOnly = true,
    privilege = "Refresh Fonts",
    onRun = function(client)
        RunConsoleCommand("fixchatplz")
        hook.Run("LoadFonts", lia.config.Font)
        client:chatNotify("Fonts have been refreshed!")
    end
})

lia.command.add("clearchat", {
    adminOnly = true,
    privilege = "Clear Chat",
    onRun = function() netstream.Start(player.GetAll(), "adminClearChat") end
})
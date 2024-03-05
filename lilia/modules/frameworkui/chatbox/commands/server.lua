local MODULE = MODULE
MODULE.OOCBans = MODULE.OOCBans or {}
lia.command.add("banooc", {
    privilege = "Ban OOC",
    syntax = "<string target>",
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
    privilege = "Unban OOC",
    syntax = "<string target>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            MODULE.OOCBans[target:SteamID()] = nil
            client:notify(target:Name() .. " has been unbanned from OOC.")
        end
    end
})

lia.command.add("blockooc", {
    privilege = "Block OOC",
    syntax = "<string target>",
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

lia.command.add("clearchat", {
    superAdminOnly = true,
    privilege = "Clear Chat",
    onRun = function() netstream.Start(player.GetAll(), "adminClearChat") end
})

lia.command.add("refreshfonts", {
    privilege = "Refresh Fonts",
    syntax = "<No Input>",
    onRun = function(client)
        RunConsoleCommand("fixchatplz")
        hook.Run("LoadFonts", lia.config.Font)
        client:ChatPrint("Fonts have been refreshed!")
    end
})

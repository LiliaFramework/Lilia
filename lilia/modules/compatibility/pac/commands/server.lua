lia.command.add("fixpac", {
    adminonly = false,
    syntax = "<No Input>",
    onRun = function(client)
        timer.Simple(0, function() if IsValid(client) then client:ConCommand("pac_clear_parts") end end)
        timer.Simple(0.5, function()
            if IsValid(client) then
                client:ConCommand("pac_urlobj_clear_cache")
                client:ConCommand("pac_urltex_clear_cache")
            end
        end)

        timer.Simple(1.0, function() if IsValid(client) then client:ConCommand("pac_restart") end end)
        timer.Simple(1.5, function() if IsValid(client) then client:ChatPrint("PAC has been successfully restarted. You might need to run this command twice!") end end)
    end
})

lia.command.add("pacenable", {
    adminonly = false,
    onRun = function(client) client:SendLua([[RunConsoleCommand("pac_enable", "1")]]) end
})

lia.command.add("pacdisable", {
    adminonly = false,
    onRun = function(client)
        client:SendLua([[RunConsoleCommand("pac_enable", "0")]])
        client:SendLua([[chat.AddText("PAC has been disabled to boost performance. If you would like to re-enable it type /pacenable in chat.")]])
    end
})
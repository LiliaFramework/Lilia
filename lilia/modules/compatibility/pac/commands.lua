lia.command.add("fixpac", {
    adminonly = false,
    onRun = function(client)
        timer.Simple(0, function() if IsValid(client) then client:ConCommand("pac_clear_parts") end end)
        timer.Simple(0.5, function()
            if IsValid(client) then
                client:ConCommand("pac_urlobj_clear_cache")
                client:ConCommand("pac_urltex_clear_cache")
            end
        end)

        timer.Simple(1.0, function() if IsValid(client) then client:ConCommand("pac_restart") end end)
        timer.Simple(1.5, function() if IsValid(client) then client:notifyLocalized("fixpac_success") end end)
    end
})

lia.command.add("pacenable", {
    adminonly = false,
    onRun = function(client)
        client:ConCommand("pac_enable 1")
        client:notifyLocalized("pacenable_success")
    end
})

lia.command.add("pacdisable", {
    adminonly = false,
    onRun = function(client)
        client:ConCommand("pac_enable 0")
        client:notifyLocalized("pacdisable_message")
    end
})

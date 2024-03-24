local MODULE = MODULE
lia.command.add("toggleraise", {
    adminOnly = false,
    onRun = function(client)
        if (client.liaNextToggle or 0) < CurTime() and MODULE.WepAlwaysRaised then
            client:toggleWepRaised()
            client.liaNextToggle = CurTime() + MODULE.WeaponToggleDelay
        end
    end
})
local MODULE = MODULE
local WeaponToggleDelay = 1
lia.command.add("toggleraise", {
    adminOnly = false,
    onRun = function(client)
        if (client.liaNextToggle or 0) < CurTime() and MODULE.WepAlwaysRaised then
            client:toggleWepRaised()
            client.liaNextToggle = CurTime() + WeaponToggleDelay
        end
    end
})
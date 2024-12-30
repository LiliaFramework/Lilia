lia.command.add("viewBodygroups", {
    adminOnly = true,
    privilege = "Manage Bodygroups",
    syntax = "[string charname]",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1] or "")
        if not target or not IsValid(target) then
            client:notifyLocalized("noTarget")
            return
        end

        net.Start("BodygrouperMenu")
        net.WriteEntity(target)
        net.Send(client)
    end
})
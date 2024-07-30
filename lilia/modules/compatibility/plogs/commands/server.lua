lia.command.add("plogs", {
    adminOnly = false,
    onRun = function(client)
        if plogs.HasPerms(client) then
            plogs.OpenMenu(client)
        else
            client:ChatPrint("You do not have permission to use plogs!")
        end
    end
})
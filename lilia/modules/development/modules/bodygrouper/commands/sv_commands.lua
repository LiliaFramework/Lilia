--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "viewBodygroups",
    {
        adminOnly = true,
        privilege = "Change Bodygroups",
        syntax = "[string name]",
        onRun = function(client, args)
            local target = lia.command.findPlayer(client, args[1] or "")
            net.Start("BodygrouperMenu")
            if IsValid(target) then net.WriteEntity(target) end
            net.Send(client)
        end
    }
)
--------------------------------------------------------------------------------------------------------------------------

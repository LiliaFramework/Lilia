sam.command.new("blind"):SetPermission("blind", "superadmin"):AddArg("player"):Help("Blinds the Players"):OnExecute(function(client, targets)
    for i = 1, #targets do
        local target = targets[i]
        net.Start("sam_blind")
        net.WriteBool(true)
        net.Send(target)
    end

    if not sam.is_command_silent then
        client:sam_send_message("{A} Blinded {T}", {
            A = client,
            T = targets
        })
    end
end):End()

sam.command.new("unblind"):SetPermission("blind", "superadmin"):AddArg("player"):Help("Unblinds the Players"):OnExecute(function(client, targets)
    for i = 1, #targets do
        local target = targets[i]
        net.Start("sam_blind")
        net.WriteBool(false)
        net.Send(target)
    end

    if not sam.is_command_silent then
        client:sam_send_message("{A} Un-Blinded {T}", {
            A = client,
            T = targets
        })
    end
end):End()


function MODULE:InitializedModules()
    hook.Remove("PlayerSay", "SAM.Chat.Asay")
end

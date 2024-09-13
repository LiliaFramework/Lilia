local MODULE = MODULE
function sam.player.send_message(client, msg, tbl)
    if SERVER then
        if sam.isconsole(client) then
            local result = sam.format_message(msg, tbl)
            sam.print(unpack(result, 1, result.__cnt))
        else
            return sam.netstream.Start(client, "send_message", msg, tbl)
        end
    else
        local prefix_result = sam.format_message(sam.config.get("ChatPrefix", ""))
        local prefix_n = #prefix_result
        local result = sam.format_message(msg, tbl, prefix_result, prefix_n)
        if MODULE.DisplayStaffCommands then chat.AddText(unpack(result, 1, result.__cnt)) end
    end
end

function MODULE:PlayerSay(client, text)
    if text:sub(1, 1) == "@" then

        return ""
    end
end

sam.command.new("blind"):SetPermission("blind", "superadmin"):AddArg("player"):Help("Blinds the Players"):OnExecute(function(ply, targets)
    for i = 1, #targets do
        local target = targets[i]
        net.Start("sam_blind")
        net.WriteBool(true)
        net.Send(target)
    end

    if not sam.is_command_silent then
        ply:sam_send_message("{A} Blinded {T}", {
            A = ply,
            T = targets
        })
    end
end):End()

sam.command.new("unblind"):SetPermission("blind", "superadmin"):AddArg("player"):Help("Unblinds the Players"):OnExecute(function(ply, targets)
    for i = 1, #targets do
        local target = targets[i]
        net.Start("sam_blind")
        net.WriteBool(false)
        net.Send(target)
    end

    if not sam.is_command_silent then
        ply:sam_send_message("{A} Un-Blinded {T}", {
            A = ply,
            T = targets
        })
    end
end):End()

hook.Remove("PlayerSay", "SAM.Chat.Asay")
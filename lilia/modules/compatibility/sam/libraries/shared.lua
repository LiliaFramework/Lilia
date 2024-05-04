local MODULE = MODULE
function sam.player.send_message(ply, msg, tbl)
    if SERVER then
        if sam.isconsole(ply) then
            local result = sam.format_message(msg, tbl)
            sam.print(unpack(result, 1, result.__cnt))
        else
            return sam.netstream.Start(ply, "send_message", msg, tbl)
        end
    else
        local prefix_result = sam.format_message(sam.config.get("ChatPrefix", ""))
        local prefix_n = #prefix_result
        local result = sam.format_message(msg, tbl, prefix_result, prefix_n)
        if MODULE.DisplayStaffCommands then chat.AddText(unpack(result, 1, result.__cnt)) end
    end
end
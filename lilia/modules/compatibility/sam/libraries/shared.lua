﻿local MODULE = MODULE
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

function MODULE:PlayerSay(client, text)
    if text:sub(1, 1) == "@" then
        lia.command.run(client, "asay", {text:sub(2)})
        return ""
    end
end

lia.chat.register("asay", {
    onCanSay = function(client) return CAMI.PlayerHasAccess(client, "Staff Permissions - Speak in Admin Chat", nil) end,
    onCanHear = function(_, client) return CAMI.PlayerHasAccess(client, "Staff Permissions - Read Admin Chat", nil) end,
    onChatAdd = function(client, text) if CAMI.PlayerHasAccess(client, "Staff Permissions - Read Admin Chat", nil) then chat.AddText(Color(255, 0, 0), "[Admin] ", speaker, " (" .. speaker:steamName() .. ") ", Color(0, 255, 0), ": " .. text) end end,
    font = "liaChatFont",
    filter = "admin"
})

hook.Remove("PlayerSay", "SAM.Chat.Asay")
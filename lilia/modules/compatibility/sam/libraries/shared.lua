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
        lia.command.run(client, "asay", {text:sub(2)})
        return ""
    end
end

lia.chat.register("asay", {
    onCanSay = function() return true end,
    onCanHear = function(_, speaker) return speaker:HasPrivilege("Staff Permissions - Read Admin Chat") end,
    onChatAdd = function(speaker, text) if speaker:HasPrivilege("Staff Permissions - Read Admin Chat") then chat.AddText(Color(255, 0, 0), "[Admin] ", speaker, " (" .. speaker:steamName() .. ") ", Color(0, 255, 0), ": " .. text) end end,
    font = "liaChatFont",
    filter = "admin"
})

hook.Remove("PlayerSay", "SAM.Chat.Asay")

local MODULE = MODULE
function MODULE:CanReadNotifications(client)
    if not self.DisplayStaffCommands then return false end
    if not self.AdminOnlyNotification then return true end
    return client:hasPrivilege("Staff Permissions - Can See SAM Notifications") or client:isStaffOnDuty()
end

function sam.player.send_message(client, msg, tbl)
    if SERVER then
        if sam.isconsole(client) then
            local result = sam.format_message(msg, tbl)
            sam.print(unpack(result, 1, result.__cnt))
        elseif client then
            return sam.netstream.Start(client, "send_message", msg, tbl)
        end
    else
        if client and MODULE:CanReadNotifications(client) then
            local prefix_result = sam.format_message(sam.config.get("ChatPrefix", ""))
            local prefix_n = #prefix_result
            local result = sam.format_message(msg, tbl, prefix_result, prefix_n)
            chat.AddText(unpack(result, 1, result.__cnt))
        end
    end
end

hook.Remove("PlayerSay", "SAM.Chat.Asay")

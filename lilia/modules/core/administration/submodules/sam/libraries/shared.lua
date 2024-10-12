local MODULE = MODULE

function MODULE:CanReadNotifications(client)
    if not self.DisplayStaffCommands then return false end
    if not self.AdminOnlyNotification then return true end
    return client:HasPrivilege("Staff Permissions - Can See SAM Notifications") or client:isStaffOnDuty()
end

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
        if MODULE:CanReadNotifications(client) then chat.AddText(unpack(result, 1, result.__cnt)) end
    end
end

function MODULE:HasAccess(client)
    return client:HasPrivilege("Staff Permissions - Always See Tickets") or client:isStaffOnDuty()
end

hook.Remove("PlayerSay", "SAM.Chat.Asay")
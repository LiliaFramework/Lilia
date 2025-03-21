local function CanReadNotifications(client)
    if not lia.config.get("DisplayStaffCommands") then return false end
    if not lia.config.get("AdminOnlyNotification") then return true end
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
        if client and CanReadNotifications(client) then
            local prefix_result = sam.format_message(sam.config.get("ChatPrefix", ""))
            local prefix_n = #prefix_result
            local result = sam.format_message(msg, tbl, prefix_result, prefix_n)
            chat.AddText(unpack(result, 1, result.__cnt))
        end
    end
end

hook.Add("SAM.CanRunCommand", "Check4Staff", function(client, _, _, cmd)
    if type(client) ~= "Player" then return true end
    if lia.config.get("SAMEnforceStaff", false) then
        if cmd.permission and not client:HasPermission(cmd.permission) then
            client:notifyLocalized("staffPermissionDenied")
            return false
        end

        if client:hasPrivilege(client, "Staff Permissions - Can Bypass Staff Faction SAM Command whitelist", nil) or client:isStaffOnDuty() then
            return true
        else
            client:notifyLocalized("staffRestrictedCommand")
            return false
        end
    end
end)
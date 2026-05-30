hook.Remove("PostGamemodeLoaded", "SAM.DarkRP")
local function getGroupLevelForPermissionSummary(groupName, visited)
    visited = visited or {}
    if visited[groupName] then return 1 end
    visited[groupName] = true
    local defaultGroups = lia.admin and lia.admin.DefaultGroups or {}
    if defaultGroups[groupName] then return defaultGroups[groupName] end
    local groupData = lia.admin and lia.admin.groups and lia.admin.groups[groupName]
    if not groupData then return 1 end
    local inheritance = groupData._info and groupData._info.inheritance or "user"
    if inheritance == groupName then return 1 end
    return getGroupLevelForPermissionSummary(inheritance, visited)
end

local function getDefaultPermissionValueForSummary(groupName, privilege, visited)
    visited = visited or {}
    local visitKey = tostring(groupName) .. ":" .. tostring(privilege)
    if visited[visitKey] then return false end
    visited[visitKey] = true
    local privilegeMinAccess = lia.admin and lia.admin.privileges and lia.admin.privileges[privilege]
    local defaultGroups = lia.admin and lia.admin.DefaultGroups or {}
    if privilegeMinAccess and getGroupLevelForPermissionSummary(groupName) >= (defaultGroups[tostring(privilegeMinAccess):lower()] or 1) then return true end
    local groupData = lia.admin and lia.admin.groups and lia.admin.groups[groupName]
    if not groupData then return false end
    local inheritance = groupData._info and groupData._info.inheritance or "user"
    if inheritance and inheritance ~= "" and inheritance ~= groupName then
        local inheritedGroup = lia.admin and lia.admin.groups and lia.admin.groups[inheritance]
        if inheritedGroup and inheritedGroup[privilege] == true then return true end
        return getDefaultPermissionValueForSummary(inheritance, privilege, visited)
    end
    return false
end

local function getGroupPermissionOverrides(groupName)
    local groupData = lia.admin and lia.admin.groups and lia.admin.groups[groupName]
    if not groupData then return {} end
    local overrides = {}
    for permission in pairs(lia.admin.privileges or {}) do
        if permission ~= "_info" and groupData[permission] ~= nil then
            local currentValue = groupData[permission] == true
            local defaultValue = getDefaultPermissionValueForSummary(groupName, permission)
            if currentValue ~= defaultValue then
                overrides[#overrides + 1] = (currentValue and "+" or "-") .. permission
            end
        end
    end

    table.sort(overrides)
    return overrides
end

local function announceSAMPermissionChange(rankName, permission, value)
    if not SERVER then return end
    local lines = {"Usergroup " .. string.upper(tostring(rankName))}
    local changedPrefix = value and "[+] " or "[-] "
    local changedPermissionName = lia.admin and lia.admin.privilegeNames and lia.admin.privilegeNames[permission] or permission
    lines[#lines + 1] = changedPrefix .. tostring(changedPermissionName) .. " - " .. permission
    for _, override in ipairs(getGroupPermissionOverrides(rankName)) do
        local permissionID = override:sub(2)
        if permissionID ~= permission then
            local prefix = override:sub(1, 1) == "+" and "[+] " or "[-] "
            local permissionName = lia.admin and lia.admin.privilegeNames and lia.admin.privilegeNames[permissionID] or permissionID
            lines[#lines + 1] = prefix .. tostring(permissionName) .. " - " .. permissionID
        end
    end

    lia.information(table.concat(lines, "\n"))
    net.Start("liaGroupPermChanged")
    net.WriteString(rankName)
    net.WriteString(permission)
    net.WriteBool(value)
    net.Broadcast()
end

local samCommands = {
    kick = function(id, _, reason) RunConsoleCommand("sam", "kick", id, reason or "") end,
    ban = function(id, dur, reason) RunConsoleCommand("sam", "ban", id, tostring(dur or 0), reason or "") end,
    unban = function(id) RunConsoleCommand("sam", "unban", id) end,
    mute = function(id, dur, reason) RunConsoleCommand("sam", "mute", id, tostring(dur or 0), reason or "") end,
    unmute = function(id) RunConsoleCommand("sam", "unmute", id) end,
    gag = function(id, dur, reason) RunConsoleCommand("sam", "gag", id, tostring(dur or 0), reason or "") end,
    ungag = function(id) RunConsoleCommand("sam", "ungag", id) end,
    freeze = function(id, dur) RunConsoleCommand("sam", "freeze", id, tostring(dur or 0)) end,
    unfreeze = function(id) RunConsoleCommand("sam", "unfreeze", id) end,
    slay = function(id) RunConsoleCommand("sam", "slay", id) end,
    bring = function(id) RunConsoleCommand("sam", "bring", id) end,
    ["goto"] = function(id) RunConsoleCommand("sam", "goto", id) end,
    ["return"] = function(id) RunConsoleCommand("sam", "return", id) end,
    jail = function(id, dur) RunConsoleCommand("sam", "jail", id, tostring(dur or 0)) end,
    unjail = function(id) RunConsoleCommand("sam", "unjail", id) end,
    cloak = function(id) RunConsoleCommand("sam", "cloak", id) end,
    uncloak = function(id) RunConsoleCommand("sam", "uncloak", id) end,
    god = function(id) RunConsoleCommand("sam", "god", id) end,
    ungod = function(id) RunConsoleCommand("sam", "ungod", id) end,
    ignite = function(id, dur) RunConsoleCommand("sam", "ignite", id, tostring(dur or 0)) end,
    extinguish = function(id) RunConsoleCommand("sam", "extinguish", id) end,
    unignite = function(id) RunConsoleCommand("sam", "extinguish", id) end,
    strip = function(id) RunConsoleCommand("sam", "strip", id) end
}

hook.Add("RunAdminSystemCommand", "liaSam", function(cmd, admin, victim, dur, reason)
    local id = isstring(victim) and victim or IsValid(victim) and victim:SteamID()
    if not id then return end
    local commandFunc = samCommands[cmd]
    if commandFunc then
        commandFunc(id, dur, reason)
        return true, function() end
    end
end)

hook.Add("OnSetUsergroup", "liaSAMSetUserGroup", function(steamID, group)
    if not sam and not SAM then return end
    if not steamID or steamID == "" or not group or group == "" then return end
    lia.debug("[Permissions]", "SAM syncing usergroup", "steamID=", tostring(steamID), "group=", tostring(group))
    RunConsoleCommand("sam", "setrankid", steamID, group)
end)

hook.Add("SAM.CanRunCommand", "liaSAM", function(client, _, _, cmd)
    if type(client) ~= "Player" then return true end
    if lia.config.get("SAMEnforceStaff", false) then
        local hasSamPermission = cmd.permission and client:HasPermission(cmd.permission) or true
        lia.debug("[Permissions]", "Permission Check for hook SAM.CanRunCommand SAM permission", "commandPermission=", tostring(cmd.permission), "HasPermission=", tostring(hasSamPermission), "finalResult=", tostring(hasSamPermission))
        if cmd.permission and not hasSamPermission then
            client:notifyErrorLocalized("staffPermissionDenied")
            return false
        end

        local canBypassSAMFactionWhitelist = client:hasPrivilege("canBypassSAMFactionWhitelist")
        local isStaffOnDuty = client:isStaffOnDuty()
        local permission = canBypassSAMFactionWhitelist or isStaffOnDuty
        lia.debug("[Permissions]", "Permission Check for hook SAM.CanRunCommand staff whitelist", "hasPrivilege(canBypassSAMFactionWhitelist)=", tostring(canBypassSAMFactionWhitelist), "isStaffOnDuty=", tostring(isStaffOnDuty), "finalResult=", tostring(permission))
        if permission then
            return true
        else
            client:notifyErrorLocalized("staffRestrictedCommand")
            return false
        end
    end
end)

if SERVER then
    sam.command.new("blind"):SetPermission("blind", "superadmin"):AddArg("player"):Help(L("blindCommandHelp")):OnExecute(function(client, targets)
        for i = 1, #targets do
            local target = targets[i]
            net.Start("liaBlindTarget")
            net.WriteBool(true)
            net.Send(target)
        end

        if not sam.is_command_silent then
            client:sam_send_message(L("samBlindedTargets"), {
                A = client,
                T = targets
            })
        end
    end):End()

    sam.command.new("unblind"):SetPermission("blind", "superadmin"):AddArg("player"):Help(L("unblindCommandHelp")):OnExecute(function(client, targets)
        for i = 1, #targets do
            local target = targets[i]
            net.Start("liaBlindTarget")
            net.WriteBool(false)
            net.Send(target)
        end

        if not sam.is_command_silent then
            client:sam_send_message(L("samUnblindedTargets"), {
                A = client,
                T = targets
            })
        end
    end):End()

    hook.Add("InitializedModules", "SAM_InitializedModules", function() hook.Remove("PlayerSay", "SAM.Chat.Asay") end)
end

local function CanReadNotifications(client)
    if not lia.config.get("AdminOnlyNotification", true) then return true end
    if not IsValid(client) then return false end
    local hasPrivilege = client:hasPrivilege("canSeeSAMNotificationsOutsideStaff")
    local isStaffOnDuty = client:isStaffOnDuty()
    local permission = hasPrivilege or isStaffOnDuty
    return permission
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
        if not CanReadNotifications(LocalPlayer()) then return end
        local prefix_result = sam.format_message(sam.config.get("ChatPrefix", ""))
        local prefix_n = #prefix_result
        local result = sam.format_message(msg, tbl, prefix_result, prefix_n)
        chat.AddText(unpack(result, 1, result.__cnt))
    end
end

hook.Add("SAM.RankPermissionGiven", "liaSAMHandlePermissionGiven", function(rankName, permission)
    if not rankName or not permission then return end
    if not isstring(permission) or permission == "" or permission:match("^%s*$") then
        lia.error(string.format("Invalid permission passed to SAM.RankPermissionGiven - Rank: %s, Permission: %s (Type: %s)", tostring(rankName), tostring(permission), type(permission)))
        return
    end

    if CAMI and not CAMI.GetPrivilege(permission) then
        CAMI.RegisterPrivilege({
            Name = permission,
            MinAccess = "admin"
        })
    end

    lia.debug("[Permissions]", "SAM granted rank permission", "rank=", tostring(rankName), "permission=", tostring(permission))
    if SERVER then
        lia.admin.addPermission(rankName, permission, true)
        announceSAMPermissionChange(rankName, permission, true)
    end
end)

hook.Add("SAM.RankPermissionTaken", "liaSAMHandlePermissionTaken", function(rankName, permission)
    if not rankName or not permission then return end
    lia.debug("[Permissions]", "SAM removed rank permission", "rank=", tostring(rankName), "permission=", tostring(permission))
    if SERVER then
        lia.admin.removePermission(rankName, permission, true)
        announceSAMPermissionChange(rankName, permission, false)
    end
end)

lia.command.add("cleardecals", {
    adminOnly = true,
    desc = "@cleardecalsDesc",
    onRun = function()
        for _, v in player.Iterator() do
            v:ConCommand("r_cleardecals")
        end
    end
})

lia.config.add("AdminOnlyNotification", "@adminOnlyNotifications", true, nil, {
    desc = "@adminOnlyNotificationsDesc",
    category = "@core",
    type = "Boolean"
})

lia.config.add("SAMEnforceStaff", "@samEnforceStaff", true, nil, {
    desc = "@samEnforceStaffDesc",
    category = "@core",
    type = "Boolean"
})

hook.Add("InitializedModules", "liaSAMBypassRestrictions", function()
    sam.config.set("Restrictions.Tool", false)
    sam.config.set("Restrictions.Spawning", false)
    sam.config.set("Restrictions.Limits", false)
end)

hook.Add("GetPlayTime", "liaSAM", function(client) return client:sam_get_play_time() end)

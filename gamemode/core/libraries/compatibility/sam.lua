hook.Remove("PostGamemodeLoaded", "SAM.DarkRP")
hook.Add("InitializedModules", "liaSAM", function()
    for _, commandInfo in ipairs(sam.command.get_commands()) do
        local customSyntax = ""
        for _, argInfo in ipairs(commandInfo.args) do
            customSyntax = customSyntax == "" and "[" or customSyntax .. " ["
            customSyntax = customSyntax .. (argInfo.default and tostring(type(argInfo.default)) or "string") .. " "
            customSyntax = customSyntax .. argInfo.name .. "]"
        end

        if lia.command.list[commandInfo.name] then continue end
        lia.command.add(commandInfo.name, {
            desc = commandInfo.help,
            adminOnly = commandInfo.default_rank == "admin",
            superAdminOnly = commandInfo.default_rank == "superadmin",
            syntax = customSyntax,
            onRun = function(_, arguments) RunConsoleCommand("sam", commandInfo.name, unpack(arguments)) end
        })
    end
end)

hook.Add("RunAdminSystemCommand", "liaSam", function(cmd, _, victim, dur, reason)
    local id = isstring(victim) and victim or (IsValid(victim) and victim:SteamID())
    if not id then return end
    if cmd == "kick" then
        RunConsoleCommand("sam", "kick", id, reason or "")
        return true
    elseif cmd == "ban" then
        RunConsoleCommand("sam", "ban", id, tostring(dur or 0), reason or "")
        return true
    elseif cmd == "unban" then
        RunConsoleCommand("sam", "unban", id)
        return true
    elseif cmd == "mute" then
        RunConsoleCommand("sam", "mute", id, tostring(dur or 0), reason or "")
        return true
    elseif cmd == "unmute" then
        RunConsoleCommand("sam", "unmute", id)
        return true
    elseif cmd == "gag" then
        RunConsoleCommand("sam", "gag", id, tostring(dur or 0), reason or "")
        return true
    elseif cmd == "ungag" then
        RunConsoleCommand("sam", "ungag", id)
        return true
    elseif cmd == "freeze" then
        RunConsoleCommand("sam", "freeze", id, tostring(dur or 0))
        return true
    elseif cmd == "unfreeze" then
        RunConsoleCommand("sam", "unfreeze", id)
        return true
    elseif cmd == "slay" then
        RunConsoleCommand("sam", "slay", id)
        return true
    elseif cmd == "bring" then
        RunConsoleCommand("sam", "bring", id)
        return true
    elseif cmd == "goto" then
        RunConsoleCommand("sam", "goto", id)
        return true
    elseif cmd == "return" then
        RunConsoleCommand("sam", "return", id)
        return true
    elseif cmd == "jail" then
        RunConsoleCommand("sam", "jail", id, tostring(dur or 0))
        return true
    elseif cmd == "unjail" then
        RunConsoleCommand("sam", "unjail", id)
        return true
    elseif cmd == "cloak" then
        RunConsoleCommand("sam", "cloak", id)
        return true
    elseif cmd == "uncloak" then
        RunConsoleCommand("sam", "uncloak", id)
        return true
    elseif cmd == "god" then
        RunConsoleCommand("sam", "god", id)
        return true
    elseif cmd == "ungod" then
        RunConsoleCommand("sam", "ungod", id)
        return true
    elseif cmd == "ignite" then
        RunConsoleCommand("sam", "ignite", id, tostring(dur or 0))
        return true
    elseif cmd == "extinguish" or cmd == "unignite" then
        RunConsoleCommand("sam", "extinguish", id)
        return true
    elseif cmd == "strip" then
        RunConsoleCommand("sam", "strip", id)
        return true
    end
end)

hook.Add("SAM.CanRunCommand", "liaSAM", function(client, _, _, cmd)
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

if SERVER then
    sam.command.new("blind"):SetPermission("blind", "superadmin"):AddArg("player"):Help("Blinds the Players"):OnExecute(function(client, targets)
        for i = 1, #targets do
            local target = targets[i]
            net.Start("blindTarget")
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
            net.Start("blindTarget")
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

    hook.Add("InitializedModules", "SAM_InitializedModules", function() hook.Remove("PlayerSay", "SAM.Chat.Asay") end)
end

local function CanReadNotifications(client)
    if not lia.config.get("AdminOnlyNotification", true) then return true end
    return client:hasPrivilege("Staff Permissions - Can See SAM Notifications") or client:isStaffOnDuty()
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

lia.command.add("cleardecals", {
    adminOnly = true,
    privilege = "Clear Decals",
    desc = "cleardecalsDesc",
    onRun = function()
        for _, v in player.Iterator() do
            v:ConCommand("r_cleardecals")
        end
    end
})

lia.command.add("playtime", {
    adminOnly = false,
    privilege = "View Own Playtime",
    desc = "playtimeDesc",
    onRun = function(client)
        local steamID = client:SteamID64()
        local result = sql.QueryRow("SELECT play_time FROM sam_players WHERE steamid = " .. SQLStr(steamID) .. ";")
        if result then
            local secs = tonumber(result.play_time) or 0
            local h = math.floor(secs / 3600)
            local m = math.floor((secs % 3600) / 60)
            local s = secs % 60
            client:ChatPrint(L("playtimeYour", h, m, s))
        else
            client:ChatPrint(L("playtimeError"))
        end
    end
})

lia.command.add("plygetplaytime", {
    adminOnly = true,
    privilege = "View Playtime",
    syntax = "[player Char Name]",
    AdminStick = {
        Name = "adminStickGetPlayTimeName",
        Category = "moderationTools",
        SubCategory = "misc",
        Icon = "icon16/time.png"
    },
    desc = "plygetplaytimeDesc",
    onRun = function(client, args)
        if not args[1] then
            client:notifyLocalized("specifyPlayer")
            return
        end

        local target = lia.util.findPlayer(client, args[1])
        if not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local secs = target:sam_get_play_time()
        local h = math.floor(secs / 3600)
        local m = math.floor((secs % 3600) / 60)
        local s = secs % 60
        client:ChatPrint(L("playtimeFor", target:Nick(), h, m, s))
    end
})

CAMI.RegisterPrivilege({
    Name = "Staff Permissions - Can See SAM Notifications Outside Staff Character",
    MinAccess = "superadmin"
})

CAMI.RegisterPrivilege({
    Name = "Staff Permissions - Can Bypass Staff Faction SAM Command whitelist",
    MinAccess = "superadmin"
})

lia.config.add("AdminOnlyNotification", "Admin Only Notifications", true, nil, {
    desc = "Restricts certain notifications to admins with specific permissions or those on duty.",
    category = "Staff",
    type = "Boolean"
})

lia.config.add("SAMEnforceStaff", "Enforce Staff Rank To SAM", true, nil, {
    desc = "Determines whether staff enforcement for SAM commands is enabled",
    category = "Staff",
    type = "Boolean"
})

hook.Add("ShouldLiliaAdminLoad", "liaSam", function() return false end)
﻿lia.admin = lia.admin or {}
lia.admin.bans = lia.admin.bans or {}
lia.admin.groups = lia.admin.groups or {}
lia.admin.banList = lia.admin.banList or {}
lia.admin.privileges = lia.admin.privileges or {}
function lia.admin.isDisabled()
    return hook.Run("ShouldLiliaAdminLoad") == false
end

function lia.admin.load()
    if lia.admin.isDisabled() then return end
    lia.admin.groups = lia.data.get("admin_groups", {})
    for name, priv in pairs(CAMI.GetPrivileges() or {}) do
        lia.admin.privileges[name] = priv
    end

    local defaults = {"user", "admin", "superadmin"}
    local created = false
    if table.Count(lia.admin.groups) == 0 then
        for _, grp in ipairs(defaults) do
            lia.admin.createGroup(grp)
        end

        created = true
    else
        for _, grp in ipairs(defaults) do
            if not lia.admin.groups[grp] then
                lia.admin.createGroup(grp)
                created = true
            end
        end
    end

    if created then lia.admin.save(true) end
    lia.bootstrap("Administration", L("adminSystemLoaded"))
end

function lia.admin.createGroup(groupName, info)
    if lia.admin.isDisabled() then return end
    if lia.admin.groups[groupName] then
        Error("[Lilia Administration] This usergroup already exists!\n")
        return
    end

    lia.admin.groups[groupName] = info or {}
    if SERVER then lia.admin.save(true) end
end

function lia.admin.registerPrivilege(privilege)
    if lia.admin.isDisabled() then return end
    if not privilege or not privilege.Name then return end
    lia.admin.privileges[privilege.Name] = privilege
end

function lia.admin.removeGroup(groupName)
    if lia.admin.isDisabled() then return end
    if groupName == "user" or groupName == "admin" or groupName == "superadmin" then
        Error("[Lilia Administration] The base usergroups cannot be removed!\n")
        return
    end

    if not lia.admin.groups[groupName] then
        Error("[Lilia Administration] This usergroup doesn't exist!\n")
        return
    end

    lia.admin.groups[groupName] = nil
    if SERVER then lia.admin.save(true) end
end

if SERVER then
    function lia.admin.addPermission(groupName, permission)
        if lia.admin.isDisabled() then return end
        if not lia.admin.groups[groupName] then
            Error("[Lilia Administration] This usergroup doesn't exist!\n")
            return
        end

        lia.admin.groups[groupName][permission] = true
        if SERVER then lia.admin.save(true) end
    end

    function lia.admin.removePermission(groupName, permission)
        if lia.admin.isDisabled() then return end
        if not lia.admin.groups[groupName] then
            Error("[Lilia Administration] This usergroup doesn't exist!\n")
            return
        end

        lia.admin.groups[groupName][permission] = nil
        if SERVER then lia.admin.save(true) end
    end

    function lia.admin.save(network)
        if lia.admin.isDisabled() then return end
        lia.data.set("admin_groups", lia.admin.groups, true, true)
        if network then
            net.Start("lilia_updateAdminGroups")
            net.WriteTable(lia.admin.groups)
            net.Broadcast()
        end
    end

    function lia.admin.setPlayerGroup(ply, usergroup)
        if lia.admin.isDisabled() then return end
        ply:SetUserGroup(usergroup)
        lia.db.query(Format("UPDATE lia_players SET _userGroup = '%s' WHERE _steamID = %s", lia.db.escape(usergroup), ply:SteamID64()))
    end

    function lia.admin.addBan(steamid, reason, duration)
        if lia.admin.isDisabled() then return end
        if not steamid then Error("[Lilia Administration] lia.admin.addBan: no steam id specified!") end
        local banStart = os.time()
        lia.admin.banList[steamid] = {
            reason = reason or L("genericReason"),
            start = banStart,
            duration = (duration or 0) * 60
        }

        lia.db.insertTable({
            _steamID = "\"" .. steamid .. "\"",
            _banStart = banStart,
            _banDuration = (duration or 0) * 60,
            _reason = reason or L("genericReason")
        }, nil, "bans")
    end

    function lia.admin.removeBan(steamid)
        if lia.admin.isDisabled() then return end
        if not steamid then Error("[Lilia Administration] lia.admin.removeBan: no steam id specified!") end
        lia.admin.banList[steamid] = nil
        lia.db.query(Format("DELETE FROM lia_bans WHERE _steamID = '%s'", lia.db.escape(steamid)), function() MsgC(Color(0, 200, 0), "[Lilia Administration] Ban removed.\n") end)
    end

    function lia.admin.isBanned(steamid)
        if lia.admin.isDisabled() then return false end
        return lia.admin.banList[steamid] or false
    end

    function lia.admin.hasBanExpired(steamid)
        if lia.admin.isDisabled() then return true end
        local ban = lia.admin.banList[steamid]
        if not ban then return true end
        if ban.duration == 0 then return false end
        return ban.start + ban.duration <= os.time()
    end

    hook.Add("InitPostEntity", "lia_LoadAdmin", function()
        if lia.admin.isDisabled() then return end
        lia.admin.load()
    end)

    hook.Add("ShutDown", "lia_SaveAdmin", function()
        if lia.admin.isDisabled() then return end
        lia.admin.save()
    end)
end

hook.Add("PlayerAuthed", "lia_SetUserGroup", function(ply, steamID)
    if lia.admin.isDisabled() then return end
    local steam64 = util.SteamIDTo64(steamID)
    lia.db.query(Format("SELECT _userGroup FROM lia_players WHERE _steamID = %s", steam64), function(data)
        local group = istable(data) and data[1] and data[1]._userGroup
        if not group or group == "" then
            group = "user"
            lia.db.query(Format("UPDATE lia_players SET _userGroup = '%s' WHERE _steamID = %s", lia.db.escape(group), steam64))
        end

        ply:SetUserGroup(group)
    end)
end)

hook.Add("OnDatabaseLoaded", "lia_LoadBans", function()
    if lia.admin.isDisabled() then return end
    lia.db.query("SELECT * FROM lia_bans", function(data)
        if istable(data) then
            local bans = {}
            for _, ban in pairs(data) do
                bans[ban._steamID] = {
                    reason = ban._reason,
                    start = ban._banStart,
                    duration = ban._banDuration
                }
            end

            lia.admin.banList = bans
        end
    end)
end)

concommand.Add("plysetgroup", function(ply, _, args)
    if lia.admin.isDisabled() then return end
    if not IsValid(ply) then
        local target = lia.util.findPlayer(args[1])
        if IsValid(target) then
            if lia.admin.groups[args[2]] then
                lia.admin.setPlayerGroup(target, args[2])
            else
                MsgC(Color(200, 20, 20), "[Lilia Administration] Error: usergroup not found.\n")
            end
        else
            MsgC(Color(200, 20, 20), "[Lilia Administration] Error: specified player not found.\n")
        end
    end
end)

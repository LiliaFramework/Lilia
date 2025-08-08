--[[
# Administrator Library

This page documents the functions for working with administrator privileges and user groups.

---

## Overview

The administrator library provides a comprehensive system for managing user permissions, privileges, and access control within the Lilia framework. It handles user group management, privilege registration, access checking, and integration with external permission systems like CAMI. The library supports hierarchical permission structures and provides tools for administrative operations.

The library features include:
- **Hierarchical Permission System**: Supports user, admin, and superadmin levels with inheritance
- **CAMI Integration**: Seamless integration with the CAMI permission system for external addon compatibility
- **Dynamic Privilege Management**: Register and manage privileges with automatic access level assignment
- **Group Management**: Create custom user groups with specific permission sets
- **Access Control**: Comprehensive checking system for command and feature access
- **Privilege Validation**: Built-in validation for privilege requirements and user capabilities
- **Cross-Realm Support**: Works on both client and server sides with proper networking
- **Hook Integration**: Extensive hook system for custom permission logic and validation
- **Database Persistence**: Automatic saving and loading of permission configurations
- **Fallback Systems**: Graceful handling of missing permissions and default access levels

The library serves as the foundation for all administrative functionality within Lilia, providing a robust and extensible permission system that can be easily integrated with external administrative tools and addons.
]]
lia.administrator = lia.administrator or {}
lia.administrator.groups = lia.administrator.groups or {}
lia.administrator.privileges = lia.administrator.privileges or {}
lia.administrator.privMeta = lia.administrator.privMeta or {}
lia.administrator.DefaultGroups = {
    user = 1,
    admin = 2,
    superadmin = 3
}

local function getGroupLevel(group)
    local levels = lia.administrator.DefaultGroups or {}
    if levels[group] then return levels[group] end
    local visited, current = {}, group
    for _ = 1, 16 do
        if visited[current] then break end
        visited[current] = true
        local g = lia.administrator.groups and lia.administrator.groups[current]
        local inh = g and g._info and g._info.inheritance or "user"
        if levels[inh] then return levels[inh] end
        current = inh
    end
    return levels.user or 1
end

local function shouldGrant(group, min)
    local levels = lia.administrator.DefaultGroups or {}
    local m = tostring(min or "user"):lower()
    return getGroupLevel(group) >= (levels[m] or 1)
end

local function rebuildPrivileges()
    lia.administrator.privileges = lia.administrator.privileges or {}
    for groupName, perms in pairs(lia.administrator.groups or {}) do
        for priv, allowed in pairs(perms) do
            if priv ~= "_info" and allowed == true then
                local current = lia.administrator.privileges[priv]
                local groupLevel = getGroupLevel(groupName)
                local currentLevel = current and getGroupLevel(current) or math.huge
                if not current or groupLevel < currentLevel then
                    local base
                    for name, lvl in pairs(lia.administrator.DefaultGroups or {}) do
                        if lvl == groupLevel then
                            base = name
                            break
                        end
                    end

                    lia.administrator.privileges[priv] = base or "user"
                end
            end
        end
    end
end

local function camiRegisterUsergroup(name, inherits)
    if CAMI and name ~= "user" and name ~= "admin" and name ~= "superadmin" then
        CAMI.RegisterUsergroup({
            Name = name,
            Inherits = inherits or "user"
        }, "Lilia")
    end
end

local function camiUnregisterUsergroup(name)
    if CAMI and name ~= "user" and name ~= "admin" and name ~= "superadmin" then CAMI.UnregisterUsergroup(name, "Lilia") end
end

local function camiRegisterPrivilege(name, min)
    if CAMI and not CAMI.GetPrivilege(name) then
        CAMI.RegisterPrivilege({
            Name = name,
            MinAccess = tostring(min or "user"):lower()
        })
    end
end

local function camiBootstrapFromExisting()
    if not CAMI then return end
    for _, ug in ipairs(CAMI.GetUsergroups() or {}) do
        local n = ug.Name
        local inh = ug.Inherits or "user"
        lia.administrator.groups[n] = lia.administrator.groups[n] or {
            _info = {
                inheritance = inh,
                types = {}
            }
        }

        lia.administrator.applyInheritance(n)
    end

    for _, pr in ipairs(CAMI.GetPrivileges() or {}) do
        local n = pr.Name
        local m = tostring(pr.MinAccess or "user"):lower()
        if lia.administrator.privileges[n] == nil then
            lia.administrator.privileges[n] = m
            lia.administrator.privMeta[n] = L(pr.Category or "unassigned")
            for g in pairs(lia.administrator.groups or {}) do
                if shouldGrant(g, m) then lia.administrator.groups[g][n] = true end
            end
        else
            lia.administrator.privMeta[n] = lia.administrator.privMeta[n] or L(pr.Category or "unassigned")
        end
    end

    rebuildPrivileges()
end

--[[
    lia.administrator.hasAccess

    Purpose:
        Checks if a player or usergroup has access to a specific privilege.

    Parameters:
        ply (Player|string) - The player entity or usergroup name to check.
        privilege (string) - The privilege to check access for.

    Returns:
        hasAccess (boolean) - True if the player/usergroup has the privilege, false otherwise.

    Realm:
        Shared.

    Example Usage:
        -- Check if a player has the "manageUsergroups" privilege
        if lia.administrator.hasAccess(ply, "manageUsergroups") then
            print(ply:Nick() .. " can manage usergroups!")
        end

        -- Check if the "admin" group has the "ban" privilege
        if lia.administrator.hasAccess("admin", "ban") then
            print("Admins can ban players.")
        end
]]
function lia.administrator.hasAccess(ply, privilege)
    local grp = "user"
    if isstring(ply) then
        grp = ply
    elseif IsValid(ply) then
        if ply.getUserGroup then
            grp = tostring(ply:getUserGroup() or "user")
        elseif ply.GetUserGroup then
            grp = tostring(ply:GetUserGroup() or "user")
        end
    end

    if tostring(grp):lower() == "superadmin" then return true end
    local g = lia.administrator.groups and lia.administrator.groups[grp] or nil
    if g and g[privilege] == true then return true end
    local min = lia.administrator.privileges and lia.administrator.privileges[privilege] or "user"
    return shouldGrant(grp, min)
end

--[[
    lia.administrator.registerPrivilege

    Purpose:
        Registers a new privilege in the admin system, assigning it to all usergroups that meet the minimum access level.

    Parameters:
        priv (table) - A table describing the privilege. Should contain:
            Name (string) - The name of the privilege.
            MinAccess (string) - (Optional) The minimum usergroup required to have this privilege (default: "user").
            Category (string) - (Optional) The category for the privilege.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Register a new privilege "canFly" for admins and above
        lia.administrator.registerPrivilege({
            Name = "canFly",
            MinAccess = "admin",
            Category = "Fun"
        })
]]
function lia.administrator.registerPrivilege(priv)
    if not priv or not priv.Name then return end
    local name = L(priv.Name)
    if name == "" then return end
    if lia.administrator.privileges[name] ~= nil then return end
    local min = tostring(priv.MinAccess or "user"):lower()
    lia.administrator.privileges[name] = min
    local category = L(priv.Category or "unassigned")
    lia.administrator.privMeta[name] = category
    for groupName, perms in pairs(lia.administrator.groups) do
        perms = perms or {}
        lia.administrator.groups[groupName] = perms
        if shouldGrant(groupName, min) then perms[name] = true end
    end

    if CAMI then camiRegisterPrivilege(name, min) end
    hook.Run("OnPrivilegeRegistered", {
        Name = name,
        MinAccess = min,
        Category = category
    })

    if SERVER then lia.administrator.save() end
end

--[[
    lia.administrator.unregisterPrivilege

    Purpose:
        Unregisters a privilege from the admin system, removing it from all usergroups.

    Parameters:
        name (string) - The name of the privilege to unregister.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Remove the "canFly" privilege from all groups
        lia.administrator.unregisterPrivilege("canFly")
]]
function lia.administrator.unregisterPrivilege(name)
    name = tostring(name or "")
    if name == "" or lia.administrator.privileges[name] == nil then return end
    lia.administrator.privileges[name] = nil
    lia.administrator.privMeta[name] = nil
    for _, perms in pairs(lia.administrator.groups or {}) do
        perms[name] = nil
    end

    if CAMI then CAMI.UnregisterPrivilege(name) end
    hook.Run("OnPrivilegeUnregistered", {
        Name = name
    })

    if SERVER then lia.administrator.save() end
end

--[[
    lia.administrator.applyInheritance

    Purpose:
        Applies inheritance to a usergroup, copying privileges from its parent group and ensuring minimum privileges are granted.

    Parameters:
        groupName (string) - The name of the usergroup to apply inheritance to.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Apply inheritance to the "moderator" group after changing its parent
        lia.administrator.applyInheritance("moderator")
]]
function lia.administrator.applyInheritance(groupName)
    local groups = lia.administrator.groups or {}
    local g = groups[groupName]
    if not g then return end
    local info = g._info or {}
    local inh = info.inheritance or "user"
    local visited = {}
    local function copyFrom(srcName)
        if visited[srcName] then return end
        visited[srcName] = true
        local src = groups[srcName]
        if src then
            for k, v in pairs(src) do
                if k ~= "_info" and v == true and g[k] == nil then g[k] = true end
            end

            local nxt = src._info and src._info.inheritance
            if nxt and nxt ~= srcName then copyFrom(nxt) end
        end
    end

    copyFrom(inh)
    for priv, min in pairs(lia.administrator.privileges or {}) do
        if shouldGrant(groupName, min) then g[priv] = true end
    end
end

--[[
    lia.administrator.load

    Purpose:
        Loads usergroups and privileges from the database, ensures default groups exist, applies inheritance, and synchronizes with CAMI if available.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        -- Load all admin groups and privileges on server startup
        lia.administrator.load()
]]
function lia.administrator.load()
    local function ensureDefaults(groups)
        local created = false
        for _, grp in ipairs({"user", "admin", "superadmin"}) do
            local data = groups[grp]
            if not data then
                data = {
                    _info = {
                        inheritance = grp,
                        types = {},
                    }
                }

                groups[grp] = data
                created = true
            end

            data._info = data._info or {
                inheritance = grp,
                types = {}
            }

            if data._info.inheritance ~= grp then
                data._info.inheritance = grp
                created = true
            end

            data._info.types = data._info.types or {}
            if grp == "admin" or grp == "superadmin" then
                local hasStaff = false
                for _, typ in ipairs(data._info.types) do
                    if tostring(typ):lower() == "staff" then
                        hasStaff = true
                        break
                    end
                end

                if not hasStaff then
                    table.insert(data._info.types, "Staff")
                    created = true
                end
            end
        end
        return created
    end

    local function continueLoad(groups)
        lia.administrator.groups = groups or {}
        if CAMI then
            for n, t in pairs(lia.administrator.groups) do
                camiRegisterUsergroup(n, t._info and t._info.inheritance or "user")
            end

            for n, m in pairs(lia.administrator.privileges or {}) do
                camiRegisterPrivilege(n, m)
            end

            camiBootstrapFromExisting()
        end

        lia.admin(L("adminSystemLoaded"))
        hook.Run("OnAdminSystemLoaded", lia.administrator.groups or {}, lia.administrator.privileges or {})
    end

    lia.db.select("*", "admin"):next(function(res)
        local rows = res and res.results or {}
        local groups = {}
        for _, row in ipairs(rows or {}) do
            local name = row.usergroup or row.usergroups or row.group
            if isstring(name) and name ~= "" then
                local privs = util.JSONToTable(row.privileges or "") or {}
                privs._info = {
                    inheritance = row.inheritance or "user",
                    types = util.JSONToTable(row.types or "") or {}
                }

                groups[name] = privs
            end
        end

        local created = ensureDefaults(groups)
        lia.administrator._loading = true
        lia.administrator.groups = groups
        for n in pairs(groups) do
            lia.administrator.applyInheritance(n)
        end

        rebuildPrivileges()
        if created then lia.administrator.save(true) end
        lia.administrator._loading = false
        continueLoad(groups)
    end)
end

--[[
    lia.administrator.createGroup

    Purpose:
        Creates a new usergroup with the specified name and info, applies inheritance, and registers it with CAMI.

    Parameters:
        groupName (string) - The name of the new usergroup.
        info (table) - (Optional) Table containing group info, such as inheritance and types.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Create a new "moderator" group that inherits from "user"
        lia.administrator.createGroup("moderator", {
            _info = {
                inheritance = "user",
                types = {"Staff"}
            }
        })
]]
function lia.administrator.createGroup(groupName, info)
    if lia.administrator.groups[groupName] then
        lia.error(L("usergroupExists"))
        return
    end

    info = info or {}
    info._info = info._info or {
        inheritance = "user",
        types = {}
    }

    lia.administrator.groups[groupName] = info
    lia.administrator.applyInheritance(groupName)
    camiRegisterUsergroup(groupName, info._info.inheritance or "user")
    hook.Run("OnUsergroupCreated", groupName, lia.administrator.groups[groupName])
    if SERVER then lia.administrator.save() end
end

--[[
    lia.administrator.removeGroup

    Purpose:
        Removes a usergroup from the admin system, unregisters it from CAMI, and saves the changes.

    Parameters:
        groupName (string) - The name of the usergroup to remove.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Remove the "moderator" group
        lia.administrator.removeGroup("moderator")
]]
function lia.administrator.removeGroup(groupName)
    if groupName == "user" or groupName == "admin" or groupName == "superadmin" then
        lia.error(L("baseUsergroupCannotBeRemoved"))
        return
    end

    if not lia.administrator.groups[groupName] then
        lia.error(L("usergroupDoesntExist"))
        return
    end

    lia.administrator.groups[groupName] = nil
    camiUnregisterUsergroup(groupName)
    hook.Run("OnUsergroupRemoved", groupName)
    if SERVER then lia.administrator.save() end
end

--[[
    lia.administrator.renameGroup

    Purpose:
        Renames an existing usergroup, updates inheritance, and synchronizes with CAMI.

    Parameters:
        oldName (string) - The current name of the usergroup.
        newName (string) - The new name for the usergroup.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Rename the "moderator" group to "helper"
        lia.administrator.renameGroup("moderator", "helper")
]]
function lia.administrator.renameGroup(oldName, newName)
    if lia.administrator.DefaultGroups[oldName] then
        lia.error(L("baseUsergroupCannotBeRenamed"))
        return
    end

    if not lia.administrator.groups[oldName] then
        lia.error(L("usergroupDoesntExist"))
        return
    end

    if lia.administrator.groups[newName] then
        lia.error(L("usergroupExists"))
        return
    end

    lia.administrator.groups[newName] = lia.administrator.groups[oldName]
    lia.administrator.groups[oldName] = nil
    lia.administrator.applyInheritance(newName)
    camiUnregisterUsergroup(oldName)
    local inh = lia.administrator.groups[newName]._info and lia.administrator.groups[newName]._info.inheritance or "user"
    camiRegisterUsergroup(newName, inh)
    hook.Run("OnUsergroupRenamed", oldName, newName)
    if SERVER then lia.administrator.save() end
end

if SERVER then
    --[[
        lia.administrator.addPermission

        Purpose:
            Adds a permission/privilege to a usergroup and saves the change.

        Parameters:
            groupName (string) - The name of the usergroup.
            permission (string) - The privilege to add.
            silent (boolean) - (Optional) If true, suppresses network updates.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            -- Give the "moderator" group the "kick" privilege
            lia.administrator.addPermission("moderator", "kick")
    ]]
    function lia.administrator.addPermission(groupName, permission, silent)
        if not lia.administrator.groups[groupName] then
            if lia.administrator._loading then return end
            lia.error(L("usergroupDoesntExist"))
            return
        end

        if lia.administrator.DefaultGroups[groupName] then return end
        lia.administrator.groups[groupName][permission] = true
        lia.administrator.save(silent and true or false)
        hook.Run("OnUsergroupPermissionsChanged", groupName, lia.administrator.groups[groupName])
    end

    --[[
        lia.administrator.removePermission

        Purpose:
            Removes a permission/privilege from a usergroup and saves the change.

        Parameters:
            groupName (string) - The name of the usergroup.
            permission (string) - The privilege to remove.
            silent (boolean) - (Optional) If true, suppresses network updates.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            -- Remove the "ban" privilege from the "moderator" group
            lia.administrator.removePermission("moderator", "ban")
    ]]
    function lia.administrator.removePermission(groupName, permission, silent)
        if not lia.administrator.groups[groupName] then
            if lia.administrator._loading then return end
            lia.error(L("usergroupDoesntExist"))
            return
        end

        if lia.administrator.DefaultGroups[groupName] then return end
        lia.administrator.groups[groupName][permission] = nil
        lia.administrator.save(silent and true or false)
        hook.Run("OnUsergroupPermissionsChanged", groupName, lia.administrator.groups[groupName])
    end

    --[[
        lia.administrator.sync

        Purpose:
            Synchronizes admin privileges, privilege meta, and groups to a specific client or all clients.

        Parameters:
            c (Player) - (Optional) The player to sync to. If nil, syncs to all players.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            -- Sync admin data to a specific player
            lia.administrator.sync(somePlayer)

            -- Sync admin data to all players
            lia.administrator.sync()
    ]]
    function lia.administrator.sync(c)
        lia.net.ready = lia.net.ready or setmetatable({}, {
            __mode = "k"
        })

        local function push(ply)
            if not IsValid(ply) then return end
            if not lia.net.ready[ply] then return end
            lia.net.writeBigTable(ply, "updateAdminPrivileges", lia.administrator.privileges or {})
            timer.Simple(0.05, function() if IsValid(ply) and lia.net.ready[ply] then lia.net.writeBigTable(ply, "updateAdminPrivilegeMeta", lia.administrator.privMeta or {}) end end)
            timer.Simple(0.15, function() if IsValid(ply) and lia.net.ready[ply] then lia.net.writeBigTable(ply, "updateAdminGroups", lia.administrator.groups or {}) end end)
        end

        if c and IsValid(c) then
            push(c)
            return
        end

        local t = player.GetHumans()
        for _, p in ipairs(t) do
            push(p)
        end
    end

    --[[
        lia.administrator.save

        Purpose:
            Saves all usergroups and privileges to the database and optionally synchronizes with clients.

        Parameters:
            noNetwork (boolean) - (Optional) If true, does not sync to clients after saving.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            -- Save admin data and sync to clients
            lia.administrator.save()

            -- Save admin data without syncing to clients
            lia.administrator.save(true)
    ]]
    function lia.administrator.save(noNetwork)
        rebuildPrivileges()
        local rows = {}
        for name, data in pairs(lia.administrator.groups) do
            local info = istable(data._info) and data._info or {}
            local privs = table.Copy(data)
            privs._info = nil
            rows[#rows + 1] = {
                usergroup = name,
                privileges = util.TableToJSON(privs),
                inheritance = info.inheritance or "user",
                types = util.TableToJSON(info.types or {})
            }
        end

        lia.db.query("DELETE FROM lia_admin")
        lia.db.bulkInsert("admin", rows)
        if noNetwork or lia.administrator._loading then return end
        lia.net.ready = lia.net.ready or setmetatable({}, {
            __mode = "k"
        })

        local hasReady = false
        for ply in pairs(lia.net.ready) do
            if IsValid(ply) and lia.net.ready[ply] then
                hasReady = true
                break
            end
        end

        if not hasReady then return end
        lia.administrator.sync()
    end

    --[[
        lia.administrator.setPlayerUsergroup

        Purpose:
            Sets a player's usergroup and notifies CAMI of the change.

        Parameters:
            ply (Player) - The player whose usergroup to set.
            newGroup (string) - The new usergroup name.
            source (string) - (Optional) The source of the change (for CAMI).

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            -- Set a player to the "admin" group
            lia.administrator.setPlayerUsergroup(targetPlayer, "admin", "Console")
    ]]
    function lia.administrator.setPlayerUsergroup(ply, newGroup, source)
        if not IsValid(ply) then return end
        local old = tostring(ply:GetUserGroup() or "user")
        local new = tostring(newGroup or "user")
        if old == new then return end
        ply:SetUserGroup(new)
        if CAMI then CAMI.SignalUserGroupChanged(ply, old, new, source or "Lilia") end
    end

    --[[
        lia.administrator.setSteamIDUsergroup

        Purpose:
            Sets the usergroup for a player by SteamID, updating both online and offline players, and notifies CAMI.

        Parameters:
            steamId (string) - The SteamID of the player.
            newGroup (string) - The new usergroup name.
            source (string) - (Optional) The source of the change (for CAMI).

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            -- Set a SteamID to the "vip" group
            lia.administrator.setSteamIDUsergroup("STEAM_0:1:123456", "vip", "Admin Panel")
    ]]
    function lia.administrator.setSteamIDUsergroup(steamId, newGroup, source)
        local sid = tostring(steamId or "")
        if sid == "" then return end
        local ply = lia.util.getBySteamID(sid)
        local old = IsValid(ply) and tostring(ply:GetUserGroup() or "user") or "user"
        local new = tostring(newGroup or "user")
        if IsValid(ply) then ply:SetUserGroup(new) end
        if CAMI then CAMI.SignalSteamIDUserGroupChanged(sid, old, new, source or "Lilia") end
    end
else
    --[[
        lia.administrator.execCommand

        Purpose:
            Executes an admin command as a chat command, such as kick, ban, mute, etc.

        Parameters:
            cmd (string) - The command to execute (e.g., "kick", "ban", "mute").
            victim (Player|string) - The player entity or SteamID to target.
            dur (number) - (Optional) Duration for timed commands (e.g., ban, mute).
            reason (string) - (Optional) Reason for the command.

        Returns:
            success (boolean) - True if the command was executed, false otherwise.

        Realm:
            Client.

        Example Usage:
            -- Kick a player for "AFK"
            lia.administrator.execCommand("kick", targetPlayer, nil, "AFK")

            -- Ban a player for 60 minutes for "Cheating"
            lia.administrator.execCommand("ban", "STEAM_0:1:123456", 60, "Cheating")
    ]]
    function lia.administrator.execCommand(cmd, victim, dur, reason)
        if hook.Run("RunAdminSystemCommand") == true then return end
        local id = IsValid(victim) and victim:SteamID() or tostring(victim)
        if cmd == "kick" then
            RunConsoleCommand("say", "/plykick " .. string.format("'%s'", tostring(id)) .. (reason and " " .. string.format("'%s'", tostring(reason)) or ""))
            return true
        elseif cmd == "ban" then
            RunConsoleCommand("say", "/plyban " .. string.format("'%s'", tostring(id)) .. " " .. tostring(dur or 0) .. (reason and " " .. string.format("'%s'", tostring(reason)) or ""))
            return true
        elseif cmd == "unban" then
            RunConsoleCommand("say", "/plyunban " .. string.format("'%s'", tostring(id)))
            return true
        elseif cmd == "mute" then
            RunConsoleCommand("say", "/plymute " .. string.format("'%s'", tostring(id)) .. " " .. tostring(dur or 0) .. (reason and " " .. string.format("'%s'", tostring(reason)) or ""))
            return true
        elseif cmd == "unmute" then
            RunConsoleCommand("say", "/plyunmute " .. string.format("'%s'", tostring(id)))
            return true
        elseif cmd == "gag" then
            RunConsoleCommand("say", "/plygag " .. string.format("'%s'", tostring(id)) .. " " .. tostring(dur or 0) .. (reason and " " .. string.format("'%s'", tostring(reason)) or ""))
            return true
        elseif cmd == "ungag" then
            RunConsoleCommand("say", "/plyungag " .. string.format("'%s'", tostring(id)))
            return true
        elseif cmd == "freeze" then
            RunConsoleCommand("say", "/plyfreeze " .. string.format("'%s'", tostring(id)) .. " " .. tostring(dur or 0))
            return true
        elseif cmd == "unfreeze" then
            RunConsoleCommand("say", "/plyunfreeze " .. string.format("'%s'", tostring(id)))
            return true
        elseif cmd == "slay" then
            RunConsoleCommand("say", "/plyslay " .. string.format("'%s'", tostring(id)))
            return true
        elseif cmd == "bring" then
            RunConsoleCommand("say", "/plybring " .. string.format("'%s'", tostring(id)))
            return true
        elseif cmd == "goto" then
            RunConsoleCommand("say", "/plygoto " .. string.format("'%s'", tostring(id)))
            return true
        elseif cmd == "return" then
            RunConsoleCommand("say", "/plyreturn " .. string.format("'%s'", tostring(id)))
            return true
        elseif cmd == "jail" then
            RunConsoleCommand("say", "/plyjail " .. string.format("'%s'", tostring(id)) .. " " .. tostring(dur or 0))
            return true
        elseif cmd == "unjail" then
            RunConsoleCommand("say", "/plyunjail " .. string.format("'%s'", tostring(id)))
            return true
        elseif cmd == "cloak" then
            RunConsoleCommand("say", "/plycloak " .. string.format("'%s'", tostring(id)))
            return true
        elseif cmd == "uncloak" then
            RunConsoleCommand("say", "/plyuncloak " .. string.format("'%s'", tostring(id)))
            return true
        elseif cmd == "god" then
            RunConsoleCommand("say", "/plygod " .. string.format("'%s'", tostring(id)))
            return true
        elseif cmd == "ungod" then
            RunConsoleCommand("say", "/plyungod " .. string.format("'%s'", tostring(id)))
            return true
        elseif cmd == "ignite" then
            RunConsoleCommand("say", "/plyignite " .. string.format("'%s'", tostring(id)) .. " " .. tostring(dur or 0))
            return true
        elseif cmd == "extinguish" or cmd == "unignite" then
            RunConsoleCommand("say", "/plyextinguish " .. string.format("'%s'", tostring(id)))
            return true
        elseif cmd == "strip" then
            RunConsoleCommand("say", "/plystrip " .. string.format("'%s'", tostring(id)))
            return true
        elseif cmd == "respawn" then
            RunConsoleCommand("say", "/plyrespawn " .. string.format("'%s'", tostring(id)))
            return true
        elseif cmd == "blind" then
            RunConsoleCommand("say", "/plyblind " .. string.format("'%s'", tostring(id)))
            return true
        elseif cmd == "unblind" then
            RunConsoleCommand("say", "/plyunblind " .. string.format("'%s'", tostring(id)))
            return true
        end
    end
end

if SERVER then
    local function ensureStructures()
        lia.administrator.groups = lia.administrator.groups or {}
        for n in pairs(lia.administrator.groups) do
            lia.administrator.groups[n] = lia.administrator.groups[n] or {}
        end
    end

    local function broadcastGroups()
        lia.net.ready = lia.net.ready or setmetatable({}, {
            __mode = "k"
        })

        local players = player.GetHumans()
        for _, ply in ipairs(players) do
            if lia.net.ready[ply] then lia.net.writeBigTable(ply, "updateAdminGroups", lia.administrator.groups or {}) end
        end
    end

    ensureStructures()
    net.Receive("liaGroupsRequest", function(_, p)
        if not IsValid(p) or not p:hasPrivilege(L("manageUsergroups")) then return end
        lia.net.ready = lia.net.ready or setmetatable({}, {
            __mode = "k"
        })

        lia.net.ready[p] = true
        lia.administrator.sync(p)
    end)

    net.Receive("liaGroupsAdd", function(_, p)
        if not p:hasPrivilege(L("manageUsergroups")) then return end
        local data = net.ReadTable()
        local n = string.Trim(tostring(data.name or ""))
        if n == "" then return end
        lia.administrator.groups = lia.administrator.groups or {}
        if lia.administrator.DefaultGroups and lia.administrator.DefaultGroups[n] then return end
        if lia.administrator.groups[n] then return end
        lia.administrator.createGroup(n, {
            _info = {
                inheritance = data.inherit or "user",
                types = data.types or {}
            }
        })

        lia.administrator.save()
        broadcastGroups()
        p:notifyLocalized("groupCreated", n)
    end)

    net.Receive("liaGroupsRemove", function(_, p)
        if not p:hasPrivilege(L("manageUsergroups")) then return end
        local n = net.ReadString()
        if n == "" or lia.administrator.DefaultGroups and lia.administrator.DefaultGroups[n] then return end
        lia.administrator.removeGroup(n)
        if lia.administrator.groups then lia.administrator.groups[n] = nil end
        lia.administrator.save()
        broadcastGroups()
        p:notifyLocalized("groupRemoved", n)
    end)

    net.Receive("liaGroupsRename", function(_, p)
        if not p:hasPrivilege(L("manageUsergroups")) then return end
        local old = string.Trim(net.ReadString() or "")
        local new = string.Trim(net.ReadString() or "")
        if old == "" or new == "" then return end
        if old == new then return end
        if not lia.administrator.groups or not lia.administrator.groups[old] then return end
        if lia.administrator.groups[new] or lia.administrator.DefaultGroups and lia.administrator.DefaultGroups[new] then return end
        if lia.administrator.DefaultGroups and lia.administrator.DefaultGroups[old] then return end
        lia.administrator.renameGroup(old, new)
        broadcastGroups()
        p:notifyLocalized("groupRenamed", old, new)
    end)

    net.Receive("liaGroupsSetPerm", function(_, p)
        if not p:hasPrivilege(L("manageUsergroups")) then return end
        local group = net.ReadString()
        local privilege = net.ReadString()
        local value = net.ReadBool()
        if group == "" or privilege == "" then return end
        if lia.administrator.DefaultGroups and lia.administrator.DefaultGroups[group] then return end
        if not lia.administrator.groups or not lia.administrator.groups[group] then return end
        if SERVER then
            if value then
                lia.administrator.addPermission(group, privilege, true)
            else
                lia.administrator.removePermission(group, privilege, true)
            end
        end

        net.Start("liaGroupPermChanged")
        net.WriteString(group)
        net.WriteString(privilege)
        net.WriteBool(value)
        net.Broadcast()
        p:notifyLocalized("groupPermissionsUpdated")
    end)
else
    local LAST_GROUP
    local function computeCategoryMap(groups)
        local cats, labels, seen = {}, {}, {}
        for name in pairs(lia.administrator.privileges or {}) do
            local c = tostring(lia.administrator.privMeta and lia.administrator.privMeta[name] or L("unassigned"))
            local key = c:lower()
            labels[key] = labels[key] or c
            cats[key] = cats[key] or {}
            cats[key][#cats[key] + 1], seen[name] = name, true
        end

        for _, data in pairs(groups or {}) do
            for name in pairs(data or {}) do
                if name ~= "_info" and not seen[name] then
                    local c = tostring(lia.administrator.privMeta and lia.administrator.privMeta[name] or L("unassigned"))
                    local key = c:lower()
                    labels[key] = labels[key] or c
                    cats[key] = cats[key] or {}
                    cats[key][#cats[key] + 1], seen[name] = name, true
                end
            end
        end

        local keys = {}
        for k in pairs(cats) do
            keys[#keys + 1] = k
        end

        table.sort(keys, function(a, b) return a < b end)
        for _, k in ipairs(keys) do
            table.sort(cats[k], function(a, b) return a:lower() < b:lower() end)
        end

        local ordered = {}
        for _, k in ipairs(keys) do
            ordered[#ordered + 1] = {
                label = labels[k],
                items = cats[k]
            }
        end
        return ordered
    end

    local function promptCreateGroup()
        lia.util.requestArguments(L("create") .. " " .. L("group"), {
            Name = "string",
            Inheritance = {"table", {"user", "admin", "superadmin"}},
            Staff = "boolean",
            User = "boolean",
            VIP = "boolean"
        }, function(data)
            local name = string.Trim(tostring(data.Name or ""))
            if name == "" then return end
            local types = {}
            if data.Staff then types[#types + 1] = "Staff" end
            if data.User then types[#types + 1] = "User" end
            if data.VIP then types[#types + 1] = "VIP" end
            LAST_GROUP = name
            net.Start("liaGroupsAdd")
            net.WriteTable({
                name = name,
                inherit = data.Inheritance or "user",
                types = types
            })

            net.SendToServer()
        end)
    end

    local function buildPrivilegeList(container, g, groups, editable)
        local current = table.Copy(groups[g] or {})
        current._info = nil
        local categoryList = container:Add("DCategoryList")
        categoryList:Dock(FILL)
        lia.gui.usergroups.checks = lia.gui.usergroups.checks or {}
        lia.gui.usergroups.checks[g] = lia.gui.usergroups.checks[g] or {}
        local function addRow(list, name)
            local row = list:Add("DPanel")
            row:Dock(TOP)
            row:DockMargin(0, 0, 0, 8)
            local isUsergroup = name == L("usergroupStaff") or name == L("usergroupVIP")
            local font = isUsergroup and "liaBigFont" or "liaMediumFont"
            local boxSize = 56
            local rightOffset = isUsergroup and 16 or 12
            surface.SetFont(font)
            local _, textHeight = surface.GetTextSize("W")
            local rowHeight = math.max(textHeight + 28, boxSize + 14)
            row:SetTall(rowHeight)
            row.Paint = function(pnl, w, h) derma.SkinHook("Paint", "Panel", pnl, w, h) end
            local lbl = row:Add("DLabel")
            lbl:Dock(FILL)
            lbl:DockMargin(8, 0, isUsergroup and 16 or 0, 0)
            lbl:SetText(name)
            lbl:SetFont(font)
            lbl:SetContentAlignment(4)
            local chk = row:Add("liaCheckBox")
            chk:SetSize(boxSize, boxSize)
            row.PerformLayout = function(_, w, h) chk:SetPos(w - boxSize - rightOffset, h - boxSize) end
            chk:SetChecked(current[name] and true or false)
            if editable then
                chk.OnChange = function(_, v)
                    if chk._suppress then
                        chk._suppress = false
                        return
                    end

                    if v then
                        current[name] = true
                    else
                        current[name] = nil
                    end

                    net.Start("liaGroupsSetPerm")
                    net.WriteString(g)
                    net.WriteString(name)
                    net.WriteBool(v)
                    net.SendToServer()
                end
            else
                chk:SetMouseInputEnabled(false)
                chk:SetCursor("arrow")
            end

            lia.gui.usergroups.checks[g][name] = chk
        end

        local ordered = computeCategoryMap(groups)
        surface.SetFont("liaBigFont")
        local _, hfh = surface.GetTextSize("W")
        local headerH = math.max(hfh + 18, 36)
        for _, cat in ipairs(ordered) do
            local wrap = vgui.Create("DPanel")
            wrap.Paint = function(pnl, w, h) derma.SkinHook("Paint", "InnerPanel", pnl, w, h) end
            local list = vgui.Create("DListLayout", wrap)
            list:Dock(TOP)
            list:DockMargin(8, 8, 8, 8)
            for _, priv in ipairs(cat.items) do
                addRow(list, priv)
            end

            wrap:InvalidateLayout(true)
            wrap:SizeToChildren(true, true)
            local c = categoryList:Add(cat.label)
            c:SetContents(wrap)
            c:SetExpanded(false)
            local header = c.Header or c.GetHeader and c:GetHeader() or nil
            if IsValid(header) then
                header:SetFont("liaBigFont")
                header:SetTall(headerH)
                header:SetTextInset(12, 0)
                header:SetContentAlignment(4)
            end
        end

        categoryList:InvalidateLayout(true)
    end

    local function renderGroupInfo(parent, g, groups)
        parent:Clear()
        local isDefault = lia.administrator.DefaultGroups and lia.administrator.DefaultGroups[g] ~= nil
        local editable = not isDefault
        local bottomTall, bottomMargin = 44, 12
        local bottom = parent:Add("DPanel")
        bottom:Dock(BOTTOM)
        bottom:SetTall(bottomTall)
        bottom:DockMargin(10, 0, 10, bottomMargin)
        bottom.Paint = function() end
        local content = parent:Add("DPanel")
        content:Dock(FILL)
        content:DockMargin(0, 0, 0, bottomTall + bottomMargin)
        content.Paint = function() end
        local details = content:Add("DPanel")
        details:Dock(TOP)
        details:DockMargin(20, 20, 20, 10)
        details.Paint = function() end
        local nameLbl = details:Add("DLabel")
        nameLbl:Dock(TOP)
        nameLbl:SetText(L("name") .. ":")
        nameLbl:SetFont("liaBigFont")
        nameLbl:SetContentAlignment(5)
        nameLbl:SizeToContents()
        local nameVal = details:Add("DLabel")
        nameVal:Dock(TOP)
        nameVal:DockMargin(0, 8, 0, 14)
        nameVal:SetText(g)
        nameVal:SetFont("liaMediumFont")
        nameVal:SetContentAlignment(5)
        nameVal:SizeToContents()
        if not isDefault then
            local inhLbl = details:Add("DLabel")
            inhLbl:Dock(TOP)
            inhLbl:DockMargin(0, 14, 0, 0)
            inhLbl:SetText(L("inheritsFrom") .. ":")
            inhLbl:SetFont("liaBigFont")
            inhLbl:SetContentAlignment(5)
            inhLbl:SizeToContents()
            local inhVal = details:Add("DLabel")
            inhVal:Dock(TOP)
            inhVal:DockMargin(0, 8, 0, 14)
            local info = groups[g] and groups[g]._info or {}
            inhVal:SetText(info.inheritance or "user")
            inhVal:SetFont("liaMediumFont")
            inhVal:SetContentAlignment(5)
            inhVal:SizeToContents()
        end

        local function hasType(t)
            for _, v in ipairs((groups[g]._info or {}).types or {}) do
                if v:lower() == t:lower() then return true end
            end
            return false
        end

        local staffLbl = details:Add("DLabel")
        staffLbl:Dock(TOP)
        staffLbl:DockMargin(0, 14, 0, 0)
        staffLbl:SetText(L("isStaff"))
        staffLbl:SetFont("liaBigFont")
        staffLbl:SetContentAlignment(5)
        staffLbl:SizeToContents()
        local staffPanel = details:Add("DPanel")
        staffPanel:Dock(TOP)
        staffPanel:DockMargin(0, 8, 0, 14)
        staffPanel:SetTall(56)
        staffPanel.Paint = nil
        local staffChk = staffPanel:Add("liaCheckBox")
        staffChk:SetSize(56, 56)
        staffPanel.PerformLayout = function(_, w, h) staffChk:SetPos((w - 56) / 2, h - 56) end
        staffChk:SetChecked(hasType("Staff"))
        staffChk:SetMouseInputEnabled(false)
        staffChk:SetCursor("arrow")
        local vipLbl = details:Add("DLabel")
        vipLbl:Dock(TOP)
        vipLbl:DockMargin(0, 14, 0, 0)
        vipLbl:SetText(L("isVIP"))
        vipLbl:SetFont("liaBigFont")
        vipLbl:SetContentAlignment(5)
        vipLbl:SizeToContents()
        local vipPanel = details:Add("DPanel")
        vipPanel:Dock(TOP)
        vipPanel:DockMargin(0, 8, 0, 0)
        vipPanel:SetTall(56)
        vipPanel.Paint = nil
        local vipChk = vipPanel:Add("liaCheckBox")
        vipChk:SetSize(56, 56)
        vipPanel.PerformLayout = function(_, w, h) vipChk:SetPos((w - 56) / 2, h - 56) end
        vipChk:SetChecked(hasType("VIP"))
        vipChk:SetMouseInputEnabled(false)
        vipChk:SetCursor("arrow")
        details:InvalidateLayout(true)
        details:SizeToChildren(true, true)
        local privContainer = content:Add("DPanel")
        privContainer:Dock(FILL)
        privContainer:DockMargin(20, 0, 20, 0)
        privContainer.Paint = function() end
        buildPrivilegeList(privContainer, g, groups, editable)
        if editable then
            local createBtn = bottom:Add("liaMediumButton")
            local renameBtn = bottom:Add("liaMediumButton")
            local delBtn = bottom:Add("liaMediumButton")
            createBtn:SetText(L("create") .. " " .. L("group"))
            renameBtn:SetText(L("rename") .. " " .. L("group"))
            delBtn:SetText(L("delete") .. " " .. L("group"))
            createBtn.DoClick = promptCreateGroup
            renameBtn.DoClick = function()
                Derma_StringRequest(L("rename") .. " " .. L("group"), L("renameGroupPrompt", g) .. ":", g, function(txt)
                    txt = string.Trim(txt or "")
                    if txt ~= "" and txt ~= g then
                        net.Start("liaGroupsRename")
                        net.WriteString(g)
                        net.WriteString(txt)
                        net.SendToServer()
                    end
                end)
            end

            delBtn.DoClick = function()
                Derma_Query(L("deleteGroupPrompt", g), L("confirm"), L("yes"), function()
                    net.Start("liaGroupsRemove")
                    net.WriteString(g)
                    net.SendToServer()
                end, L("no"))
            end

            bottom.PerformLayout = function(_, w, h)
                local bw = math.floor(w / 3)
                createBtn:SetPos(0, 0)
                createBtn:SetSize(bw, h)
                renameBtn:SetPos(bw, 0)
                renameBtn:SetSize(bw, h)
                delBtn:SetPos(bw * 2, 0)
                delBtn:SetSize(w - bw * 2, h)
            end
        else
            local addBtn = bottom:Add("liaMediumButton")
            addBtn:SetText(L("create") .. " " .. L("group"))
            addBtn.DoClick = promptCreateGroup
            bottom.PerformLayout = function(_, w, h)
                addBtn:SetPos(0, 0)
                addBtn:SetSize(w, h)
            end
        end
    end

    local function buildGroupsUI(panel, groups)
        panel:Clear()
        local sheet = panel:Add("DPropertySheet")
        sheet:Dock(FILL)
        sheet:DockMargin(10, 10, 10, 10)
        panel.pages = {}
        panel.checks = {}
        lia.gui.usergroups.checks = {}
        local keys = {}
        for g in pairs(groups or {}) do
            keys[#keys + 1] = g
        end

        table.sort(keys, function(a, b) return a:lower() < b:lower() end)
        for _, g in ipairs(keys) do
            local page = sheet:Add("DPanel")
            page:Dock(FILL)
            page.Paint = function(pnl, w, h) derma.SkinHook("Paint", "Panel", pnl, w, h) end
            renderGroupInfo(page, g, groups)
            sheet:AddSheet(g, page)
            panel.pages[g] = page
        end

        if LAST_GROUP and groups[LAST_GROUP] then
            for _, tab in ipairs(sheet.Items) do
                if tab.Name == LAST_GROUP then
                    sheet:SetActiveTab(tab.Tab)
                    break
                end
            end
        elseif sheet.Items[1] then
            sheet:SetActiveTab(sheet.Items[1].Tab)
        end
    end

    lia.net.readBigTable("updateAdminGroups", function(tbl)
        lia.administrator.groups = tbl
        if IsValid(lia.gui.usergroups) then buildGroupsUI(lia.gui.usergroups, tbl) end
    end)

    lia.net.readBigTable("updateAdminPrivileges", function(tbl) lia.administrator.privileges = tbl end)
    lia.net.readBigTable("updateAdminPrivilegeMeta", function(tbl)
        lia.administrator.privMeta = tbl or {}
        if IsValid(lia.gui.usergroups) and lia.administrator.groups then buildGroupsUI(lia.gui.usergroups, lia.administrator.groups) end
    end)

    net.Receive("liaGroupPermChanged", function()
        local group = net.ReadString()
        local privilege = net.ReadString()
        local value = net.ReadBool()
        lia.administrator.groups = lia.administrator.groups or {}
        lia.administrator.groups[group] = lia.administrator.groups[group] or {}
        if value then
            lia.administrator.groups[group][privilege] = true
        else
            lia.administrator.groups[group][privilege] = nil
        end

        if IsValid(lia.gui.usergroups) and lia.gui.usergroups.checks and lia.gui.usergroups.checks[group] then
            local chk = lia.gui.usergroups.checks[group][privilege]
            if IsValid(chk) and chk:GetChecked() ~= value then
                chk._suppress = true
                chk:SetChecked(value)
            end
        end
    end)

    hook.Add("PopulateAdminTabs", "liaAdmin", function(pages)
        if not IsValid(LocalPlayer()) or not LocalPlayer():hasPrivilege(L("manageUsergroups")) then return end
        pages[#pages + 1] = {
            name = L("userGroups"),
            icon = "icon16/group.png",
            drawFunc = function(parent)
                lia.gui.usergroups = parent
                parent:Clear()
                parent:DockPadding(10, 10, 10, 10)
                parent.Paint = function(p, w, h) derma.SkinHook("Paint", "Frame", p, w, h) end
                buildGroupsUI(parent, lia.administrator.groups)
                net.Start("liaGroupsRequest")
                net.SendToServer()
            end
        }
    end)
end
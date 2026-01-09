--[[
    Folder: Libraries
    File: administrator.md
]]
--[[
    Administrator Library

    Comprehensive user group and privilege management system for the Lilia framework.
]]
--[[
    Overview:
        The administrator library provides comprehensive functionality for managing user groups, privileges, and administrative permissions in the Lilia framework. It handles the creation, modification, and deletion of user groups with inheritance-based privilege systems. The library operates on both server and client sides, with the server managing privilege storage and validation while the client provides user interface elements for administrative management. It includes integration with CAMI (Comprehensive Administration Management Interface) for compatibility with other administrative systems. The library ensures proper privilege inheritance, automatic privilege registration for tools and properties, and comprehensive logging of administrative actions. It supports both console-based and GUI-based administrative command execution with proper permission checking and validation.

    Setting Superadmin:
        To set yourself as superadmin in the console, use: plysetgroup "STEAMID" superadmin
        The system has three default user groups with inheritance levels: user (level 1), admin (level 2), and superadmin (level 3).
        Superadmin automatically has all privileges and cannot be restricted by any permission checks.
]]
lia.administrator = lia.administrator or {}
lia.administrator.groups = lia.administrator.groups or {}
lia.administrator.privileges = lia.administrator.privileges or {}
lia.administrator.privilegeCategories = lia.administrator.privilegeCategories or {}
lia.administrator.privilegeNames = lia.administrator.privilegeNames or {}
lia.administrator.missingGroups = lia.administrator.missingGroups or {}
lia.administrator._lastSyncPrivilegeCount = lia.administrator._lastSyncPrivilegeCount or 0
lia.administrator._lastSyncGroupCount = lia.administrator._lastSyncGroupCount or 0
lia.administrator.DefaultGroups = {
    user = 1,
    admin = 2,
    superadmin = 3
}

local defaultUserTools = {
    remover = true,
}

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
            types = {},
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

ensureDefaults(lia.administrator.groups)
local privilegeCategoryCache = {}
function getPrivilegeCategory(privilegeName)
    if not privilegeName then return L("unassigned") end
    if privilegeCategoryCache[privilegeName] then return privilegeCategoryCache[privilegeName] end
    local categoryChecks = {
        {
            match = function(name) return string.match(name, "^tool_") end,
            category = "staffPermissions"
        },
        {
            match = function(name) return string.match(name, "^property_") end,
            category = "staffPermissions"
        },
        {
            match = function(name) return name == "stopSoundForEveryone" end,
            category = "staffPermissions"
        },
        {
            match = function(name) return string.match(name, "simfphys") end,
            category = "compatibility"
        },
        {
            match = function(name) return string.match(name, "SAM") end,
            category = "compatibility"
        },
        {
            match = function(name) return string.match(name, "PAC") end,
            category = "compatibility"
        },
        {
            match = function(name) return string.match(name, "ServerGuard") end,
            category = "compatibility"
        },
        {
            match = function(name) return name == "receiveCheaterNotifications" end,
            category = "exploiting"
        },
        {
            match = function(name) return name == "useDisallowedTools" end,
            category = "staffPermissions"
        }
    }

    local category
    if lia.administrator and lia.administrator.privilegeCategories and lia.administrator.privilegeCategories[privilegeName] then
        category = L(lia.administrator.privilegeCategories[privilegeName])
    elseif lia.command and lia.command.list and lia.command.list[privilegeName] then
        category = L("staffPermissions")
    else
        for _, module in pairs(lia.module.list) do
            if module.Privileges and istable(module.Privileges) then
                for _, priv in ipairs(module.Privileges) do
                    if priv.ID == privilegeName then
                        category = L(priv.Category or module.name or "unassigned")
                        break
                    end
                end
            end

            if category then break end
        end
    end

    if not category and CAMI then
        local camiPriv = CAMI.GetPrivilege(privilegeName)
        if camiPriv and camiPriv.Category then category = L(camiPriv.Category) end
    end

    if not category then
        for _, check in ipairs(categoryChecks) do
            if check.match(privilegeName) then
                category = L(check.category)
                break
            end
        end
    end

    if not category then category = L("unassigned") end
    privilegeCategoryCache[privilegeName] = category
    return category
end

local function clearPrivilegeCategoryCache()
    privilegeCategoryCache = {}
end

local groupLevelCache = {}
local function clearGroupLevelCache()
    groupLevelCache = {}
end

local function getGroupLevel(group)
    if groupLevelCache[group] ~= nil then return groupLevelCache[group] end
    local levels = lia.administrator.DefaultGroups or {}
    if levels[group] then
        groupLevelCache[group] = levels[group]
        return levels[group]
    end

    local visited, current = {}, group
    for _ = 1, 16 do
        if visited[current] then break end
        visited[current] = true
        local g = lia.administrator.groups and lia.administrator.groups[current]
        local inh = g and g._info and g._info.inheritance or "user"
        if levels[inh] then
            groupLevelCache[group] = levels[inh]
            return levels[inh]
        end

        current = inh
    end

    local defaultLevel = levels.user or 1
    groupLevelCache[group] = defaultLevel
    return defaultLevel
end

local function shouldGrant(group, min)
    local levels = lia.administrator.DefaultGroups or {}
    local m = tostring(min or "user"):lower()
    return getGroupLevel(group) >= (levels[m] or 1)
end

local function rebuildPrivileges()
    lia.administrator.privileges = lia.administrator.privileges or {}
    local rebuildCache = {}
    local function getCachedGroupLevel(groupName)
        if rebuildCache[groupName] == nil then rebuildCache[groupName] = getGroupLevel(groupName) end
        return rebuildCache[groupName]
    end

    for groupName, perms in pairs(lia.administrator.groups or {}) do
        local groupLevel = getCachedGroupLevel(groupName)
        for priv, allowed in pairs(perms) do
            if priv ~= "_info" and allowed == true then
                local current = lia.administrator.privileges[priv]
                local currentLevel = current and getCachedGroupLevel(current) or math.huge
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

        clearPrivilegeCategoryCache()
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
            clearPrivilegeCategoryCache()
            for g in pairs(lia.administrator.groups or {}) do
                if shouldGrant(g, m) then lia.administrator.groups[g][n] = true end
            end
        end
    end

    rebuildPrivileges()
end

--[[
    Purpose:
        Applies kick or ban punishments to a player based on the provided parameters.

    When Called:
        Called when an automated system or admin action needs to punish a player with a kick or ban.

    Parameters:
        client (Player)
            The player to punish.
        infraction (string)
            Description of the infraction that caused the punishment.
        kick (boolean)
            Whether to kick the player.
        ban (boolean)
            Whether to ban the player.
        time (number)
            Ban duration in minutes (only used if ban is true).
        kickKey (string)
            Localization key for kick message (defaults to "kickedForInfraction").
        banKey (string)
            Localization key for ban message (defaults to "bannedForInfraction").

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
        -- Kick a player for spamming
        lia.administrator.applyPunishment(player, "Spamming in chat", true, false, nil, nil, nil)

        -- Ban a player for griefing for 24 hours
        lia.administrator.applyPunishment(player, "Griefing", false, true, 1440, nil, nil)

        -- Both kick and ban with custom messages
        lia.administrator.applyPunishment(player, "Hacking", true, true, 10080, "kickedForHacking", "bannedForHacking")
        ```
]]
function lia.administrator.applyPunishment(client, infraction, kick, ban, time, kickKey, banKey)
    local bantime = time or 0
    kickKey = kickKey or "kickedForInfraction"
    banKey = banKey or "bannedForInfraction"
    if kick then lia.administrator.execCommand("kick", client, nil, L(kickKey, infraction)) end
    if ban then lia.administrator.execCommand("ban", client, bantime, L(banKey, infraction)) end
end

--[[
    Purpose:
        Checks if a player has access to a specific privilege based on their usergroup and privilege requirements.

    When Called:
        Called when verifying if a player can perform an action that requires specific permissions.

    Parameters:
        ply (Player|string)
            The player to check access for, or a usergroup string.
        privilege (string)
            The privilege ID to check access for (e.g., "command_kick", "property_door", "tool_remover").

    Returns:
        boolean
            true if the player has access to the privilege, false otherwise.

    Realm:
        Shared

    Example Usage:
        ```lua
        -- Check if player can use kick command
        if lia.administrator.hasAccess(player, "command_kick") then
            -- Allow kicking
        end

        -- Check if player has access to a tool
        if lia.administrator.hasAccess(player, "tool_remover") then
            -- Give tool access
        end

        -- Check usergroup access directly
        if lia.administrator.hasAccess("admin", "command_ban") then
            -- Admin group has ban access
        end
        ```
]]
function lia.administrator.hasAccess(ply, privilege)
    if not isstring(privilege) then
        lia.error(L("hasAccessExpectedString", tostring(privilege)))
        return false
    end

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

    if not lia.administrator.privileges[privilege] then
        if privilege:find("^property_") and properties and properties.List then
            local propName = privilege:sub(10)
            local prop = properties.List[propName]
            if prop then
                lia.administrator.registerPrivilege({
                    Name = L("accessPropertyPrivilege", prop.MenuLabel or propName),
                    ID = privilege,
                    MinAccess = "admin",
                    Category = "staffPermissions",
                })
            end
        elseif privilege:find("^tool_") then
            local toolName = privilege:sub(6)
            for _, wep in ipairs(weapons.GetList()) do
                if wep.ClassName == "gmod_tool" and wep.Tool and wep.Tool[toolName] then
                    lia.administrator.registerPrivilege({
                        Name = L("accessToolPrivilege", toolName:gsub("^%l", string.upper)),
                        ID = privilege,
                        MinAccess = defaultUserTools[string.lower(toolName)] and "user" or "admin",
                        Category = "staffPermissions",
                    })

                    break
                end
            end
        end
    end

    local groupLevel = getGroupLevel(grp)
    local defaultGroups = lia.administrator.DefaultGroups or {}
    local superadminLevel = defaultGroups.superadmin or 3
    local adminLevel = defaultGroups.admin or 3
    if not lia.administrator.privileges[privilege] then
        if SERVER then
            local playerInfo = IsValid(ply) and ply:Nick() .. " (" .. ply:SteamID() .. ")" or "Unknown"
            lia.log.add(ply, "missingPrivilege", privilege, playerInfo, grp)
        end
        return groupLevel >= adminLevel
    end

    if groupLevel >= superadminLevel then return true end
    local g = lia.administrator.groups and lia.administrator.groups[grp] or nil
    if g and g[privilege] == true then return true end
    local min = lia.administrator.privileges[privilege]
    return shouldGrant(grp, min)
end

--[[
    Purpose:
        Saves administrator group configurations and privileges to the database.

    When Called:
        Called when administrator settings are modified and need to be persisted, or when syncing with clients.

    Parameters:
        noNetwork (boolean)
            If true, skips network synchronization with clients after saving.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
        -- Save admin groups without network sync
        lia.administrator.save(true)

        -- Save and sync with all clients
        lia.administrator.save(false)
        -- or simply:
        lia.administrator.save()
        ```
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
    Purpose:
        Registers a new privilege in the administrator system with specified access levels and categories.

    When Called:
        Called when defining new administrative permissions that can be granted to user groups.

    Parameters:
        priv (table)
            Privilege configuration table with the following fields:
            - ID (string): Unique identifier for the privilege (required)
            - Name (string): Display name for the privilege (optional, defaults to ID)
            - MinAccess (string): Minimum usergroup required ("user", "admin", "superadmin")
            - Category (string): Category for organizing privileges in menus

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
        -- Register a custom admin command privilege
        lia.administrator.registerPrivilege({
            ID = "command_customban",
            Name = "Custom Ban Command",
            MinAccess = "admin",
            Category = "staffCommands"
        })

        -- Register a property privilege
        lia.administrator.registerPrivilege({
            ID = "property_teleport",
            Name = "Teleport Property",
            MinAccess = "admin",
            Category = "staffPermissions"
        })
        ```
]]
function lia.administrator.registerPrivilege(priv)
    if not priv or not priv.ID then
        lia.error(L("privilegeRegistrationError"))
        return
    end

    local id = tostring(priv.ID)
    if id == "" then return end
    if lia.administrator.privileges[id] ~= nil then return end
    local min = tostring(priv.MinAccess or "user"):lower()
    lia.administrator.privileges[id] = min
    lia.administrator.privilegeNames[id] = priv.Name or priv.ID
    clearPrivilegeCategoryCache()
    if priv.Category then lia.administrator.privilegeCategories[id] = priv.Category end
    local defaultGroups = lia.administrator.DefaultGroups or {}
    local minLevel = defaultGroups[tostring(min):lower()] or 1
    for groupName, perms in pairs(lia.administrator.groups) do
        perms = perms or {}
        lia.administrator.groups[groupName] = perms
        if getGroupLevel(groupName) >= minLevel then perms[id] = true end
    end

    local name = L(priv.Name or priv.ID)
    if CAMI then camiRegisterPrivilege(priv.ID, min) end
    local category = getPrivilegeCategory(id)
    hook.Run("OnPrivilegeRegistered", {
        Name = name,
        ID = priv.ID,
        MinAccess = min,
        Category = category
    })

    if SERVER then lia.administrator.save() end
end

--[[
    Purpose:
        Removes a privilege from the administrator system and cleans up all associated data.

    When Called:
        Called when a privilege is no longer needed or when cleaning up removed permissions.

    Parameters:
        id (string)
            The privilege ID to unregister.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
        -- Unregister a custom privilege
        lia.administrator.unregisterPrivilege("command_customban")

        -- Clean up a tool privilege
        lia.administrator.unregisterPrivilege("tool_remover")
        ```
]]
function lia.administrator.unregisterPrivilege(id)
    id = tostring(id or "")
    if id == "" or lia.administrator.privileges[id] == nil then return end
    lia.administrator.privileges[id] = nil
    clearPrivilegeCategoryCache()
    lia.administrator.privilegeCategories[id] = nil
    lia.administrator.privilegeNames[id] = nil
    for _, perms in pairs(lia.administrator.groups or {}) do
        perms[id] = nil
    end

    if CAMI then CAMI.UnregisterPrivilege(id) end
    hook.Run("OnPrivilegeUnregistered", {
        Name = id,
        ID = id
    })

    if SERVER then lia.administrator.save() end
end

--[[
    Purpose:
        Applies privilege inheritance to a usergroup, copying permissions from parent groups and ensuring appropriate access levels.

    When Called:
        Called when setting up or updating usergroup permissions to ensure inheritance rules are properly applied.

    Parameters:
        groupName (string)
            The name of the usergroup to apply inheritance to.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
        -- Apply inheritance to a moderator group
        lia.administrator.applyInheritance("moderator")

        -- Apply inheritance after creating a new usergroup
        lia.administrator.applyInheritance("customadmin")
        ```
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
    local groupLevel = getGroupLevel(groupName)
    local defaultGroups = lia.administrator.DefaultGroups or {}
    for priv, min in pairs(lia.administrator.privileges or {}) do
        local m = tostring(min or "user"):lower()
        if groupLevel >= (defaultGroups[m] or 1) then g[priv] = true end
    end

    clearGroupLevelCache()
end

--[[
    Purpose:
        Loads administrator group configurations from the database and initializes the admin system.

    When Called:
        Called during server startup to restore saved administrator settings and permissions.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
        -- Load admin system (called automatically during server initialization)
        lia.administrator.load()
        ```
]]
function lia.administrator.load()
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

        MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logAdmin") .. "] ")
        MsgC(Color(255, 153, 0), L("adminSystemLoaded"), "\n")
        clearGroupLevelCache()
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
    Purpose:
        Creates a new administrator usergroup with specified configuration and inheritance.

    When Called:
        Called when setting up new administrator roles or permission levels in the system.

    Parameters:
        groupName (string)
            The name of the usergroup to create.
        info (table)
            Optional configuration table for the group (privileges, inheritance, etc.).

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
        -- Create a moderator group
        lia.administrator.createGroup("moderator", {
            _info = {
                inheritance = "user",
                types = {}
            },
            command_kick = true,
            command_mute = true
        })

        -- Create a custom admin group
        lia.administrator.createGroup("customadmin")
        ```
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
    lia.administrator.missingGroups[groupName] = nil
    lia.administrator.applyInheritance(groupName)
    camiRegisterUsergroup(groupName, info._info.inheritance or "user")
    clearGroupLevelCache()
    hook.Run("OnUsergroupCreated", groupName, lia.administrator.groups[groupName])
    if SERVER then lia.administrator.save() end
end

--[[
    Purpose:
        Removes an administrator usergroup from the system.

    When Called:
        Called when cleaning up or removing unused administrator roles.

    Parameters:
        groupName (string)
            The name of the usergroup to remove.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
        -- Remove a custom moderator group
        lia.administrator.removeGroup("moderator")

        -- Remove a custom admin group
        lia.administrator.removeGroup("customadmin")
        ```
]]
function lia.administrator.removeGroup(groupName)
    if groupName == "user" or groupName == "admin" or groupName == "superadmin" then
        lia.error(L("baseUsergroupCannotBeRemoved"))
        return
    end

    if not lia.administrator.groups[groupName] then
        lia.error(L("usergroupDoesntExist", groupName))
        return
    end

    lia.administrator.groups[groupName] = nil
    camiUnregisterUsergroup(groupName)
    clearGroupLevelCache()
    hook.Run("OnUsergroupRemoved", groupName)
    if SERVER then lia.administrator.save() end
end

--[[
    Purpose:
        Renames an existing administrator usergroup to a new name.

    When Called:
        Called when reorganizing or rebranding administrator roles.

    Parameters:
        oldName (string)
            The current name of the usergroup to rename.
        newName (string)
            The new name for the usergroup.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
        -- Rename moderator group to staff
        lia.administrator.renameGroup("moderator", "staff")

        -- Rename admin group to administrator
        lia.administrator.renameGroup("admin", "administrator")
        ```
]]
function lia.administrator.renameGroup(oldName, newName)
    if lia.administrator.DefaultGroups[oldName] then
        lia.error(L("baseUsergroupCannotBeRenamed"))
        return
    end

    if not lia.administrator.groups[oldName] then
        lia.error(L("usergroupDoesntExist", oldName))
        return
    end

    if lia.administrator.groups[newName] then
        lia.error(L("usergroupExists"))
        return
    end

    lia.administrator.groups[newName] = lia.administrator.groups[oldName]
    lia.administrator.groups[oldName] = nil
    lia.administrator.missingGroups[oldName] = nil
    lia.administrator.missingGroups[newName] = nil
    lia.administrator.applyInheritance(newName)
    camiUnregisterUsergroup(oldName)
    local inh = lia.administrator.groups[newName]._info and lia.administrator.groups[newName]._info.inheritance or "user"
    camiRegisterUsergroup(newName, inh)
    clearGroupLevelCache()
    hook.Run("OnUsergroupRenamed", oldName, newName)
    if SERVER then lia.administrator.save() end
end

if SERVER then
    --[[
    Purpose:
        Sends a notification to all administrators who have permission to see admin notifications.

    When Called:
        Called when important administrative events need to be communicated to staff.

    Parameters:
        notification (string)
            The notification message key to send.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
        -- Notify admins of a potential exploit
        lia.administrator.notifyAdmin("exploitDetected")

        -- Notify admins of a player report
        lia.administrator.notifyAdmin("playerReportReceived")
        ```
]]
    function lia.administrator.notifyAdmin(notification)
        for _, client in player.Iterator() do
            if IsValid(client) and client:hasPrivilege("canSeeAltingNotifications") then client:notifyAdminLocalized(notification) end
        end
    end

    --[[
    Purpose:
        Grants a specific permission to an administrator usergroup.

    When Called:
        Called when configuring permissions for administrator roles.

    Parameters:
        groupName (string)
            The name of the usergroup to grant the permission to.
        permission (string)
            The permission ID to grant.
        silent (boolean)
            If true, skips network synchronization.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
        -- Grant kick permission to moderators
        lia.administrator.addPermission("moderator", "command_kick", false)

        -- Grant ban permission to admins silently
        lia.administrator.addPermission("admin", "command_ban", true)
        ```
]]
    function lia.administrator.addPermission(groupName, permission, silent)
        if not lia.administrator.groups[groupName] then
            if lia.administrator._loading then return end
            if not lia.administrator.missingGroups[groupName] then
                lia.administrator.missingGroups[groupName] = true
                lia.error(L("usergroupDoesntExist", groupName))
            end
            return
        end

        if lia.administrator.DefaultGroups[groupName] then return end
        lia.administrator.groups[groupName][permission] = true
        lia.administrator.save(silent and true or false)
        hook.Run("OnUsergroupPermissionsChanged", groupName, lia.administrator.groups[groupName])
    end

    --[[
    Purpose:
        Removes a specific permission from an administrator usergroup.

    When Called:
        Called when revoking permissions from administrator roles.

    Parameters:
        groupName (string)
            The name of the usergroup to remove the permission from.
        permission (string)
            The permission ID to remove.
        silent (boolean)
            If true, skips network synchronization.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
        -- Remove kick permission from moderators
        lia.administrator.removePermission("moderator", "command_kick", false)

        -- Remove ban permission from admins silently
        lia.administrator.removePermission("admin", "command_ban", true)
        ```
]]
    function lia.administrator.removePermission(groupName, permission, silent)
        if not lia.administrator.groups[groupName] then
            if lia.administrator._loading then return end
            if not lia.administrator.missingGroups[groupName] then
                lia.administrator.missingGroups[groupName] = true
                lia.error(L("usergroupDoesntExist", groupName))
            end
            return
        end

        if lia.administrator.DefaultGroups[groupName] then return end
        lia.administrator.groups[groupName][permission] = nil
        lia.administrator.save(silent and true or false)
        hook.Run("OnUsergroupPermissionsChanged", groupName, lia.administrator.groups[groupName])
    end

    --[[
    Purpose:
        Synchronizes administrator privileges and usergroups with clients.

    When Called:
        Called when administrator data changes and needs to be updated on clients, or when a player joins.

    Parameters:
        c (Player)
            Optional specific client to sync with. If not provided, syncs with all clients in batches.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
        -- Sync admin data with all clients
        lia.administrator.sync()

        -- Sync admin data with a specific player
        lia.administrator.sync(specificPlayer)
        ```
]]
    function lia.administrator.sync(c)
        lia.net.ready = lia.net.ready or setmetatable({}, {
            __mode = "k"
        })

        local function push(ply)
            if not IsValid(ply) then return end
            if not lia.net.ready[ply] then return end
            lia.net.writeBigTable(ply, "liaUpdateAdminPrivileges", {
                privileges = lia.administrator.privileges or {},
                names = lia.administrator.privilegeNames or {}
            })

            timer.Simple(0.05, function() if IsValid(ply) and lia.net.ready[ply] then lia.net.writeBigTable(ply, "liaUpdateAdminGroups", lia.administrator.groups or {}) end end)
        end

        if c and IsValid(c) then
            push(c)
            return
        end

        lia.administrator._lastSyncPrivilegeCount = table.Count(lia.administrator.privileges)
        lia.administrator._lastSyncGroupCount = table.Count(lia.administrator.groups)
        local t = player.GetHumans()
        local batchSize = 5
        local delay = 0
        for i = 1, #t, batchSize do
            timer.Simple(delay, function()
                local batch = {}
                for j = i, math.min(i + batchSize - 1, #t) do
                    table.insert(batch, t[j])
                end

                for _, p in ipairs(batch) do
                    push(p)
                end
            end)

            delay = delay + 0.1
        end
    end

    --[[
    Purpose:
        Checks if administrator privileges or groups have changed since the last sync.

    When Called:
        Called to determine if a sync operation is needed.

    Parameters:
        None

    Returns:
        boolean
            true if there are unsynced changes, false otherwise.

    Realm:
        Server

    Example Usage:
        ```lua
        -- Check if admin data needs syncing
        if lia.administrator.hasChanges() then
            lia.administrator.sync()
        end
        ```
]]
    function lia.administrator.hasChanges()
        local currentPrivilegeCount = table.Count(lia.administrator.privileges)
        local currentGroupCount = table.Count(lia.administrator.groups)
        return currentPrivilegeCount ~= lia.administrator._lastSyncPrivilegeCount or currentGroupCount ~= lia.administrator._lastSyncGroupCount
    end

    --[[
    Purpose:
        Sets the usergroup of a player entity.

    When Called:
        Called when promoting, demoting, or changing a player's administrative role.

    Parameters:
        ply (Player)
            The player to change the usergroup for.
        newGroup (string)
            The new usergroup name to assign.
        source (string)
            Optional source identifier for logging.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
        -- Promote player to admin
        lia.administrator.setPlayerUsergroup(player, "admin", "promotion")

        -- Demote player to user
        lia.administrator.setPlayerUsergroup(player, "user", "demotion")
        ```
]]
    function lia.administrator.setPlayerUsergroup(ply, newGroup, source)
        if not IsValid(ply) then return end
        lia.administrator.setSteamIDUsergroup(ply:SteamID(), newGroup, source)
    end

    --[[
    Purpose:
        Sets the usergroup of a player by their SteamID.

    When Called:
        Called when changing a player's usergroup using their SteamID, useful for offline players.

    Parameters:
        steamId (string)
            The SteamID of the player to change the usergroup for.
        newGroup (string)
            The new usergroup name to assign.
        source (string)
            Optional source identifier for logging.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
        -- Set offline player's usergroup to admin
        lia.administrator.setSteamIDUsergroup("STEAM_0:1:12345678", "admin", "promotion")

        -- Demote player by SteamID
        lia.administrator.setSteamIDUsergroup("STEAM_0:1:12345678", "user", "demotion")
        ```
]]
    function lia.administrator.setSteamIDUsergroup(steamId, newGroup, source)
        local sid = string.Trim(tostring(steamId or ""))
        if sid == "" or not string.match(sid, "^STEAM_%d+:%d+:%d+$") then return end
        local new = tostring(newGroup or "user")
        if new ~= "user" and not lia.administrator.groups[new] then return end
        local ply = lia.util.getBySteamID(sid)
        local old = IsValid(ply) and tostring(ply:GetUserGroup() or "user") or "user"
        if old == new then return end
        if IsValid(ply) then ply:SetUserGroup(new) end
        if CAMI then CAMI.SignalSteamIDUserGroupChanged(sid, old, new, source or "Lilia") end
        hook.Run("OnSetUsergroup", sid, new, source, ply)
    end

    --[[
    Purpose:
        Executes administrative commands on players with proper permission checking and logging.

    When Called:
        Called when an administrator uses commands like kick, ban, mute, gag, freeze, slay, bring, goto, etc.

    Parameters:
        cmd (string)
            The command to execute (e.g., "kick", "ban", "mute", "gag", "freeze", "slay", "bring", "goto", "return", "jail", "cloak", "god", "ignite", "strip", "respawn", "blind").
        victim (Player|string)
            The target player entity or SteamID string.
        dur (number|string)
            Duration for commands that support time limits (ban, freeze, blind, ignite).
        reason (string)
            Reason for the action (used in kick, ban, etc.).
        admin (Player)
            The administrator executing the command.

    Returns:
        boolean
            true if the command was executed successfully, false otherwise.

    Realm:
        Server

    Example Usage:
        ```lua
        -- Kick a player for spamming
        lia.administrator.serverExecCommand("kick", targetPlayer, nil, "Spamming in chat", adminPlayer)

        -- Ban a player for 24 hours
        lia.administrator.serverExecCommand("ban", targetPlayer, 1440, "Griefing", adminPlayer)

        -- Mute a player
        lia.administrator.serverExecCommand("mute", targetPlayer, nil, nil, adminPlayer)

        -- Bring a player to admin's position
        lia.administrator.serverExecCommand("bring", targetPlayer, nil, nil, adminPlayer)
        ```
]]
    function lia.administrator.serverExecCommand(cmd, victim, dur, reason, admin)
        local privilegeID = string.lower("command_" .. cmd)
        if not lia.administrator.hasAccess(admin, privilegeID) then
            admin:notifyErrorLocalized("noPerm")
            lia.log.add(admin, "unauthorizedCommand", cmd)
            return false
        end

        local function staffAction(tag, text)
            StaffAddTextShadowed(Color(255, 215, 0), tag, Color(255, 255, 255), text)
        end

        local target
        if IsValid(victim) then
            target = victim
        elseif isstring(victim) then
            target = lia.util.findPlayer(admin, victim)
        end

        if not IsValid(target) then
            admin:notifyErrorLocalized("targetNotFound")
            return false
        end

        local targetInfo = target:Name() .. " (Steam64ID: " .. target:SteamID64() .. ")"
        if cmd == "kick" then
            target:Kick(reason or L("genericReason"))
            admin:notifySuccessLocalized("plyKicked")
            lia.log.add(admin, "plyKick", target:Name())
            staffAction("KICK", admin:Name() .. " kicked " .. target:Name() .. " (Steam64ID: " .. target:SteamID64() .. ")")
            lia.db.insertTable({
                player = target:Name(),
                playerSteamID = target:SteamID(),
                steamID = target:SteamID(),
                action = "plykick",
                staffName = admin:Name(),
                staffSteamID = admin:SteamID(),
                timestamp = os.time()
            }, nil, "staffactions")
            return true
        elseif cmd == "ban" then
            target:banPlayer(reason, tonumber(dur) or 0, admin)
            admin:notifySuccessLocalized("plyBanned")
            lia.log.add(admin, "plyBan", target:Name())
            staffAction("BAN", admin:Name() .. " banned " .. target:Name() .. " (Steam64ID: " .. target:SteamID64() .. ")")
            return true
        elseif cmd == "unban" then
            local steamid = IsValid(target) and target:SteamID() or tostring(victim)
            if steamid and steamid ~= "" then
                lia.db.query("DELETE FROM lia_bans WHERE playerSteamID = " .. lia.db.convertDataType(steamid))
                admin:notifySuccessLocalized("playerUnbanned")
                lia.log.add(admin, "plyUnban", steamid)
                staffAction("UNBAN", admin:Name() .. " unbanned SteamID " .. steamid)
                return true
            end
        elseif cmd == "mute" then
            if target:getChar() then
                target:setLiliaData("liaMuted", true)
                admin:notifySuccessLocalized("plyMuted")
                lia.log.add(admin, "plyMute", target:Name())
                lia.db.insertTable({
                    player = target:Name(),
                    playerSteamID = target:SteamID(),
                    steamID = target:SteamID(),
                    action = "plymute",
                    staffName = admin:Name(),
                    staffSteamID = admin:SteamID(),
                    timestamp = os.time()
                }, nil, "staffactions")

                staffAction("MUTE", admin:Name() .. " muted " .. target:Name() .. " (Steam64ID: " .. target:SteamID64() .. ")")
                hook.Run("PlayerMuted", target, admin)
                return true
            end
        elseif cmd == "unmute" then
            if target:getChar() then
                target:setLiliaData("liaMuted", false)
                admin:notifySuccessLocalized("plyUnmuted")
                lia.log.add(admin, "plyUnmute", target:Name())
                staffAction("UNMUTE", admin:Name() .. " unmuted " .. target:Name() .. " (Steam64ID: " .. target:SteamID64() .. ")")
                hook.Run("PlayerUnmuted", target, admin)
                return true
            end
        elseif cmd == "gag" then
            target:setLiliaData("liaGagged", true)
            admin:notifySuccessLocalized("plyGagged")
            lia.log.add(admin, "plyGag", target:Name())
            staffAction("GAG", admin:Name() .. " gagged " .. targetInfo)
            hook.Run("PlayerGagged", target, admin)
            return true
        elseif cmd == "ungag" then
            target:setLiliaData("liaGagged", false)
            admin:notifySuccessLocalized("plyUngagged")
            lia.log.add(admin, "plyUngag", target:Name())
            staffAction("UNGAG", admin:Name() .. " ungagged " .. targetInfo)
            hook.Run("PlayerUngagged", target, admin)
            return true
        elseif cmd == "freeze" then
            target:Freeze(true)
            local duration = tonumber(dur) or 0
            if duration > 0 then timer.Simple(duration, function() if IsValid(target) then target:Freeze(false) end end) end
            admin:notifySuccessLocalized("plyFrozen", target:Name())
            lia.log.add(admin, "plyFreeze", target:Name(), duration)
            staffAction("FREEZE", admin:Name() .. " froze " .. targetInfo)
            return true
        elseif cmd == "unfreeze" then
            target:Freeze(false)
            admin:notifySuccessLocalized("plyUnfrozen", target:Name())
            lia.log.add(admin, "plyUnfreeze", target:Name())
            staffAction("UNFREEZE", admin:Name() .. " unfroze " .. targetInfo)
            return true
        elseif cmd == "slay" then
            target:Kill()
            timer.Simple(0.05, function() if IsValid(target) and not target:Alive() then hook.Run("PlayerDeath", target, nil, admin) end end)
            admin:notifySuccessLocalized("plyKilled")
            lia.log.add(admin, "plySlay", target:Name())
            staffAction("SLAY", admin:Name() .. " slayed " .. targetInfo)
            return true
        elseif cmd == "kill" then
            target:Kill()
            admin:notifySuccessLocalized("plyKilled")
            lia.log.add(admin, "plyKill", target:Name())
            lia.db.insertTable({
                player = target:Name(),
                playerSteamID = target:SteamID(),
                steamID = target:SteamID(),
                action = "plykill",
                staffName = admin:Name(),
                staffSteamID = admin:SteamID(),
                timestamp = os.time()
            }, nil, "staffactions")

            staffAction("KILL", admin:Name() .. " killed " .. targetInfo)
            return true
        elseif cmd == "bring" then
            returnPositions = returnPositions or {}
            returnPositions[target] = target:GetPos()
            target:SetPos(admin:GetPos() + admin:GetForward() * 50)
            admin:notifySuccessLocalized("plyBrought", target:Name())
            lia.log.add(admin, "plyBring", target:Name())
            staffAction("BRING", admin:Name() .. " brought " .. targetInfo)
            return true
        elseif cmd == "goto" then
            returnPositions = returnPositions or {}
            returnPositions[admin] = admin:GetPos()
            admin:SetPos(target:GetPos() + target:GetForward() * 50)
            admin:notifySuccessLocalized("plyGoto", target:Name())
            lia.log.add(admin, "plyGoto", target:Name())
            staffAction("GOTO", admin:Name() .. " went to " .. targetInfo)
            return true
        elseif cmd == "return" then
            returnPositions = returnPositions or {}
            local pos = returnPositions[target] or returnPositions[admin]
            if pos then
                (IsValid(target) and target or admin):SetPos(pos)
                returnPositions[target] = nil
                returnPositions[admin] = nil
                admin:notifySuccessLocalized("plyReturned", IsValid(target) and target:Name() or admin:Name())
                lia.log.add(admin, "plyReturn", IsValid(target) and target:Name() or admin:Name())
                staffAction("RETURN", admin:Name() .. " returned " .. targetInfo)
                return true
            end
        elseif cmd == "jail" then
            target:Lock()
            target:Freeze(true)
            admin:notifySuccessLocalized("plyJailed", target:Name())
            lia.log.add(admin, "plyJail", target:Name())
            lia.db.insertTable({
                player = target:Name(),
                playerSteamID = target:SteamID(),
                steamID = target:SteamID(),
                action = "plyjail",
                staffName = admin:Name(),
                staffSteamID = admin:SteamID(),
                timestamp = os.time()
            }, nil, "staffactions")

            staffAction("JAIL", admin:Name() .. " jailed " .. targetInfo)
            return true
        elseif cmd == "unjail" then
            target:UnLock()
            target:Freeze(false)
            admin:notifySuccessLocalized("plyUnjailed", target:Name())
            lia.log.add(admin, "plyUnjail", target:Name())
            staffAction("UNJAIL", admin:Name() .. " unjailed " .. targetInfo)
            return true
        elseif cmd == "cloak" then
            target:SetNoDraw(true)
            admin:notifySuccessLocalized("plyCloaked", target:Name())
            lia.log.add(admin, "plyCloak", target:Name())
            staffAction("CLOAK", admin:Name() .. " cloaked " .. targetInfo)
            return true
        elseif cmd == "uncloak" then
            target:SetNoDraw(false)
            admin:notifySuccessLocalized("plyUncloaked", target:Name())
            lia.log.add(admin, "plyUncloak", target:Name())
            staffAction("UNCLOAK", admin:Name() .. " uncloaked " .. targetInfo)
            return true
        elseif cmd == "god" then
            target:GodEnable()
            admin:notifySuccessLocalized("plyGodded", target:Name())
            lia.log.add(admin, "plyGod", target:Name())
            staffAction("GOD", admin:Name() .. " enabled god mode for " .. targetInfo)
            return true
        elseif cmd == "ungod" then
            target:GodDisable()
            admin:notifySuccessLocalized("plyUngodded", target:Name())
            lia.log.add(admin, "plyUngod", target:Name())
            staffAction("UNGOD", admin:Name() .. " disabled god mode for " .. targetInfo)
            return true
        elseif cmd == "ignite" then
            local duration = tonumber(dur) or 5
            target:Ignite(duration)
            admin:notifySuccessLocalized("plyIgnited", target:Name())
            lia.log.add(admin, "plyIgnite", target:Name(), duration)
            staffAction("IGNITE", admin:Name() .. " ignited " .. targetInfo)
            return true
        elseif cmd == "extinguish" or cmd == "unignite" then
            target:Extinguish()
            admin:notifySuccessLocalized("plyExtinguished", target:Name())
            lia.log.add(admin, "plyExtinguish", target:Name())
            staffAction("EXTINGUISH", admin:Name() .. " extinguished " .. targetInfo)
            return true
        elseif cmd == "strip" then
            target:StripWeapons()
            admin:notifySuccessLocalized("plyStripped", target:Name())
            lia.log.add(admin, "plyStrip", target:Name())
            lia.db.insertTable({
                player = target:Name(),
                playerSteamID = target:SteamID(),
                steamID = target:SteamID(),
                action = "plystrip",
                staffName = admin:Name(),
                staffSteamID = admin:SteamID(),
                timestamp = os.time()
            }, nil, "staffactions")

            staffAction("STRIP", admin:Name() .. " stripped weapons from " .. targetInfo)
            return true
        elseif cmd == "respawn" then
            target:Spawn()
            target:setLocalVar("lastDeathTime", 0)
            admin:notifySuccessLocalized("plyRespawned", target:Name())
            lia.log.add(admin, "plyRespawn", target:Name())
            lia.db.insertTable({
                player = target:Name(),
                playerSteamID = target:SteamID(),
                steamID = target:SteamID(),
                action = "plyrespawn",
                staffName = admin:Name(),
                staffSteamID = admin:SteamID(),
                timestamp = os.time()
            }, nil, "staffactions")

            staffAction("RESPAWN", admin:Name() .. " respawned " .. targetInfo)
            return true
        elseif cmd == "blind" then
            net.Start("liaBlindTarget")
            net.WriteBool(true)
            net.Send(target)
            local duration = tonumber(dur) or 0
            if duration > 0 then
                timer.Create("liaBlind" .. target:SteamID(), duration, 1, function()
                    if IsValid(target) then
                        net.Start("liaBlindTarget")
                        net.WriteBool(false)
                        net.Send(target)
                    end
                end)
            end

            admin:notifySuccessLocalized("plyBlinded", target:Name())
            lia.log.add(admin, "plyBlind", target:Name(), duration)
            lia.db.insertTable({
                player = target:Name(),
                playerSteamID = target:SteamID(),
                steamID = target:SteamID(),
                action = "plyblind",
                staffName = admin:Name(),
                staffSteamID = admin:SteamID(),
                timestamp = os.time()
            }, nil, "staffactions")

            staffAction("BLIND", admin:Name() .. " blinded " .. targetInfo)
            return true
        elseif cmd == "unblind" then
            net.Start("liaBlindTarget")
            net.WriteBool(false)
            net.Send(target)
            admin:notifySuccessLocalized("plyUnblinded", target:Name())
            lia.log.add(admin, "plyUnblind", target:Name())
            staffAction("UNBLIND", admin:Name() .. " unblinded " .. targetInfo)
            return true
        end
        return false
    end
else
    local liaCommands = {
        kick = function(id, _, reason) RunConsoleCommand("say", "/plykick " .. string.format("'%s'", tostring(id)) .. (reason and " " .. string.format("'%s'", tostring(reason)) or "")) end,
        ban = function(id, dur, reason) RunConsoleCommand("say", "/plyban " .. string.format("'%s'", tostring(id)) .. " " .. tostring(dur or 0) .. (reason and " " .. string.format("'%s'", tostring(reason)) or "")) end,
        unban = function(id) RunConsoleCommand("say", "/plyunban " .. string.format("'%s'", tostring(id))) end,
        mute = function(id, dur, reason) RunConsoleCommand("say", "/plymute " .. string.format("'%s'", tostring(id)) .. " " .. tostring(dur or 0) .. (reason and " " .. string.format("'%s'", tostring(reason)) or "")) end,
        unmute = function(id) RunConsoleCommand("say", "/plyunmute " .. string.format("'%s'", tostring(id))) end,
        gag = function(id, dur, reason) RunConsoleCommand("say", "/plygag " .. string.format("'%s'", tostring(id)) .. " " .. tostring(dur or 0) .. (reason and " " .. string.format("'%s'", tostring(reason)) or "")) end,
        ungag = function(id) RunConsoleCommand("say", "/plyungag " .. string.format("'%s'", tostring(id))) end,
        freeze = function(id, dur) RunConsoleCommand("say", "/plyfreeze " .. string.format("'%s'", tostring(id)) .. " " .. tostring(dur or 0)) end,
        unfreeze = function(id) RunConsoleCommand("say", "/plyunfreeze " .. string.format("'%s'", tostring(id))) end,
        slay = function(id) RunConsoleCommand("say", "/plyslay " .. string.format("'%s'", tostring(id))) end,
        bring = function(id) RunConsoleCommand("say", "/plybring " .. string.format("'%s'", tostring(id))) end,
        ["goto"] = function(id) RunConsoleCommand("say", "/plygoto " .. string.format("'%s'", tostring(id))) end,
        ["return"] = function(id) RunConsoleCommand("say", "/plyreturn " .. string.format("'%s'", tostring(id))) end,
        jail = function(id, dur) RunConsoleCommand("say", "/plyjail " .. string.format("'%s'", tostring(id)) .. " " .. tostring(dur or 0)) end,
        unjail = function(id) RunConsoleCommand("say", "/plyunjail " .. string.format("'%s'", tostring(id))) end,
        cloak = function(id) RunConsoleCommand("say", "/plycloak " .. string.format("'%s'", tostring(id))) end,
        uncloak = function(id) RunConsoleCommand("say", "/plyuncloak " .. string.format("'%s'", tostring(id))) end,
        god = function(id) RunConsoleCommand("say", "/plygod " .. string.format("'%s'", tostring(id))) end,
        ungod = function(id) RunConsoleCommand("say", "/plyungod " .. string.format("'%s'", tostring(id))) end,
        ignite = function(id, dur) RunConsoleCommand("say", "/plyignite " .. string.format("'%s'", tostring(id)) .. " " .. tostring(dur or 0)) end,
        extinguish = function(id) RunConsoleCommand("say", "/plyextinguish " .. string.format("'%s'", tostring(id))) end,
        unignite = function(id) RunConsoleCommand("say", "/plyextinguish " .. string.format("'%s'", tostring(id))) end,
        strip = function(id) RunConsoleCommand("say", "/plystrip " .. string.format("'%s'", tostring(id))) end,
        respawn = function(id) RunConsoleCommand("say", "/plyrespawn " .. string.format("'%s'", tostring(id))) end,
        blind = function(id) RunConsoleCommand("say", "/plyblind " .. string.format("'%s'", tostring(id))) end,
        unblind = function(id) RunConsoleCommand("say", "/plyunblind " .. string.format("'%s'", tostring(id))) end,
        spectate = function(id) RunConsoleCommand("say", "/plyspectate " .. string.format("'%s'", tostring(id))) end
    }

    --[[
    Purpose:
        Executes an administrative command using the client-side command system.

    When Called:
        Called when running admin commands through console commands or automated systems.

    Parameters:
        cmd (string)
            The command to execute (e.g., "kick", "ban", "mute", "freeze", etc.).
        victim (Player|string)
            The target player or identifier.
        dur (number)
            Duration for time-based commands.
        reason (string)
            Reason for the administrative action.

    Returns:
        boolean
            true if the command was executed successfully, false otherwise.

    Realm:
        Server

    Example Usage:
        ```lua
        -- Kick a player via console command
        lia.administrator.execCommand("kick", targetPlayer, nil, "Rule violation")

        -- Ban a player for 24 hours
        lia.administrator.execCommand("ban", targetPlayer, 1440, "Griefing")
        ```
]]
    function lia.administrator.execCommand(cmd, victim, dur, reason)
        local hookResult, callback = hook.Run("RunAdminSystemCommand", cmd, victim, dur, reason)
        if hookResult == true then
            callback()
            return true
        end

        local id
        if IsValid(victim) and victim:IsPlayer() then
            if victim:IsBot() then
                id = victim:Name()
            else
                id = victim:SteamID()
            end
        else
            id = tostring(victim)
        end

        local commandFunc = liaCommands[cmd]
        if commandFunc then
            commandFunc(id, dur, reason)
            return true
        end
    end
end

if properties and properties.List then
    for name, prop in pairs(properties.List) do
        if name ~= "persist" and name ~= "drive" and name ~= "bonemanipulate" then
            local id = "property_" .. tostring(name)
            lia.administrator.registerPrivilege({
                Name = L("accessPropertyPrivilege", prop.MenuLabel or name),
                ID = id,
                MinAccess = "admin",
                Category = "staffPermissions"
            })
        end
    end
end

for _, wep in ipairs(weapons.GetList()) do
    if wep.ClassName == "gmod_tool" and wep.Tool then
        for tool in pairs(wep.Tool) do
            local id = "tool_" .. tostring(tool)
            lia.administrator.registerPrivilege({
                Name = L("accessToolPrivilege", tool:gsub("^%l", string.upper)),
                ID = id,
                MinAccess = defaultUserTools[string.lower(tool)] and "user" or "admin",
                Category = "staffPermissions"
            })
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

    ensureStructures()
else
    local categoryMapCache = {}
    local lastCacheGroups = {}
    local function computeCategoryMap(groups)
        local groupsChanged = false
        local currentGroupsTable = {}
        for groupName, groupData in pairs(groups or {}) do
            currentGroupsTable[groupName] = {}
            for permName, hasPerm in pairs(groupData or {}) do
                if permName ~= "_info" then currentGroupsTable[groupName][permName] = hasPerm end
            end
        end

        if not lastCacheGroups then
            groupsChanged = true
        else
            for groupName, groupData in pairs(currentGroupsTable) do
                if not lastCacheGroups[groupName] then
                    groupsChanged = true
                    break
                end

                for permName, hasPerm in pairs(groupData) do
                    if lastCacheGroups[groupName][permName] ~= hasPerm then
                        groupsChanged = true
                        break
                    end
                end

                if groupsChanged then break end
            end

            for groupName, groupData in pairs(lastCacheGroups) do
                if not currentGroupsTable[groupName] then
                    groupsChanged = true
                    break
                end

                for permName, hasPerm in pairs(groupData) do
                    if currentGroupsTable[groupName][permName] ~= hasPerm then
                        groupsChanged = true
                        break
                    end
                end

                if groupsChanged then break end
            end
        end

        if not groupsChanged and categoryMapCache and #categoryMapCache > 0 then return categoryMapCache end
        lastCacheGroups = currentGroupsTable
        local cats, labels, seen = {}, {}, {}
        for name in pairs(lia.administrator.privileges or {}) do
            local c = tostring(getPrivilegeCategory(name))
            local key = c:lower()
            labels[key] = labels[key] or c
            cats[key] = cats[key] or {}
            cats[key][#cats[key] + 1], seen[name] = name, true
        end

        for _, data in pairs(groups or {}) do
            for name in pairs(data or {}) do
                if name ~= "_info" and not seen[name] then
                    local c = tostring(getPrivilegeCategory(name))
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

        categoryMapCache = {}
        for _, k in ipairs(keys) do
            categoryMapCache[#categoryMapCache + 1] = {
                label = labels[k],
                items = cats[k]
            }
        end
        return categoryMapCache
    end

    local function promptCreateGroup()
        lia.derma.requestArguments(L("create") .. " " .. L("group"), {
            Name = "string",
            Inheritance = {"table", {"user", "admin", "superadmin"}},
            Staff = "boolean",
            User = "boolean",
            VIP = "boolean"
        }, function(success, data)
            if not success then return end
            local name = string.Trim(tostring(data.Name or ""))
            if name == "" then return end
            local types = {}
            if data.Staff then types[#types + 1] = "Staff" end
            if data.User then types[#types + 1] = "User" end
            if data.VIP then types[#types + 1] = "VIP" end
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
        local tabs = container:Add("liaTabs")
        tabs:Dock(FILL)
        lia.gui.usergroups.checks = lia.gui.usergroups.checks or {}
        lia.gui.usergroups.checks[g] = lia.gui.usergroups.checks[g] or {}
        local function addRow(list, name)
            local row = list:Add("liaPrivilegeRow")
            row:Dock(TOP)
            row:SetTall(50)
            row:DockMargin(0, 0, 0, 8)
            row:SetPrivilege(name, current[name] and true or false, editable)
            if editable then
                row.OnChange = function(_, value)
                    if value then
                        current[name] = true
                    else
                        current[name] = nil
                    end

                    net.Start("liaGroupsSetPerm")
                    net.WriteString(g)
                    net.WriteString(name)
                    net.WriteBool(value)
                    net.SendToServer()
                end
            end

            lia.gui.usergroups.checks[g][name] = row
        end

        local ordered = computeCategoryMap(groups)
        for _, cat in ipairs(ordered) do
            local wrap = vgui.Create("DPanel")
            wrap.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(8):Color(lia.color.theme.panel[1]):Shape(lia.derma.SHAPE_IOS):Draw() end
            local list = vgui.Create("DListLayout", wrap)
            list:Dock(TOP)
            list:DockMargin(8, 8, 8, 8)
            for _, priv in ipairs(cat.items) do
                addRow(list, priv)
            end

            wrap:InvalidateLayout(true)
            wrap:SizeToChildren(true, true)
            tabs:AddTab(cat.label, wrap)
        end

        tabs:InvalidateLayout(true)
    end

    lia.net.readBigTable("liaUpdateAdminGroups", function(tbl)
        lia.administrator.groups = tbl
        if IsValid(lia.gui.usergroups) and lia.gui.usergroups.refreshTabs then lia.gui.usergroups.refreshTabs() end
    end)

    lia.net.readBigTable("liaUpdateAdminPrivileges", function(tbl)
        if tbl and tbl.privileges then
            lia.administrator.privileges = tbl.privileges
            lia.administrator.privilegeNames = tbl.names or {}
        else
            lia.administrator.privileges = tbl
        end

        hook.Run("AdminPrivilegesUpdated")
    end)

    local function SetupUserGroupInterface(parent)
        local container = parent:Add("DPanel")
        container:Dock(FILL)
        container.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.panel[1]):Shape(lia.derma.SHAPE_IOS):Draw() end
        local tabs = container:Add("liaTabs")
        tabs:Dock(FILL)
        tabs:DockMargin(10, 10, 10, 10)
        local bottom = container:Add("DPanel")
        bottom:Dock(BOTTOM)
        bottom:SetTall(50)
        bottom:DockMargin(10, 5, 10, 10)
        bottom.Paint = function() end
        local createBtn = vgui.Create("liaButton", bottom)
        createBtn:Dock(LEFT)
        createBtn:SetWide(120)
        createBtn:DockMargin(0, 0, 10, 0)
        createBtn:SetTxt(L("create") .. " " .. L("group"))
        createBtn.DoClick = function() promptCreateGroup() end
        local renameBtn = vgui.Create("liaButton", bottom)
        renameBtn:Dock(LEFT)
        renameBtn:SetWide(120)
        renameBtn:DockMargin(0, 0, 10, 0)
        renameBtn:SetTxt(L("rename") .. " " .. L("group"))
        renameBtn.DoClick = function()
            local activeTab = tabs:GetActiveTab()
            if not activeTab or not activeTab.groupName then return end
            if lia.administrator.DefaultGroups[activeTab.groupName] then
                LocalPlayer():notifyErrorLocalized("baseUsergroupCannotBeRenamed")
                return
            end

            LocalPlayer():requestString(L("rename") .. " " .. L("group"), L("renameGroupPrompt", activeTab.groupName) .. ":", function(txt)
                txt = string.Trim(txt or "")
                if txt ~= "" and txt ~= activeTab.groupName then
                    net.Start("liaGroupsRename")
                    net.WriteString(activeTab.groupName)
                    net.WriteString(txt)
                    net.SendToServer()
                end
            end, activeTab.groupName)
        end

        local deleteBtn = vgui.Create("liaButton", bottom)
        deleteBtn:Dock(LEFT)
        deleteBtn:SetWide(120)
        deleteBtn:DockMargin(0, 0, 10, 0)
        deleteBtn:SetTxt(L("delete") .. " " .. L("group"))
        deleteBtn.DoClick = function()
            local activeTab = tabs:GetActiveTab()
            if not activeTab or not activeTab.groupName then return end
            if lia.administrator.DefaultGroups[activeTab.groupName] then
                LocalPlayer():notifyErrorLocalized("baseUsergroupCannotBeRemoved")
                return
            end

            LocalPlayer():requestString(L("confirm"), L("deleteGroupPrompt", activeTab.groupName), function(value)
                if value and value:lower() == "yes" then
                    net.Start("liaGroupsRemove")
                    net.WriteString(activeTab.groupName)
                    net.SendToServer()
                end
            end)
        end

        local function createGroupTab(groupName, groups)
            if not groups[groupName] then return end
            local tabPanel = vgui.Create("DPanel")
            tabPanel:Dock(FILL)
            tabPanel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(12):Color(lia.color.theme.panel[1]):Shape(lia.derma.SHAPE_IOS):Draw() end
            local isDefault = lia.administrator.DefaultGroups and lia.administrator.DefaultGroups[groupName] ~= nil
            local editable = not isDefault
            local privContainer = tabPanel:Add("DPanel")
            privContainer:Dock(FILL)
            privContainer:DockMargin(20, 20, 20, 20)
            privContainer.Paint = function() end
            buildPrivilegeList(privContainer, groupName, groups, editable)
            local tabData = tabs:AddTab(groupName, tabPanel)
            tabData.groupName = groupName
            return tabData
        end

        local function refreshTabs()
            tabs:Clear()
            local groups = lia.administrator.groups or {}
            local keys = {}
            for g in pairs(groups) do
                keys[#keys + 1] = g
            end

            table.sort(keys, function(a, b) return a:lower() < b:lower() end)
            for _, groupName in ipairs(keys) do
                createGroupTab(groupName, groups)
            end
        end

        parent.refreshTabs = refreshTabs
    end

    hook.Add("PopulateAdminTabs", "liaAdmin", function(pages)
        if not IsValid(LocalPlayer()) or not LocalPlayer():hasPrivilege("manageUsergroups") then return end
        pages[#pages + 1] = {
            name = "userGroups",
            icon = "icon16/group.png",
            drawFunc = function(parent)
                lia.gui.usergroups = parent
                parent:Clear()
                parent:DockPadding(10, 10, 10, 10)
                parent.Paint = function(p, w, h) derma.SkinHook("Paint", "Frame", p, w, h) end
                SetupUserGroupInterface(parent)
                timer.Simple(0.1, function() if IsValid(parent) and parent.refreshTabs then parent.refreshTabs() end end)
                net.Start("liaGroupsRequest")
                net.SendToServer()
            end
        }
    end)
end

hook.Add("OnAdminSystemLoaded", "liaAdminSyncAfterLoad", function() lia.administrator.sync() end)
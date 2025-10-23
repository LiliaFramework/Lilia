--[[
    Administrator Library

    Comprehensive user group and privilege management system for the Lilia framework.
]]
--[[
    Overview:
    The administrator library provides comprehensive functionality for managing user groups, privileges,
    and administrative permissions in the Lilia framework. It handles the creation, modification,
    and deletion of user groups with inheritance-based privilege systems. The library operates on
    both server and client sides, with the server managing privilege storage and validation while
    the client provides user interface elements for administrative management. It includes integration
    with CAMI (Comprehensive Administration Management Interface) for compatibility with other
    administrative systems. The library ensures proper privilege inheritance, automatic privilege
    registration for tools and properties, and comprehensive logging of administrative actions.
    It supports both console-based and GUI-based administrative command execution with proper
    permission checking and validation.
]]
lia.administrator = lia.administrator or {}
lia.administrator.groups = lia.administrator.groups or {}
lia.administrator.privileges = lia.administrator.privileges or {}
lia.administrator.privilegeCategories = lia.administrator.privilegeCategories or {}
lia.administrator.privilegeNames = lia.administrator.privilegeNames or {}
lia.administrator.missingGroups = lia.administrator.missingGroups or {}
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
            category = "categoryStaffTools"
        },
        {
            match = function(name) return string.match(name, "^property_") end,
            category = "categoryStaffManagement"
        },
        {
            match = function(name) return name == "stopSoundForEveryone" end,
            category = "categoryServer"
        },
        {
            match = function(name) return string.match(name, "simfphys") end,
            category = "simfphysVehicles"
        },
        {
            match = function(name) return string.match(name, "SAM") end,
            category = "categorySAM"
        },
        {
            match = function(name) return string.match(name, "PAC") end,
            category = "categoryPAC3"
        },
        {
            match = function(name) return string.match(name, "ServerGuard") end,
            category = "categoryServerGuard"
        },
        {
            match = function(name) return name == "receiveCheaterNotifications" end,
            category = "protection"
        },
        {
            match = function(name) return name == "useDisallowedTools" end,
            category = "categoryStaffTools"
        }
    }

    local category
    if lia.administrator and lia.administrator.privilegeCategories and lia.administrator.privilegeCategories[privilegeName] then
        category = L(lia.administrator.privilegeCategories[privilegeName])
    elseif lia.command and lia.command.list and lia.command.list[privilegeName] then
        category = L("commands")
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
    Purpose: Applies punishment actions (kick/ban) to a player based on infraction details
    When Called: When an administrative action needs to be taken against a player for rule violations
    Parameters:
        - client (Player): The player to punish
        - infraction (string): Description of the infraction committed
        - kick (boolean): Whether to kick the player
        - ban (boolean): Whether to ban the player
        - time (number): Ban duration in minutes (0 = permanent)
        - kickKey (string): Language key for kick message (optional)
        - banKey (string): Language key for ban message (optional)
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Kick a player for cheating
        lia.administrator.applyPunishment(player, "Cheating detected", true, false)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Ban a player for 60 minutes with custom message
        lia.administrator.applyPunishment(player, "RDM", false, true, 60, "kickedForRDM", "bannedForRDM")
        ```

        High Complexity:
        ```lua
        -- High: Apply punishment based on infraction severity
        local punishments = {
            ["RDM"] = {kick = true, ban = false, time = 0},
            ["Cheating"] = {kick = true, ban = true, time = 0},
            ["Spam"] = {kick = true, ban = false, time = 30}
        }
        local punishment = punishments[infractionType]
        if punishment then
            lia.administrator.applyPunishment(player, infractionType, punishment.kick, punishment.ban, punishment.time)
        end
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
    Purpose: Checks if a player or user group has access to a specific privilege
    When Called: When permission validation is needed before allowing access to features or commands
    Parameters:
        - ply (Player|string): Player entity or user group name to check
        - privilege (string): The privilege identifier to check access for
    Returns: boolean - true if access is granted, false otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check if player can use admin tools
        if lia.administrator.hasAccess(player, "tool_adminstick") then
            -- Grant access to admin stick
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Check access for different user groups
        local groups = {"admin", "moderator", "user"}
        for _, group in ipairs(groups) do
            if lia.administrator.hasAccess(group, "manageUsergroups") then
                print(group .. " can manage user groups")
            end
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex permission checking with fallback
        local function checkMultiplePrivileges(player, privileges)
            for _, privilege in ipairs(privileges) do
                if lia.administrator.hasAccess(player, privilege) then
                    return true, privilege
                end
            end
            return false, nil
        end

        local hasAccess, grantedPrivilege = checkMultiplePrivileges(player, {"admin", "moderator", "helper"})
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
                    Category = "properties",
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
                        Category = "categoryStaffTools",
                    })

                    break
                end
            end
        end
    end

    if not lia.administrator.privileges[privilege] then
        if SERVER then
            local playerInfo = IsValid(ply) and ply:Nick() .. " (" .. ply:SteamID() .. ")" or "Unknown"
            lia.log.add(ply, "missingPrivilege", privilege, playerInfo, grp)
        end
        return getGroupLevel(grp) >= (lia.administrator.DefaultGroups.admin or 3)
    end

    if getGroupLevel(grp) >= (lia.administrator.DefaultGroups.superadmin or 3) then return true end
    local g = lia.administrator.groups and lia.administrator.groups[grp] or nil
    if g and g[privilege] == true then return true end
    local min = lia.administrator.privileges[privilege]
    return shouldGrant(grp, min)
end

--[[
    Purpose: Saves all administrator groups and privileges to the database and synchronizes with clients
    When Called: When administrator data needs to be persisted to the database after changes
    Parameters:
        - noNetwork (boolean): If true, skips network synchronization (optional)
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Save administrator data
        lia.administrator.save()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Save without network sync during bulk operations
        for i = 1, 10 do
            lia.administrator.createGroup("group" .. i, {})
        end
        lia.administrator.save(true) -- Save without network sync
        lia.administrator.save() -- Final save with sync
        ```

        High Complexity:
        ```lua
        -- High: Batch save with error handling
        local function safeSave(noNetwork)
            local success, err = pcall(function()
                lia.administrator.save(noNetwork)
            end)
            if not success then
                lia.log.add(nil, "adminSaveError", err)
                return false
            end
            return true
        end

        if safeSave(true) then
            print("Administrator data saved successfully")
        end
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
    Purpose: Registers a new privilege in the administrator system with specified access requirements
    When Called: When a new privilege needs to be added to the system for permission checking
    Parameters:
        - priv (table): Privilege definition table containing:
            - ID (string): Unique identifier for the privilege
            - Name (string): Display name for the privilege (optional)
            - MinAccess (string): Minimum access level required (default: "user")
            - Category (string): Category for organizing privileges (optional)
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Register a basic privilege
        lia.administrator.registerPrivilege({
            ID = "accessAdminPanel",
            Name = "Access Admin Panel",
            MinAccess = "admin"
        })
        ```

        Medium Complexity:
        ```lua
        -- Medium: Register privilege with category
        lia.administrator.registerPrivilege({
            ID = "managePlayers",
            Name = "Manage Players",
            MinAccess = "moderator",
            Category = "Player Management"
        })
        ```

        High Complexity:
        ```lua
        -- High: Register multiple privileges from module
        local modulePrivileges = {
            {ID = "module_feature1", Name = "Feature 1", MinAccess = "user", Category = "Module"},
            {ID = "module_feature2", Name = "Feature 2", MinAccess = "admin", Category = "Module"},
            {ID = "module_feature3", Name = "Feature 3", MinAccess = "superadmin", Category = "Module"}
        }

        for _, privilege in ipairs(modulePrivileges) do
            lia.administrator.registerPrivilege(privilege)
        end
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
    for groupName, perms in pairs(lia.administrator.groups) do
        perms = perms or {}
        lia.administrator.groups[groupName] = perms
        if shouldGrant(groupName, min) then perms[id] = true end
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
    Purpose: Removes a privilege from the administrator system and all user groups
    When Called: When a privilege is no longer needed and should be completely removed
    Parameters:
        - id (string): The privilege identifier to remove
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Remove a privilege
        lia.administrator.unregisterPrivilege("oldPrivilege")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Remove privilege with validation
        local privilegeToRemove = "deprecatedFeature"
        if lia.administrator.privileges[privilegeToRemove] then
            lia.administrator.unregisterPrivilege(privilegeToRemove)
            print("Privilege removed: " .. privilegeToRemove)
        end
        ```

        High Complexity:
        ```lua
        -- High: Remove multiple privileges with cleanup
        local privilegesToRemove = {"old_feature1", "old_feature2", "deprecated_tool"}
        for _, privilege in ipairs(privilegesToRemove) do
            if lia.administrator.privileges[privilege] then
                lia.administrator.unregisterPrivilege(privilege)
                lia.log.add(nil, "privilegeRemoved", privilege)
            end
        end
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
    Purpose: Applies privilege inheritance from parent groups to a specific user group
    When Called: When a user group's inheritance needs to be recalculated after changes
    Parameters:
        - groupName (string): The name of the user group to apply inheritance to
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Apply inheritance to a group
        lia.administrator.applyInheritance("moderator")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Apply inheritance after group modification
        lia.administrator.groups["moderator"]._info.inheritance = "admin"
        lia.administrator.applyInheritance("moderator")
        ```

        High Complexity:
        ```lua
        -- High: Apply inheritance to multiple groups with validation
        local groupsToUpdate = {"moderator", "helper", "vip"}
        for _, groupName in ipairs(groupsToUpdate) do
            if lia.administrator.groups[groupName] then
                lia.administrator.applyInheritance(groupName)
                print("Applied inheritance to: " .. groupName)
            end
        end
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
    for priv, min in pairs(lia.administrator.privileges or {}) do
        if shouldGrant(groupName, min) then g[priv] = true end
    end
end

--[[
    Purpose: Loads administrator groups and privileges from the database and initializes the system
    When Called: During server startup or when administrator data needs to be reloaded
    Parameters: None
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Load administrator data
        lia.administrator.load()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Load with callback handling
        lia.administrator.load()
        hook.Add("OnAdminSystemLoaded", "MyModule", function(groups, privileges)
            print("Admin system loaded with " .. table.Count(groups) .. " groups")
        end)
        ```

        High Complexity:
        ```lua
        -- High: Load with error handling and validation
        local function safeLoad()
            local success, err = pcall(function()
                lia.administrator.load()
            end)
            if not success then
                lia.log.add(nil, "adminLoadError", err)
                -- Fallback to default groups
                lia.administrator.groups = {
                    user = {_info = {inheritance = "user", types = {}}},
                    admin = {_info = {inheritance = "admin", types = {"Staff"}}},
                    superadmin = {_info = {inheritance = "superadmin", types = {"Staff"}}}
                }
                return false
            end
            return true
        end

        if safeLoad() then
            print("Administrator system loaded successfully")
        else
            print("Failed to load administrator system, using defaults")
        end
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
    Purpose: Creates a new user group with specified inheritance and type information
    When Called: When a new user group needs to be added to the administrator system
    Parameters:
        - groupName (string): The name of the new user group
        - info (table): Group configuration table containing:
            - _info (table): Group metadata with inheritance and types (optional)
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Create a basic group
        lia.administrator.createGroup("moderator")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Create group with inheritance
        lia.administrator.createGroup("helper", {
            _info = {
                inheritance = "user",
                types = {"Staff"}
            }
        })
        ```

        High Complexity:
        ```lua
        -- High: Create multiple groups with different configurations
        local groupConfigs = {
            {name = "moderator", inherit = "admin", types = {"Staff"}},
            {name = "helper", inherit = "user", types = {"Staff"}},
            {name = "vip", inherit = "user", types = {"VIP"}}
        }

        for _, config in ipairs(groupConfigs) do
            lia.administrator.createGroup(config.name, {
                _info = {
                    inheritance = config.inherit,
                    types = config.types
                }
            })
        end
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
    hook.Run("OnUsergroupCreated", groupName, lia.administrator.groups[groupName])
    if SERVER then lia.administrator.save() end
end

--[[
    Purpose: Removes a user group from the administrator system (cannot remove base groups)
    When Called: When a user group is no longer needed and should be deleted
    Parameters:
        - groupName (string): The name of the user group to remove
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Remove a group
        lia.administrator.removeGroup("oldGroup")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Remove group with validation
        local groupToRemove = "deprecatedGroup"
        if lia.administrator.groups[groupToRemove] and not lia.administrator.DefaultGroups[groupToRemove] then
            lia.administrator.removeGroup(groupToRemove)
            print("Group removed: " .. groupToRemove)
        end
        ```

        High Complexity:
        ```lua
        -- High: Remove multiple groups with safety checks
        local groupsToRemove = {"tempGroup1", "tempGroup2", "oldModerator"}
        for _, groupName in ipairs(groupsToRemove) do
            if lia.administrator.groups[groupName] and not lia.administrator.DefaultGroups[groupName] then
                lia.administrator.removeGroup(groupName)
                lia.log.add(nil, "groupRemoved", groupName)
            else
                print("Cannot remove group: " .. groupName)
            end
        end
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
    hook.Run("OnUsergroupRemoved", groupName)
    if SERVER then lia.administrator.save() end
end

--[[
    Purpose: Renames an existing user group to a new name (cannot rename base groups)
    When Called: When a user group needs to be renamed for organizational purposes
    Parameters:
        - oldName (string): The current name of the user group
        - newName (string): The new name for the user group
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Rename a group
        lia.administrator.renameGroup("oldModerator", "moderator")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Rename with validation
        local oldGroupName = "tempGroup"
        local newGroupName = "permanentGroup"
        if lia.administrator.groups[oldGroupName] and not lia.administrator.groups[newGroupName] then
            lia.administrator.renameGroup(oldGroupName, newGroupName)
        end
        ```

        High Complexity:
        ```lua
        -- High: Batch rename with error handling
        local renameOperations = {
            {old = "oldHelper", new = "helper"},
            {old = "oldVIP", new = "vip"},
            {old = "tempMod", new = "moderator"}
        }

        for _, operation in ipairs(renameOperations) do
            if lia.administrator.groups[operation.old] and not lia.administrator.groups[operation.new] then
                lia.administrator.renameGroup(operation.old, operation.new)
                lia.log.add(nil, "groupRenamed", operation.old, operation.new)
            else
                print("Cannot rename " .. operation.old .. " to " .. operation.new)
            end
        end
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
    hook.Run("OnUsergroupRenamed", oldName, newName)
    if SERVER then lia.administrator.save() end
end

if SERVER then
    --[[
    Purpose: Sends administrative notifications to all players with the appropriate privilege
    When Called: When administrative notifications need to be broadcast to qualified players
    Parameters:
        - notification (table): Notification data to send to players
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Notify admins about an event
        lia.administrator.notifyAdmin({
            text = "Player kicked for cheating",
            type = "warning"
        })
        ```

        Medium Complexity:
        ```lua
        -- Medium: Notify with specific privilege requirement
        lia.administrator.notifyAdmin({
            text = "Suspicious activity detected",
            type = "alert",
            privilege = "canSeeAltingNotifications"
        })
        ```

        High Complexity:
        ```lua
        -- High: Batch notifications with different privilege levels
        local notifications = {
            {text = "Server restart in 5 minutes", privilege = "admin"},
            {text = "New player joined", privilege = "moderator"},
            {text = "VIP player online", privilege = "vip"}
        }

        for _, notification in ipairs(notifications) do
            lia.administrator.notifyAdmin(notification)
        end
        ```
]]
    function lia.administrator.notifyAdmin(notification)
        for _, client in player.Iterator() do
            if IsValid(client) and client:hasPrivilege("canSeeAltingNotifications") then client:notifyAdminLocalized(notification) end
        end
    end

    --[[
    Purpose: Adds a permission to a specific user group
    When Called: When a user group needs to be granted a new permission
    Parameters:
        - groupName (string): The name of the user group
        - permission (string): The permission identifier to add
        - silent (boolean): If true, skips network synchronization (optional)
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Add permission to group
        lia.administrator.addPermission("moderator", "kickPlayers")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Add permission silently during bulk operations
        lia.administrator.addPermission("helper", "mutePlayers", true)
        ```

        High Complexity:
        ```lua
        -- High: Add multiple permissions with validation
        local permissions = {"kickPlayers", "mutePlayers", "banPlayers"}
        for _, permission in ipairs(permissions) do
            if not lia.administrator.groups["moderator"][permission] then
                lia.administrator.addPermission("moderator", permission)
            end
        end
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
    Purpose: Removes a permission from a specific user group
    When Called: When a user group should no longer have a specific permission
    Parameters:
        - groupName (string): The name of the user group
        - permission (string): The permission identifier to remove
        - silent (boolean): If true, skips network synchronization (optional)
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Remove permission from group
        lia.administrator.removePermission("moderator", "banPlayers")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Remove permission silently during bulk operations
        lia.administrator.removePermission("helper", "kickPlayers", true)
        ```

        High Complexity:
        ```lua
        -- High: Remove multiple permissions with validation
        local permissionsToRemove = {"banPlayers", "kickPlayers", "mutePlayers"}
        for _, permission in ipairs(permissionsToRemove) do
            if lia.administrator.groups["moderator"][permission] then
                lia.administrator.removePermission("moderator", permission)
            end
        end
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
    Purpose: Synchronizes administrator data with connected clients
    When Called: When administrator data needs to be sent to clients after changes
    Parameters:
        - c (Player): Specific client to sync with (optional, syncs all if nil)
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Sync with all clients
        lia.administrator.sync()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Sync with specific client
        lia.administrator.sync(player)
        ```

        High Complexity:
        ```lua
        -- High: Sync with validation and error handling
        local function safeSync(client)
            if client and not IsValid(client) then
                lia.log.add(nil, "syncError", "Invalid client")
                return false
            end

            local success, err = pcall(function()
                lia.administrator.sync(client)
            end)

            if not success then
                lia.log.add(nil, "syncError", err)
                return false
            end

            return true
        end

        if safeSync(player) then
            print("Administrator data synced successfully")
        end
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
    Purpose: Changes a player's user group and triggers CAMI events
    When Called: When a player's user group needs to be changed
    Parameters:
        - ply (Player): The player whose group should be changed
        - newGroup (string): The new user group name
        - source (string): Source identifier for CAMI events (optional)
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Change player's group
        lia.administrator.setPlayerUsergroup(player, "moderator")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Change group with source tracking
        lia.administrator.setPlayerUsergroup(player, "admin", "MyModule")
        ```

        High Complexity:
        ```lua
        -- High: Batch group changes with validation
        local groupChanges = {
            {player = player1, group = "moderator", source = "promotion"},
            {player = player2, group = "helper", source = "demotion"},
            {player = player3, group = "vip", source = "donation"}
        }

        for _, change in ipairs(groupChanges) do
            if IsValid(change.player) then
                lia.administrator.setPlayerUsergroup(change.player, change.group, change.source)
                lia.log.add(nil, "groupChanged", change.player:Name(), change.group)
            end
        end
        ```
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
    Purpose: Changes a Steam ID's user group and triggers CAMI events
    When Called: When a Steam ID's user group needs to be changed (for offline players)
    Parameters:
        - steamId (string): The Steam ID whose group should be changed
        - newGroup (string): The new user group name
        - source (string): Source identifier for CAMI events (optional)
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Change Steam ID's group
        lia.administrator.setSteamIDUsergroup("STEAM_0:1:123456789", "moderator")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Change group with source tracking
        lia.administrator.setSteamIDUsergroup("STEAM_0:1:123456789", "admin", "WebPanel")
        ```

        High Complexity:
        ```lua
        -- High: Batch Steam ID group changes with validation
        local steamGroupChanges = {
            {steamid = "STEAM_0:1:123456789", group = "moderator", source = "promotion"},
            {steamid = "STEAM_0:1:987654321", group = "helper", source = "demotion"},
            {steamid = "STEAM_0:1:555555555", group = "vip", source = "donation"}
        }

        for _, change in ipairs(steamGroupChanges) do
            if change.steamid and change.steamid ~= "" then
                lia.administrator.setSteamIDUsergroup(change.steamid, change.group, change.source)
                lia.log.add(nil, "steamGroupChanged", change.steamid, change.group)
            end
        end
        ```
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

    --[[
    Purpose: Executes administrative commands on the server with permission checking
    When Called: When administrative commands need to be executed with proper validation
    Parameters:
        - cmd (string): The command to execute
        - victim (Player|string): Target player or Steam ID
        - dur (number): Duration parameter for timed commands (optional)
        - reason (string): Reason for the command (optional)
        - admin (Player): The admin executing the command
    Returns: boolean - true if command was executed successfully, false otherwise
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Kick a player
        lia.administrator.serverExecCommand("kick", player, nil, "Cheating", admin)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Ban player with duration
        lia.administrator.serverExecCommand("ban", player, 60, "RDM", admin)
        ```

        High Complexity:
        ```lua
        -- High: Execute multiple commands with validation
        local commands = {
            {cmd = "kick", target = player1, reason = "Cheating"},
            {cmd = "ban", target = player2, duration = 30, reason = "RDM"},
            {cmd = "mute", target = player3, duration = 10, reason = "Spam"}
        }

        for _, command in ipairs(commands) do
            local success = lia.administrator.serverExecCommand(
                command.cmd,
                command.target,
                command.duration,
                command.reason,
                admin
            )
            if success then
                print("Command executed: " .. command.cmd)
            end
        end
        ```
]]
    function lia.administrator.serverExecCommand(cmd, victim, dur, reason, admin)
        local privilegeID = string.lower("command_" .. cmd)
        if not lia.administrator.hasAccess(admin, privilegeID) then
            admin:notifyErrorLocalized("noPerm")
            lia.log.add(admin, "unauthorizedCommand", cmd)
            return false
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

        if cmd == "kick" then
            target:Kick(reason or L("genericReason"))
            admin:notifySuccessLocalized("plyKicked")
            lia.log.add(admin, "plyKick", target:Name())
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
            return true
        elseif cmd == "unban" then
            local steamid = IsValid(target) and target:SteamID() or tostring(victim)
            if steamid and steamid ~= "" then
                lia.db.query("DELETE FROM lia_bans WHERE playerSteamID = " .. lia.db.convertDataType(steamid))
                admin:notifySuccessLocalized("playerUnbanned")
                lia.log.add(admin, "plyUnban", steamid)
                return true
            end
        elseif cmd == "mute" then
            if target:getChar() then
                target:setLiliaData("VoiceBan", true)
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

                hook.Run("PlayerMuted", target, admin)
                return true
            end
        elseif cmd == "unmute" then
            if target:getChar() then
                target:setLiliaData("VoiceBan", false)
                admin:notifySuccessLocalized("plyUnmuted")
                lia.log.add(admin, "plyUnmute", target:Name())
                hook.Run("PlayerUnmuted", target, admin)
                return true
            end
        elseif cmd == "gag" then
            target:setNetVar("liaGagged", true)
            admin:notifySuccessLocalized("plyGagged")
            lia.log.add(admin, "plyGag", target:Name())
            hook.Run("PlayerGagged", target, admin)
            return true
        elseif cmd == "ungag" then
            target:setNetVar("liaGagged", false)
            admin:notifySuccessLocalized("plyUngagged")
            lia.log.add(admin, "plyUngag", target:Name())
            hook.Run("PlayerUngagged", target, admin)
            return true
        elseif cmd == "freeze" then
            target:Freeze(true)
            local duration = tonumber(dur) or 0
            if duration > 0 then timer.Simple(duration, function() if IsValid(target) then target:Freeze(false) end end) end
            lia.log.add(admin, "plyFreeze", target:Name(), duration)
            return true
        elseif cmd == "unfreeze" then
            target:Freeze(false)
            lia.log.add(admin, "plyUnfreeze", target:Name())
            return true
        elseif cmd == "slay" then
            target:Kill()
            -- Ensure death countdown appears by triggering a delayed death event
            timer.Simple(0.05, function() if IsValid(target) and not target:Alive() then hook.Run("PlayerDeath", target, nil, admin) end end)
            admin:notifySuccessLocalized("plyKilled")
            lia.log.add(admin, "plySlay", target:Name())
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
            return true
        elseif cmd == "bring" then
            returnPositions = returnPositions or {}
            returnPositions[target] = target:GetPos()
            target:SetPos(admin:GetPos() + admin:GetForward() * 50)
            lia.log.add(admin, "plyBring", target:Name())
            return true
        elseif cmd == "goto" then
            returnPositions = returnPositions or {}
            returnPositions[admin] = admin:GetPos()
            admin:SetPos(target:GetPos() + target:GetForward() * 50)
            lia.log.add(admin, "plyGoto", target:Name())
            return true
        elseif cmd == "return" then
            returnPositions = returnPositions or {}
            local pos = returnPositions[target] or returnPositions[admin]
            if pos then
                (IsValid(target) and target or admin):SetPos(pos)
                returnPositions[target] = nil
                returnPositions[admin] = nil
                lia.log.add(admin, "plyReturn", IsValid(target) and target:Name() or admin:Name())
                return true
            end
        elseif cmd == "jail" then
            target:Lock()
            target:Freeze(true)
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
            return true
        elseif cmd == "unjail" then
            target:UnLock()
            target:Freeze(false)
            lia.log.add(admin, "plyUnjail", target:Name())
            return true
        elseif cmd == "cloak" then
            target:SetNoDraw(true)
            lia.log.add(admin, "plyCloak", target:Name())
            return true
        elseif cmd == "uncloak" then
            target:SetNoDraw(false)
            lia.log.add(admin, "plyUncloak", target:Name())
            return true
        elseif cmd == "god" then
            target:GodEnable()
            lia.log.add(admin, "plyGod", target:Name())
            return true
        elseif cmd == "ungod" then
            target:GodDisable()
            lia.log.add(admin, "plyUngod", target:Name())
            return true
        elseif cmd == "ignite" then
            local duration = tonumber(dur) or 5
            target:Ignite(duration)
            lia.log.add(admin, "plyIgnite", target:Name(), duration)
            return true
        elseif cmd == "extinguish" or cmd == "unignite" then
            target:Extinguish()
            lia.log.add(admin, "plyExtinguish", target:Name())
            return true
        elseif cmd == "strip" then
            target:StripWeapons()
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
            return true
        elseif cmd == "respawn" then
            target:Spawn()
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
            return true
        elseif cmd == "unblind" then
            net.Start("liaBlindTarget")
            net.WriteBool(false)
            net.Send(target)
            lia.log.add(admin, "plyUnblind", target:Name())
            return true
        end
        return false
    end
else
    --[[
    Purpose: Executes administrative commands on the client with hook system integration and callback support
    When Called: When administrative commands need to be executed from the client side
    Parameters:
        - cmd (string): The command to execute
        - victim (Player|string): Target player or Steam ID
        - dur (number): Duration parameter for timed commands (optional)
        - reason (string): Reason for the command (optional)
    Returns: boolean - true if command was executed successfully, false otherwise
    Realm: Client
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Kick a player
        lia.administrator.execCommand("kick", player, nil, "Cheating")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Ban player with duration
        lia.administrator.execCommand("ban", player, 60, "RDM")
        ```

        High Complexity:
        ```lua
        -- High: Execute multiple commands with validation
        local commands = {
            {cmd = "kick", target = player1, reason = "Cheating"},
            {cmd = "ban", target = player2, duration = 30, reason = "RDM"},
            {cmd = "mute", target = player3, duration = 10, reason = "Spam"}
        }

        for _, command in ipairs(commands) do
            local success = lia.administrator.execCommand(
                command.cmd,
                command.target,
                command.duration,
                command.reason
            )
            if success then
                print("Command sent: " .. command.cmd)
            end
        end
        ```

        Hook Implementation Example:
        ```lua
        -- Custom admin system hook
        hook.Add("RunAdminSystemCommand", "MyAdminSystem", function(cmd, victim, dur, reason)
            if cmd == "kick" then
                MyAdminSystem:KickPlayer(victim, reason)
                return true, function()
                    print("Player kicked via MyAdminSystem")
                end
            end
            return false -- Don't handle other commands
        end)
        ```
]]
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

    function lia.administrator.execCommand(cmd, victim, dur, reason)
        local hookResult, callback = hook.Run("RunAdminSystemCommand", cmd, victim, dur, reason)
        if hookResult == true then
            callback()
            return true
        end

        local id = IsValid(victim) and victim:SteamID() or tostring(victim)
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
                Category = "properties"
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
                Category = "categoryStaffTools"
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

    local function broadcastGroups()
        lia.net.ready = lia.net.ready or setmetatable({}, {
            __mode = "k"
        })

        local players = player.GetHumans()
        for _, ply in ipairs(players) do
            if lia.net.ready[ply] then lia.net.writeBigTable(ply, "liaUpdateAdminGroups", lia.administrator.groups or {}) end
        end
    end

    ensureStructures()
    net.Receive("liaGroupsRequest", function(_, p)
        if not IsValid(p) or not p:hasPrivilege("manageUsergroups") then return end
        lia.net.ready = lia.net.ready or setmetatable({}, {
            __mode = "k"
        })

        lia.net.ready[p] = true
        lia.administrator.sync(p)
    end)

    net.Receive("liaGroupsAdd", function(_, p)
        if not p:hasPrivilege("manageUsergroups") then return end
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
        p:notifySuccessLocalized("groupCreated", n)
    end)

    net.Receive("liaGroupsRemove", function(_, p)
        if not p:hasPrivilege("manageUsergroups") then return end
        local n = net.ReadString()
        if n == "" or lia.administrator.DefaultGroups and lia.administrator.DefaultGroups[n] then return end
        lia.administrator.removeGroup(n)
        if lia.administrator.groups then lia.administrator.groups[n] = nil end
        lia.administrator.save()
        broadcastGroups()
        p:notifySuccessLocalized("groupRemoved", n)
    end)

    net.Receive("liaGroupsRename", function(_, p)
        if not p:hasPrivilege("manageUsergroups") then return end
        local old = string.Trim(net.ReadString() or "")
        local new = string.Trim(net.ReadString() or "")
        if old == "" or new == "" then return end
        if old == new then return end
        if not lia.administrator.groups or not lia.administrator.groups[old] then return end
        if lia.administrator.groups[new] or lia.administrator.DefaultGroups and lia.administrator.DefaultGroups[new] then return end
        if lia.administrator.DefaultGroups and lia.administrator.DefaultGroups[old] then return end
        lia.administrator.renameGroup(old, new)
        broadcastGroups()
        p:notifySuccessLocalized("groupRenamed", old, new)
    end)

    net.Receive("liaGroupsSetPerm", function(_, p)
        if not p:hasPrivilege("manageUsergroups") then return end
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
        p:notifySuccessLocalized("groupPermissionsUpdated")
    end)
else
    local LAST_GROUP
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
        surface.SetFont("liaBigFont")
        local _, hfh = surface.GetTextSize("W")
        local headerH = math.max(hfh + 18, 36)
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
            local c = categoryList:Add(cat.label)
            c:SetContents(wrap)
            c:SetExpanded(false)
            local header = c.Header or c.GetHeader and c:GetHeader() or nil
            if IsValid(header) then
                header:SetFont("liaBigFont")
                header:SetTall(headerH)
                header:SetTextInset(12, 0)
                header:SetContentAlignment(4)
                header.Paint = function(_, w, h)
                    lia.derma.rect(0, 0, w, h):Rad(8):Color(lia.color.theme.panel[1]):Shape(lia.derma.SHAPE_IOS):Draw()
                    draw.SimpleText(cat.label, "liaBigFont", 12, h / 2, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
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
                LocalPlayer():requestString(L("rename") .. " " .. L("group"), L("renameGroupPrompt", g) .. ":", function(txt)
                    txt = string.Trim(txt or "")
                    if txt ~= "" and txt ~= g then
                        net.Start("liaGroupsRename")
                        net.WriteString(g)
                        net.WriteString(txt)
                        net.SendToServer()
                    end
                end, g)
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

    lia.net.readBigTable("liaUpdateAdminGroups", function(tbl)
        lia.administrator.groups = tbl
        if IsValid(lia.gui.usergroups) then
            if lia.gui.usergroups.groupsList then
                lia.gui.usergroups.groupsList:SetGroups(tbl)
            else
                buildGroupsUI(lia.gui.usergroups, tbl)
            end
        end
    end)

    lia.net.readBigTable("liaUpdateAdminPrivileges", function(tbl)
        if tbl and tbl.privileges then
            lia.administrator.privileges = tbl.privileges
            lia.administrator.privilegeNames = tbl.names or {}
        else
            lia.administrator.privileges = tbl
        end
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

        if IsValid(lia.gui.usergroups) then
            if lia.gui.usergroups.groupsList then
                local selectedGroup = lia.gui.usergroups.groupsList:GetSelectedGroup()
                if selectedGroup == group and lia.gui.usergroups.updateGroupDetails then lia.gui.usergroups.updateGroupDetails(group) end
            elseif lia.gui.usergroups.checks and lia.gui.usergroups.checks[group] then
                local chk = lia.gui.usergroups.checks[group][privilege]
                if IsValid(chk) and chk:GetChecked() ~= value then
                    chk._suppress = true
                    chk:SetChecked(value)
                end
            end
        end
    end)

    local function SetupUserGroupInterface(parent)
        local container = parent:Add("DPanel")
        container:Dock(FILL)
        container.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.panel[1]):Shape(lia.derma.SHAPE_IOS):Draw() end
        local groupsList = container:Add("liaUserGroupList")
        groupsList:Dock(LEFT)
        groupsList:SetWide(200)
        groupsList:DockMargin(10, 5, 5, 10)
        groupsList.buttonType = "liaButton" -- Use modern button style
        local groupDetails = container:Add("DPanel")
        groupDetails:Dock(FILL)
        groupDetails:DockMargin(5, 5, 10, 10)
        groupDetails.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(12):Color(lia.color.theme.panel[1]):Shape(lia.derma.SHAPE_IOS):Draw() end
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
            local selectedGroup = groupsList:GetSelectedGroup()
            if not selectedGroup then return end
            LocalPlayer():requestString(L("rename") .. " " .. L("group"), L("renameGroupPrompt", selectedGroup) .. ":", function(txt)
                txt = string.Trim(txt or "")
                if txt ~= "" and txt ~= selectedGroup then
                    net.Start("liaGroupsRename")
                    net.WriteString(selectedGroup)
                    net.WriteString(txt)
                    net.SendToServer()
                end
            end, selectedGroup)
        end

        local deleteBtn = vgui.Create("liaButton", bottom)
        deleteBtn:Dock(LEFT)
        deleteBtn:SetWide(120)
        deleteBtn:DockMargin(0, 0, 10, 0)
        deleteBtn:SetTxt(L("delete") .. " " .. L("group"))
        deleteBtn.DoClick = function()
            local selectedGroup = groupsList:GetSelectedGroup()
            if not selectedGroup then return end
            Derma_Query(L("deleteGroupPrompt", selectedGroup), L("confirm"), L("yes"), function()
                net.Start("liaGroupsRemove")
                net.WriteString(selectedGroup)
                net.SendToServer()
            end, L("no"))
        end

        local function updateGroupDetails(groupName)
            if not groupName or not lia.administrator.groups[groupName] then
                groupDetails:Clear()
                return
            end

            groupDetails:Clear()
            local isDefault = lia.administrator.DefaultGroups and lia.administrator.DefaultGroups[groupName] ~= nil
            local editable = not isDefault
            local privContainer = groupDetails:Add("DPanel")
            privContainer:Dock(FILL)
            privContainer:DockMargin(20, 0, 20, 20)
            privContainer.Paint = function() end
            buildPrivilegeList(privContainer, groupName, lia.administrator.groups, editable)
        end

        groupsList.OnGroupSelected = function(_, groupName) updateGroupDetails(groupName) end
        groupsList:SetGroups(lia.administrator.groups)
        parent.groupsList = groupsList
        parent.updateGroupDetails = updateGroupDetails
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
                net.Start("liaGroupsRequest")
                net.SendToServer()
            end
        }
    end)
end
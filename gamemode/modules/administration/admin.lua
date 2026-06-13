lia.admin = lia.admin or {}
lia.admin.groups = lia.admin.groups or {}
lia.admin.privileges = lia.admin.privileges or {}
lia.admin.privilegeCategories = lia.admin.privilegeCategories or {}
lia.admin.privilegeNames = lia.admin.privilegeNames or {}
lia.admin.privilegeAliases = lia.admin.privilegeAliases or {}
lia.admin.externalPrivilegeNames = lia.admin.externalPrivilegeNames or {}
lia.admin.externalPrivilegeIDsByName = lia.admin.externalPrivilegeIDsByName or {}
lia.admin.missingGroups = lia.admin.missingGroups or {}
lia.admin._lastSyncPrivilegeCount = lia.admin._lastSyncPrivilegeCount or 0
lia.admin._lastSyncGroupCount = lia.admin._lastSyncGroupCount or 0
lia.admin.DefaultGroups = {
    user = 1,
    admin = 2,
    superadmin = 3
}

function lia.admin.isValidGroup(groupName)
    local group = string.Trim(tostring(groupName or ""))
    if group == "" then return false end
    local groups = lia.admin.groups or {}
    local defaultGroups = lia.admin.DefaultGroups or {}
    return groups[group] ~= nil or defaultGroups[group] ~= nil
end

function lia.admin.getDefaultUserGroup()
    local fallbackGroup = "user"
    local configuredGroup = string.Trim(tostring(lia.config and lia.config.get and lia.config.get("DefaultUserGroup", fallbackGroup) or fallbackGroup))
    if lia.admin.isValidGroup(configuredGroup) then return configuredGroup end
    return fallbackGroup
end

function lia.admin.shouldShowUsergroupIcons()
    return lia.config and lia.config.get and lia.config.get("ShowUsergroupIcons", true) or true
end

function lia.admin.getUsergroupIcon(groupOrPlayer)
    if not lia.admin.shouldShowUsergroupIcons() then return nil end
    local groupName = groupOrPlayer
    if IsValid(groupOrPlayer) and groupOrPlayer:IsPlayer() then
        groupName = groupOrPlayer:GetUserGroup()
    end

    groupName = string.Trim(tostring(groupName or ""))
    if groupName == "" then return "icon16/group.png" end
    local groupData = lia.admin.groups and lia.admin.groups[groupName] or nil
    local info = istable(groupData) and groupData._info or nil
    return hook.Run("GetUsergroupIcon", groupName, groupData, groupOrPlayer) or info and info.icon or groupData and groupData.icon or "icon16/group.png"
end

hook.Add("GetUsergroupIcon", "liaAdminDefaultUsergroupIcon", function(groupName)
    local normalizedGroup = string.lower(string.Trim(tostring(groupName or "")))
    if normalizedGroup == "superadmin" then
        return "icon16/shield.png"
    elseif normalizedGroup == "admin" then
        return "icon16/star.png"
    elseif normalizedGroup == "user" then
        return "icon16/user.png"
    end
end)

lia.config.add("DefaultUserGroup", "Default User Group", "user", nil, {
    desc = "Usergroup assigned to players when Lilia does not already have one stored for their SteamID.",
    category = "@userGroups",
    type = "Generic",
    options = function()
        local options = {}
        for groupName in pairs(lia.admin.groups or {}) do
            options[#options + 1] = groupName
        end

        table.sort(options, function(a, b) return tostring(a):lower() < tostring(b):lower() end)
        return options
    end
})

lia.config.add("ShowUsergroupIcons", "OOC/LOOC Icon Message", true, nil, {
    desc = "Displays icon16 usergroup icons in OOC/LOOC messages and usergroup tabs.",
    category = "@userGroups",
    type = "Boolean"
})

local defaultUserTools = {
    remover = true,
}

local camiPathExceptions = {"lua/sam/",}
local function isBundledCamiCompatibility(path)
    local normalizedPath = path:gsub("\\", "/"):lower()
    if normalizedPath == "lilia/gamemode/core/libraries/compatibility/cami.lua" or normalizedPath:find("/core/libraries/compatibility/cami.lua", 1, true) ~= nil then return true end
    for _, exception in ipairs(camiPathExceptions) do
        if normalizedPath:find(exception, 1, true) ~= nil then return true end
    end
    return false
end

local function findCamiConflictFiles()
    local matches = {}
    local seen = {}
    local function addMatch(path)
        local normalizedPath = path:gsub("\\", "/"):lower()
        if seen[normalizedPath] then return end
        if isBundledCamiCompatibility(path) then return end
        seen[normalizedPath] = true
        matches[#matches + 1] = path
    end

    local function scanTarget(baseDir, searchPath)
        local function recurse(currentDir)
            local files, folders = file.Find(currentDir .. "*", searchPath)
            if not files then return end
            folders = folders or {}
            for _, fileName in ipairs(files) do
                local normalizedName = string.lower(fileName)
                if normalizedName == "sh_cami.lua" or normalizedName == "cami.lua" then addMatch(baseDir .. fileName) end
            end

            for _, folderName in ipairs(folders) do
                recurse(currentDir .. folderName .. "/")
            end
        end

        recurse(baseDir)
    end

    local schema = engine.ActiveGamemode()
    if schema and schema ~= "" then scanTarget("gamemodes/" .. schema .. "/", "GAME") end
    for _, addon in ipairs(engine.GetAddons() or {}) do
        if addon and addon.title and addon.title:lower() ~= "lilia" then scanTarget(addon.baseDir or "", addon.title) end
    end

    local files, _ = file.Find("lua/*", "GAME")
    for _, fileName in ipairs(files or {}) do
        local normalizedName = string.lower(fileName)
        if normalizedName == "sh_cami.lua" or normalizedName == "cami.lua" then addMatch("lua/" .. fileName) end
    end

    local function scanLuaDirectories(baseDir)
        local dirFiles, dirFolders = file.Find(baseDir .. "*", "GAME")
        for _, fileName in ipairs(dirFiles or {}) do
            local normalizedName = string.lower(fileName)
            if normalizedName == "sh_cami.lua" or normalizedName == "cami.lua" then addMatch(baseDir .. fileName) end
        end

        for _, directoryName in ipairs(dirFolders or {}) do
            scanLuaDirectories(baseDir .. directoryName .. "/")
        end
    end

    scanLuaDirectories("lua/")
    table.sort(matches, function(a, b) return a:lower() < b:lower() end)
    return matches
end

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

local function warnBaseGroupMutation(groupName, permission, action, source)
    lia.warning(string.format("[Lilia] Refused to %s base usergroup '%s'%s%s. Base groups are immutable and will be reset to default behavior.", tostring(action or "modify"), tostring(groupName), permission and permission ~= "" and (" for privilege '" .. tostring(permission) .. "'") or "", source and source ~= "" and (" (source: " .. tostring(source) .. ")") or ""))
end

local function sanitizeBaseGroups(groups, source)
    groups = groups or {}
    local changed = false
    for groupName in pairs(lia.admin.DefaultGroups or {}) do
        local groupData = groups[groupName]
        if groupData then
            for key in pairs(groupData) do
                if key ~= "_info" then
                    groupData[key] = nil
                    changed = true
                end
            end
        end
    end

    if changed then lia.debug("[Permissions]", "Sanitized base usergroups", "source=", tostring(source or "unknown")) end
    return changed
end

ensureDefaults(lia.admin.groups)
local privilegeCategoryCache = {}
local protectedStaffCommands = {
    kick = true,
    ban = true,
    mute = true,
    unmute = true,
    gag = true,
    ungag = true,
    freeze = true,
    unfreeze = true,
    slay = true,
    kill = true,
    bring = true,
    ["return"] = true,
    jail = true,
    unjail = true,
    cloak = true,
    uncloak = true,
    god = true,
    ungod = true,
    ignite = true,
    extinguish = true,
    unignite = true,
    strip = true,
    respawn = true,
    blind = true,
    unblind = true
}

function lia.admin.isProtectedStaffTarget(cmd, target)
    local protectedCommand = protectedStaffCommands[string.lower(tostring(cmd or ""))] or false
    local validTarget = IsValid(target)
    local targetIsPlayer = validTarget and target:IsPlayer() or false
    local targetIsStaffOnDuty = targetIsPlayer and target:isStaffOnDuty() or false
    local permission = protectedCommand and validTarget and targetIsPlayer and targetIsStaffOnDuty or false
    lia.debug("[Permissions]", "Permission Check for function lia.admin.isProtectedStaffTarget", "commandProtected=", tostring(protectedCommand), "targetValid=", tostring(validTarget), "targetIsPlayer=", tostring(targetIsPlayer), "targetIsStaffOnDuty=", tostring(targetIsStaffOnDuty), "finalResult=", tostring(permission))
    return permission
end

function lia.admin.notifyProtectedStaffTarget(admin)
    if IsValid(admin) then admin:notifyErrorLocalized("staffFactionCommandBlocked") end
end

function getPrivilegeCategory(privilegeName)
    if not privilegeName then return lia.lang.resolveToken("@unassigned") end
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
    if lia.admin and lia.admin.privilegeCategories and lia.admin.privilegeCategories[privilegeName] then
        category = lia.admin.privilegeCategories[privilegeName]
    elseif lia.command and lia.command.list and lia.command.list[privilegeName] then
        category = lia.lang.resolveToken("@staffPermissions")
    else
        for _, module in pairs(lia.module.list) do
            if module.Privileges and istable(module.Privileges) then
                for privID, priv in pairs(module.Privileges) do
                    if privID == privilegeName then
                        category = lia.lang.resolveToken(priv.Category or module.name or "@unassigned")
                        break
                    end
                end
            end

            if category then break end
        end
    end

    if not category and CAMI then
        local camiPriv = CAMI.GetPrivilege(privilegeName)
        if camiPriv and camiPriv.Category then category = lia.lang.resolveToken(camiPriv.Category) end
    end

    if not category then
        for _, check in ipairs(categoryChecks) do
            if check.match(privilegeName) then
                category = lia.lang.resolveToken("@" .. check.category)
                break
            end
        end
    end

    if not category then category = lia.lang.resolveToken("@unassigned") end
    privilegeCategoryCache[privilegeName] = category
    return category
end

local function clearPrivilegeCategoryCache()
    privilegeCategoryCache = {}
end

function lia.admin.getExternalPrivilegeName(id)
    id = tostring(id or "")
    if id == "" then return "" end
    if lia.admin.externalPrivilegeNames and lia.admin.externalPrivilegeNames[id] then return lia.admin.externalPrivilegeNames[id] end
    local displayName = lia.admin.privilegeNames and lia.admin.privilegeNames[id] or id
    local externalName = tostring(displayName or id)
    local owner = lia.admin.externalPrivilegeIDsByName and lia.admin.externalPrivilegeIDsByName[externalName] or nil
    if owner and owner ~= id then externalName = string.format("%s (%s)", externalName, id) end
    lia.admin.externalPrivilegeNames[id] = externalName
    lia.admin.externalPrivilegeIDsByName[externalName] = id
    lia.admin.privilegeAliases[externalName] = id
    return externalName
end

function lia.admin.normalizePrivilege(privilege)
    privilege = tostring(privilege or "")
    if privilege == "" then return privilege end
    if lia.admin.privileges and lia.admin.privileges[privilege] ~= nil then return privilege end
    return lia.admin.privilegeAliases and lia.admin.privilegeAliases[privilege] or privilege
end

local groupLevelCache = {}
local function clearGroupLevelCache()
    groupLevelCache = {}
end

local function getGroupLevel(group)
    if groupLevelCache[group] ~= nil then return groupLevelCache[group] end
    local levels = lia.admin.DefaultGroups or {}
    if levels[group] then
        groupLevelCache[group] = levels[group]
        return levels[group]
    end

    local visited, current = {}, group
    for _ = 1, 16 do
        if visited[current] then break end
        visited[current] = true
        local g = lia.admin.groups and lia.admin.groups[current]
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
    local levels = lia.admin.DefaultGroups or {}
    local m = tostring(min or "user"):lower()
    return getGroupLevel(group) >= (levels[m] or 1)
end

local targetedCommandPrivilegeMap = {
    kick = "command_plykick",
    ban = "command_plyban",
    unban = "command_plyunban",
    kill = "command_plykill",
    freeze = "command_plyfreeze",
    unfreeze = "command_plyunfreeze",
    slay = "command_plyslay",
    respawn = "command_plyrespawn",
    blind = "command_plyblind",
    unblind = "command_plyunblind",
    gag = "command_plygag",
    ungag = "command_plyungag",
    mute = "command_plymute",
    unmute = "command_plyunmute",
    bring = "command_plybring",
    ["goto"] = "command_plygoto",
    ["return"] = "command_plyreturn",
    jail = "command_plyjail",
    unjail = "command_plyunjail",
    cloak = "command_plycloak",
    uncloak = "command_plyuncloak",
    god = "command_plygod",
    ungod = "command_plyungod",
    ignite = "command_plyignite",
    extinguish = "command_plyextinguish",
    strip = "command_plystrip"
}

function lia.admin.getCommandPrivilegeID(cmd)
    cmd = string.lower(tostring(cmd or ""))
    if cmd == "" then return nil end
    return targetedCommandPrivilegeMap[cmd] or "command_" .. cmd
end

local function rebuildPrivileges()
    lia.admin.privileges = lia.admin.privileges or {}
    local rebuildCache = {}
    local function getCachedGroupLevel(groupName)
        if rebuildCache[groupName] == nil then rebuildCache[groupName] = getGroupLevel(groupName) end
        return rebuildCache[groupName]
    end

    for groupName, perms in pairs(lia.admin.groups or {}) do
        local groupLevel = getCachedGroupLevel(groupName)
        for priv, allowed in pairs(perms) do
            if priv ~= "_info" and allowed == true then
                local current = lia.admin.privileges[priv]
                local currentLevel = current and getCachedGroupLevel(current) or 0
                if not current or groupLevel > currentLevel then
                    local base
                    for name, lvl in pairs(lia.admin.DefaultGroups or {}) do
                        if lvl == groupLevel then
                            base = name
                            break
                        end
                    end

                    if base then lia.admin.privileges[priv] = base end
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
    if CAMI then
        local externalName = lia.admin.getExternalPrivilegeName(name)
        if name ~= externalName and CAMI.GetPrivilege(name) then
            lia.admin._suppressCamiPrivilegeHooks = true
            CAMI.UnregisterPrivilege(name)
            lia.admin._suppressCamiPrivilegeHooks = false
        end

        if CAMI.GetPrivilege(externalName) then return end
        lia.admin._suppressCamiPrivilegeHooks = true
        CAMI.RegisterPrivilege({
            Name = externalName,
            MinAccess = tostring(min or "user"):lower()
        })

        lia.admin._suppressCamiPrivilegeHooks = false
    end
end

local function camiBootstrapFromExisting()
    if not CAMI then return end
    for _, ug in ipairs(CAMI.GetUsergroups() or {}) do
        local n = ug.Name
        local inh = ug.Inherits or "user"
        lia.admin.groups[n] = lia.admin.groups[n] or {
            _info = {
                inheritance = inh,
                types = {}
            }
        }

        lia.admin.applyInheritance(n)
    end

    for _, pr in ipairs(CAMI.GetPrivileges() or {}) do
        local n = pr.Name
        local m = tostring(pr.MinAccess or "user"):lower()
        if lia.admin.privileges[n] == nil then
            lia.admin.privileges[n] = m
            clearPrivilegeCategoryCache()
            for g in pairs(lia.admin.groups or {}) do
                if shouldGrant(g, m) then lia.admin.groups[g][n] = true end
            end
        end
    end

    rebuildPrivileges()
end

function lia.admin.applyPunishment(client, infraction, kick, ban, time, kickKey, banKey)
    local bantime = time or 0
    kickKey = kickKey or "kickedForInfraction"
    banKey = banKey or "bannedForInfraction"
    if kick then lia.admin.execCommand("kick", client, nil, L(kickKey, infraction)) end
    if ban then lia.admin.execCommand("ban", client, bantime, L(banKey, infraction)) end
end

function lia.admin.hasAccess(ply, privilege)
    if not isstring(privilege) then
        lia.error(L("hasAccessExpectedString", tostring(privilege)))
        return false
    end

    privilege = lia.admin.normalizePrivilege(privilege)
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

    if not lia.admin.privileges[privilege] then
        if privilege:find("^property_") and properties and properties.List then
            local propName = privilege:sub(10)
            local prop = properties.List[propName]
            if prop then
                lia.admin.registerPrivilege({
                    Name = L("accessPropertyPrivilege", prop.MenuLabel or propName),
                    ID = privilege,
                    MinAccess = "admin",
                    Category = "@staffPermissions",
                })
            end
        elseif privilege:find("^tool_") then
            local toolName = privilege:sub(6)
            for _, wep in ipairs(weapons.GetList()) do
                if wep.ClassName == "gmod_tool" and wep.Tool and wep.Tool[toolName] then
                    lia.admin.registerPrivilege({
                        Name = L("accessToolPrivilege", toolName:gsub("^%l", string.upper)),
                        ID = privilege,
                        MinAccess = defaultUserTools[string.lower(toolName)] and "user" or "admin",
                        Category = "@staffPermissions",
                    })

                    break
                end
            end
        end
    end

    local groupLevel = getGroupLevel(grp)
    local defaultGroups = lia.admin.DefaultGroups or {}
    local superadminLevel = defaultGroups.superadmin or 3
    local adminLevel = defaultGroups.admin or 3
    if not lia.admin.privileges[privilege] then
        if SERVER then
            local playerInfo = IsValid(ply) and ply:Nick() .. " (" .. ply:SteamID() .. ")" or "Unknown"
            lia.log.add(ply, "missingPrivilege", privilege, playerInfo, grp)
        end
        return groupLevel >= adminLevel
    end

    if groupLevel >= superadminLevel then return true end
    local g = lia.admin.groups and lia.admin.groups[grp] or nil
    if g and g[privilege] == true then return true end
    if g and g[privilege] == false then return false end
    local min = lia.admin.privileges[privilege]
    return shouldGrant(grp, min)
end

function lia.admin.save(noNetwork)
    sanitizeBaseGroups(lia.admin.groups, "lia.admin.save")
    rebuildPrivileges()
    local rows = {}
    for name, data in pairs(lia.admin.groups) do
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
    if noNetwork or lia.admin._loading then return end
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
    lia.admin.sync()
end

function lia.admin.registerPrivilege(priv)
    if not priv or not priv.ID then
        lia.error(L("privilegeRegistrationError"))
        return
    end

    local id = tostring(priv.ID)
    if id == "" then return end
    if lia.admin.privileges[id] ~= nil then return end
    local min = tostring(priv.MinAccess or "user"):lower()
    lia.admin.privileges[id] = min
    lia.admin.privilegeNames[id] = lia.lang.resolveToken(priv.Name or priv.ID)
    lia.admin.privilegeAliases[id] = id
    lia.admin.getExternalPrivilegeName(id)
    clearPrivilegeCategoryCache()
    if priv.Category then lia.admin.privilegeCategories[id] = lia.lang.resolveToken(priv.Category) end
    local defaultGroups = lia.admin.DefaultGroups or {}
    local minLevel = defaultGroups[tostring(min):lower()] or 1
    for groupName, perms in pairs(lia.admin.groups) do
        perms = perms or {}
        lia.admin.groups[groupName] = perms
        if not defaultGroups[groupName] and getGroupLevel(groupName) >= minLevel then perms[id] = true end
    end

    local name = lia.admin.privilegeNames[id]
    if CAMI then camiRegisterPrivilege(priv.ID, min) end
    local category = getPrivilegeCategory(id)
    hook.Run("OnPrivilegeRegistered", {
        Name = name,
        ID = priv.ID,
        MinAccess = min,
        Category = category
    })

    if SERVER then lia.admin.save() end
end

function lia.admin.unregisterPrivilege(id)
    id = tostring(id or "")
    if id == "" or lia.admin.privileges[id] == nil then return end
    local externalName = lia.admin.externalPrivilegeNames and lia.admin.externalPrivilegeNames[id] or nil
    lia.admin.privileges[id] = nil
    clearPrivilegeCategoryCache()
    lia.admin.privilegeCategories[id] = nil
    lia.admin.privilegeNames[id] = nil
    lia.admin.externalPrivilegeNames[id] = nil
    lia.admin.privilegeAliases[id] = nil
    if externalName then
        lia.admin.externalPrivilegeIDsByName[externalName] = nil
        lia.admin.privilegeAliases[externalName] = nil
    end

    for _, perms in pairs(lia.admin.groups or {}) do
        perms[id] = nil
    end

    if CAMI then
        if externalName then CAMI.UnregisterPrivilege(externalName) end
        if externalName ~= id then CAMI.UnregisterPrivilege(id) end
    end

    hook.Run("OnPrivilegeUnregistered", {
        Name = id,
        ID = id
    })

    if SERVER then lia.admin.save() end
end

function lia.admin.applyInheritance(groupName)
    local groups = lia.admin.groups or {}
    local g = groups[groupName]
    if not g then return end
    if lia.admin.DefaultGroups[groupName] then
        sanitizeBaseGroups(groups, "lia.admin.applyInheritance:" .. tostring(groupName))
        clearGroupLevelCache()
        return
    end

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
    local defaultGroups = lia.admin.DefaultGroups or {}
    for priv, min in pairs(lia.admin.privileges or {}) do
        local m = tostring(min or "user"):lower()
        if g[priv] == nil and groupLevel >= (defaultGroups[m] or 1) then g[priv] = true end
    end

    clearGroupLevelCache()
end

function lia.admin.load()
    local function continueLoad(groups)
        lia.admin.groups = groups or {}
        if CAMI then
            for n, t in pairs(lia.admin.groups) do
                camiRegisterUsergroup(n, t._info and t._info.inheritance or "user")
            end

            for n, m in pairs(lia.admin.privileges or {}) do
                camiRegisterPrivilege(n, m)
            end

            camiBootstrapFromExisting()
        end

        MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("admin") .. "] ")
        MsgC(Color(255, 153, 0), L("adminSystemLoaded"), "\n")
        clearGroupLevelCache()
        hook.Run("OnAdminSystemLoaded", lia.admin.groups or {}, lia.admin.privileges or {})
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
        lia.admin._loading = true
        lia.admin.groups = groups
        for n in pairs(groups) do
            lia.admin.applyInheritance(n)
        end

        local sanitized = sanitizeBaseGroups(lia.admin.groups, "lia.admin.load")
        rebuildPrivileges()
        if created or sanitized then lia.admin.save(true) end
        lia.admin._loading = false
        continueLoad(groups)
    end)
end

function lia.admin.createGroup(groupName, info)
    if lia.admin.groups[groupName] then
        lia.error(L("usergroupExists"))
        return
    end

    info = info or {}
    info._info = info._info or {
        inheritance = "user",
        types = {}
    }

    lia.admin.groups[groupName] = info
    lia.admin.missingGroups[groupName] = nil
    lia.admin.applyInheritance(groupName)
    camiRegisterUsergroup(groupName, info._info.inheritance or "user")
    clearGroupLevelCache()
    hook.Run("OnUsergroupCreated", groupName, lia.admin.groups[groupName])
    if SERVER then lia.admin.save() end
end

function lia.admin.removeGroup(groupName)
    if groupName == "user" or groupName == "admin" or groupName == "superadmin" then
        lia.error(L("baseUsergroupCannotBeRemoved"))
        return
    end

    if not lia.admin.groups[groupName] then
        lia.error(L("usergroupDoesntExist", groupName))
        return
    end

    lia.admin.groups[groupName] = nil
    camiUnregisterUsergroup(groupName)
    clearGroupLevelCache()
    hook.Run("OnUsergroupRemoved", groupName)
    if SERVER then lia.admin.save() end
end

function lia.admin.renameGroup(oldName, newName)
    if lia.admin.DefaultGroups[oldName] then
        lia.error(L("baseUsergroupCannotBeRenamed"))
        return
    end

    if not lia.admin.groups[oldName] then
        lia.error(L("usergroupDoesntExist", oldName))
        return
    end

    if lia.admin.groups[newName] then
        lia.error(L("usergroupExists"))
        return
    end

    lia.admin.groups[newName] = lia.admin.groups[oldName]
    lia.admin.groups[oldName] = nil
    lia.admin.missingGroups[oldName] = nil
    lia.admin.missingGroups[newName] = nil
    lia.admin.applyInheritance(newName)
    camiUnregisterUsergroup(oldName)
    local inh = lia.admin.groups[newName]._info and lia.admin.groups[newName]._info.inheritance or "user"
    camiRegisterUsergroup(newName, inh)
    clearGroupLevelCache()
    hook.Run("OnUsergroupRenamed", oldName, newName)
    if SERVER then lia.admin.save() end
end

if SERVER then
    function lia.admin.notifyAdmin(notification)
        for _, client in player.Iterator() do
            local permission = IsValid(client) and client:hasPrivilege("canSeeAltingNotifications") or false
            if permission then client:notifyAdminLocalized(notification) end
        end
    end

    function lia.admin.addPermission(groupName, permission, silent)
        permission = lia.admin.normalizePrivilege(permission)
        if not lia.admin.groups[groupName] then
            if lia.admin._loading then return end
            if not lia.admin.missingGroups[groupName] then
                lia.admin.missingGroups[groupName] = true
                lia.error(L("usergroupDoesntExist", groupName))
            end
            return
        end

        if lia.admin.DefaultGroups[groupName] then
            warnBaseGroupMutation(groupName, permission, "grant", "lia.admin.addPermission")
            sanitizeBaseGroups(lia.admin.groups, "lia.admin.addPermission")
            return
        end

        lia.admin.groups[groupName][permission] = true
        lia.admin.save(silent and true or false)
        hook.Run("OnUsergroupPermissionsChanged", groupName, lia.admin.groups[groupName])
    end

    function lia.admin.removePermission(groupName, permission, silent)
        permission = lia.admin.normalizePrivilege(permission)
        if not lia.admin.groups[groupName] then
            if lia.admin._loading then return end
            if not lia.admin.missingGroups[groupName] then
                lia.admin.missingGroups[groupName] = true
                lia.error(L("usergroupDoesntExist", groupName))
            end
            return
        end

        if lia.admin.DefaultGroups[groupName] then
            warnBaseGroupMutation(groupName, permission, "revoke", "lia.admin.removePermission")
            sanitizeBaseGroups(lia.admin.groups, "lia.admin.removePermission")
            return
        end

        lia.admin.groups[groupName][permission] = false
        lia.admin.save(silent and true or false)
        hook.Run("OnUsergroupPermissionsChanged", groupName, lia.admin.groups[groupName])
    end

    function lia.admin.sync(c)
        lia.net.ready = lia.net.ready or setmetatable({}, {
            __mode = "k"
        })

        local function push(ply)
            if not IsValid(ply) then return end
            if not lia.net.ready[ply] then return end
            lia.net.writeBigTable(ply, "liaUpdateAdminPrivileges", {
                privileges = lia.admin.privileges or {},
                names = lia.admin.privilegeNames or {}
            })

            timer.Simple(0.05, function() if IsValid(ply) and lia.net.ready[ply] then lia.net.writeBigTable(ply, "liaUpdateAdminGroups", lia.admin.groups or {}) end end)
        end

        if c and IsValid(c) then
            push(c)
            return
        end

        lia.admin._lastSyncPrivilegeCount = table.Count(lia.admin.privileges)
        lia.admin._lastSyncGroupCount = table.Count(lia.admin.groups)
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

    function lia.admin.hasChanges()
        local currentPrivilegeCount = table.Count(lia.admin.privileges)
        local currentGroupCount = table.Count(lia.admin.groups)
        return currentPrivilegeCount ~= lia.admin._lastSyncPrivilegeCount or currentGroupCount ~= lia.admin._lastSyncGroupCount
    end

    function lia.admin.setPlayerUsergroup(ply, newGroup, source)
        if not IsValid(ply) then return end
        lia.admin.setSteamIDUsergroup(ply:SteamID(), newGroup, source)
    end

    function lia.admin.setSteamIDUsergroup(steamId, newGroup, source)
        local sid = string.Trim(tostring(steamId or ""))
        if sid == "" or not string.match(sid, "^STEAM_%d+:%d+:%d+$") then return end
        local hasExplicitGroup = string.Trim(tostring(newGroup or "")) ~= ""
        local new = hasExplicitGroup and tostring(newGroup) or lia.admin.getDefaultUserGroup()
        if not lia.admin.isValidGroup(new) then return end
        local ply = lia.util.getBySteamID(sid)
        local old = IsValid(ply) and tostring(ply:GetUserGroup() or lia.admin.getDefaultUserGroup()) or lia.admin.getDefaultUserGroup()
        if old == new then return end
        lia.debug("[Permissions]", "setSteamIDUsergroup called", "steamID=", tostring(sid), "oldGroup=", tostring(old), "newGroup=", tostring(new), "source=", tostring(source), "playerValid=", tostring(IsValid(ply)), "isDefaultNewGroup=", tostring(lia.admin.DefaultGroups and lia.admin.DefaultGroups[new] ~= nil), "newGroupExistsInLilia=", tostring(lia.admin.groups and lia.admin.groups[new] ~= nil))
        if IsValid(ply) then ply:SetUserGroup(new) end
        if CAMI then CAMI.SignalSteamIDUserGroupChanged(sid, old, new, source or "Lilia") end
        hook.Run("OnSetUsergroup", sid, new, source, ply)
    end

    function lia.admin.serverExecCommand(cmd, victim, dur, reason, admin)
        local isConsoleAdmin = not IsValid(admin)
        local adminName = isConsoleAdmin and "Console" or admin:Name()
        local adminSteamID = isConsoleAdmin and "CONSOLE" or admin:SteamID()
        local target
        local function notifyAdmin(kind, key, ...)
            if not isstring(key) or key == "" then return end
            if IsValid(admin) then
                if kind == "error" then
                    admin:notifyErrorLocalized(key, ...)
                else
                    admin:notifySuccessLocalized(key, ...)
                end
            elseif SERVER then
                print("[Lilia] " .. tostring(L(key, ...)))
            end
        end

        local function logAdminAction(logType, ...)
            if IsValid(admin) then
                lia.log.add(admin, logType, ...)
            else
                lia.log.add(nil, "command", string.format("Console executed %s on %s", tostring(cmd), IsValid(target) and target:Name() or tostring(victim)))
            end
        end

        local privilegeID = lia.admin.getCommandPrivilegeID(cmd)
        if not isConsoleAdmin and not lia.admin.hasAccess(admin, privilegeID) then
            notifyAdmin("error", "noPerm")
            lia.log.add(admin, "unauthorizedCommand", cmd)
            return false
        end

        local function staffAction(tag, text)
            StaffAddTextShadowed(Color(255, 215, 0), tag, Color(255, 255, 255), text)
        end

        if IsValid(victim) then
            target = victim
        elseif isstring(victim) then
            target = lia.util.findPlayer(admin, victim)
        end

        if not IsValid(target) then
            notifyAdmin("error", "targetNotFound")
            return false
        end

        if lia.admin.isProtectedStaffTarget(cmd, target) then
            notifyAdmin("error", "staffFactionCommandBlocked")
            return false
        end

        local targetInfo = L("staffLogPlayerSteam64", target:Name(), target:SteamID64())
        if cmd == "kick" then
            target:Kick(reason or L("genericReason"))
            notifyAdmin("success", "plyKicked")
            logAdminAction("plyKick", target:Name())
            staffAction("KICK", L("staffActionKicked", adminName, target:Name(), target:SteamID64()))
            lia.db.insertTable({
                player = target:Name(),
                playerSteamID = target:SteamID(),
                steamID = target:SteamID(),
                action = "plykick",
                staffName = adminName,
                staffSteamID = adminSteamID,
                timestamp = os.time()
            }, nil, "staffactions")
            return true
        elseif cmd == "ban" then
            target:banPlayer(reason, tonumber(dur) or 0, admin)
            notifyAdmin("success", "plyBanned")
            logAdminAction("plyBan", target:Name())
            staffAction("BAN", L("staffActionBanned", adminName, target:Name(), target:SteamID64()))
            return true
        elseif cmd == "unban" then
            local steamid = IsValid(target) and target:SteamID() or tostring(victim)
            if steamid and steamid ~= "" then
                lia.db.query("DELETE FROM lia_bans WHERE playerSteamID = " .. lia.db.convertDataType(steamid))
                notifyAdmin("success", "playerUnbanned")
                logAdminAction("plyUnban", steamid)
                staffAction("UNBAN", L("staffActionUnbannedSteamID", adminName, steamid))
                return true
            end
        elseif cmd == "mute" then
            if target:getChar() then
                target:setLiliaData("liaMuted", true)
                notifyAdmin("success", "plyMuted")
                logAdminAction("plyMute", target:Name())
                lia.db.insertTable({
                    player = target:Name(),
                    playerSteamID = target:SteamID(),
                    steamID = target:SteamID(),
                    action = "plymute",
                    staffName = adminName,
                    staffSteamID = adminSteamID,
                    timestamp = os.time()
                }, nil, "staffactions")

                staffAction("MUTE", L("staffActionMuted", adminName, target:Name(), target:SteamID64()))
                hook.Run("PlayerMuted", target, admin)
                return true
            end
        elseif cmd == "unmute" then
            if target:getChar() then
                target:setLiliaData("liaMuted", false)
                notifyAdmin("success", "plyUnmuted")
                logAdminAction("plyUnmute", target:Name())
                staffAction("UNMUTE", L("staffActionUnmuted", adminName, target:Name(), target:SteamID64()))
                hook.Run("PlayerUnmuted", target, admin)
                return true
            end
        elseif cmd == "gag" then
            target:setLiliaData("liaGagged", true)
            notifyAdmin("success", "plyGagged")
            logAdminAction("plyGag", target:Name())
            staffAction("GAG", adminName .. " gagged " .. targetInfo)
            hook.Run("PlayerGagged", target, admin)
            return true
        elseif cmd == "ungag" then
            target:setLiliaData("liaGagged", false)
            notifyAdmin("success", "plyUngagged")
            logAdminAction("plyUngag", target:Name())
            staffAction("UNGAG", adminName .. " ungagged " .. targetInfo)
            hook.Run("PlayerUngagged", target, admin)
            return true
        elseif cmd == "freeze" then
            target:Freeze(true)
            local duration = tonumber(dur) or 0
            if duration > 0 then timer.Simple(duration, function() if IsValid(target) then target:Freeze(false) end end) end
            notifyAdmin("success", "plyFrozen", target:Name())
            logAdminAction("plyFreeze", target:Name(), duration)
            staffAction("FREEZE", adminName .. " froze " .. targetInfo)
            return true
        elseif cmd == "unfreeze" then
            target:Freeze(false)
            notifyAdmin("success", "plyUnfrozen", target:Name())
            logAdminAction("plyUnfreeze", target:Name())
            staffAction("UNFREEZE", adminName .. " unfroze " .. targetInfo)
            return true
        elseif cmd == "slay" then
            target:Kill()
            timer.Simple(0.05, function() if IsValid(target) and not target:Alive() then hook.Run("PlayerDeath", target, nil, admin) end end)
            notifyAdmin("success", "plyKilled")
            logAdminAction("plySlay", target:Name())
            staffAction("SLAY", adminName .. " slayed " .. targetInfo)
            return true
        elseif cmd == "kill" then
            target:Kill()
            notifyAdmin("success", "plyKilled")
            logAdminAction("plyKill", target:Name())
            lia.db.insertTable({
                player = target:Name(),
                playerSteamID = target:SteamID(),
                steamID = target:SteamID(),
                action = "plykill",
                staffName = adminName,
                staffSteamID = adminSteamID,
                timestamp = os.time()
            }, nil, "staffactions")

            staffAction("KILL", adminName .. " killed " .. targetInfo)
            return true
        elseif cmd == "bring" then
            if isConsoleAdmin then
                print("[Lilia] lia_plybring cannot be used from the server console.")
                return false
            end

            returnPositions = returnPositions or {}
            returnPositions[target] = target:GetPos()
            target:SetPos(admin:GetPos() + admin:GetForward() * 50)
            notifyAdmin("success", "plyBrought", target:Name())
            logAdminAction("plyBring", target:Name())
            staffAction("BRING", adminName .. " brought " .. targetInfo)
            return true
        elseif cmd == "goto" then
            if isConsoleAdmin then
                print("[Lilia] lia_plygoto cannot be used from the server console.")
                return false
            end

            returnPositions = returnPositions or {}
            returnPositions[admin] = admin:GetPos()
            admin:SetPos(target:GetPos() + target:GetForward() * 50)
            notifyAdmin("success", "plyGoto", target:Name())
            logAdminAction("plyGoto", target:Name())
            staffAction("GOTO", adminName .. " went to " .. targetInfo)
            return true
        elseif cmd == "return" then
            returnPositions = returnPositions or {}
            local pos = returnPositions[target] or returnPositions[admin]
            if pos then
                (IsValid(target) and target or admin):SetPos(pos)
                returnPositions[target] = nil
                returnPositions[admin] = nil
                notifyAdmin("success", "plyReturned", IsValid(target) and target:Name() or adminName)
                logAdminAction("plyReturn", IsValid(target) and target:Name() or adminName)
                staffAction("RETURN", adminName .. " returned " .. targetInfo)
                return true
            end
        elseif cmd == "jail" then
            target:Lock()
            target:Freeze(true)
            notifyAdmin("success", "plyJailed", target:Name())
            logAdminAction("plyJail", target:Name())
            lia.db.insertTable({
                player = target:Name(),
                playerSteamID = target:SteamID(),
                steamID = target:SteamID(),
                action = "plyjail",
                staffName = adminName,
                staffSteamID = adminSteamID,
                timestamp = os.time()
            }, nil, "staffactions")

            staffAction("JAIL", adminName .. " jailed " .. targetInfo)
            return true
        elseif cmd == "unjail" then
            target:UnLock()
            target:Freeze(false)
            notifyAdmin("success", "plyUnjailed", target:Name())
            logAdminAction("plyUnjail", target:Name())
            staffAction("UNJAIL", adminName .. " unjailed " .. targetInfo)
            return true
        elseif cmd == "cloak" then
            target:SetNoDraw(true)
            notifyAdmin("success", "plyCloaked", target:Name())
            logAdminAction("plyCloak", target:Name())
            staffAction("CLOAK", adminName .. " cloaked " .. targetInfo)
            return true
        elseif cmd == "uncloak" then
            target:SetNoDraw(false)
            notifyAdmin("success", "plyUncloaked", target:Name())
            logAdminAction("plyUncloak", target:Name())
            staffAction("UNCLOAK", adminName .. " uncloaked " .. targetInfo)
            return true
        elseif cmd == "god" then
            target:GodEnable()
            notifyAdmin("success", "plyGodded", target:Name())
            logAdminAction("plyGod", target:Name())
            staffAction("GOD", adminName .. " enabled god mode for " .. targetInfo)
            return true
        elseif cmd == "ungod" then
            target:GodDisable()
            notifyAdmin("success", "plyUngodded", target:Name())
            logAdminAction("plyUngod", target:Name())
            staffAction("UNGOD", adminName .. " disabled god mode for " .. targetInfo)
            return true
        elseif cmd == "ignite" then
            local duration = tonumber(dur) or 5
            target:Ignite(duration)
            notifyAdmin("success", "plyIgnited", target:Name())
            logAdminAction("plyIgnite", target:Name(), duration)
            staffAction("IGNITE", adminName .. " ignited " .. targetInfo)
            return true
        elseif cmd == "extinguish" or cmd == "unignite" then
            target:Extinguish()
            notifyAdmin("success", "plyExtinguished", target:Name())
            logAdminAction("plyExtinguish", target:Name())
            staffAction("EXTINGUISH", adminName .. " extinguished " .. targetInfo)
            return true
        elseif cmd == "strip" then
            target:StripWeapons()
            notifyAdmin("success", "plyStripped", target:Name())
            logAdminAction("plyStrip", target:Name())
            lia.db.insertTable({
                player = target:Name(),
                playerSteamID = target:SteamID(),
                steamID = target:SteamID(),
                action = "plystrip",
                staffName = adminName,
                staffSteamID = adminSteamID,
                timestamp = os.time()
            }, nil, "staffactions")

            staffAction("STRIP", adminName .. " stripped weapons from " .. targetInfo)
            return true
        elseif cmd == "respawn" then
            target:Spawn()
            target:setLocalVar("lastDeathTime", 0)
            notifyAdmin("success", "plyRespawned", target:Name())
            logAdminAction("plyRespawn", target:Name())
            lia.db.insertTable({
                player = target:Name(),
                playerSteamID = target:SteamID(),
                steamID = target:SteamID(),
                action = "plyrespawn",
                staffName = adminName,
                staffSteamID = adminSteamID,
                timestamp = os.time()
            }, nil, "staffactions")

            staffAction("RESPAWN", adminName .. " respawned " .. targetInfo)
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

            notifyAdmin("success", "plyBlinded", target:Name())
            logAdminAction("plyBlind", target:Name(), duration)
            lia.db.insertTable({
                player = target:Name(),
                playerSteamID = target:SteamID(),
                steamID = target:SteamID(),
                action = "plyblind",
                staffName = adminName,
                staffSteamID = adminSteamID,
                timestamp = os.time()
            }, nil, "staffactions")

            staffAction("BLIND", adminName .. " blinded " .. targetInfo)
            return true
        elseif cmd == "unblind" then
            net.Start("liaBlindTarget")
            net.WriteBool(false)
            net.Send(target)
            notifyAdmin("success", "plyUnblinded", target:Name())
            logAdminAction("plyUnblind", target:Name())
            staffAction("UNBLIND", adminName .. " unblinded " .. targetInfo)
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

    function lia.admin.execCommand(cmd, victim, dur, reason)
        if lia.admin.isProtectedStaffTarget(cmd, victim) then
            lia.admin.notifyProtectedStaffTarget(LocalPlayer())
            return false
        end

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
            lia.admin.registerPrivilege({
                Name = L("accessPropertyPrivilege", prop.MenuLabel or name),
                ID = id,
                MinAccess = "admin",
                Category = "@staffPermissions"
            })
        end
    end
end

for _, wep in ipairs(weapons.GetList()) do
    if wep.ClassName == "gmod_tool" and wep.Tool then
        for tool in pairs(wep.Tool) do
            local id = "tool_" .. tostring(tool)
            lia.admin.registerPrivilege({
                Name = L("accessToolPrivilege", tool:gsub("^%l", string.upper)),
                ID = id,
                MinAccess = defaultUserTools[string.lower(tool)] and "user" or "admin",
                Category = "@staffPermissions"
            })
        end
    end
end

if SERVER then
    local function ensureStructures()
        lia.admin.groups = lia.admin.groups or {}
        for n in pairs(lia.admin.groups) do
            lia.admin.groups[n] = lia.admin.groups[n] or {}
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
        for name in pairs(lia.admin.privileges or {}) do
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
            IconPNG = "string",
            Staff = "boolean",
            User = "boolean",
            VIP = "boolean"
        }, function(success, data)
            if not success then return end
            local name = string.Trim(tostring(data.Name or ""))
            local icon = string.Trim(tostring(data.IconPNG or ""))
            if name == "" then return end
            local types = {}
            if data.Staff then types[#types + 1] = "Staff" end
            if data.User then types[#types + 1] = "User" end
            if data.VIP then types[#types + 1] = "VIP" end
            net.Start("liaGroupsAdd")
            net.WriteTable({
                name = name,
                inherit = data.Inheritance or "user",
                types = types,
                icon = icon
            })

            net.SendToServer()
        end)
    end

    local function buildPrivilegeList(container, g, groups, editable)
        local current = table.Copy(groups[g] or {})
        current._info = nil
        if not editable then
            local disclaimer = container:Add("DLabel")
            disclaimer:Dock(TOP)
            disclaimer:DockMargin(12, 12, 12, 8)
            disclaimer:SetFont("LiliaFont.17")
            disclaimer:SetTextColor(Color(220, 160, 90))
            disclaimer:SetWrap(true)
            disclaimer:SetAutoStretchVertical(true)
            disclaimer:SetContentAlignment(5)
            disclaimer:SetText(L("baseUsergroupCannotBeEditedDesc"))
        end

        local scrollPanel = container:Add("liaScrollPanel")
        scrollPanel:Dock(FILL)
        local list = scrollPanel:Add("DListLayout")
        list:Dock(TOP)
        list:DockMargin(12, editable and 12 or 4, 12, 12)
        lia.gui.usergroups.checks = lia.gui.usergroups.checks or {}
        lia.gui.usergroups.checks[g] = lia.gui.usergroups.checks[g] or {}
        local function addRow(name)
            local row = list:Add("liaPrivilegeRow")
            row:Dock(TOP)
            row:SetTall(20)
            row:DockMargin(4, 0, 4, 4)
            local explicitValue = current[name]
            local effectiveValue = lia.admin.hasAccess(g, name)
            lia.debug("[Permissions UI]", "Rendering privilege row", "group=", tostring(g), "privilege=", tostring(name), "explicitValue=", tostring(explicitValue), "effectiveValue=", tostring(effectiveValue), "requiredMinAccess=", tostring(lia.admin.privileges and lia.admin.privileges[name] or "nil"), "editable=", tostring(editable))
            row:SetPrivilege(name, effectiveValue, editable)
            if editable then
                row.OnChange = function(_, value)
                    lia.debug("[Permissions UI]", "Privilege row changed", "group=", tostring(g), "privilege=", tostring(name), "previousExplicitValue=", tostring(current[name]), "previousEffectiveValue=", tostring(lia.admin.hasAccess(g, name)), "newRequestedValue=", tostring(value))
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
            else
                local function showBaseRankNotification()
                    LocalPlayer():notifyErrorLocalized("baseUsergroupCannotBeEdited")
                end

                row.OnChange = showBaseRankNotification
                row.DoClick = showBaseRankNotification
                if IsValid(row.checkbox) then row.checkbox.DoClick = showBaseRankNotification end
            end

            lia.gui.usergroups.checks[g][name] = row
        end

        local ordered = computeCategoryMap(groups)
        for _, cat in ipairs(ordered) do
            local categoryLabel = list:Add("DPanel")
            categoryLabel:Dock(TOP)
            categoryLabel:SetTall(28)
            categoryLabel:DockMargin(4, 8, 4, 8)
            categoryLabel:SetPaintBackground(false)
            categoryLabel.Paint = function(panel, w, h)
                local theme = lia.color.theme
                local accent = theme and theme.accent or theme.header or theme.theme or Color(100, 150, 200, 255)
                local bgColor = Color(30, 33, 40, 255)
                lia.derma.rect(0, 0, w, h):Rad(6):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
                lia.derma.rect(0, 0, w, 3):Radii(6, 6, 0, 0):Color(accent):Draw()
                local glowColor = Color(accent.r, accent.g, accent.b, 12)
                lia.derma.rect(1, 1, w - 2, h - 2):Rad(5):Color(glowColor):Outline(1):Draw()
                local textColor = theme and theme.category_text or theme.text or color_white
                local displayText = cat.label
                local localized = L(displayText)
                if localized and localized ~= "" then displayText = localized end
                draw.SimpleText(displayText, "LiliaFont.18", w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            for _, priv in ipairs(cat.items) do
                addRow(priv)
            end
        end

        list:InvalidateLayout(true)
        scrollPanel:InvalidateLayout(true)
    end

    lia.net.readBigTable("liaUpdateAdminGroups", function(tbl)
        lia.admin.groups = tbl
        lia.debug("[Permissions UI]", "Received admin groups sync", "groupCount=", tostring(table.Count(lia.admin.groups or {})))
        if IsValid(lia.gui.usergroups) and lia.gui.usergroups.refreshTabs then lia.gui.usergroups.refreshTabs() end
    end)

    lia.net.readBigTable("liaUpdateAdminPrivileges", function(tbl)
        if tbl and tbl.privileges then
            lia.admin.privileges = tbl.privileges
            lia.admin.privilegeNames = tbl.names or {}
        else
            lia.admin.privileges = tbl
        end

        lia.debug("[Permissions UI]", "Received admin privileges sync", "privilegeCount=", tostring(table.Count(lia.admin.privileges or {})), "hasAlwaysSpawnAdminStick=", tostring(lia.admin.privileges and lia.admin.privileges.alwaysSpawnAdminStick or "nil"))
        hook.Run("AdminPrivilegesUpdated")
    end)

    local function SetupUserGroupInterface(parent)
        local container = parent:Add("DPanel")
        container:Dock(FILL)
        container.Paint = function() end
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
            if lia.admin.DefaultGroups[activeTab.groupName] then
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
            if lia.admin.DefaultGroups[activeTab.groupName] then
                LocalPlayer():notifyErrorLocalized("baseUsergroupCannotBeRemoved")
                return
            end

            LocalPlayer():requestString("@confirm", L("deleteGroupPrompt", activeTab.groupName), function(value)
                local normalizedValue = isstring(value) and value:Trim():lower() or ""
                local localizedYes = string.lower(L("yes"))
                if normalizedValue == localizedYes then
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
            tabPanel.Paint = function() end
            local isDefault = lia.admin.DefaultGroups and lia.admin.DefaultGroups[groupName] ~= nil
            local editable = not isDefault
            lia.debug("[Permissions UI]", "Creating group tab", "group=", tostring(groupName), "isDefaultGroup=", tostring(isDefault), "localPlayerUserGroup=", tostring(IsValid(LocalPlayer()) and LocalPlayer():GetUserGroup() or "unknown"), "localPlayerHasGroup=", tostring(IsValid(LocalPlayer()) and tostring(LocalPlayer():GetUserGroup() or "user") == tostring(groupName) or false))
            local privContainer = tabPanel:Add("DPanel")
            privContainer:Dock(FILL)
            privContainer:DockMargin(20, 20, 20, 20)
            privContainer.Paint = function() end
            buildPrivilegeList(privContainer, groupName, groups, editable)
            local tabData = tabs:AddTab(groupName, tabPanel, lia.admin.getUsergroupIcon(groupName))
            tabData.groupName = groupName
            return tabData
        end

        local function refreshTabs()
            tabs:Clear()
            local groups = lia.admin.groups or {}
            local keys = {}
            for g in pairs(groups) do
                keys[#keys + 1] = g
            end

            table.sort(keys, function(a, b) return a:lower() < b:lower() end)
            lia.debug("[Permissions UI]", "Refreshing group tabs", "groupCount=", tostring(#keys), "localPlayerUserGroup=", tostring(IsValid(LocalPlayer()) and LocalPlayer():GetUserGroup() or "unknown"))
            for _, groupName in ipairs(keys) do
                createGroupTab(groupName, groups)
            end
        end

        parent.refreshTabs = refreshTabs
    end

    hook.Add("PopulateAdminTabs", "liaAdmin", function(pages)
        local client = LocalPlayer()
        local permission = IsValid(client) and client:hasPrivilege("manageUsergroups") or false
        if not permission then return end
        pages[#pages + 1] = {
            name = "userGroups",
            icon = "icon16/group.png",
            drawFunc = function(parent)
                lia.debug("[Permissions UI]", "Opening usergroups page", "localPlayer=", tostring(IsValid(LocalPlayer()) and LocalPlayer():Nick() or "unknown"), "localPlayerUserGroup=", tostring(IsValid(LocalPlayer()) and LocalPlayer():GetUserGroup() or "unknown"))
                lia.gui.usergroups = parent
                parent:Clear()
                parent:DockPadding(10, 10, 10, 10)
                parent.Paint = function() end
                SetupUserGroupInterface(parent)
                timer.Simple(0.1, function() if IsValid(parent) and parent.refreshTabs then parent.refreshTabs() end end)
                net.Start("liaGroupsRequest")
                net.SendToServer()
            end
        }
    end)
end

hook.Add("OnAdminSystemLoaded", "liaAdminSyncAfterLoad", function()
    lia.admin.sync()
    if lia.admin._reportedCamiConflicts then return end
    lia.admin._reportedCamiConflicts = true
    local conflictFiles = findCamiConflictFiles()
    if #conflictFiles == 0 then return end
    local header = "[Lilia] Incompatible CAMI installation detected. Remove external CAMI files to avoid admin system conflicts."
    lia.error(header)
    for _, path in ipairs(conflictFiles) do
        lia.error("[Lilia] CAMI conflict file found: " .. path)
    end
end)

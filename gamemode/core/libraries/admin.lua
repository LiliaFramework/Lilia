--[[
    Folder: Developer - Libraries
    File: admin.lua
]]
--[[
    Admin

    Shared administration helpers for usergroup management, privilege registration, permission checks, CAMI synchronization, and admin UI support.
]]
--[[
    Overview:
        This module powers Lilia's admin permission system under `lia.admin`. It manages built-in and custom usergroups, resolves privilege inheritance, integrates with CAMI, synchronizes permission data to clients, provides usergroup editing UI, and executes or routes admin commands depending on realm.
]]
--[[
    Hooks:
        GetUsergroupIcon(string groupName, table|nil groupData, string|Player groupOrPlayer)

    Purpose:
        Allows plugins or modules to override the icon path used for a usergroup in admin-related UI.

    Category:
        Administration

    Parameters:
        groupName (string)
            The normalized usergroup name being resolved.

        groupData (table|nil)
            The stored group data for the usergroup, if available.

        groupOrPlayer (string|Player)
            The original argument passed into `lia.admin.getUsergroupIcon`.

    Example Usage:
        ```lua
        hook.Add("GetUsergroupIcon", "liaExampleGetUsergroupIcon", function(groupName, groupData, groupOrPlayer)
            return "Example Value"
        end)
        ```

    Returns:
        string|nil
            Return a string icon path to override the default icon resolution. Return nil to continue normal behavior.

    Realm:
        Shared
]]
--[[
    Hooks:
        OnAdminSystemLoaded(table groups, table privileges)

    Purpose:
        Runs after the admin system finishes loading groups and privileges from storage.

    Category:
        Administration

    Parameters:
        groups (table)
            The normalized admin usergroup table.

        privileges (table)
            The rebuilt privilege minimum-access table.

    Example Usage:
        ```lua
        hook.Add("OnAdminSystemLoaded", "liaExampleOnAdminSystemLoaded", function(groups, privileges)
            print("[MyModule] handled OnAdminSystemLoaded")
        end)
        ```

    Returns:
        nil

    Realm:
        Shared
]]
--[[
    Hooks:
        PopulateAdminTabs(table pages)

    Purpose:
        Allows modules to add pages to the admin menu, including the usergroup management panel defined in this file.

    Category:
        Administration

    Parameters:
        pages (table)
            The mutable page definition array used to build the admin interface.

    Example Usage:
        ```lua
        hook.Add("PopulateAdminTabs", "liaExamplePopulateAdminTabs", function(pages)
            pages[#pages + 1] = {
                name = "MyModule",
                icon = "icon16/plugin.png"
            }
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        AdminPrivilegesUpdated()

    Purpose:
        Runs after the client receives a refreshed admin privilege table from the admin system sync.

    Category:
        Administration

    Parameters:
        None

    Example Usage:
        ```lua
        hook.Add("AdminPrivilegesUpdated", "liaExampleAdminPrivilegesUpdated", function()
            if IsValid(lia.gui.character) then
                lia.gui.character:createStartButton()
            end
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
lia.admin = lia.admin or {}
lia.admin.groups = lia.admin.groups or {}
lia.admin.privileges = lia.admin.privileges or {}
lia.admin.privilegeCategories = lia.admin.privilegeCategories or {}
lia.admin.privilegeNames = lia.admin.privilegeNames or {}
lia.admin.privilegeDescriptions = lia.admin.privilegeDescriptions or {}
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

--[[
    Purpose:
        Checks whether a usergroup name exists in the loaded admin groups or in the built-in default groups.

    Parameters:
        groupName (string|any)
            The usergroup name to validate.

    Returns:
        boolean
            True if the group name resolves to a known group. False otherwise.

    Example Usage:
        ```lua
        local isValid = lia.admin.isValidGroup("admin")
        ```

    Realm:
        Shared
]]
function lia.admin.isValidGroup(groupName)
    local group = string.Trim(tostring(groupName or ""))
    if group == "" then return false end
    local groups = lia.admin.groups or {}
    local defaultGroups = lia.admin.DefaultGroups or {}
    return groups[group] ~= nil or defaultGroups[group] ~= nil
end

--[[
    Purpose:
        Returns the configured default usergroup, falling back to `user` when the configured value is invalid.

    Parameters:
        None

    Returns:
        string
            The valid default usergroup name to assign to players without an explicit rank.

    Example Usage:
        ```lua
        local defaultGroup = lia.admin.getDefaultUserGroup()
        ```

    Realm:
        Shared
]]
function lia.admin.getDefaultUserGroup()
    local fallbackGroup = "user"
    local configuredGroup = string.Trim(tostring(lia.config.get("DefaultUserGroup", fallbackGroup) or fallbackGroup))
    if lia.admin.isValidGroup(configuredGroup) then return configuredGroup end
    return fallbackGroup
end

--[[
    Purpose:
        Reads the configuration that controls whether usergroup icons should be shown in the UI.

    Parameters:
        None

    Returns:
        boolean
            True when usergroup icons should be displayed.

    Example Usage:
        ```lua
        if lia.admin.shouldShowUsergroupIcons() then
            -- draw icons
        end
        ```

    Realm:
        Shared
]]
function lia.admin.shouldShowUsergroupIcons()
    return lia.config.get("ShowUsergroupIcons", true) or true
end

--[[
    Purpose:
        Resolves the icon path for a usergroup name or player using configured group metadata and hooks.

    Parameters:
        groupOrPlayer (string|Player)
            A usergroup name or a player whose current usergroup should be inspected.

    Returns:
        string|nil
            The icon material path to use, or nil when icons are disabled.

    Example Usage:
        ```lua
        local icon = lia.admin.getUsergroupIcon(LocalPlayer())
        ```

    Realm:
        Shared
]]
function lia.admin.getUsergroupIcon(groupOrPlayer)
    if not lia.admin.shouldShowUsergroupIcons() then return nil end
    local groupName = groupOrPlayer
    if IsValid(groupOrPlayer) and groupOrPlayer:IsPlayer() then groupName = groupOrPlayer:GetUserGroup() end
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

lia.config.add("DefaultUserGroup", "@defaultUserGroupConfigName", "user", nil, {
    desc = "@defaultUserGroupConfigDesc",
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

lia.config.add("ShowUsergroupIcons", "@showUsergroupIconsConfigName", true, nil, {
    desc = "@showUsergroupIconsConfigDesc",
    category = "@userGroups",
    type = "Boolean"
})

local defaultUserTools = {
    remover = true,
}

local camiPathExceptions = {"lua/sam/",}
--[[
    Purpose:
        Determines whether a CAMI-related file path belongs to Lilia's bundled compatibility layer or another allowed exception.

    Parameters:
        path (string)
            The file path being checked.

    Returns:
        boolean
            True if the path should be ignored during CAMI conflict detection.

    Example Usage:
        ```lua
        local ignored = isBundledCamiCompatibility(path)
        ```

    Realm:
        Shared
]]
local function isBundledCamiCompatibility(path)
    local normalizedPath = path:gsub("\\", "/"):lower()
    if normalizedPath == "lilia/gamemode/core/libraries/compatibility/cami.lua" or normalizedPath:find("/core/libraries/compatibility/cami.lua", 1, true) ~= nil then return true end
    for _, exception in ipairs(camiPathExceptions) do
        if normalizedPath:find(exception, 1, true) ~= nil then return true end
    end
    return false
end

--[[
    Purpose:
        Scans known Lua locations for external CAMI files that may conflict with Lilia's bundled admin compatibility.

    Parameters:
        None

    Returns:
        table
            An array of conflicting file paths sorted alphabetically.

    Example Usage:
        ```lua
        local conflicts = findCamiConflictFiles()
        ```

    Realm:
        Shared
]]
local function findCamiConflictFiles()
    local matches = {}
    local seen = {}
    --[[
        Purpose:
            Adds a discovered CAMI file path to the conflict list once while ignoring bundled exceptions.

        Parameters:
            path (string)
                The file path to record as a conflict candidate.

        Returns:
            nil

        Example Usage:
            ```lua
            addMatch(path)
            ```

        Realm:
            Shared
    ]]
    local function addMatch(path)
        local normalizedPath = path:gsub("\\", "/"):lower()
        if seen[normalizedPath] then return end
        if isBundledCamiCompatibility(path) then return end
        seen[normalizedPath] = true
        matches[#matches + 1] = path
    end

    --[[
        Purpose:
            Recursively scans a base directory in a search path for CAMI files.

        Parameters:
            baseDir (string)
                The root path prefix to scan.

            searchPath (string)
                The Garry's Mod file search realm to use.

        Returns:
            nil

        Example Usage:
            ```lua
            scanTarget("gamemodes/schema/", "GAME")
            ```

        Realm:
            Shared
    ]]
    local function scanTarget(baseDir, searchPath)
        --[[
            Purpose:
                Walks child directories beneath a scan target and records CAMI file matches.

            Parameters:
                currentDir (string)
                    The current directory path being traversed.

            Returns:
                nil

            Example Usage:
                ```lua
                recurse("lua/")
                ```

            Realm:
                Shared
        ]]
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

    --[[
        Purpose:
            Recursively scans the shared Lua directory tree for CAMI files in the `GAME` search path.

        Parameters:
            baseDir (string)
                The Lua directory path prefix to scan.

        Returns:
            nil

        Example Usage:
            ```lua
            scanLuaDirectories("lua/")
            ```

        Realm:
            Shared
    ]]
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

--[[
    Purpose:
        Ensures the built-in `user`, `admin`, and `superadmin` groups exist with required metadata and default staff flags.

    Parameters:
        groups (table)
            The group table to normalize in-place.

    Returns:
        boolean
            True if any default groups or metadata had to be created or corrected.

    Example Usage:
        ```lua
        local changed = ensureDefaults(groups)
        ```

    Realm:
        Shared
]]
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

--[[
    Purpose:
        Emits a warning when code attempts to modify one of the immutable base usergroups.

    Parameters:
        groupName (string)
            The base group that was targeted.

        permission (string|nil)
            The privilege involved in the attempted change, if any.

        action (string|nil)
            A short description of the attempted mutation.

        source (string|nil)
            The subsystem or function that attempted the change.

    Returns:
        nil

    Example Usage:
        ```lua
        warnBaseGroupMutation("admin", "manageUsergroups", "grant", "lia.admin.addPermission")
        ```

    Realm:
        Shared
]]
local function warnBaseGroupMutation(groupName, permission, action, source)
    lia.warning(string.format("[Lilia] Refused to %s base usergroup '%s'%s%s. Base groups are immutable and will be reset to default behavior.", tostring(action or "modify"), tostring(groupName), permission and permission ~= "" and (" for privilege '" .. tostring(permission) .. "'") or "", source and source ~= "" and (" (source: " .. tostring(source) .. ")") or ""))
end

--[[
    Purpose:
        Removes custom privilege overrides from immutable base groups so they keep their intended default behavior.

    Parameters:
        groups (table)
            The usergroup table to sanitize.

        source (string|nil)
            A label describing where the sanitation request came from.

    Returns:
        boolean
            True if any base group data was changed.

    Example Usage:
        ```lua
        local changed = sanitizeBaseGroups(lia.admin.groups, "lia.admin.save")
        ```

    Realm:
        Shared
]]
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

--[[
    Purpose:
        Checks whether a command target is an on-duty staff member protected from targeted moderation actions.

    Parameters:
        cmd (string)
            The admin command being attempted.

        target (Entity|Player|nil)
            The entity being targeted by the command.

    Returns:
        boolean
            True when the target is protected from the requested action.

    Example Usage:
        ```lua
        if lia.admin.isProtectedStaffTarget("kick", target) then return end
        ```

    Realm:
        Shared
]]
function lia.admin.isProtectedStaffTarget(cmd, target)
    local protectedCommand = protectedStaffCommands[string.lower(tostring(cmd or ""))] or false
    local validTarget = IsValid(target)
    local targetIsPlayer = validTarget and target:IsPlayer() or false
    local targetIsStaffOnDuty = targetIsPlayer and target:isStaffOnDuty() or false
    local permission = protectedCommand and validTarget and targetIsPlayer and targetIsStaffOnDuty or false
    lia.debug("[Permissions]", "Permission Check for function lia.admin.isProtectedStaffTarget", "commandProtected=", tostring(protectedCommand), "targetValid=", tostring(validTarget), "targetIsPlayer=", tostring(targetIsPlayer), "targetIsStaffOnDuty=", tostring(targetIsStaffOnDuty), "finalResult=", tostring(permission))
    return permission
end

--[[
    Purpose:
        Sends the localized protected-staff warning to the acting administrator.

    Parameters:
        admin (Player|nil)
            The player who attempted the blocked action.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.admin.notifyProtectedStaffTarget(client)
        ```

    Realm:
        Shared
]]
function lia.admin.notifyProtectedStaffTarget(admin)
    if IsValid(admin) then admin:notifyErrorLocalized("staffFactionCommandBlocked") end
end

--[[
    Purpose:
        Resolves a display category label for a privilege using registered metadata, modules, CAMI, and fallback pattern rules.

    Parameters:
        privilegeName (string|nil)
            The privilege ID to categorize.

    Returns:
        string
            The localized category label for the privilege.

    Example Usage:
        ```lua
        local category = getPrivilegeCategory("command_plykick")
        ```

    Realm:
        Shared
]]
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

--[[
    Purpose:
        Clears the cached privilege category lookup table so categories can be rebuilt from fresh data.

    Parameters:
        None

    Returns:
        nil

    Example Usage:
        ```lua
        clearPrivilegeCategoryCache()
        ```

    Realm:
        Shared
]]
local function clearPrivilegeCategoryCache()
    privilegeCategoryCache = {}
end

function lia.admin.clearPrivilegeCategoryCache()
    clearPrivilegeCategoryCache()
end

--[[
    Purpose:
        Builds a display-safe external privilege name and caches alias mappings for integrations like CAMI.

    Parameters:
        id (string|any)
            The internal privilege ID.

    Returns:
        string
            The external display name for the privilege.

    Example Usage:
        ```lua
        local name = lia.admin.getExternalPrivilegeName("command_plykick")
        ```

    Realm:
        Shared
]]
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

--[[
    Purpose:
        Normalizes a privilege identifier by resolving stored aliases back to the canonical privilege ID.

    Parameters:
        privilege (string|any)
            The privilege name or alias to normalize.

    Returns:
        string
            The canonical privilege ID, or the original string when no alias exists.

    Example Usage:
        ```lua
        local id = lia.admin.normalizePrivilege(privilege)
        ```

    Realm:
        Shared
]]
function lia.admin.normalizePrivilege(privilege)
    privilege = tostring(privilege or "")
    if privilege == "" then return privilege end
    if lia.admin.privileges and lia.admin.privileges[privilege] ~= nil then return privilege end
    return lia.admin.privilegeAliases and lia.admin.privilegeAliases[privilege] or privilege
end

local groupLevelCache = {}
--[[
    Purpose:
        Clears cached group level lookups so inheritance and permission comparisons can be recalculated.

    Parameters:
        None

    Returns:
        nil

    Example Usage:
        ```lua
        clearGroupLevelCache()
        ```

    Realm:
        Shared
]]
local function clearGroupLevelCache()
    groupLevelCache = {}
end

--[[
    Purpose:
        Resolves the effective base level for a usergroup by following inheritance until it reaches a default rank.

    Parameters:
        group (string)
            The usergroup name to evaluate.

    Returns:
        number
            The numeric level used for privilege comparisons.

    Example Usage:
        ```lua
        local level = getGroupLevel("moderator")
        ```

    Realm:
        Shared
]]
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

--[[
    Purpose:
        Determines whether a usergroup should inherit a privilege based on its effective level and a minimum access rank.

    Parameters:
        group (string)
            The group being checked.

        min (string|nil)
            The minimum access level required for the privilege.

    Returns:
        boolean
            True if the group meets or exceeds the required level.

    Example Usage:
        ```lua
        local granted = shouldGrant("admin", "user")
        ```

    Realm:
        Shared
]]
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

--[[
    Purpose:
        Converts an admin command name into the privilege ID used to authorize that command.

    Parameters:
        cmd (string|any)
            The command name to translate.

    Returns:
        string|nil
            The matching privilege ID, or nil when the command name is empty.

    Example Usage:
        ```lua
        local privilegeID = lia.admin.getCommandPrivilegeID("kick")
        ```

    Realm:
        Shared
]]
function lia.admin.getCommandPrivilegeID(cmd)
    cmd = string.lower(tostring(cmd or ""))
    if cmd == "" then return nil end
    return targetedCommandPrivilegeMap[cmd] or "command_" .. cmd
end

--[[
    Purpose:
        Rebuilds the global privilege minimum-access map from the currently loaded group permission assignments.

    Parameters:
        None

    Returns:
        nil

    Example Usage:
        ```lua
        rebuildPrivileges()
        ```

    Realm:
        Shared
]]
local function rebuildPrivileges()
    lia.admin.privileges = lia.admin.privileges or {}
    local rebuildCache = {}
    --[[
        Purpose:
            Retrieves and memoizes effective group levels during a privilege rebuild pass.

        Parameters:
            groupName (string)
                The group whose level should be cached.

        Returns:
            number
                The effective numeric level for the group.

        Example Usage:
            ```lua
            local level = getCachedGroupLevel("admin")
            ```

        Realm:
            Shared
    ]]
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

--[[
    Purpose:
        Registers a non-base Lilia usergroup with CAMI so external admin systems can recognize it.

    Parameters:
        name (string)
            The usergroup name to register.

        inherits (string|nil)
            The CAMI parent group name.

    Returns:
        nil

    Example Usage:
        ```lua
        camiRegisterUsergroup("moderator", "admin")
        ```

    Realm:
        Shared
]]
local function camiRegisterUsergroup(name, inherits)
    if CAMI and name ~= "user" and name ~= "admin" and name ~= "superadmin" then
        CAMI.RegisterUsergroup({
            Name = name,
            Inherits = inherits or "user"
        }, "Lilia")
    end
end

--[[
    Purpose:
        Unregisters a non-base Lilia usergroup from CAMI.

    Parameters:
        name (string)
            The usergroup name to unregister.

    Returns:
        nil

    Example Usage:
        ```lua
        camiUnregisterUsergroup("moderator")
        ```

    Realm:
        Shared
]]
local function camiUnregisterUsergroup(name)
    if CAMI and name ~= "user" and name ~= "admin" and name ~= "superadmin" then CAMI.UnregisterUsergroup(name, "Lilia") end
end

--[[
    Purpose:
        Registers or refreshes a privilege in CAMI using Lilia's resolved external privilege naming.

    Parameters:
        name (string)
            The internal privilege ID.

        min (string|nil)
            The minimum access level required for the privilege.

    Returns:
        nil

    Example Usage:
        ```lua
        camiRegisterPrivilege("command_plykick", "admin")
        ```

    Realm:
        Shared
]]
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

--[[
    Purpose:
        Imports existing CAMI usergroups and privileges into Lilia's admin tables during startup.

    Parameters:
        None

    Returns:
        nil

    Example Usage:
        ```lua
        camiBootstrapFromExisting()
        ```

    Realm:
        Shared
]]
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

--[[
    Purpose:
        Applies a standardized kick and/or ban punishment for a named infraction using localized reason strings.

    Parameters:
        client (Player)
            The player receiving the punishment.

        infraction (string)
            The infraction label inserted into the localized reason text.

        kick (boolean)
            Whether the player should be kicked.

        ban (boolean)
            Whether the player should be banned.

        time (number|nil)
            The ban duration in minutes, or 0 for permanent/default behavior.

        kickKey (string|nil)
            The localization key used to build the kick reason.

        banKey (string|nil)
            The localization key used to build the ban reason.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.admin.applyPunishment(client, "cheating", true, true, 60)
        ```

    Realm:
        Shared
]]
function lia.admin.applyPunishment(client, infraction, kick, ban, time, kickKey, banKey)
    local bantime = time or 0
    kickKey = kickKey or "kickedForInfraction"
    banKey = banKey or "bannedForInfraction"
    if kick then lia.admin.execCommand("kick", client, nil, L(kickKey, infraction)) end
    if ban then lia.admin.execCommand("ban", client, bantime, L(banKey, infraction)) end
end

--[[
    Purpose:
        Determines whether a player or usergroup has access to a specific privilege, creating dynamic tool and property privileges when needed.

    Parameters:
        ply (Player|string)
            The player to check, or a usergroup name.

        privilege (string)
            The privilege ID to authorize.

    Returns:
        boolean
            True if the player or group has the requested privilege.

    Example Usage:
        ```lua
        if lia.admin.hasAccess(client, "manageUsergroups") then
            -- allow action
        end
        ```

    Realm:
        Shared
]]
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

--[[
    Purpose:
        Persists the current admin group configuration to the database and optionally re-syncs it to connected clients.

    Parameters:
        noNetwork (boolean|nil)
            When true, skips the client synchronization step after saving.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.admin.save()
        ```

    Realm:
        Shared
]]
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

--[[
    Purpose:
        Registers a new privilege, stores its metadata, seeds inherited group access, and notifies integrations.

    Parameters:
        priv (table)
            The privilege definition containing fields such as `ID`, `Name`, `MinAccess`, and `Category`.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.admin.registerPrivilege({
            ID = "examplePrivilege",
            Name = "Example Privilege",
            MinAccess = "admin"
        })
        ```

    Realm:
        Shared
]]
function lia.admin.registerPrivilege(priv)
    if not priv or not priv.ID then
        lia.error(L("privilegeRegistrationError"))
        return
    end

    local id = tostring(priv.ID)
    if id == "" then return end
    local alreadyRegistered = lia.admin.privileges[id] ~= nil
    local min = tostring(priv.MinAccess or lia.admin.privileges[id] or "user"):lower()
    lia.admin.privileges[id] = min
    lia.admin.privilegeNames[id] = lia.lang.resolveToken(priv.Name or lia.admin.privilegeNames[id] or priv.ID)
    local description = string.Trim(tostring(priv.Description or priv.Desc or priv.description or priv.desc or priv.Help or priv.help or priv.Tooltip or priv.tooltip or ""))
    if description ~= "" then
        lia.admin.privilegeDescriptions[id] = lia.lang.resolveToken(description)
    elseif not alreadyRegistered then
        lia.admin.privilegeDescriptions[id] = nil
    end

    lia.admin.privilegeAliases[id] = id
    lia.admin.getExternalPrivilegeName(id)
    clearPrivilegeCategoryCache()
    if priv.Category then lia.admin.privilegeCategories[id] = lia.lang.resolveToken(priv.Category) end
    if alreadyRegistered then
        if SERVER and lia.admin.sync then timer.Create("liaAdminPrivilegeMetadataSync", 0, 1, function() lia.admin.sync() end) end
        return
    end

    local defaultGroups = lia.admin.DefaultGroups or {}
    local minLevel = defaultGroups[min] or 1
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
        Category = category,
        Description = lia.admin.privilegeDescriptions[id]
    })

    if SERVER then lia.admin.save() end
end

--[[
    Purpose:
        Removes a privilege from Lilia's caches, usergroups, and CAMI registrations.

    Parameters:
        id (string|any)
            The privilege ID to unregister.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.admin.unregisterPrivilege("examplePrivilege")
        ```

    Realm:
        Shared
]]
function lia.admin.unregisterPrivilege(id)
    id = tostring(id or "")
    if id == "" or lia.admin.privileges[id] == nil then return end
    local externalName = lia.admin.externalPrivilegeNames and lia.admin.externalPrivilegeNames[id] or nil
    lia.admin.privileges[id] = nil
    clearPrivilegeCategoryCache()
    lia.admin.privilegeCategories[id] = nil
    lia.admin.privilegeNames[id] = nil
    lia.admin.privilegeDescriptions[id] = nil
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

--[[
    Purpose:
        Applies inherited permissions and default minimum-access grants to a usergroup.

    Parameters:
        groupName (string)
            The group whose effective permissions should be rebuilt.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.admin.applyInheritance("moderator")
        ```

    Realm:
        Shared
]]
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
    --[[
        Purpose:
            Copies inherited positive permissions from a source group chain into the target group once per ancestor.

        Parameters:
            srcName (string)
                The group name currently being inherited from.

        Returns:
            nil

        Example Usage:
            ```lua
            copyFrom("admin")
            ```

        Realm:
            Shared
    ]]
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

--[[
    Purpose:
        Loads admin groups from the database, normalizes them, rebuilds privileges, and finishes CAMI synchronization.

    Parameters:
        None

    Returns:
        nil

    Example Usage:
        ```lua
        lia.admin.load()
        ```

    Realm:
        Shared
]]
function lia.admin.load()
    --[[
        Purpose:
            Finalizes loaded admin data by storing it, synchronizing CAMI registrations, and firing load hooks.

        Parameters:
            groups (table)
                The normalized admin group table that was loaded from storage.

        Returns:
            nil

        Example Usage:
            ```lua
            continueLoad(groups)
            ```

        Realm:
            Shared
    ]]
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

--[[
    Purpose:
        Creates a new custom usergroup, applies inheritance, and registers it with hooks and CAMI.

    Parameters:
        groupName (string)
            The name of the new usergroup.

        info (table|nil)
            Optional group data including `_info` metadata.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.admin.createGroup("moderator", {
            _info = {
                inheritance = "admin",
                types = {"Staff"}
            }
        })
        ```

    Realm:
        Shared
]]
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

--[[
    Purpose:
        Removes a custom usergroup and unregisters it from CAMI.

    Parameters:
        groupName (string)
            The name of the group to remove.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.admin.removeGroup("moderator")
        ```

    Realm:
        Shared
]]
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

--[[
    Purpose:
        Renames a custom usergroup while preserving its permissions and inheritance data.

    Parameters:
        oldName (string)
            The existing group name.

        newName (string)
            The new group name to assign.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.admin.renameGroup("helper", "moderator")
        ```

    Realm:
        Shared
]]
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
    --[[
        Purpose:
            Sends an admin-only localized notification to every player with permission to view alting-related alerts.

        Parameters:
            notification (string)
                The localization key to send to eligible staff members.

        Returns:
            nil

        Example Usage:
            ```lua
            lia.admin.notifyAdmin("playerAltDetected")
            ```

        Realm:
            Server
    ]]
    function lia.admin.notifyAdmin(notification)
        for _, client in player.Iterator() do
            local permission = IsValid(client) and client:hasPrivilege("canSeeAltingNotifications") or false
            if permission then client:notifyAdminLocalized(notification) end
        end
    end

    --[[
        Purpose:
            Grants or explicitly enables a privilege for a custom usergroup and saves the change.

        Parameters:
            groupName (string)
                The usergroup receiving the permission.

            permission (string)
                The privilege ID or alias to enable.

            silent (boolean|nil)
                When true, skips immediate network synchronization during the save call.

        Returns:
            nil

        Example Usage:
            ```lua
            lia.admin.addPermission("moderator", "manageUsergroups")
            ```

        Realm:
            Server
    ]]
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

    --[[
        Purpose:
            Revokes or explicitly disables a privilege for a custom usergroup and saves the change.

        Parameters:
            groupName (string)
                The usergroup losing the permission.

            permission (string)
                The privilege ID or alias to disable.

            silent (boolean|nil)
                When true, skips immediate network synchronization during the save call.

        Returns:
            nil

        Example Usage:
            ```lua
            lia.admin.removePermission("moderator", "manageUsergroups")
            ```

        Realm:
            Server
    ]]
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

    --[[
        Purpose:
            Sends the latest admin privilege and group tables to one client or to all ready human clients in batches.

        Parameters:
            c (Player|nil)
                An optional player to sync individually. When nil, all ready human clients are synced.

        Returns:
            nil

        Example Usage:
            ```lua
            lia.admin.sync()
            ```

        Realm:
            Server
    ]]
    function lia.admin.sync(c)
        lia.net.ready = lia.net.ready or setmetatable({}, {
            __mode = "k"
        })

        --[[
            Purpose:
                Sends the current privilege and group tables to one ready client.

            Parameters:
                ply (Player)
                    The client to receive the sync payload.

            Returns:
                nil

            Example Usage:
                ```lua
                push(client)
                ```

            Realm:
                Server
        ]]
        local function push(ply)
            if not IsValid(ply) then return end
            if not lia.net.ready[ply] then return end
            lia.net.writeBigTable(ply, "liaUpdateAdminPrivileges", {
                privileges = lia.admin.privileges or {},
                names = lia.admin.privilegeNames or {},
                descriptions = lia.admin.privilegeDescriptions or {}
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

    --[[
        Purpose:
            Compares current privilege and group counts against the last broadcast snapshot to detect unsynced changes.

        Parameters:
            None

        Returns:
            boolean
                True when the cached sync counts no longer match the current admin data.

        Example Usage:
            ```lua
            local dirty = lia.admin.hasChanges()
            ```

        Realm:
            Server
    ]]
    function lia.admin.hasChanges()
        local currentPrivilegeCount = table.Count(lia.admin.privileges)
        local currentGroupCount = table.Count(lia.admin.groups)
        return currentPrivilegeCount ~= lia.admin._lastSyncPrivilegeCount or currentGroupCount ~= lia.admin._lastSyncGroupCount
    end

    --[[
        Purpose:
            Updates a live player's usergroup by SteamID through the shared SteamID assignment helper.

        Parameters:
            ply (Player)
                The player whose rank should change.

            newGroup (string|nil)
                The target group name, or nil to fall back to the configured default group.

            source (string|nil)
                A source label passed into CAMI and hooks.

        Returns:
            nil

        Example Usage:
            ```lua
            lia.admin.setPlayerUsergroup(client, "admin", "Console")
            ```

        Realm:
            Server
    ]]
    function lia.admin.setPlayerUsergroup(ply, newGroup, source)
        if not IsValid(ply) then return end
        lia.admin.setSteamIDUsergroup(ply:SteamID(), newGroup, source)
    end

    --[[
        Purpose:
            Assigns a usergroup to a SteamID, updates the live player if connected, and signals CAMI and hooks.

        Parameters:
            steamId (string)
                The SteamID to update.

            newGroup (string|nil)
                The target group name, or nil to use the configured default group.

            source (string|nil)
                A label describing who or what initiated the change.

        Returns:
            nil

        Example Usage:
            ```lua
            lia.admin.setSteamIDUsergroup("STEAM_0:1:12345", "admin", "Lilia")
            ```

        Realm:
            Server
    ]]
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

    --[[
        Purpose:
            Executes a server-side admin action against a target player after validating privileges and special protections.

        Parameters:
            cmd (string)
                The admin command to execute.

            victim (Player|string)
                The target player entity or a lookup string.

            dur (number|nil)
                An optional duration used by timed commands.

            reason (string|nil)
                An optional reason string for punishments.

            admin (Player|nil)
                The acting administrator, or nil when the server console initiated the action.

        Returns:
            boolean
                True when the command completed successfully. False otherwise.

        Example Usage:
            ```lua
            lia.admin.serverExecCommand("kick", target, nil, "Rule violation", client)
            ```

        Realm:
            Server
    ]]
    function lia.admin.serverExecCommand(cmd, victim, dur, reason, admin)
        local isConsoleAdmin = not IsValid(admin)
        local adminName = isConsoleAdmin and "Console" or admin:Name()
        local adminSteamID = isConsoleAdmin and "CONSOLE" or admin:SteamID()
        local target
        --[[
            Purpose:
                Reports command success or failure back to the acting admin or the server console.

            Parameters:
                kind (string)
                    Either `error` or another value for success notifications.

                key (string)
                    The localization key to send or print.

                ... (any)
                    Optional localization formatting arguments.

            Returns:
                nil

            Example Usage:
                ```lua
                notifyAdmin("error", "noPerm")
                ```

            Realm:
                Server
        ]]
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

        --[[
            Purpose:
                Writes an admin action entry to Lilia's logging system for a handled command.

            Parameters:
                logType (string)
                    The log type identifier to record.

                ... (any)
                    Additional values passed to the logger.

            Returns:
                nil

            Example Usage:
                ```lua
                logAdminAction("plyKick", target:Name())
                ```

            Realm:
                Server
        ]]
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

        --[[
            Purpose:
                Broadcasts a formatted staff activity message using the staff action feed styling.

            Parameters:
                tag (string)
                    The short action label to highlight.

                text (string)
                    The descriptive action text to display.

            Returns:
                nil

            Example Usage:
                ```lua
                staffAction("KICK", message)
                ```

            Realm:
                Server
        ]]
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

    --[[
        Purpose:
            Executes a clientside admin command by routing it through hooks or chat command fallbacks.

        Parameters:
            cmd (string)
                The admin command to execute.

            victim (Player|string)
                The target player or identifier.

            dur (number|nil)
                An optional duration argument for timed actions.

            reason (string|nil)
                An optional reason string to forward with the command.

        Returns:
            boolean|nil
                True when a command handler ran successfully, false when blocked, or nil when no handler exists.

        Example Usage:
            ```lua
            lia.admin.execCommand("kick", target, nil, "Rule violation")
            ```

        Realm:
            Client
    ]]
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
    --[[
        Purpose:
            Ensures the server-side admin group table exists and that each known group has a table allocated.

        Parameters:
            None

        Returns:
            nil

        Example Usage:
            ```lua
            ensureStructures()
            ```

        Realm:
            Server
    ]]
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
    --[[
        Purpose:
            Builds a cached category-to-privilege map for the clientside usergroup editor UI.

        Parameters:
            groups (table)
                The current synced admin group table.

        Returns:
            table
                An ordered array of category entries containing labels and privilege item lists.

        Example Usage:
            ```lua
            local orderedCategories = computeCategoryMap(lia.admin.groups)
            ```

        Realm:
            Client
    ]]
    local function computeCategoryMap(groups)
        local groupsChanged = false
        local currentGroupsTable = {}
        for groupName, groupData in pairs(groups or {}) do
            if isstring(groupName) and istable(groupData) then
                currentGroupsTable[groupName] = {}
                for permName, hasPerm in pairs(groupData) do
                    if isstring(permName) and permName ~= "_info" then currentGroupsTable[groupName][permName] = hasPerm end
                end
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
            if isstring(name) then
                local c = tostring(getPrivilegeCategory(name))
                local key = c:lower()
                labels[key] = labels[key] or c
                cats[key] = cats[key] or {}
                cats[key][#cats[key] + 1], seen[name] = name, true
            end
        end

        for _, data in pairs(groups or {}) do
            for name in pairs(data or {}) do
                if isstring(name) and name ~= "_info" and not seen[name] then
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

        table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
        for _, k in ipairs(keys) do
            table.sort(cats[k], function(a, b) return tostring(a):lower() < tostring(b):lower() end)
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

    --[[
        Purpose:
            Opens the clientside dialog used to create a new usergroup and sends the result to the server.

        Parameters:
            None

        Returns:
            nil

        Example Usage:
            ```lua
            promptCreateGroup()
            ```

        Realm:
            Client
    ]]
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

    --[[
        Purpose:
            Populates a usergroup panel with categorized privilege rows and editing controls.

        Parameters:
            container (Panel)
                The parent panel that should receive the generated privilege UI.

            g (string)
                The usergroup name being displayed.

            groups (table)
                The full synced admin group table.

            editable (boolean)
                Whether the privilege rows should allow changes.

        Returns:
            nil

        Example Usage:
            ```lua
            buildPrivilegeList(panel, "admin", lia.admin.groups, true)
            ```

        Realm:
            Client
    ]]
    local function getPermissionsTheme()
        local theme = lia.color and lia.color.theme or {}
        local configuredAccent = lia.config and lia.config.get and lia.config.get("Color") or nil
        local accent = theme.accent or theme.theme or configuredAccent or Color(45, 190, 170)
        local textColor = theme.text or Color(225, 238, 238)
        local mutedText = Color(155, 178, 179)
        local panel = Color(5, 18, 23, 220)
        local panelAlt = Color(3, 16, 21, 185)
        local border = Color(accent.r, accent.g, accent.b, 80)
        return accent, textColor, mutedText, panel, panelAlt, border
    end

    local function drawPermissionsPanel(x, y, w, h, radius, color, outline)
        lia.derma.rect(x, y, w, h):Rad(radius):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
        if outline then lia.derma.rect(x, y, w, h):Rad(radius):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
    end

    local function drawPermissionsIcon(material, x, y, size, color)
        if not material or material:IsError() then return end
        surface.SetMaterial(material)
        surface.SetDrawColor(color or color_white)
        surface.DrawTexturedRect(x, y, size, size)
    end

    local function drawPermissionBadge(text, font, x, y, paddingX, paddingY, foreground, background, outline, alignRight)
        surface.SetFont(font)
        local textWidth, textHeight = surface.GetTextSize(text)
        local width = textWidth + paddingX * 2
        local height = textHeight + paddingY * 2
        local drawX = alignRight and x - width or x
        drawPermissionsPanel(drawX, y, width, height, 4, background, outline)
        draw.SimpleText(text, font, drawX + width * 0.5, y + height * 0.5, foreground, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return drawX, width, height
    end

    local function getPrivilegeDisplayName(name)
        local displayName = lia.admin.privilegeNames and lia.admin.privilegeNames[name] or name
        displayName = lia.lang.resolveToken(displayName)
        if not displayName or displayName == "" then return tostring(name) end
        return tostring(displayName)
    end

    local function prettifyPermissionText(value)
        value = tostring(value or "")
        value = value:gsub("^command_", "")
        value = value:gsub("^tool_", "")
        value = value:gsub("[_%-]+", " ")
        value = value:gsub("([a-z%d])([A-Z])", "%1 %2")
        value = value:gsub("([A-Z])([A-Z][a-z])", "%1 %2")
        value = value:gsub("%s+", " ")
        value = string.Trim(value)
        if value == "" then return "" end
        return value:gsub("(%a)([%w']*)", function(first, rest) return string.upper(first) .. string.lower(rest) end)
    end

    local function truncatePermissionText(text, font, maxWidth)
        text = tostring(text or "")
        if text == "" then return "" end
        surface.SetFont(font)
        if surface.GetTextSize(text) <= maxWidth then return text end
        local suffix = "..."
        local suffixWidth = surface.GetTextSize(suffix)
        local result = text
        while result ~= "" and surface.GetTextSize(result) + suffixWidth > maxWidth do
            result = string.sub(result, 1, -2)
        end

        result = string.Trim(result)
        if result == "" then return suffix end
        return result .. suffix
    end

    local function getPrivilegeDescription(name)
        local privilegeID = lia.admin.normalizePrivilege(name)
        local rawDescription = lia.admin.privilegeDescriptions and (lia.admin.privilegeDescriptions[privilegeID] or lia.admin.privilegeDescriptions[name]) or nil
        if rawDescription ~= nil then
            local description = string.Trim(tostring(lia.lang.resolveToken(rawDescription) or ""))
            if description ~= "" and description ~= tostring(privilegeID) then return description end
        end

        for _, module in pairs(lia.module.list or {}) do
            local privilege = module.Privileges and module.Privileges[privilegeID] or nil
            local moduleDescription = privilege and (privilege.Description or privilege.Desc or privilege.description or privilege.desc or privilege.Help or privilege.help or privilege.Tooltip or privilege.tooltip) or nil
            if moduleDescription ~= nil then
                local description = string.Trim(tostring(lia.lang.resolveToken(moduleDescription) or ""))
                if description ~= "" and description ~= tostring(privilegeID) then return description end
            end
        end

        if CAMI and CAMI.GetPrivilege then
            local externalName = lia.admin.externalPrivilegeNames and lia.admin.externalPrivilegeNames[privilegeID] or privilegeID
            local camiPrivilege = CAMI.GetPrivilege(externalName) or CAMI.GetPrivilege(privilegeID)
            local camiDescription = camiPrivilege and (camiPrivilege.Description or camiPrivilege.Desc or camiPrivilege.description or camiPrivilege.desc) or nil
            if camiDescription ~= nil then
                local description = string.Trim(tostring(lia.lang.resolveToken(camiDescription) or ""))
                if description ~= "" and description ~= tostring(privilegeID) then return description end
            end
        end

        local readableName = prettifyPermissionText(privilegeID)
        if string.StartWith(privilegeID, "command_") then return "Allows access to the " .. readableName .. " command." end
        if string.StartWith(privilegeID, "tool_") then return "Allows access to the " .. readableName .. " tool." end
        if string.StartWith(privilegeID, "property_") then return "Allows access to the " .. readableName .. " property." end
        return "Allows access to " .. getPrivilegeDisplayName(privilegeID) .. "."
    end

    local function getGroupDisplayName(groupName)
        local data = lia.admin.groups and lia.admin.groups[groupName] or nil
        local info = data and data._info or {}
        local configuredName = string.Trim(tostring(info.name or info.displayName or ""))
        if configuredName ~= "" then return configuredName end
        if groupName == "superadmin" then return "Super Admin" end
        if groupName == "admin" then return "Admin" end
        if groupName == "user" then return "Regular User" end
        if groupName == "noaccess" then return "No Access" end
        local displayName = tostring(groupName or ""):gsub("[_%-]+", " ")
        return displayName:gsub("(%a)([%w']*)", function(first, rest) return string.upper(first) .. string.lower(rest) end)
    end

    local function getGroupDescription(groupName)
        if groupName == "superadmin" then return "Super Administrator" end
        if groupName == "admin" then return "Administrator" end
        if groupName == "user" then return "Regular User" end
        if groupName == "noaccess" then return "No Access" end
        local data = lia.admin.groups and lia.admin.groups[groupName] or nil
        local info = data and data._info or {}
        local description = string.Trim(tostring(info.description or info.desc or ""))
        if description ~= "" then return description end
        return "Custom Group"
    end

    local function getGroupInheritance(groupName)
        local data = lia.admin.groups and lia.admin.groups[groupName] or nil
        local info = data and data._info or {}
        local inheritance = string.Trim(tostring(info.inheritance or ""))
        if inheritance == "" then inheritance = groupName or "user" end
        return inheritance
    end

    local function getOnlineGroupCount(groupName)
        local count = 0
        for _, client in ipairs(player.GetAll()) do
            if client:GetUserGroup() == groupName then count = count + 1 end
        end
        return count
    end

    local function getPendingValue(state, groupName, privilege)
        local changes = state.pending[groupName]
        if changes and changes[privilege] ~= nil then return changes[privilege] end
        return lia.admin.hasAccess(groupName, privilege)
    end

    local function countPendingChanges(state)
        local count = 0
        for _, changes in pairs(state.pending) do
            for _ in pairs(changes) do
                count = count + 1
            end
        end
        return count
    end

    local function buildPrivilegeList(container, state)
        container:Clear()
        lia.gui.usergroups.checks = lia.gui.usergroups.checks or {}
        lia.gui.usergroups.checks[state.selectedGroup] = {}
        local scrollPanel = container:Add("liaScrollPanel")
        scrollPanel:Dock(FILL)
        scrollPanel.Paint = function() end
        local canvas = scrollPanel:GetCanvas()
        canvas:DockPadding(0, 0, 4, 8)
        canvas.Paint = function() end
        local list = canvas:Add("DListLayout")
        list:Dock(TOP)
        list:DockMargin(0, 0, 0, 8)
        local ordered = computeCategoryMap(lia.admin.groups or {})
        local searchText = string.lower(string.Trim(state.search or ""))
        local pending = state.pending[state.selectedGroup] or {}
        local visibleCount = 0
        local function shouldShowPrivilege(privilege)
            local displayName = getPrivilegeDisplayName(privilege)
            if searchText ~= "" then
                local description = getPrivilegeDescription(privilege)
                local haystack = string.lower(displayName .. " " .. description .. " " .. tostring(privilege))
                if not string.find(haystack, searchText, 1, true) then return false end
            end

            local value = getPendingValue(state, state.selectedGroup, privilege)
            if state.filter == "changed" and pending[privilege] == nil then return false end
            if state.filter == "enabled" and not value then return false end
            if state.filter == "disabled" and value then return false end
            return true
        end

        local function togglePrivilege(privilege, row, toggle)
            if not state.editable then
                LocalPlayer():notifyErrorLocalized("baseUsergroupCannotBeEdited")
                return
            end

            local groupName = state.selectedGroup
            local baseline = lia.admin.hasAccess(groupName, privilege)
            local newValue = not getPendingValue(state, groupName, privilege)
            state.pending[groupName] = state.pending[groupName] or {}
            if newValue == baseline then
                state.pending[groupName][privilege] = nil
            else
                state.pending[groupName][privilege] = newValue
            end

            local filter = tostring(state.filter or "all")
            if filter == "changed" or filter == "enabled" or filter == "disabled" then
                state.rebuildList()
            else
                row:InvalidateLayout(true)
                toggle:InvalidateLayout(true)
            end

            state.updateFooter()
            if IsValid(state.detailHeader) then state.detailHeader:InvalidateLayout(true) end
        end

        local function addPrivilegeRow(parent, privilege)
            local row = parent:Add("DButton")
            row:Dock(TOP)
            row:SetTall(56)
            row:SetText("")
            row:SetCursor(state.editable and "hand" or "arrow")
            row.Paint = function(button, w, h)
                local accent, textColor, mutedText, _, panelAlt = getPermissionsTheme()
                local changed = pending[privilege] ~= nil
                local background = button:IsHovered() and Color(255, 255, 255, 6) or panelAlt
                surface.SetDrawColor(background.r, background.g, background.b, background.a)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(accent.r, accent.g, accent.b, 24)
                surface.DrawRect(0, h - 1, w, 1)
                if changed then draw.RoundedBox(2, 10, math.floor(h * 0.5) - 2, 4, 4, accent) end
                local maxTextWidth = math.max(w - 96, 80)
                local title = truncatePermissionText(getPrivilegeDisplayName(privilege), "LiliaFont.17", maxTextWidth)
                local description = truncatePermissionText(getPrivilegeDescription(privilege), "LiliaFont.15", maxTextWidth)
                draw.SimpleText(title, "LiliaFont.17", 22, 9, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText(description, "LiliaFont.15", 22, 31, mutedText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end

            local toggle = row:Add("DButton")
            toggle:Dock(RIGHT)
            toggle:SetWide(46)
            toggle:DockMargin(0, 16, 12, 16)
            toggle:SetText("")
            toggle:SetCursor(state.editable and "hand" or "arrow")
            toggle.Paint = function(button, w, h)
                local accent = getPermissionsTheme()
                local enabled = getPendingValue(state, state.selectedGroup, privilege)
                local track = enabled and Color(accent.r, accent.g, accent.b, state.editable and 235 or 110) or Color(66, 78, 82, 225)
                local knobColor = state.editable and Color(239, 247, 247) or Color(154, 166, 166)
                draw.RoundedBox(h * 0.5, 0, 0, w, h, track)
                local knobSize = h - 6
                local knobX = enabled and w - knobSize - 3 or 3
                draw.RoundedBox(knobSize * 0.5, knobX, 3, knobSize, knobSize, knobColor)
                if state.editable and button:IsHovered() then
                    surface.SetDrawColor(255, 255, 255, 12)
                    surface.DrawRect(0, 0, w, h)
                end
            end

            toggle.DoClick = function() togglePrivilege(privilege, row, toggle) end
            row.DoClick = function() togglePrivilege(privilege, row, toggle) end
            lia.gui.usergroups.checks[state.selectedGroup][privilege] = row
            visibleCount = visibleCount + 1
        end

        for _, category in ipairs(ordered) do
            local categorySelected = not state.selectedCategory or state.selectedCategory == category.label
            if categorySelected then
                local visiblePrivileges = {}
                local enabledCount = 0
                for _, privilege in ipairs(category.items) do
                    if getPendingValue(state, state.selectedGroup, privilege) then enabledCount = enabledCount + 1 end
                    if shouldShowPrivilege(privilege) then visiblePrivileges[#visiblePrivileges + 1] = privilege end
                end

                if #visiblePrivileges > 0 then
                    local categoryKey = tostring(category.label)
                    local collapsed = state.collapsedCategories[categoryKey] == true
                    local categoryCard = list:Add("DPanel")
                    categoryCard:Dock(TOP)
                    categoryCard:SetTall(collapsed and 44 or 44 + #visiblePrivileges * 56)
                    categoryCard:DockMargin(0, visibleCount > 0 and 8 or 0, 0, 0)
                    categoryCard.Paint = function(_, w, h)
                        local accent = getPermissionsTheme()
                        drawPermissionsPanel(0, 0, w, h, 6, Color(3, 16, 21, 185), Color(accent.r, accent.g, accent.b, 68))
                    end

                    local categoryHeader = categoryCard:Add("DButton")
                    categoryHeader:Dock(TOP)
                    categoryHeader:SetTall(44)
                    categoryHeader:SetText("")
                    categoryHeader.Paint = function(button, w, h)
                        local accent, _, mutedText = getPermissionsTheme()
                        if button:IsHovered() then
                            surface.SetDrawColor(255, 255, 255, 5)
                            surface.DrawRect(0, 0, w, h)
                        end

                        draw.SimpleText(string.upper(categoryKey), "LiliaFont.17", 14, h * 0.5, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        drawPermissionBadge(enabledCount .. "/" .. #category.items, "LiliaFont.15", w - 40, 11, 9, 2, Color(213, 227, 227), Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 60), true)
                        draw.SimpleText(collapsed and "+" or "−", "LiliaFont.18", w - 17, h * 0.5, mutedText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end

                    categoryHeader.DoClick = function()
                        state.collapsedCategories[categoryKey] = not collapsed
                        state.rebuildList()
                    end

                    if not collapsed then
                        local rows = categoryCard:Add("DPanel")
                        rows:Dock(FILL)
                        rows.Paint = function() end
                        for _, privilege in ipairs(visiblePrivileges) do
                            addPrivilegeRow(rows, privilege)
                        end
                    else
                        visibleCount = visibleCount + #visiblePrivileges
                    end
                end
            end
        end

        if visibleCount == 0 then
            local empty = list:Add("DPanel")
            empty:Dock(TOP)
            empty:SetTall(120)
            empty.Paint = function(_, w, h)
                local accent, _, mutedText = getPermissionsTheme()
                drawPermissionsPanel(0, 0, w, h, 6, Color(3, 16, 21, 185), Color(accent.r, accent.g, accent.b, 54))
                drawPermissionsIcon(Material("icon16/magnifier.png", "smooth"), w * 0.5 - 12, 26, 24, mutedText)
                draw.SimpleText("No permissions match the current filters.", "LiliaFont.17", w * 0.5, 72, mutedText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        list:InvalidateLayout(true)
        canvas:InvalidateLayout(true)
        scrollPanel:InvalidateLayout(true)
    end

    local function queueUsergroupsRefresh(fullRefresh)
        local panel = lia.gui.usergroups
        if not IsValid(panel) then return end
        if fullRefresh then panel._liaNeedsFullRefresh = true end
        if timer.Exists("liaUsergroupsRefresh") then return end
        timer.Create("liaUsergroupsRefresh", 0, 1, function()
            if not IsValid(panel) then return end
            local refresh = panel._liaNeedsFullRefresh and panel.refreshTabs or panel.refreshInterface or panel.refreshTabs
            panel._liaNeedsFullRefresh = false
            if refresh then refresh() end
        end)
    end

    lia.net.readBigTable("liaUpdateAdminGroups", function(tbl)
        lia.admin.groups = tbl
        lia.debug("[Permissions UI]", "Received admin groups sync", "groupCount=", tostring(table.Count(lia.admin.groups or {})))
        queueUsergroupsRefresh(true)
    end)

    lia.net.readBigTable("liaUpdateAdminPrivileges", function(tbl)
        if tbl and tbl.privileges then
            lia.admin.privileges = tbl.privileges
            lia.admin.privilegeNames = tbl.names or {}
            lia.admin.privilegeDescriptions = tbl.descriptions or {}
        else
            lia.admin.privileges = tbl
        end

        categoryMapCache = {}
        lia.debug("[Permissions UI]", "Received admin privileges sync", "privilegeCount=", tostring(table.Count(lia.admin.privileges or {})), "hasAlwaysSpawnAdminStick=", tostring(lia.admin.privileges and lia.admin.privileges.alwaysSpawnAdminStick or "nil"))
        hook.Run("AdminPrivilegesUpdated")
        queueUsergroupsRefresh(true)
    end)

    --[[
        Purpose:
            Builds the clientside usergroup management interface, including tabs and group management buttons.

        Parameters:
            parent (Panel)
                The parent panel that will host the interface.

        Returns:
            nil

        Example Usage:
            ```lua
            SetupUserGroupInterface(parent)
            ```

        Realm:
            Client
    ]]
    local function SetupUserGroupInterface(parent)
        local searchIcon = Material("icon16/magnifier.png", "smooth")
        local groupIconCache = {}
        local state = {
            selectedGroup = nil,
            selectedCategory = nil,
            search = "",
            groupSearch = "",
            filter = "all",
            pending = {},
            editable = false,
            collapsedCategories = {}
        }

        local function getGroupIcon(groupName)
            local path = lia.admin.getUsergroupIcon(groupName) or "icon16/group.png"
            if not groupIconCache[path] then groupIconCache[path] = Material(path, "smooth") end
            return groupIconCache[path]
        end

        local function styleActionButton(button, label, iconPath, variant)
            local iconMaterial = Material(iconPath, "smooth")
            button:SetText("")
            button.Paint = function(self, w, h)
                local accent, textColor = getPermissionsTheme()
                local enabled = self:IsEnabled()
                local hovered = enabled and self:IsHovered()
                local danger = variant == "danger"
                local primary = variant == "primary"
                local baseColor = danger and Color(203, 78, 78) or accent
                local background
                local outline
                local foreground
                if primary then
                    background = enabled and Color(baseColor.r, baseColor.g, baseColor.b, hovered and 235 or 205) or Color(35, 49, 52, 210)
                    outline = enabled and Color(baseColor.r, baseColor.g, baseColor.b, 255) or Color(255, 255, 255, 18)
                    foreground = enabled and color_white or Color(108, 123, 124)
                else
                    background = hovered and Color(baseColor.r, baseColor.g, baseColor.b, danger and 18 or 24) or Color(3, 16, 21, 185)
                    outline = enabled and Color(baseColor.r, baseColor.g, baseColor.b, hovered and 125 or 68) or Color(255, 255, 255, 18)
                    foreground = enabled and (danger and baseColor or textColor) or Color(108, 123, 124)
                end

                drawPermissionsPanel(0, 0, w, h, 6, background, outline)
                drawPermissionsIcon(iconMaterial, 12, math.floor(h * 0.5) - 8, 16, foreground)
                draw.SimpleText(label, "LiliaFont.16", w * 0.5 + 8, h * 0.5, foreground, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        local function styleComboBox(combo)
            combo:SetText("")
            combo:SetFont("LiliaFont.16")
            combo.Paint = function(self, w, h)
                local accent, textColor, mutedText = getPermissionsTheme()
                local background = self:IsHovered() and Color(accent.r, accent.g, accent.b, 18) or Color(3, 16, 21, 210)
                local value = self:GetValue()
                value = value ~= "" and value or "Select"
                drawPermissionsPanel(0, 0, w, h, 6, background, Color(accent.r, accent.g, accent.b, 68))
                draw.SimpleText(value, "LiliaFont.16", 12, h * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText("▼", "LiliaFont.15", w - 15, h * 0.5, mutedText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            if IsValid(combo.TextEntry) then
                combo.TextEntry:SetVisible(false)
                combo.TextEntry:SetPaintBackground(false)
                combo.TextEntry:SetDrawBackground(false)
                combo.TextEntry:SetTextColor(Color(0, 0, 0, 0))
                combo.TextEntry.Paint = function() end
            end

            if IsValid(combo.DropButton) then
                combo.DropButton:SetWide(0)
                combo.DropButton:SetText("")
                combo.DropButton.Paint = function() end
            end
        end

        local root = parent:Add("DPanel")
        root:Dock(FILL)
        root.Paint = function() end
        local groupBrowser = root:Add("DPanel")
        groupBrowser:Dock(LEFT)
        groupBrowser:SetWide(320)
        groupBrowser:DockMargin(0, 0, 14, 0)
        groupBrowser:DockPadding(12, 12, 12, 12)
        groupBrowser.Paint = function(_, w, h)
            local _, _, _, panel, _, border = getPermissionsTheme()
            drawPermissionsPanel(0, 0, w, h, 8, panel, border)
        end

        local groupHeader = groupBrowser:Add("DPanel")
        groupHeader:Dock(TOP)
        groupHeader:SetTall(40)
        groupHeader:DockMargin(0, 0, 0, 10)
        groupHeader.Paint = function(_, _, h)
            local accent = getPermissionsTheme()
            draw.SimpleText("PERMISSION GROUPS", "LiliaFont.17", 2, h * 0.5, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local createButton = groupHeader:Add("DButton")
        createButton:Dock(RIGHT)
        createButton:SetWide(132)
        createButton:DockMargin(0, 1, 0, 1)
        styleActionButton(createButton, "Create Group", "icon16/add.png")
        createButton.DoClick = promptCreateGroup
        local groupSearchWrap = groupBrowser:Add("DPanel")
        groupSearchWrap:Dock(TOP)
        groupSearchWrap:SetTall(44)
        groupSearchWrap:DockMargin(0, 0, 0, 10)
        groupSearchWrap:DockPadding(38, 0, 8, 0)
        groupSearchWrap.Paint = function(_, w, h)
            local accent, _, mutedText = getPermissionsTheme()
            drawPermissionsPanel(0, 0, w, h, 6, Color(3, 16, 21, 210), Color(accent.r, accent.g, accent.b, 68))
            drawPermissionsIcon(searchIcon, 13, math.floor(h * 0.5) - 8, 16, mutedText)
        end

        local groupSearchEntry = groupSearchWrap:Add("DTextEntry")
        groupSearchEntry:Dock(FILL)
        groupSearchEntry:SetFont("LiliaFont.17")
        groupSearchEntry:SetPlaceholderText("Search groups...")
        groupSearchEntry:SetDrawBackground(false)
        groupSearchEntry:SetPaintBackground(false)
        groupSearchEntry:SetPaintBorderEnabled(false)
        groupSearchEntry.Paint = function(self, w, h)
            local accent, textColor = getPermissionsTheme()
            self:DrawTextEntryText(textColor, accent, textColor)
        end

        local groupFooter = groupBrowser:Add("DPanel")
        groupFooter:Dock(BOTTOM)
        groupFooter:SetTall(30)
        groupFooter:DockMargin(0, 8, 0, 0)
        groupFooter.Paint = function(_, w, h)
            local accent, _, mutedText = getPermissionsTheme()
            surface.SetDrawColor(accent.r, accent.g, accent.b, 24)
            surface.DrawRect(0, 0, w, 1)
            draw.SimpleText(state.groupFooterText or "", "LiliaFont.15", w * 0.5, h * 0.5 + 2, mutedText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local groupScroll = groupBrowser:Add("liaScrollPanel")
        groupScroll:Dock(FILL)
        groupScroll.Paint = function() end
        local groupCanvas = groupScroll:GetCanvas()
        groupCanvas:DockPadding(0, 0, 4, 0)
        groupCanvas.Paint = function() end
        local details = root:Add("DPanel")
        details:Dock(FILL)
        details:DockPadding(14, 14, 14, 14)
        details.Paint = function(_, w, h)
            local _, _, _, panel, _, border = getPermissionsTheme()
            drawPermissionsPanel(0, 0, w, h, 8, panel, border)
        end

        local detailHeader = details:Add("DPanel")
        detailHeader:Dock(TOP)
        detailHeader:SetTall(108)
        detailHeader:DockMargin(0, 0, 0, 12)
        state.detailHeader = detailHeader
        detailHeader.Paint = function(_, w, h)
            local accent, textColor, mutedText = getPermissionsTheme()
            drawPermissionsPanel(0, 0, w, h, 6, Color(3, 16, 21, 185), Color(accent.r, accent.g, accent.b, 68))
            local groupName = state.selectedGroup
            if not groupName then
                draw.SimpleText("Select a permission group", "LiliaFont.20", 18, h * 0.5, mutedText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                return
            end

            surface.SetDrawColor(accent.r, accent.g, accent.b, 235)
            surface.DrawRect(0, 0, 3, h)
            drawPermissionsIcon(getGroupIcon(groupName), 20, 22, 40, color_white)
            draw.SimpleText(getGroupDisplayName(groupName), "LiliaFont.25", 76, 16, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(getGroupDescription(groupName), "LiliaFont.17", 76, 48, mutedText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            local badgeX = 76
            local _, onlineWidth = drawPermissionBadge(getOnlineGroupCount(groupName) .. " online", "LiliaFont.15", badgeX, 74, 8, 2, Color(207, 224, 224), Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 54), false)
            badgeX = badgeX + onlineWidth + 8
            local inheritance = getGroupInheritance(groupName)
            local _, inheritanceWidth = drawPermissionBadge("inherits " .. getGroupDisplayName(inheritance), "LiliaFont.15", badgeX, 74, 8, 2, Color(207, 224, 224), Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 54), false)
            badgeX = badgeX + inheritanceWidth + 8
            if not state.editable then drawPermissionBadge("built-in", "LiliaFont.15", badgeX, 74, 8, 2, Color(207, 224, 224), Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 54), false) end
        end

        local headerActions = detailHeader:Add("DPanel")
        headerActions:Dock(RIGHT)
        headerActions:SetWide(254)
        headerActions:DockMargin(0, 34, 14, 34)
        headerActions.Paint = function() end
        local deleteButton = headerActions:Add("DButton")
        deleteButton:Dock(RIGHT)
        deleteButton:SetWide(118)
        styleActionButton(deleteButton, "Delete", "icon16/delete.png", "danger")
        local renameButton = headerActions:Add("DButton")
        renameButton:Dock(FILL)
        renameButton:DockMargin(0, 0, 8, 0)
        styleActionButton(renameButton, "Rename", "icon16/pencil.png")
        local filters = details:Add("DPanel")
        filters:Dock(TOP)
        filters:SetTall(46)
        filters:DockMargin(0, 0, 0, 10)
        filters.Paint = function() end
        local visibilityCombo = filters:Add("liaComboBox")
        visibilityCombo:Dock(RIGHT)
        visibilityCombo:SetWide(164)
        styleComboBox(visibilityCombo)
        visibilityCombo:AddChoice("All Permissions", "all", true)
        visibilityCombo:AddChoice("Changed Only", "changed")
        visibilityCombo:AddChoice("Enabled", "enabled")
        visibilityCombo:AddChoice("Disabled", "disabled")
        visibilityCombo:SetValue("All Permissions")
        local categoryCombo = filters:Add("liaComboBox")
        categoryCombo:Dock(RIGHT)
        categoryCombo:SetWide(190)
        categoryCombo:DockMargin(10, 0, 10, 0)
        styleComboBox(categoryCombo)
        local searchWrap = filters:Add("DPanel")
        searchWrap:Dock(FILL)
        searchWrap:DockPadding(38, 0, 8, 0)
        searchWrap.Paint = function(_, w, h)
            local accent, _, mutedText = getPermissionsTheme()
            drawPermissionsPanel(0, 0, w, h, 6, Color(3, 16, 21, 210), Color(accent.r, accent.g, accent.b, 68))
            drawPermissionsIcon(searchIcon, 13, math.floor(h * 0.5) - 8, 16, mutedText)
        end

        local searchEntry = searchWrap:Add("DTextEntry")
        searchEntry:Dock(FILL)
        searchEntry:SetFont("LiliaFont.17")
        searchEntry:SetPlaceholderText("Search permissions...")
        searchEntry:SetDrawBackground(false)
        searchEntry:SetPaintBackground(false)
        searchEntry:SetPaintBorderEnabled(false)
        searchEntry.Paint = function(self, w, h)
            local accent, textColor = getPermissionsTheme()
            self:DrawTextEntryText(textColor, accent, textColor)
        end

        local footer = details:Add("DPanel")
        footer:Dock(BOTTOM)
        footer:SetTall(54)
        footer:DockMargin(0, 10, 0, 0)
        footer.Paint = function(_, w, h)
            local accent = getPermissionsTheme()
            surface.SetDrawColor(accent.r, accent.g, accent.b, 24)
            surface.DrawRect(0, 0, w, 1)
        end

        local saveButton = footer:Add("DButton")
        saveButton:Dock(RIGHT)
        saveButton:SetWide(170)
        saveButton:DockMargin(10, 9, 0, 7)
        styleActionButton(saveButton, "Save Changes", "icon16/disk.png", "primary")
        local resetButton = footer:Add("DButton")
        resetButton:Dock(RIGHT)
        resetButton:SetWide(112)
        resetButton:DockMargin(0, 9, 0, 7)
        styleActionButton(resetButton, "Reset", "icon16/arrow_refresh.png")
        local statusLabel = footer:Add("DLabel")
        statusLabel:Dock(FILL)
        statusLabel:SetFont("LiliaFont.17")
        statusLabel:SetContentAlignment(4)
        statusLabel.Think = function(self)
            local _, _, mutedText = getPermissionsTheme()
            self:SetTextColor(mutedText)
        end

        local privilegeContainer = details:Add("DPanel")
        privilegeContainer:Dock(FILL)
        privilegeContainer.Paint = function() end
        local function clearGroupList()
            for _, child in ipairs(groupCanvas:GetChildren()) do
                child:Remove()
            end
        end

        local function getPrivilegeTotals(groupName)
            local total = 0
            local enabled = 0
            for _, category in ipairs(computeCategoryMap(lia.admin.groups or {})) do
                for _, privilege in ipairs(category.items) do
                    total = total + 1
                    if getPendingValue(state, groupName, privilege) then enabled = enabled + 1 end
                end
            end
            return total, enabled
        end

        state.updateFooter = function()
            if not state.selectedGroup then
                statusLabel:SetText("")
                saveButton:SetEnabled(false)
                resetButton:SetEnabled(false)
                return
            end

            local total, enabled = getPrivilegeTotals(state.selectedGroup)
            local pendingCount = countPendingChanges(state)
            local suffix = pendingCount > 0 and ("    |    " .. pendingCount .. " unsaved change" .. (pendingCount == 1 and "" or "s")) or ""
            statusLabel:SetText(total .. " permissions    |    " .. enabled .. " enabled" .. suffix)
            saveButton:SetEnabled(pendingCount > 0)
            resetButton:SetEnabled(state.pending[state.selectedGroup] and next(state.pending[state.selectedGroup]) ~= nil or false)
        end

        state.rebuildList = function()
            if not state.selectedGroup then
                privilegeContainer:Clear()
                state.updateFooter()
                return
            end

            state.editable = not (lia.admin.DefaultGroups and lia.admin.DefaultGroups[state.selectedGroup] ~= nil)
            buildPrivilegeList(privilegeContainer, state)
            state.updateFooter()
            detailHeader:InvalidateLayout(true)
        end

        state.rebuildCategoryFilter = function()
            state.rebuildingCategoryFilter = true
            categoryCombo:Clear()
            categoryCombo:AddChoice("All Categories", false)
            for _, category in ipairs(computeCategoryMap(lia.admin.groups or {})) do
                categoryCombo:AddChoice(tostring(category.label), category.label)
            end

            categoryCombo:SetValue(state.selectedCategory or "All Categories")
            state.rebuildingCategoryFilter = false
        end

        state.rebuildCategories = function() state.rebuildCategoryFilter() end
        local groupButtons = {}
        state.rebuildGroups = function()
            clearGroupList()
            groupButtons = {}
            local groups = lia.admin.groups or {}
            local keys = {}
            for groupName in pairs(groups) do
                keys[#keys + 1] = groupName
            end

            table.sort(keys, function(a, b) return getGroupDisplayName(a):lower() < getGroupDisplayName(b):lower() end)
            if not state.selectedGroup or not groups[state.selectedGroup] then state.selectedGroup = keys[1] end
            state.editable = state.selectedGroup ~= nil and not (lia.admin.DefaultGroups and lia.admin.DefaultGroups[state.selectedGroup] ~= nil)
            local query = string.lower(string.Trim(state.groupSearch or ""))
            local visibleGroups = 0
            for _, groupName in ipairs(keys) do
                local displayName = getGroupDisplayName(groupName)
                local description = getGroupDescription(groupName)
                local haystack = string.lower(displayName .. " " .. groupName .. " " .. description)
                if query == "" or string.find(haystack, query, 1, true) then
                    visibleGroups = visibleGroups + 1
                    local button = groupCanvas:Add("DButton")
                    button:Dock(TOP)
                    button:SetTall(74)
                    button:DockMargin(0, 0, 0, 7)
                    button:SetText("")
                    button.Paint = function(self, w, h)
                        local accent, textColor, mutedText = getPermissionsTheme()
                        local selected = state.selectedGroup == groupName
                        local hovered = self:IsHovered()
                        local background = selected and Color(accent.r, accent.g, accent.b, 28) or hovered and Color(255, 255, 255, 7) or Color(3, 16, 21, 185)
                        local outline = selected and Color(accent.r, accent.g, accent.b, 120) or Color(accent.r, accent.g, accent.b, 48)
                        drawPermissionsPanel(0, 0, w, h, 6, background, outline)
                        if selected then
                            surface.SetDrawColor(accent.r, accent.g, accent.b, 240)
                            surface.DrawRect(0, 7, 3, h - 14)
                        end

                        drawPermissionsIcon(getGroupIcon(groupName), 14, math.floor(h * 0.5) - 12, 24, selected and color_white or Color(165, 186, 186))
                        draw.SimpleText(displayName, "LiliaFont.18", 50, 14, selected and textColor or Color(207, 222, 222), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        draw.SimpleText(description, "LiliaFont.15", 50, 40, mutedText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        drawPermissionBadge(tostring(getOnlineGroupCount(groupName)), "LiliaFont.15", w - 10, 23, 8, 2, selected and textColor or Color(189, 208, 208), Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, selected and 90 or 45), true)
                    end

                    button.DoClick = function()
                        if state.selectedGroup == groupName then return end
                        state.selectedGroup = groupName
                        state.selectedCategory = nil
                        state.editable = not (lia.admin.DefaultGroups and lia.admin.DefaultGroups[groupName] ~= nil)
                        renameButton:SetEnabled(state.editable)
                        deleteButton:SetEnabled(state.editable)
                        for _, groupButton in ipairs(groupButtons) do
                            if IsValid(groupButton) then groupButton:InvalidateLayout(true) end
                        end

                        state.rebuildCategories()
                        state.rebuildList()
                    end

                    groupButtons[#groupButtons + 1] = button
                end
            end

            state.groupFooterText = visibleGroups == #keys and (#keys .. " groups total") or (visibleGroups .. " of " .. #keys .. " groups")
            groupFooter:InvalidateLayout(true)
            renameButton:SetEnabled(state.editable)
            deleteButton:SetEnabled(state.editable)
            state.rebuildCategories()
            state.rebuildList()
            groupCanvas:InvalidateLayout(true)
            groupScroll:InvalidateLayout(true)
        end

        groupSearchEntry.OnChange = function(entry)
            state.groupSearch = entry:GetValue()
            state.rebuildGroups()
        end

        searchEntry.OnChange = function(entry)
            state.search = entry:GetValue()
            state.rebuildList()
        end

        visibilityCombo.OnSelect = function(_, _, _, data)
            state.filter = data or "all"
            state.rebuildList()
        end

        categoryCombo.OnSelect = function(_, _, value, data)
            if state.rebuildingCategoryFilter then return end
            state.selectedCategory = data == false and nil or data
            categoryCombo:SetValue(value or "All Categories")
            state.rebuildList()
        end

        renameButton.DoClick = function()
            local groupName = state.selectedGroup
            if not groupName then return end
            if lia.admin.DefaultGroups[groupName] then
                LocalPlayer():notifyErrorLocalized("baseUsergroupCannotBeRenamed")
                return
            end

            LocalPlayer():requestString(L("rename") .. " " .. L("group"), L("renameGroupPrompt", groupName) .. ":", function(textValue)
                textValue = string.Trim(textValue or "")
                if textValue ~= "" and textValue ~= groupName then
                    net.Start("liaGroupsRename")
                    net.WriteString(groupName)
                    net.WriteString(textValue)
                    net.SendToServer()
                end
            end, groupName)
        end

        deleteButton.DoClick = function()
            local groupName = state.selectedGroup
            if not groupName then return end
            if lia.admin.DefaultGroups[groupName] then
                LocalPlayer():notifyErrorLocalized("baseUsergroupCannotBeRemoved")
                return
            end

            LocalPlayer():requestString("@confirm", L("deleteGroupPrompt", groupName), function(value)
                local normalizedValue = isstring(value) and value:Trim():lower() or ""
                if normalizedValue == string.lower(L("yes")) then
                    net.Start("liaGroupsRemove")
                    net.WriteString(groupName)
                    net.SendToServer()
                end
            end)
        end

        resetButton.DoClick = function()
            if not state.selectedGroup then return end
            state.pending[state.selectedGroup] = {}
            state.rebuildList()
        end

        saveButton.DoClick = function()
            if countPendingChanges(state) == 0 then return end
            for groupName, changes in pairs(state.pending) do
                for privilege, value in pairs(changes) do
                    net.Start("liaGroupsSetPerm")
                    net.WriteString(groupName)
                    net.WriteString(privilege)
                    net.WriteBool(value)
                    net.SendToServer()
                end
            end

            state.pending = {}
            state.rebuildList()
        end

        parent.refreshTabs = state.rebuildGroups
        parent.refreshInterface = function()
            if not state.selectedGroup then
                state.rebuildGroups()
                return
            end

            state.rebuildCategories()
            state.rebuildList()
            detailHeader:InvalidateLayout(true)
        end

        state.rebuildGroups()
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
                parent:DockPadding(0, 0, 0, 0)
                parent.Paint = function() end
                SetupUserGroupInterface(parent)
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

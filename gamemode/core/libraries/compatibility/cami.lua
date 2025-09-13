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

local function defaultAccessHandler(actor, privilege, callback, _, extra)
    local grp = "user"
    if IsValid(actor) then
        if actor.getUserGroup then
            grp = tostring(actor:getUserGroup() or "user")
        elseif actor.GetUserGroup then
            grp = tostring(actor:GetUserGroup() or "user")
        end
    end

    local allow
    if tostring(grp):lower() == "superadmin" then
        allow = true
    else
        local g = lia.administrator.groups and lia.administrator.groups[grp] or nil
        if g and g[privilege] == true then
            allow = true
        else
            local min = lia.administrator.privileges and lia.administrator.privileges[privilege] or "user"
            allow = shouldGrant(grp, min)
        end
    end

    if istable(extra) and (extra.isUse or extra.IsUse or extra.use) then if IsValid(actor) and actor:IsFrozen() then allow = false end end
    if isfunction(callback) then callback(allow, "lia") end
    return true
end

hook.Add("CAMI.PlayerHasAccess", "liaAdminAccess", defaultAccessHandler)
hook.Add("CAMI.OnUsergroupRegistered", "liaAdminUGAdded", function(usergroup)
    local ug = usergroup or {}
    local n = ug.Name
    if not isstring(n) or n == "" then return end
    if not lia.administrator.groups[n] then
        lia.administrator.groups[n] = {
            _info = {
                inheritance = ug.Inherits or "user",
                types = {}
            }
        }

        lia.administrator.applyInheritance(n)
        if SERVER then
            lia.administrator.save()
            lia.administrator.sync()
        end
    end
end)

hook.Add("CAMI.OnUsergroupUnregistered", "liaAdminUGRemoved", function(usergroup)
    local ug = usergroup or {}
    local n = ug.Name
    if not isstring(n) or n == "" then return end
    if lia.administrator.groups[n] and not lia.administrator.DefaultGroups[n] then
        lia.administrator.groups[n] = nil
        if SERVER then
            lia.administrator.save()
            lia.administrator.sync()
        end
    end
end)

hook.Add("CAMI.OnPrivilegeRegistered", "liaAdminPrivAdded", function(priv)
    local name = priv and priv.Name
    if not isstring(name) or name == "" then return end
    if lia.administrator.privileges[name] ~= nil then return end
    local min = tostring(priv.MinAccess or "user"):lower()
    lia.administrator.privileges[name] = min
    for groupName in pairs(lia.administrator.groups or {}) do
        if shouldGrant(groupName, min) then lia.administrator.groups[groupName][name] = true end
    end

    if SERVER then
        lia.administrator.save()
        lia.administrator.sync()
    end
end)

hook.Add("CAMI.OnPrivilegeUnregistered", "liaAdminPrivRemoved", function(priv)
    local name = priv and priv.Name
    if not isstring(name) or name == "" then return end
    if lia.administrator.privileges[name] == nil then return end
    lia.administrator.privileges[name] = nil
    for _, g in pairs(lia.administrator.groups or {}) do
        g[name] = nil
    end

    if SERVER then
        lia.administrator.save()
        lia.administrator.sync()
    end
end)

hook.Add("CAMI.PlayerUsergroupChanged", "liaAdminPlyUGChanged", function(ply, _, new)
    if not SERVER then return end
    if not IsValid(ply) then return end
    local newGroup = tostring(new or "user")
    if tostring(ply:GetUserGroup() or "user") ~= newGroup then ply:SetUserGroup(newGroup) end
    lia.db.query(Format("UPDATE lia_players SET userGroup = '%s' WHERE steamID = %s", lia.db.escape(newGroup), lia.db.convertDataType(ply:SteamID())))
end)

hook.Add("CAMI.SteamIDUsergroupChanged", "liaAdminSIDUGChanged", function(steamId, _, new)
    if not SERVER then return end
    local sid = tostring(steamId or "")
    if sid == "" then return end
    local newGroup = tostring(new or "user")
    local ply = lia.util.getBySteamID(sid)
    if IsValid(ply) and tostring(ply:GetUserGroup() or "user") ~= newGroup then ply:SetUserGroup(newGroup) end
    lia.db.query(Format("UPDATE lia_players SET userGroup = '%s' WHERE steamID = %s", lia.db.escape(newGroup), lia.db.convertDataType(sid)))
end)
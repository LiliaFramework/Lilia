CAMI.ULX_TOKEN = "ULX"
local function ulxPlayerHasAccess(_, actorPly, privilegeName, callback)
    local allowed = ULib.ucl.query(actorPly, privilegeName:lower(), true)
    callback(allowed, CAMI.ULX_TOKEN)
    return true
end

hook.Add("CAMI.PlayerHasAccess", "ULXCamiPlayerHasAccess", ulxPlayerHasAccess)
local function ulxSteamIDHasAccess(_, steamID, privilegeName, callback)
    local id = steamID:upper()
    if not ULib.isValidSteamID(id) then return end
    local ply = ULib.getPlyByID(id)
    if ply then return ulxPlayerHasAccess(_, ply, privilegeName, callback) end
end

hook.Add("CAMI.SteamIDHasAccess", "ULXCamiSteamidHasAccess", ulxSteamIDHasAccess)
if SERVER then
    local function onUsergroupRegistered(cGroup, origin)
        if origin == CAMI.ULX_TOKEN then return end
        if ULib.findInTable({"superadmin", "admin", "user"}, cGroup.Name) then return end
        if not ULib.ucl.groups[cGroup.Name] then ULib.ucl.addGroup(cGroup.Name, nil, cGroup.Inherits, true) end
    end

    hook.Add("CAMI.OnUsergroupRegistered", "ULXCamiGroupRegistered", onUsergroupRegistered)
    local function onUsergroupUnregistered(cGroup, origin)
        if origin == CAMI.ULX_TOKEN then return end
        if ULib.findInTable({"superadmin", "admin", "user"}, cGroup.Name) then return end
        ULib.ucl.removeGroup(cGroup.Name, true)
    end

    hook.Add("CAMI.OnUsergroupUnregistered", "ULXCamiGroupRemoved", onUsergroupUnregistered)
    local function syncSteamIDGroup(id, _, newGroup, origin)
        if origin == CAMI.ULX_TOKEN then return end
        if newGroup == ULib.ACCESS_ALL then
            if ULib.ucl.users[id] then ULib.ucl.removeUser(id, true) end
        else
            if not ULib.ucl.groups[newGroup] then
                local cg = CAMI.GetUsergroup(newGroup)
                ULib.ucl.addGroup(newGroup, nil, cg and cg.Inherits or "user", true)
            end

            ULib.ucl.addUser(id, nil, nil, newGroup, true)
        end
    end

    hook.Add("CAMI.SteamIDUsergroupChanged", "ULXCamiSteamidUserGroupChanged", syncSteamIDGroup)
    hook.Add("CAMI.PlayerUsergroupChanged", "ULXCamiPlayerUserGroupChanged", function(ply, _, newGroup, origin)
        if not IsValid(ply) or origin == CAMI.ULX_TOKEN then return end
        local id = ULib.ucl.getUserRegisteredID(ply) or ply:SteamID()
        syncSteamIDGroup(id, _, newGroup, origin)
    end)

    local function onPrivilegeRegistered(cPriv)
        ULib.ucl.registerAccess(cPriv.Name:lower(), cPriv.MinAccess, "CAMI privilege", "CAMI")
    end

    hook.Add("CAMI.OnPrivilegeRegistered", "ULXCamiPrivilegeRegistered", onPrivilegeRegistered)
    for _, priv in pairs(CAMI.GetPrivileges()) do
        onPrivilegeRegistered(priv)
    end

    for _, group in pairs(CAMI.GetUsergroups()) do
        onUsergroupRegistered(group, CAMI.ULX_TOKEN)
    end

    for name, data in pairs(ULib.ucl.groups) do
        if not ULib.findInTable({"superadmin", "admin", "user"}, name) then
            CAMI.RegisterUsergroup({
                Name = name,
                Inherits = data.inherit_from or "user"
            }, CAMI.ULX_TOKEN)
        end
    end
end
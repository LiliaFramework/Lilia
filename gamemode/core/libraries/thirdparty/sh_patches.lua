if true then return end
local NULL = NULL
local math_random = math.random
local next, pairs, rawset, istable, _ = next, pairs, rawset, istable, ipairs
do
    local mmin, mmax = math.min, math.max
    function math.Clamp(_in, low, high)
        return mmin(mmax(_in, low), high)
    end
end

do
    local length, index = 0, 1
    function table.Shuffle(tbl)
        length = #tbl
        for i = length, 1, -1 do
            index = math_random(1, length)
            tbl[i], tbl[index] = tbl[index], tbl[i]
        end
        return tbl
    end

    local keys = setmetatable({}, {
        __mode = "v"
    })

    function table.Random(tbl, issequential)
        if issequential then
            length = #tbl
            if length == 0 then return end
            index = 1
            if length > 1 then index = math_random(1, length) end
        else
            if next(tbl) == nil then return end
            length, index = 0, 1
            for key in pairs(tbl) do
                length = length + 1
                keys[length] = key
            end

            if length == 1 then
                index = keys[1]
            else
                index = keys[math_random(1, length)]
            end
        end
        return tbl[index], index
    end
end

function table.Random(tbl, issequential)
    local keys = issequential and tbl or table.GetKeys(tbl)
    local rand = keys[math_random(1, #keys)]
    return tbl[rand], rand
end

if SERVER then
    local R = debug.getregistry()
    local ENTITY = R.Entity
    RunConsoleCommand("sv_defaultdeployspeed", "1")
    CreateConVar("room_type", "0")
    scripted_ents.Register({
        ["Base"] = "base_point",
        ["Type"] = "point"
    }, "info_ladder")

    do
        local meta = FindMetaTable("Player")
        CUserID = CUserID or meta.UserID
        CSteamID64 = CSteamID64 or meta.SteamID64
        CSteamID = CSteamID or meta.SteamID
        local UserID, SteamID64, SteamID = CUserID, CSteamID64, CSteamID
        function meta:UserID()
            return self.__UserID or UserID(self)
        end

        function meta:SteamID64()
            return self.__SteamID64 or SteamID64(self)
        end

        function meta:SteamID()
            return self.__SteamID or SteamID(self)
        end

        local function Cache(ply)
            ply.__UserID = UserID(ply)
            ply.__SteamID64 = SteamID64(ply)
            ply.__SteamID = SteamID(ply)
        end

        hook.Add("PlayerInitialSpawn", "Lilia CacheUserID", Cache, HOOK_MONITOR_HIGH)
        hook.Add("PlayerAuthed", "Lilia CacheUserID", Cache, HOOK_MONITOR_HIGH)
    end

    local CEntityGetInternalVariable = ENTITY.GetInternalVariable
    local CEntityGetClass = ENTITY.GetClass
    do
        local mapIsCleaning = false
        hook.Add("PreCleanupMap", "Lilia Area Portal Fix", function() mapIsCleaning = true end)
        hook.Add("PostCleanupMap", "Lilia Area Portal Fix", function() mapIsCleaning = false end)
        local doorClasses = {
            ["func_door_rotating"] = true,
            ["prop_door_rotating"] = true,
            ["func_movelinear"] = true,
            ["func_door"] = true
        }

        local ents_FindByClass = ents.FindByClass
        hook.Add("EntityRemoved", "Lilia Area Portal Fix", function(ent)
            if mapIsCleaning then return end
            if ent and ent:IsValid() and doorClasses[CEntityGetClass(ent)] then
                local name = ent:GetName()
                if name ~= "" then
                    local portals = ents_FindByClass("func_areaportal")
                    local portal = NULL
                    for i = 1, #portals do
                        portal = portals[i]
                        if portal and CEntityGetInternalVariable(portal, "target") == name then
                            portal:SetSaveValue("target", "")
                            portal:Fire("open")
                        end
                    end
                end
            end
        end)
    end

    do
        local EFL_NO_THINK_FUNCTION = EFL_NO_THINK_FUNCTION
        local podName = "prop_vehicle_prisoner_pod"
        local CEntityAddEFlags = ENTITY.AddEFlags
        hook.Add("EntityTakeDamage", "Lilia PrisonerFix", function(ent, dmg)
            if not ent or not ent:IsValid() or ent:IsNPC() then return end
            if CEntityGetClass(ent) ~= podName or ent.AcceptDamageForce then return end
            ent:TakePhysicsDamage(dmg)
        end)

        hook.Add("OnEntityCreated", "Lilia Pod Fix", function(veh) if CEntityGetClass(veh) == podName then CEntityAddEFlags(veh, EFL_NO_THINK_FUNCTION) end end)
        hook.Add("PlayerEnteredVehicle", "Lilia Pod Fix", function(_, veh) if CEntityGetClass(veh) == podName then veh:RemoveEFlags(EFL_NO_THINK_FUNCTION) end end)
        hook.Add("PlayerLeaveVehicle", "Lilia Pod Fix", function(_, veh)
            if CEntityGetClass(veh) ~= podName then return end
            hook.Add("Think", veh, function(self)
                hook.Remove("Think", self)
                if CEntityGetInternalVariable(self, "m_bEnterAnimOn") then return end
                if CEntityGetInternalVariable(self, "m_bExitAnimOn") then return end
                CEntityAddEFlags(self, EFL_NO_THINK_FUNCTION)
            end)
        end)
    end

    do
        local CEntitySetPos = ENTITY.SetPos
        local positions = {}
        FindMetaTable("Player").SetPos = function(ply, pos) if isvector(pos) then positions[ply] = pos end end
        hook.Add("FinishMove", "Lilia SetPos Fix", function(ply)
            local pos = positions[ply]
            if not pos then return end
            CEntitySetPos(ply, pos)
            positions[ply] = nil
            return true
        end)

        hook.Add("PlayerDisconnected", "Lilia SetPos Fix", function(ply) positions[ply] = nil end)
    end
end

do
    local playerMeta = FindMetaTable("Player")
    CPlayerLagC = CPlayerLagC or playerMeta.LagCompensation
    function playerMeta:LagCompensation(bool)
        if bool and self.isLagCompensation then return end
        self.isLagCompensation = bool
        CPlayerLagC(self, bool)
    end
end

if CLIENT then
    do
        game.oldCleanUpMap = game.oldCleanUpMap or game.CleanUpMap
        local cleanUp = game.oldCleanUpMap
        local ents = {"env_fire", "entityflame", "_firesmoke"}
        function game.CleanUpMap(dontSendToClients, extraFilters)
            if istable(extraFilters) then
                local len = #extraFilters
                rawset(extraFilters, len + 1, "env_fire")
                rawset(extraFilters, len + 2, "entityflame")
                rawset(extraFilters, len + 3, "_firesmoke")
            else
                return cleanUp(dontSendToClients, ents)
            end
            return cleanUp(dontSendToClients, extraFilters)
        end
    end

    do
        cam.oldStartOrthoView = cam.oldStartOrthoView or cam.StartOrthoView
        local startOrtho = cam.oldStartOrthoView
        local camStack = 0
        function cam.StartOrthoView(a, b, c, d)
            camStack = camStack + 1
            startOrtho(a, b, c, d)
        end

        cam.oldEndOrthoView = cam.oldEndOrthoView or cam.EndOrthoView
        local endOrtho = cam.oldEndOrthoView
        function cam.EndOrthoView()
            if camStack == 0 then return end
            camStack = math.max(0, camStack - 1)
            endOrtho()
        end
    end

    do
        local ply
        local localPlayer = LocalPlayer
        function LocalPlayer()
            ply = localPlayer()
            if ply and ply:IsValid() then _G.LocalPlayer = function() return ply end end
            return ply
        end
    end

    local camStart = cam.Start
    do
        local data = {
            type = "2D"
        }

        function cam.Start2D()
            return camStart(data)
        end
    end

    do
        local tab = {
            type = "3D"
        }

        function cam.Start3D(pos, ang, fov, x, y, w, h, znear, zfar)
            tab.origin = pos
            tab.angles = ang
            if fov ~= nil then tab.fov = fov end
            if x ~= nil and y ~= nil and w ~= nil and h ~= nil then
                tab.x = x
                tab.y = y
                tab.w = w
                tab.h = h
                tab.aspect = w / h
            end

            if znear ~= nil and zfar ~= nil then
                tab.znear = znear
                tab.zfar = zfar
            end
            return camStart(tab)
        end
    end
end

do
    local isSingle = game.SinglePlayer()
    local isDedicated = game.IsDedicated()
    function game.SinglePlayer()
        return isSingle
    end

    function game.IsDedicated()
        return isDedicated
    end
end

do
    local pairs_aux = pairs({})
    local index, keys = 0, {}
    local sort = table.sort
    local function fn1(a, b)
        return a > b
    end

    local function fn2(a, b)
        return a < b
    end

    function SortedPairs(tbl, desc)
        keys, index = {}, 0
        for k in pairs_aux, tbl do
            index = index + 1
            keys[index] = k
        end

        sort(keys, desc and fn1 or fn2)
        return pairs_aux, tbl
    end
end

function widgets.PlayerTick()
end

hook.Remove("PlayerTick", "TickWidgets")
hook.Remove("PostDrawEffects", "RenderWidgets")
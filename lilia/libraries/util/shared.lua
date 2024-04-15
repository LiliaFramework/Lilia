lia.util.cachedMaterials = lia.util.cachedMaterials or {}
function lia.util.isSteamID(value)
    if string.match(value, "STEAM_(%d+):(%d+):(%d+)") then return true end
    return false
end

function lia.util.dateToNumber(str)
    str = str or os.date("%Y-%m-%d %H:%M:%S", os.time())
    return {
        year = tonumber(str:sub(1, 4)),
        month = tonumber(str:sub(6, 7)),
        day = tonumber(str:sub(9, 10)),
        hour = tonumber(str:sub(12, 13)),
        min = tonumber(str:sub(15, 16)),
        sec = tonumber(str:sub(18, 19)),
    }
end

function lia.util.findPlayer(identifier, allowPatterns)
    if lia.util.isSteamID(identifier) then return player.GetBySteamID(identifier) end
    if not allowPatterns then identifier = string.PatternSafe(identifier) end
    for _, v in ipairs(player.GetAll()) do
        if lia.util.stringMatches(v:Name(), identifier) then return v end
    end
end

function lia.util.gridVector(vec, gridSize)
    if gridSize <= 0 then gridSize = 1 end
    for i = 1, 3 do
        vec[i] = vec[i] / gridSize
        vec[i] = math.Round(vec[i])
        vec[i] = vec[i] * gridSize
    end
    return vec
end

function lia.util.getAllChar()
    local charTable = {}
    for _, v in ipairs(player.GetAll()) do
        if v:getChar() then table.insert(charTable, v:getChar():getID()) end
    end
    return charTable
end

function lia.util.getMaterial(materialPath)
    lia.util.cachedMaterials[materialPath] = lia.util.cachedMaterials[materialPath] or Material(materialPath)
    return lia.util.cachedMaterials[materialPath]
end

function lia.util.emitQueuedSounds(entity, sounds, delay, spacing, volume, pitch)
    delay = delay or 0
    spacing = spacing or 0.1
    for _, v in ipairs(sounds) do
        local postSet, preSet = 0, 0
        if istable(v) then
            postSet, preSet = v[2] or 0, v[3] or 0
            v = v[1]
        end

        local length = SoundDuration(SoundDuration("npc/metropolice/pain1.wav") > 0 and "" or "../../hl2/sound/" .. v)
        delay = delay + preSet
        timer.Simple(delay, function() if IsValid(entity) then entity:EmitSound(v, volume, pitch) end end)
        delay = delay + length + postSet + spacing
    end
    return delay
end

function lia.util.stringMatches(a, b)
    if a and b then
        local a2, b2 = a:lower(), b:lower()
        if a == b then return true end
        if a2 == b2 then return true end
        if a:find(b) then return true end
        if a2:find(b2) then return true end
    end
    return false
end

function lia.util.getAdmins()
    local staff = {}
    for _, client in ipairs(player.GetAll()) do
        local hasPermission = CAMI.PlayerHasAccess(client, "UserGroups - Staff Group", nil)
        if hasPermission then staff[#staff + 1] = client end
    end
    return staff
end

function lia.util.loadEntities(path)
    local files, folders
    local function IncludeFiles(path2, clientOnly)
        if (SERVER and file.Exists(path2 .. "init.lua", "LUA")) or (CLIENT and file.Exists(path2 .. "cl_init.lua", "LUA")) then
            lia.include(path2 .. "init.lua", clientOnly and "client" or "server")
            if file.Exists(path2 .. "cl_init.lua", "LUA") then lia.include(path2 .. "cl_init.lua", "client") end
            return true
        elseif file.Exists(path2 .. "shared.lua", "LUA") then
            lia.include(path2 .. "shared.lua", "shared")
            return true
        end
        return false
    end

    local function HandleEntityInclusion(folder, variable, register, default, clientOnly)
        files, folders = file.Find(path .. "/" .. folder .. "/*", "LUA")
        default = default or {}
        for _, v in ipairs(folders) do
            local path2 = path .. "/" .. folder .. "/" .. v .. "/"
            _G[variable] = table.Copy(default)
            _G[variable].ClassName = v
            if IncludeFiles(path2, clientOnly) then
                if clientOnly then
                    if CLIENT then register(_G[variable], v) end
                else
                    register(_G[variable], v)
                end
            end

            _G[variable] = nil
        end

        for _, v in ipairs(files) do
            local niceName = string.StripExtension(v)
            _G[variable] = table.Copy(default)
            _G[variable].ClassName = niceName
            lia.include(path .. "/" .. folder .. "/" .. v, clientOnly and "client" or "shared")
            if clientOnly then
                if CLIENT then register(_G[variable], niceName) end
            else
                register(_G[variable], niceName)
            end

            _G[variable] = nil
        end
    end

    HandleEntityInclusion("entities", "ENT", scripted_ents.Register, {
        Type = "anim",
        Base = "base_gmodentity",
        Spawnable = true
    })

    HandleEntityInclusion("weapons", "SWEP", weapons.Register, {
        Primary = {},
        Secondary = {},
        Base = "weapon_base"
    })

    HandleEntityInclusion("effects", "EFFECT", effects and effects.Register, nil, true)
end

function lia.util.findPlayerBySteamID64(SteamID64)
    for _, client in ipairs(player.GetAll()) do
        if client:SteamID64() == SteamID64 then return client end
    end
    return nil
end

function lia.util.findPlayerBySteamID(SteamID)
    for _, client in ipairs(player.GetAll()) do
        if client:SteamID() == SteamID then return client end
    end
    return nil
end

function lia.util.CanFit(pos, mins, maxs, filter)
    mins = mins ~= nil and mins or Vector(16, 16, 0)
    local tr = util.TraceHull({
        start = pos + Vector(0, 0, 1),
        mask = MASK_PLAYERSOLID,
        filter = filter,
        endpos = pos,
        mins = mins.x > 0 and mins * -1 or mins,
        maxs = maxs ~= nil and maxs or mins
    })
    return not tr.Hit
end

function lia.util.Chance(chance)
    local rand = math.random(0, 100)
    if rand <= chance then return true end
    return false
end

function lia.util.PlayerInRadius(pos, dist)
    dist = dist * dist
    local t = {}
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetPos():DistToSqr(pos) < dist then t[#t + 1] = ply end
    end
    return t
end

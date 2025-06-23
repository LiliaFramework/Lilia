if glua_ext_loaded then return end
local ENTITY = FindMetaTable("Entity")
local WEAPON = FindMetaTable("Weapon")
local NPC = FindMetaTable("NPC")
local PLAYER = FindMetaTable("Player")
local PHYS = FindMetaTable("PhysObj")
local VECTOR = FindMetaTable("Vector")
local ANGLE = FindMetaTable("Angle")
local VMATRIX = FindMetaTable("VMatrix")
local COLOR = FindMetaTable("Color")
local VEHICLE = FindMetaTable("Vehicle")
local IMATERIAL = FindMetaTable("IMaterial")
local DINFO = FindMetaTable("CTakeDamageInfo")
local EDATA = FindMetaTable("CEffectData")
local MDATA = FindMetaTable("CMoveData")
local CMD = FindMetaTable("CUserCmd")
local CONVAR = FindMetaTable("ConVar")
if CLIENT then
    PANEL = FindMetaTable("Panel")
    CSENT = FindMetaTable("CSEnt")
    IMESH = FindMetaTable("IMesh")
end

local THREAD = getmetatable(coroutine.create(function() end))
local FUNC = getmetatable(function() end)
local oldType = type
local oldID = TypeID
local getmt = getmetatable
local typeMeta = {}
local function map(mt, name)
    if mt then typeMeta[mt] = name end
end

map(VECTOR, "Vector")
map(ANGLE, "Angle")
map(VMATRIX, "VMatrix")
map(PLAYER, "Player")
map(ENTITY, "Entity")
map(WEAPON, "Weapon")
map(NPC, "NPC")
map(COLOR, "table")
map(PHYS, "PhysObj")
map(VEHICLE, "Vehicle")
map(IMATERIAL, "IMaterial")
map(DINFO, "CTakeDamageInfo")
map(EDATA, "CEffectData")
map(MDATA, "CMoveData")
map(CMD, "CUserCmd")
map(CONVAR, "ConVar")
map(FUNC, "function")
map(THREAD, "thread")
if CLIENT then
    map(PANEL, "Panel")
    map(CSENT, "CSEnt")
    map(IMESH, "IMesh")
end

function type(obj)
    if obj == nil then return "nil" end
    local mt = typeMeta[getmt(obj)]
    if mt then return mt end
    return oldType(obj)
end

local TYPE_NIL = TYPE_NIL
if jit.status() then
    local typeIDs = {}
    local function mapID(mt, id)
        if mt then typeIDs[mt] = id end
    end

    mapID(VECTOR, TYPE_VECTOR)
    mapID(ANGLE, TYPE_ANGLE)
    mapID(VMATRIX, TYPE_MATRIX)
    mapID(PLAYER, TYPE_ENTITY)
    mapID(ENTITY, TYPE_ENTITY)
    mapID(WEAPON, TYPE_ENTITY)
    mapID(NPC, TYPE_ENTITY)
    mapID(COLOR, TYPE_COLOR)
    mapID(PHYS, TYPE_PHYSOBJ)
    mapID(VEHICLE, TYPE_ENTITY)
    mapID(IMATERIAL, TYPE_MATERIAL)
    mapID(DINFO, TYPE_DAMAGEINFO)
    mapID(EDATA, TYPE_EFFECTDATA)
    mapID(MDATA, TYPE_MOVEDATA)
    mapID(CMD, TYPE_USERCMD)
    mapID(CONVAR, TYPE_CONVAR)
    if CLIENT then
        mapID(PANEL, TYPE_PANEL)
        mapID(CSENT, TYPE_ENTITY)
        mapID(IMESH, TYPE_IMESH)
    end

    function TypeID(obj)
        if obj == nil then return TYPE_NIL end
        local mt = typeIDs[getmt(obj)]
        if mt then return mt end
        return oldID(obj)
    end
else
    function TypeID(obj)
        if obj == nil then return TYPE_NIL end
        return oldID(obj)
    end
end

function table.Remove(tbl, idx)
    local n = #tbl
    local v = tbl[idx]
    if idx >= n or n == 1 then
        tbl[idx] = nil
    else
        tbl[idx] = tbl[n]
        tbl[n] = nil
    end
    return v
end

do
    local sub = string.sub
    local len = string.len
    function string.SplitString(sep, str)
        local res = {}
        local i = 1
        local last = 1
        while i <= len(str) do
            if sub(str, i, i) == sep then
                res[#res + 1] = sub(str, last, i - 1)
                last = i + 1
            end

            i = i + 1
        end

        local tail = sub(str, last)
        if tail ~= "" then res[#res + 1] = tail end
        return res
    end
end

do
    local trace = {}
    local data = {
        output = trace,
        filter = {}
    }

    function util.BlastDamageSqr(inf, atk, pos, r, dmg)
        if dmg == 0 then return end
        local _, players = player.Iterator()
        local sqr = r * r
        local info = DamageInfo()
        info:SetAttacker(atk)
        info:SetInflictor(inf)
        info:SetDamageType(DMG_BLAST)
        info:SetDamageForce(vector_up)
        info:SetDamagePosition(pos)
        data.start = pos
        data.filter[1] = inf
        for _, ply in ipairs(players) do
            if ply then
                local d2 = ply:GetPos():DistToSqr(pos)
                if d2 == 0 or d2 <= sqr then
                    local hitDmg = d2 == 0 and dmg or 0
                    if hitDmg == 0 then
                        data.filter[2] = ply
                        data.endpos = ply:NearestPoint(pos)
                        util.TraceLine(data)
                        if not trace.Hit or trace.Entity == ply then hitDmg = (r - data.endpos:Distance(pos)) / r * dmg end
                    end

                    if hitDmg > 0 then
                        info:SetDamage(hitDmg)
                        ply:TakeDamageInfo(info)
                    end
                end
            end
        end
    end
end

local functionRet = function() return false end
local functionTrue = function() return true end
ENTITY.IsPlayer = functionRet
ENTITY.IsWeapon = functionRet
ENTITY.IsNPC = functionRet
ENTITY.IsNextbot = functionRet
WEAPON.IsPlayer = functionRet
WEAPON.IsWeapon = functionTrue
WEAPON.IsNPC = functionRet
WEAPON.IsNextbot = functionRet
NPC.IsPlayer = functionRet
NPC.IsWeapon = functionRet
NPC.IsNPC = functionTrue
NPC.IsNextbot = functionRet
PLAYER.IsPlayer = functionTrue
PLAYER.IsWeapon = functionRet
PLAYER.IsNPC = functionRet
PLAYER.IsNextbot = functionRet
PHYS.IsPlayer = functionRet
PHYS.IsWeapon = functionRet
PHYS.IsNPC = functionRet
PHYS.IsNextbot = functionRet
if SERVER then
    local NEXTBOT = FindMetaTable("NextBot")
    NEXTBOT.IsPlayer = functionRet
    NEXTBOT.IsWeapon = functionRet
    NEXTBOT.IsNPC = functionRet
    NEXTBOT.IsNextbot = functionTrue
end

do
    local ipairs0 = ipairs({})
    local eCache, pCache, eN, pN
    function player.Count()
        if not pCache then
            pCache = player.GetAll()
            pN = #pCache
        end
        return pN
    end

    function ents.Count()
        if not eCache then
            eCache = ents.GetAll()
            eN = #eCache
        end
        return eN
    end

    function player.Iterator()
        if not pCache then
            pCache = player.GetAll()
            pN = #pCache
        end
        return ipairs0, pCache, 0
    end

    function ents.Iterator()
        if not eCache then
            eCache = ents.GetAll()
            eN = #eCache
        end
        return ipairs0, eCache, 0
    end

    function player.All()
        if not pCache then
            pCache = player.GetAll()
            pN = #pCache
        end
        return pN, pCache
    end

    function ents.All()
        if not eCache then
            eCache = ents.GetAll()
            eN = #eCache
        end
        return eN, eCache
    end

    local function invalidate(ent)
        if ent:IsPlayer() then pCache, pN = nil end
        eCache, eN = nil
    end

    hook.Remove("OnEntityCreated", "player.Iterator")
    hook.Remove("EntityRemoved", "player.Iterator")
    hook.Add("OnEntityCreated", "ents.Iterator", invalidate)
    hook.Add("EntityRemoved", "ents.Iterator", invalidate)
end

do
    local FrameNumber = FrameNumber
    local TraceLine = util.TraceLine
    local START, ENDV, DIR = Vector(), Vector(), Vector()
    local tr = {
        output = {},
        start = START,
        endpos = ENDV,
        filter = NULL
    }

    local lastEye, lastAim
    function PLAYER:GetEyeTrace(dist)
        if CLIENT then
            local fn = FrameNumber()
            if lastEye == fn then return tr.output end
            lastEye = fn
        end

        local ev = self:EyePos()
        local av = self:GetAimVector()
        START:Set(ev)
        ENDV:Set(ev)
        DIR:Set(av)
        DIR:Mul(dist or 32768)
        ENDV:Add(DIR)
        tr.filter = self
        TraceLine(tr)
        return tr.output
    end

    function PLAYER:GetEyeTraceNoCursor(dist)
        if CLIENT then
            local fn = FrameNumber()
            if lastAim == fn then return tr.output end
            lastAim = fn
        end

        local ev = self:EyePos()
        local ang = self:EyeAngles():Forward()
        START:Set(ev)
        ENDV:Set(ev)
        DIR:Set(ang)
        DIR:Mul(dist or 32768)
        ENDV:Add(DIR)
        tr.filter = self
        TraceLine(tr)
        return tr.output
    end
end

MAX_PLAYER_BITS = math.ceil(math.log(1 + game.MaxPlayers()) / math.log(2))
do
    local hexToNum = {}
    local numToHex = {}
    for i = 0, 255 do
        local hex = string.format("%02x", i)
        hexToNum[hex] = i
        numToHex[i] = hex
    end

    util.RGBToHex2 = function(r, g, b) return numToHex[r] .. numToHex[g] .. numToHex[b] .. "ff" end
    util.RGBToHex = function(c) return numToHex[c.r] .. numToHex[c.g] .. numToHex[c.b] .. "ff" end
    util.RGBAToHex = function(c) return numToHex[c.r] .. numToHex[c.g] .. numToHex[c.b] .. numToHex[c.a] end
    util.HexToRGB = function(h) return hexToNum[h:sub(1, 2)], hexToNum[h:sub(3, 4)], hexToNum[h:sub(5, 6)] end
    util.HexToRGBA = function(h) return hexToNum[h:sub(1, 2)], hexToNum[h:sub(3, 4)], hexToNum[h:sub(5, 6)], hexToNum[h:sub(7, 8)] end
end

glua_ext_loaded = true

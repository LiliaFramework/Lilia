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
local typeMeta = {
    [getmt("")] = "string",
    [getmt(0)] = "number",
    [getmt(false)] = "boolean",
    [FUNC] = "function",
    [THREAD] = "thread",
    [VECTOR] = "Vector",
    [ANGLE] = "Angle",
    [VMATRIX] = "VMatrix",
    [PLAYER] = "Player",
    [ENTITY] = "Entity",
    [WEAPON] = "Weapon",
    [NPC] = "NPC",
    [COLOR] = "table",
    [PHYS] = "PhysObj",
    [VEHICLE] = "Vehicle",
    [IMATERIAL] = "IMaterial",
    [DINFO] = "CTakeDamageInfo",
    [EDATA] = "CEffectData",
    [MDATA] = "CMoveData",
    [CMD] = "CUserCmd",
    [CONVAR] = "ConVar"
}

if CLIENT then
    typeMeta[PANEL] = "Panel"
    typeMeta[CSENT] = "CSEnt"
    typeMeta[IMESH] = "IMesh"
end

function type(obj)
    if obj == nil then return "nil" end
    return typeMeta[getmt(obj)] or oldType(obj)
end

if jit.status() then
    local TYPE_NIL = TYPE_NIL
    local oldTypeID = oldID
    local typeIDs = {
        [getmt("")] = TYPE_STRING,
        [getmt(0)] = TYPE_NUMBER,
        [getmt(false)] = TYPE_BOOL,
        [FUNC] = TYPE_FUNCTION,
        [THREAD] = TYPE_THREAD,
        [VECTOR] = TYPE_VECTOR,
        [ANGLE] = TYPE_ANGLE,
        [VMATRIX] = TYPE_MATRIX,
        [PLAYER] = TYPE_ENTITY,
        [ENTITY] = TYPE_ENTITY,
        [WEAPON] = TYPE_ENTITY,
        [NPC] = TYPE_ENTITY,
        [COLOR] = TYPE_COLOR,
        [PHYS] = TYPE_PHYSOBJ,
        [VEHICLE] = TYPE_ENTITY,
        [IMATERIAL] = TYPE_MATERIAL,
        [DINFO] = TYPE_DAMAGEINFO,
        [EDATA] = TYPE_EFFECTDATA,
        [MDATA] = TYPE_MOVEDATA,
        [CMD] = TYPE_USERCMD,
        [CONVAR] = TYPE_CONVAR
    }

    if CLIENT then
        typeIDs[PANEL] = TYPE_PANEL
        typeIDs[CSENT] = TYPE_ENTITY
        typeIDs[IMESH] = TYPE_IMESH
    end

    function TypeID(obj)
        if obj == nil then return TYPE_NIL end
        return typeIDs[getmt(obj)] or oldTypeID(obj)
    end
else
    local TYPE_NIL = TYPE_NIL
    local oldTypeID = oldID
    function TypeID(obj)
        if obj == nil then return TYPE_NIL end
        return oldTypeID(obj)
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
    local sub, len = string.sub, string.len
    function string.SplitString(sep, str)
        local res, i, last = {}, 1, 1
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
    local trace, data = {}, {
        output = trace,
        filter = {}
    }

    function util.BlastDamageSqr(inf, atk, pos, r, dmg)
        if dmg == 0 then return end
        local _, players = player.Iterator()
        local sqr, info = r * r, DamageInfo()
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
    local FrameNumber, TraceLine = FrameNumber, util.TraceLine
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
    local hexToNum, numToHex = {}, {}
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
local MODULE = MODULE

local DATA_KEY = "secondary_bases"
local REQUIRED_FLAG = lia.config and lia.config.get and lia.config.get("SecondaryBasesFlag", "S") or "S"

function MODULE:LoadData()
    self.bases = lia.data.get(DATA_KEY, {}) or {}
    -- ensure numeric ids
    for i, b in ipairs(self.bases) do
        if not b.id then b.id = i end
    end
end

function MODULE:SaveData()
    lia.data.set(DATA_KEY, self.bases or {})
end

local function playerHasPermission(ply)
    if not IsValid(ply) then return false end
    local char = ply:getChar()
    if not char then return false end
    if not char:hasFlags(REQUIRED_FLAG) then return false end
    if not ply:IsAdmin() then return false end
    return true
end

local function sendFullList(target)
    net.Start("liaSecondaryBases_Sync")
    local bases = MODULE.bases or {}
    net.WriteUInt(#bases, 16)
    for i = 1, #bases do
        local b = bases[i]
        net.WriteUInt(b.id or i, 32)
        net.WriteString(b.name or "")
        net.WriteBool(not not b.enabled)
        net.WriteString(b.map or "")
        local factions = b.factions or {}
        net.WriteUInt(#factions, 16)
        for j = 1, #factions do net.WriteString(tostring(factions[j])) end
        net.WriteType(b.pos or nil)
        net.WriteType(b.ang or nil)
    end
    if target then net.Send(target) else net.Broadcast() end
end

net.Receive("liaSecondaryBases_RequestList", function(len, ply)
    if not playerHasPermission(ply) then return end
    sendFullList(ply)
end)

net.Receive("liaSecondaryBases_Toggle", function(len, ply)
    if not playerHasPermission(ply) then return end
    local id = net.ReadUInt(32)
    local enabled = net.ReadBool()
    if not MODULE.bases then MODULE.bases = {} end
    for i, b in ipairs(MODULE.bases) do
        if b.id == id then
            b.enabled = enabled
            MODULE:SaveData()
            sendFullList()
            return
        end
    end
end)

net.Receive("liaSecondaryBases_Remove", function(len, ply)
    if not playerHasPermission(ply) then return end
    local id = net.ReadUInt(32)
    if not MODULE.bases then MODULE.bases = {} end
    for i, b in ipairs(MODULE.bases) do
        if b.id == id then
            table.remove(MODULE.bases, i)
            MODULE:SaveData()
            sendFullList()
            return
        end
    end
end)

net.Receive("liaSecondaryBases_Create", function(len, ply)
    if not playerHasPermission(ply) then return end
    local name = net.ReadString()
    local map = net.ReadString()
    local pos = net.ReadVector()
    local ang = net.ReadAngle()
    local fcount = net.ReadUInt(16)
    local factions = {}
    for i = 1, fcount do factions[i] = net.ReadString() end
    MODULE.bases = MODULE.bases or {}
    local newid = 1
    for _, b in ipairs(MODULE.bases) do newid = math.max(newid, (b.id or 0) + 1) end
    local entry = {
        id = newid,
        name = name,
        map = map,
        pos = pos,
        ang = ang,
        factions = factions,
        enabled = true
    }
    table.insert(MODULE.bases, entry)
    MODULE:SaveData()
    sendFullList()
    if ply.notifySuccess then
        ply:notifySuccess("Secondary base '" .. tostring(name or "") .. "' created.")
    end
end)

local function factionForPlayer(ply)
    for _, info in ipairs(lia.faction.indices or {}) do
        if info.index == ply:Team() then return info.uniqueID end
    end
    return nil
end

net.Receive("liaSecondaryBases_RequestAvailable", function(len, ply)
    if not IsValid(ply) then return end
    local out = {}
    local curMap = lia.data.getEquivalencyMap(game.GetMap()):lower()
    local playerFac = factionForPlayer(ply)
    for _, b in ipairs(MODULE.bases or {}) do
        if not b then continue end
        if not b.enabled then continue end
        if b.map and b.map ~= "" and tostring(b.map):lower() ~= curMap then continue end
        local hasFaction = false
        if not b.factions or #b.factions == 0 then hasFaction = true else
            for _, f in ipairs(b.factions) do if tostring(f) == tostring(playerFac) then hasFaction = true break end end
        end
        if not hasFaction then continue end
        -- validate position
        local pos = b.pos
        if not isvector(pos) then
            local decoded = nil
            local ok, res = pcall(lia.data.decodeVector, pos)
            if ok then decoded = res end
            pos = decoded
        end
        if not isvector(pos) then continue end
        table.insert(out, b)
    end

    net.Start("liaSecondaryBases_Available")
    net.WriteUInt(#out, 16)
    for i = 1, #out do
        local b = out[i]
        net.WriteUInt(b.id or i, 32)
        net.WriteString(b.name or "")
        net.WriteString(b.map or "")
        net.WriteType(b.pos or nil)
        net.WriteType(b.ang or nil)
    end
    net.Send(ply)
end)

net.Receive("liaSecondaryBases_MapViewRequest", function(len, ply)
    if not IsValid(ply) then return end
    -- prepare bases for current map and compute bounds from saved base positions
    local curMap = lia.data.getEquivalencyMap(game.GetMap()):lower()
    local out = {}
    local minx, miny, minz, maxx, maxy, maxz
    for _, b in ipairs(MODULE.bases or {}) do
        if not b then continue end
        if b.map and b.map ~= "" and tostring(b.map):lower() ~= curMap then continue end
        local pos = b.pos
        if not isvector(pos) then
            local ok, res = pcall(lia.data.decodeVector, pos)
            if ok then pos = res end
        end
        if not isvector(pos) then continue end
        out[#out + 1] = {id = b.id, name = b.name, pos = pos, enabled = b.enabled, factions = b.factions or {}}
        minx = math.min(minx or pos.x, pos.x)
        miny = math.min(miny or pos.y, pos.y)
        minz = math.min(minz or pos.z, pos.z)
        maxx = math.max(maxx or pos.x, pos.x)
        maxy = math.max(maxy or pos.y, pos.y)
        maxz = math.max(maxz or pos.z, pos.z)
    end

    -- fallback bounds
    if not minx then
        minx, miny, minz = -1024, -1024, -1024
        maxx, maxy, maxz = 1024, 1024, 1024
    else
        -- pad bounds
        local pad = 256
        minx = minx - pad
        miny = miny - pad
        maxx = maxx + pad
        maxy = maxy + pad
    end

    net.Start("liaSecondaryBases_MapViewResponse")
    net.WriteUInt(#out, 16)
    for i = 1, #out do
        local b = out[i]
        net.WriteUInt(b.id or 0, 32)
        net.WriteString(b.name or "")
        net.WriteVector(b.pos)
        net.WriteBool(not not b.enabled)
        local facs = b.factions or {}
        net.WriteUInt(#facs, 16)
        for j = 1, #facs do net.WriteString(tostring(facs[j])) end
    end
    net.WriteVector(Vector(minx, miny, minz))
    net.WriteVector(Vector(maxx, maxy, maxz))
    net.Send(ply)
end)

net.Receive("liaSecondaryBases_Select", function(len, ply)
    if not IsValid(ply) then return end
    local id = net.ReadUInt(32)
    local selected = nil
    for _, b in ipairs(MODULE.bases or {}) do if b.id == id then selected = b break end end
    if not selected then
        if ply.notifyError then ply:notifyError("Invalid secondary base.") end
        return
    end
    if not selected.enabled then if ply.notifyError then ply:notifyError("That secondary base is disabled.") end return end
    local curMap = lia.data.getEquivalencyMap(game.GetMap()):lower()
    if selected.map and selected.map ~= "" and tostring(selected.map):lower() ~= curMap then if ply.notifyError then ply:notifyError("That secondary base is not on this map.") end return end
    local playerFac = factionForPlayer(ply)
    if selected.factions and #selected.factions > 0 then
        local ok = false
        for _, f in ipairs(selected.factions) do if tostring(f) == tostring(playerFac) then ok = true break end end
        if not ok then if ply.notifyError then ply:notifyError("You are not permitted to spawn at that secondary base.") end return end
    end
    local pos = selected.pos
    if not isvector(pos) then
        local ok, res = pcall(lia.data.decodeVector, pos)
        if ok then pos = res end
    end
    if not isvector(pos) then if ply.notifyError then ply:notifyError("That secondary base has no valid position.") end return end
    pos = pos + Vector(0, 0, 16)
    local ang = selected.ang
    if not isangle(ang) then
        local ok, res = pcall(lia.data.decodeAngle, ang)
        if ok then ang = res end
    end
    ply:SetPos(pos)
    if isangle(ang) then ply:SetEyeAngles(ang) end
    hook.Run("PlayerSpawnPointSelected", ply, pos, ang)
end)

-- ensure data is loaded on module load
MODULE:LoadData()

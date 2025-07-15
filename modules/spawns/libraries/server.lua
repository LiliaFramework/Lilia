local MODULE = MODULE
local function decodeVector(tbl)
    if istable(tbl) and tbl[1] and tbl[2] and tbl[3] then return Vector(tbl[1], tbl[2], tbl[3]) end
    return tbl
end

local function encodeVector(vec)
    return {vec.x, vec.y, vec.z}
end

function MODULE:LoadData()
    local data = self:getData() or {}
    if not next(data) then data = self:getData(nil, true) or {} end
    self.spawns = {}
    self.globalSpawns = {}
    local factions = data.factions or data
    for factionID, spawnList in pairs(factions) do
        self.spawns[factionID] = {}
        for _, pos in ipairs(spawnList) do
            local vec = decodeVector(pos)
            self.spawns[factionID][#self.spawns[factionID] + 1] = vec
        end
    end

    for _, pos in ipairs(data.global or {}) do
        local vec = decodeVector(pos)
        self.globalSpawns[#self.globalSpawns + 1] = vec
    end
end

function MODULE:SaveData()
    local factions = {}
    for factionID, spawnList in pairs(self.spawns or {}) do
        factions[factionID] = {}
        for _, pos in ipairs(spawnList) do
            factions[factionID][#factions[factionID] + 1] = encodeVector(pos)
        end
    end

    local global = {}
    for _, pos in ipairs(self.globalSpawns or {}) do
        global[#global + 1] = encodeVector(pos)
    end

    self:setData({
        factions = factions,
        global = global
    })
end

local function SpawnPlayer(client)
    if not IsValid(client) then return end
    local character = client:getChar()
    if character then
        local posData = character:getLastPos()
        if posData and posData[3] and posData[3]:lower() == game.GetMap():lower() then
            client:SetPos(posData[1].x and posData[1] or client:GetPos())
            client:SetEyeAngles(posData[2].p and posData[2] or angle_zero)
            character:setLastPos(nil)
            return
        end
    end

    local factionID
    for _, info in ipairs(lia.faction.indices) do
        if info.index == client:Team() then
            factionID = info.uniqueID
            break
        end
    end

    local spawnPos
    if factionID then
        local factionSpawns = MODULE.spawns[factionID]
        if factionSpawns and #factionSpawns > 0 then spawnPos = table.Random(factionSpawns) end
    end

    if not spawnPos and MODULE.globalSpawns and #MODULE.globalSpawns > 0 then spawnPos = table.Random(MODULE.globalSpawns) end
    if spawnPos then
        spawnPos = spawnPos + Vector(0, 0, 16)
        client:SetPos(spawnPos)
        hook.Run("PlayerSpawnPointSelected", client, spawnPos)
    end
end

function MODULE:CharPreSave(character)
    local client = character:getPlayer()
    if IsValid(client) and not client:hasValidVehicle() and client:Alive() then character:setLastPos({client:GetPos(), client:EyeAngles(), game.GetMap()}) end
end

function MODULE:PlayerDeath(client, _, attacker)
    local char = client:getChar()
    if not char then return end
    if attacker:IsPlayer() then
        if lia.config.get("LoseItemsonDeathHuman", false) then self:RemovedDropOnDeathItems(client) end
        if lia.config.get("DeathPopupEnabled", true) then
            local dateStr = lia.time.GetDate()
            local attackerChar = attacker:getChar()
            local charId = attackerChar and tostring(attackerChar:getID()) or L("na")
            local steamId = tostring(attacker:SteamID64())
            ClientAddText(client, Color(255, 0, 0), "[" .. string.upper(L("death")) .. "]: ", Color(255, 255, 255), dateStr, " - ", L("killedBy"), " ", Color(255, 215, 0), L("characterID"), ": ", Color(255, 255, 255), charId, " (", Color(0, 255, 0), steamId, Color(255, 255, 255), ")")
        end
    end

    client:setNetVar("IsDeadRestricted", true)
    client:setNetVar("lastDeathTime", os.time())
    timer.Simple(lia.config.get("SpawnTime"), function() if IsValid(client) then client:setNetVar("IsDeadRestricted", false) end end)
    client:SetDSP(30, false)
    char:setLastPos(nil)
    if not attacker:IsPlayer() and lia.config.get("LoseItemsonDeathNPC", false) or attacker:IsWorld() and lia.config.get("LoseItemsonDeathWorld", false) then self:RemovedDropOnDeathItems(client) end
    char:setData("deathPos", client:GetPos())
end

function MODULE:RemovedDropOnDeathItems(client)
    local character = client:getChar()
    if not character then return end
    local inventory = character:getInv()
    if not inventory then return end
    local items = inventory:getItems()
    client.carryWeapons = {}
    client.LostItems = {}
    for _, item in pairs(items) do
        if item.isWeapon and item.DropOnDeath and item:getData("equip", false) or not item.isWeapon and item.DropOnDeath then
            table.insert(client.LostItems, {
                name = item.name,
                id = item.id
            })

            item:remove()
        end
    end

    if #client.LostItems > 0 then client:notifyLocalized("itemsLostOnDeath", #client.LostItems) end
end

function MODULE:PlayerSpawn(client)
    client:setNetVar("IsDeadRestricted", false)
    client:SetDSP(0, false)
end

net.Receive("request_respawn", function(_, client)
    if not IsValid(client) or not client:getChar() then return end
    local respawnTime = lia.config.get("SpawnTime", 5)
    local override = hook.Run("OverrideSpawnTime", client, respawnTime)
    if override then respawnTime = override end
    local lastDeath = client:getNetVar("lastDeathTime", os.time())
    if os.time() - lastDeath < respawnTime then return end
    if not client:Alive() and not client:getNetVar("IsDeadRestricted", false) then client:Spawn() end
end)

hook.Add("PostPlayerLoadout", "liaSpawns", SpawnPlayer)
hook.Add("PostPlayerLoadedChar", "liaSpawns", SpawnPlayer)
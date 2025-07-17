local MODULE = MODULE
MODULE.spawns = MODULE.spawns or {}
local function decodeVector(tbl)
    if istable(tbl) and tbl[1] and tbl[2] and tbl[3] then return Vector(tbl[1], tbl[2], tbl[3]) end
    return tbl
end

local function encodeVector(vec)
    return {vec.x, vec.y, vec.z}
end

function MODULE:LoadData()
    local data = self:getData()
    self.spawns = {}
    print("[MODULE] LoadData: fetched data")
    PrintTable(data, 1)
    local factions = data.factions or data
    for fac, spawns in pairs(factions or {}) do
        self.spawns[fac] = {}
        print(string.format("[MODULE] LoadData: faction '%s' has %d raw entries", fac, #spawns))
        for i, pos in ipairs(spawns) do
            local vec = decodeVector(pos)
            print(string.format("[MODULE] LoadData: decoded %s spawn #%d → %s", fac, i, tostring(vec)))
            self.spawns[fac][#self.spawns[fac] + 1] = vec
        end

        print(string.format("[MODULE] LoadData: faction '%s' total spawns = %d", fac, #self.spawns[fac]))
    end
end

function MODULE:SaveData()
    local factions = {}
    print("[MODULE] SaveData: preparing faction data")
    for fac, spawns in pairs(self.spawns or {}) do
        factions[fac] = {}
        print(string.format("[MODULE] SaveData: faction '%s' has %d spawns to encode", fac, #spawns))
        for i, pos in ipairs(spawns) do
            local enc = encodeVector(pos)
            print(string.format("[MODULE] SaveData: encoded %s spawn #%d → %s", fac, i, enc))
            factions[fac][#factions[fac] + 1] = enc
        end

        print(string.format("[MODULE] SaveData: faction '%s' total encoded = %d", fac, #factions[fac]))
    end

    PrintTable(factions)
    print("--------------------------")
    self:setData({
        factions = factions
    })

    print("[MODULE] SaveData: data saved successfully")
end

local function SpawnPlayer(client)
    if not IsValid(client) then
        print("[SpawnPlayer] invalid client")
        return
    end

    local character = client:getChar()
    if character then
        print("[SpawnPlayer] character found for client:", client)
        local posData = character:getLastPos()
        if posData and posData[3] and posData[3]:lower() == game.GetMap():lower() then
            print("[SpawnPlayer] restoring saved position on map:", posData[3])
            client:SetPos(posData[1].x and posData[1] or client:GetPos())
            client:SetEyeAngles(posData[2].p and posData[2] or angle_zero)
            character:setLastPos(nil)
            return
        end

        print("[SpawnPlayer] no valid saved position found or map mismatch")
    else
        print("[SpawnPlayer] no character for client:", client)
    end

    local factionID
    for _, info in ipairs(lia.faction.indices) do
        if info.index == client:Team() then
            factionID = info.uniqueID
            print("[SpawnPlayer] detected factionID:", factionID)
            break
        end
    end

    local spawnPos
    print("Found " .. table.Count(MODULE.spawns or {}) .. " faction spawns")
    if factionID and MODULE.spawns then
        local factionSpawns = MODULE.spawns[factionID]
        if factionSpawns and #factionSpawns > 0 then
            spawnPos = table.Random(factionSpawns)
            print("[SpawnPlayer] selected faction spawn:", tostring(spawnPos))
        end
    end

    if spawnPos then
        spawnPos = spawnPos + Vector(0, 0, 16)
        client:SetPos(spawnPos)
        hook.Run("PlayerSpawnPointSelected", client, spawnPos)
        print("[SpawnPlayer] final spawn position set to:", tostring(spawnPos))
    else
        print("[SpawnPlayer] no spawn position available")
    end
end

function MODULE:CharPreSave(character)
    local client = character:getPlayer()
    local InVehicle = client:hasValidVehicle()
    if IsValid(client) and not InVehicle and client:Alive() then character:setLastPos({client:GetPos(), client:EyeAngles(), game.GetMap()}) end
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

    local lostCount = #client.LostItems
    if lostCount > 0 then client:notifyLocalized("itemsLostOnDeath", lostCount) end
end

function MODULE:PlayerSpawn(client)
    client:setNetVar("IsDeadRestricted", false)
    client:SetDSP(0, false)
end

net.Receive("request_respawn", function(_, client)
    if not IsValid(client) or not client:getChar() then return end
    local respawnTime = lia.config.get("SpawnTime", 5)
    local spawnTimeOverride = hook.Run("OverrideSpawnTime", client, respawnTime)
    if spawnTimeOverride then respawnTime = spawnTimeOverride end
    local lastDeathTime = client:getNetVar("lastDeathTime", os.time())
    local timePassed = os.time() - lastDeathTime
    if timePassed < respawnTime then return end
    if not client:Alive() and not client:getNetVar("IsDeadRestricted", false) then client:Spawn() end
end)

hook.Add("PostPlayerLoadout", "liaSpawns", SpawnPlayer)
hook.Add("PostPlayerLoadedChar", "liaSpawns", SpawnPlayer)

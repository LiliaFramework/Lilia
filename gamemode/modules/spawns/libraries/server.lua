local MODULE = MODULE
MODULE.spawns = MODULE.spawns or {}
local encodetable = lia.data.encodetable
local TABLE = "spawns"
local function buildCondition(folder, map)
    return "_schema = " .. lia.db.convertDataType(folder) .. " AND _map = " .. lia.db.convertDataType(map)
end

function MODULE:LoadData(n)
    n = n or 1
    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = game.GetMap()
    local condition = buildCondition(folder, map)
    lia.db.selectOne({"_data"}, TABLE, condition):next(function(res)
        local data = res and lia.data.deserialize(res._data) or {}
        local factions = data.factions or data
        if (not istable(factions) or table.IsEmpty(factions)) and n < 5 then
            timer.Simple(1, function() if not self.loaded then self:LoadData(n + 1) end end)
            return
        end

        self.spawns = {}
        for fac, spawns in pairs(factions or {}) do
            local t = {}
            for i = 1, #spawns do
                t[i] = lia.data.decode(spawns[i])
            end

            self.spawns[fac] = t
        end

        self.loaded = true
    end)
end

function MODULE:SaveData()
    local factions = {}
    for fac, spawns in pairs(self.spawns or {}) do
        factions[fac] = {}
        for _, pos in ipairs(spawns) do
            factions[fac][#factions[fac] + 1] = encodetable(pos)
        end
    end

    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = game.GetMap()
    lia.db.upsert({
        _schema = folder,
        _map = map,
        _data = lia.data.serialize({
            factions = factions
        })
    }, TABLE)
end

local function SpawnPlayer(client)
    if not IsValid(client) then return end
    local character = client:getChar()
    if not character then return end
    local posData = character:getLastPos()
    if posData and posData.map and posData.map:lower() == game.GetMap():lower() then
        client:SetPos(posData.pos and posData.pos.x and posData.pos or client:GetPos())
        client:SetEyeAngles(posData.ang and posData.ang.p and posData.ang or angle_zero)
        character:setLastPos(nil)
        return
    end

    local factionID
    for _, info in ipairs(lia.faction.indices) do
        if info.index == client:Team() then
            factionID = info.uniqueID
            break
        end
    end

    local spawnPos
    if factionID and MODULE.spawns then
        local factionSpawns = MODULE.spawns[factionID]
        if factionSpawns and #factionSpawns > 0 then spawnPos = table.Random(factionSpawns) end
    end

    if spawnPos then
        spawnPos = spawnPos + Vector(0, 0, 16)
        client:SetPos(spawnPos)
        hook.Run("PlayerSpawnPointSelected", client, spawnPos)
    end
end

function MODULE:CharPreSave(character)
    local client = character:getPlayer()
    local InVehicle = client:hasValidVehicle()
    if IsValid(client) and not InVehicle and client:Alive() then
        character:setLastPos({
            pos = client:GetPos(),
            ang = client:EyeAngles(),
            map = game.GetMap()
        })
    end
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
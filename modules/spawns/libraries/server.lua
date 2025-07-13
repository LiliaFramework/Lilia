local MODULE = MODULE
function MODULE:LoadData()
    local data = self:getData() or {}
    if data.factions or data.global then
        self.spawns = data.factions or {}
        self.globalSpawns = data.global or {}
    else
        self.spawns = data
        self.globalSpawns = {}
    end
end

function MODULE:SaveData()
    self:setData({
        factions = self.spawns,
        global = self.globalSpawns
    })
end

local function SpawnCheck(client)
    local char = client:getChar()
    timer.Simple(0, function()
        if not IsValid(client) or not char then
            print("SpawnCheck: invalid client or char:", client, char)
            return
        end

        print("SpawnCheck: client and char are valid for", client)
        local data = char:getData("pos")
        if data and data[3] and data[3]:lower() == game.GetMap():lower() then
            print("SpawnCheck: restoring saved position on map", data[3])
            local pos = data[1].x and data[1] or client:GetPos()
            local ang = data[2].p and data[2] or angle_zero
            client:SetPos(pos)
            client:SetEyeAngles(ang)
            char:setData("pos", nil)
            print("SpawnCheck: position & angle applied, cleared pos data")
            return
        end

        print("SpawnCheck: no valid saved position, clearing pos data")
        char:setData("pos", nil)
        local spawnList = {}
        for _, faction in ipairs(lia.faction.indices) do
            if faction.index == client:Team() and MODULE.spawns and MODULE.spawns[faction.uniqueID] and #MODULE.spawns[faction.uniqueID] > 0 then
                spawnList = MODULE.spawns[faction.uniqueID]
                print("SpawnCheck: found faction spawns for", faction.uniqueID)
                break
            end
        end

        if #spawnList == 0 and MODULE.globalSpawns and #MODULE.globalSpawns > 0 then
            spawnList = MODULE.globalSpawns
            print("SpawnCheck: using global spawns")
        end

        if #spawnList > 0 then
            local chosen = table.Random(spawnList)
            client:SetPos(chosen)
            print("SpawnCheck: set client pos to", chosen)
        else
            print("SpawnCheck: no spawn positions available")
        end
    end)
end

function MODULE:CharPreSave(character)
    local client = character:getPlayer()
    local InVehicle = client:hasValidVehicle()
    if IsValid(client) and not InVehicle and client:Alive() then character:setData("pos", {client:GetPos(), client:EyeAngles(), game.GetMap()}) end
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
    char:setData("pos", nil)
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

hook.Add("PostPlayerLoadout", "liaSpawnsPostPlayerLoadout", SpawnCheck)
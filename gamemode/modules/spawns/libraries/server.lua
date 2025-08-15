local MODULE = MODULE
function MODULE:FetchSpawns()
    local d = deferred.new()
    local stored = lia.data.get("spawns", {})
    local data = istable(stored) and stored or {}
    local factions = data.factions or data
    local result = {}
    for fac, spawns in pairs(factions or {}) do
        local t = {}
        spawns = istable(spawns) and spawns or {spawns}
        for i = 1, #spawns do
            local spawnData = lia.data.deserialize(spawns[i])
            if isvector(spawnData) then
                spawnData = {
                    pos = spawnData,
                    ang = angle_zero
                }
            end

            t[i] = spawnData
        end

        result[fac] = t
    end

    d:resolve(result)
    return d
end

function MODULE:StoreSpawns(spawns)
    local factions = {}
    for fac, list in pairs(spawns or {}) do
        factions[fac] = {}
        for _, data in ipairs(list) do
            factions[fac][#factions[fac] + 1] = lia.data.encodetable(data)
        end
    end

    lia.data.set("spawns", {
        factions = factions
    })
    return deferred.resolve(true)
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

    if factionID then
        MODULE:FetchSpawns():next(function(spawns)
            local factionSpawns = spawns and spawns[factionID]
            if factionSpawns and #factionSpawns > 0 then
                local valid = {}
                local curMap = game.GetMap():lower()
                for _, v in ipairs(factionSpawns) do
                    if not v.map or v.map:lower() == curMap then valid[#valid + 1] = v end
                end

                if #valid > 0 then
                    local data = table.Random(valid)
                    local basePos = data.pos or data
                    if not isvector(basePos) then
                        local parsedPos = lia.data.decodeVector(basePos)
                        basePos = parsedPos
                    end

                    if not isvector(basePos) then basePos = Vector(0, 0, 0) end
                    local pos = basePos + Vector(0, 0, 16)
                    local ang = data.ang
                    if not isangle(ang) then
                        local parsedAng = lia.data.decodeAngle(ang)
                        if isangle(parsedAng) then
                            ang = parsedAng
                        else
                            ang = angle_zero
                        end
                    end

                    client:SetPos(pos)
                    client:SetEyeAngles(ang)
                    hook.Run("PlayerSpawnPointSelected", client, pos, ang)
                end
            end
        end)
    end
end

function MODULE:CharPreSave(character)
    local client = character:getPlayer()
    if not IsValid(client) then return end
    local InVehicle = client:hasValidVehicle()
    if not InVehicle and client:Alive() then
        character:setLastPos({
            pos = client:GetPos(),
            ang = client:EyeAngles(),
            map = game.GetMap()
        })
    end
end

local function RemovedDropOnDeathItems(client)
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

function MODULE:PlayerDeath(client, _, attacker)
    local char = client:getChar()
    if not char then return end
    if attacker:IsPlayer() then
        if lia.config.get("LoseItemsonDeathHuman", false) then RemovedDropOnDeathItems(client) end
        if lia.config.get("DeathPopupEnabled", true) then
            local dateStr = lia.time.GetDate()
            local attackerChar = attacker:getChar()
            local steamId = tostring(attacker:SteamID())
            ClientAddText(client, Color(255, 0, 0), "[" .. string.upper(L("death")) .. "]: ", Color(255, 255, 255), dateStr, " - ", L("killedBy"), " ", Color(255, 215, 0), L("characterID"), ": ", Color(255, 255, 255), attackerChar and tostring(attackerChar:getID()) or L("na"), " (", Color(0, 255, 0), steamId, Color(255, 255, 255), ")")
        end
    end

    client:setNetVar("IsDeadRestricted", true)
    client:setNetVar("lastDeathTime", os.time())
    timer.Simple(lia.config.get("SpawnTime"), function() if IsValid(client) then client:setNetVar("IsDeadRestricted", false) end end)
    client:SetDSP(30, false)
    char:setLastPos(nil)
    if not attacker:IsPlayer() and lia.config.get("LoseItemsonDeathNPC", false) or attacker:IsWorld() and lia.config.get("LoseItemsonDeathWorld", false) then RemovedDropOnDeathItems(client) end
    char:setData("deathPos", client:GetPos())
end

function MODULE:PlayerSpawn(client)
    client:setNetVar("IsDeadRestricted", false)
    client:SetDSP(0, false)
    local char = client:getChar()
    if char then char:setLastPos(nil) end
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

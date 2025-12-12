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
            local spawnData = spawns[i]
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
    lia.data.set("spawns", {
        factions = spawns
    })
    return deferred.resolve(true)
end

local function DoSpawnLogic(client, isRespawning)
    if not IsValid(client) then return end
    local character = client:getChar()
    if not character then return end
    if isRespawning then
        local respawnLocation = hook.Run("GetPlayerRespawnLocation", client, character)
        if respawnLocation then
            local pos = respawnLocation.pos or respawnLocation.position
            local ang = respawnLocation.ang or respawnLocation.angle
            if isvector(pos) then
                pos = pos + Vector(0, 0, 16)
                client:SetPos(pos)
            end

            if isangle(ang) then client:SetEyeAngles(ang) end
            hook.Run("PlayerSpawnPointSelected", client, pos or Vector(0, 0, 16), ang or angle_zero)
            return
        end
    end

    local overrideLocation = hook.Run("GetPlayerSpawnLocation", client, character)
    if overrideLocation then
        local pos = overrideLocation.pos or overrideLocation.position
        local ang = overrideLocation.ang or overrideLocation.angle
        if isvector(pos) then
            pos = pos + Vector(0, 0, 16)
            client:SetPos(pos)
        end

        if isangle(ang) then client:SetEyeAngles(ang) end
        hook.Run("PlayerSpawnPointSelected", client, pos or Vector(0, 0, 16), ang or angle_zero)
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
        local factionInfo = lia.faction.get(factionID)
        local curMap = lia.data.getEquivalencyMap(game.GetMap()):lower()
        if factionInfo and factionInfo.spawns and factionInfo.spawns[curMap] then
            local mapSpawns = factionInfo.spawns[curMap]
            if istable(mapSpawns) and #mapSpawns > 0 then
                local data = table.Random(mapSpawns)
                if data then
                    local pos = data.position or data.pos
                    local ang = data.angle or data.ang
                    if isvector(pos) then
                        pos = pos + Vector(0, 0, 16)
                        client:SetPos(pos)
                    end

                    if isangle(ang) then client:SetEyeAngles(ang) end
                    hook.Run("PlayerSpawnPointSelected", client, pos or Vector(0, 0, 16), ang or angle_zero)
                    return
                end
            end
        end

        MODULE:FetchSpawns():next(function(spawns)
            local factionSpawns = spawns and spawns[factionID]
            if factionSpawns and #factionSpawns > 0 then
                local valid = {}
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
    if IsValid(client) and client:getChar() == character then
        local lastPosData = {
            pos = client:GetPos(),
            ang = Angle(0, 0, 0),
            map = lia.data.getEquivalencyMap(game.GetMap())
        }

        character:setLastPos(lastPosData)
    end
end

local function RemovedDropOnDeathItems(client)
    local character = client:getChar()
    if not character then return end
    local inventory = character:getInv()
    if not inventory then return end
    local items = inventory:getItems()
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
    if lostCount > 0 then client:notifyWarningLocalized("itemsLostOnDeath", lostCount) end
end

function MODULE:PlayerSpawn(client)
    client.liaSpawnHandled = nil
end

function MODULE:OnCharDisconnect(client, character)
    if not IsValid(client) or not character then return end
    local lastPosData = {
        pos = client:GetPos(),
        ang = Angle(0, 0, 0),
        map = lia.data.getEquivalencyMap(game.GetMap())
    }

    character:setLastPos(lastPosData)
    character:save()
end

function MODULE:PlayerDeath(client, _, attacker)
    local char = client:getChar()
    if not char then return end
    if not client:IsBot() then
        local deathTime = os.time()
        client:setLocalVar("lastDeathTime", deathTime)
        timer.Simple(0.1, function() if IsValid(client) and client:getChar() and not client:Alive() then client:setLocalVar("lastDeathTime", deathTime) end end)
    else
        local spawnTime = lia.config.get("SpawnTime", 5)
        timer.Simple(spawnTime, function() if IsValid(client) and client:getChar() and not client:Alive() then client:Spawn() end end)
    end

    if attacker:IsPlayer() then
        if lia.config.get("LoseItemsonDeathHuman", false) then RemovedDropOnDeathItems(client) end
        if lia.config.get("DeathPopupEnabled", true) then
            local dateStr = lia.time.getDate()
            local attackerChar = attacker:getChar()
            local steamId = tostring(attacker:SteamID())
            ClientAddText(client, Color(255, 0, 0), "[" .. string.upper(L("death")) .. "]: ", Color(255, 255, 255), dateStr, " - ", L("killedBy"), " ", Color(255, 215, 0), L("characterID"), ": ", Color(255, 255, 255), attackerChar and tostring(attackerChar:getID()) or L("na"), " (", Color(0, 255, 0), steamId, Color(255, 255, 255), ")")
        end
    end

    client:SetDSP(30, false)
    char:setLastPos(nil)
    if not attacker:IsPlayer() and lia.config.get("LoseItemsonDeathNPC", false) or attacker:IsWorld() and lia.config.get("LoseItemsonDeathWorld", false) then RemovedDropOnDeathItems(client) end
    char:setData("deathPos", client:GetPos())
end

function MODULE:PostPlayerLoadout(client)
    local character = client:getChar()
    if not character then return end
    if client.liaSpawnHandled then return end
    if client.liaIsRespawning then
        local respawnLocation = hook.Run("GetPlayerRespawnLocation", client)
        if respawnLocation then
            local pos = respawnLocation.pos or respawnLocation.position
            local ang = respawnLocation.ang or respawnLocation.angle
            if isvector(pos) then
                pos = pos + Vector(0, 0, 16)
                client:SetPos(pos)
            end

            if isangle(ang) then client:SetEyeAngles(ang) end
            client.liaIsRespawning = nil
            client.liaSpawnHandled = true
            hook.Run("PlayerSpawnPointSelected", client, pos or Vector(0, 0, 16), ang or angle_zero)
            return
        end
    end

    local lastPos = character:getLastPos()
    if lastPos and lastPos.map then
        local currentMap = lia.data.getEquivalencyMap(game.GetMap()):lower()
        local savedMapLower = tostring(lastPos.map):lower()
        if savedMapLower == currentMap then
            if lastPos.pos and isvector(lastPos.pos) then client:SetPos(lastPos.pos) end
            if lastPos.ang and isangle(lastPos.ang) then client:SetEyeAngles(lastPos.ang) end
            character:setLastPos(nil)
            client.liaSpawnHandled = true
            client.liaIsRespawning = nil
            return
        end
    end

    client.liaSpawnHandled = true
    local wasRespawning = client.liaIsRespawning
    client.liaIsRespawning = nil
    DoSpawnLogic(client, wasRespawning)
end

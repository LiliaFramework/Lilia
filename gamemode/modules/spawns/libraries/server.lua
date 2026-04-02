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

local function resolveFromEntity(ent)
    if not IsValid(ent) then return nil end
    if ent:IsPlayer() then return ent end
    if ent:IsVehicle() and ent.GetDriver then
        local driver = ent:GetDriver()
        if IsValid(driver) and driver:IsPlayer() then return driver end
    end

    if ent.GetOwner then
        local owner = ent:GetOwner()
        if IsValid(owner) and owner:IsPlayer() then return owner end
    end

    if ent.GetCreator then
        local creator = ent:GetCreator()
        if IsValid(creator) and creator:IsPlayer() then return creator end
    end

    if ent.CPPIGetOwner then
        local owner = ent:CPPIGetOwner()
        if IsValid(owner) and owner:IsPlayer() then return owner end
    end
    return nil
end

local function ResolveDeathAttacker(victim, inflictor, attacker)
    if IsValid(attacker) then
        if attacker == victim or attacker:IsWorld() or attacker:GetClass() == "worldspawn" then
            local resolved = resolveFromEntity(inflictor) or resolveFromEntity(attacker)
            if IsValid(resolved) then return resolved end
        else
            local resolved = resolveFromEntity(attacker) or resolveFromEntity(inflictor)
            if IsValid(resolved) then return resolved end
        end
    end

    local resolved = resolveFromEntity(inflictor)
    if IsValid(resolved) then return resolved end
    lia.log.add(client, "playerDeath", attackerName)
    return attacker
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

function MODULE:PlayerDeath(client, inflictor, attacker)
    local char = client:getChar()
    if not char then return end
    local shouldAutoRespawnBot = client:IsBot() and hook.Run("ShouldBotAutoRespawn", client, lia.config.get("SpawnTime", 5))
    if not client:IsBot() or shouldAutoRespawnBot == false then
        local deathTime = os.time()
        client:setLocalVar("lastDeathTime", deathTime)
        timer.Simple(0.1, function() if IsValid(client) and client:getChar() and not client:Alive() then client:setLocalVar("lastDeathTime", deathTime) end end)
    else
        local spawnTime = lia.config.get("SpawnTime", 5)
        timer.Simple(spawnTime, function() if IsValid(client) and client:getChar() and not client:Alive() then client:Spawn() end end)
    end

    if lia.config.get("DeathPopupEnabled", true) then
        local resolvedAttacker = ResolveDeathAttacker(client, inflictor, attacker)
        if lia.config.get("DeathDebug", false) then
            local function entShort(ent)
                if not IsValid(ent) then return "<invalid>" end
                if ent:IsPlayer() then return ent:Name() end
                return ent.GetClass and ent:GetClass() or tostring(ent)
            end

            MsgC(Color(255, 200, 0), "[Lilia DeathDebug] ", color_white, "PlayerDeath victim=", client:Name(), " attacker=", entShort(attacker), " inflictor=", entShort(inflictor), " resolved=", entShort(resolvedAttacker), "\n")
        end

        local dateStr = os.date("%d/%m/%Y", os.time())
        local timeStr = os.date("%H:%M:%S", os.time())
        local attackerName = L("na")
        local attackerChar = nil
        if IsValid(resolvedAttacker) then
            if resolvedAttacker == client or resolvedAttacker:IsWorld() or resolvedAttacker:GetClass() == "worldspawn" then
                attackerName = L("theEnvironment")
            elseif resolvedAttacker:IsPlayer() then
                attackerChar = resolvedAttacker:getChar()
                local charID = attackerChar and tostring(attackerChar:getID()) or L("na")
                local steamID = resolvedAttacker:SteamID64()
                attackerName = L("characterIDSteamID64", charID, steamID)
            else
                attackerName = resolvedAttacker:GetClass() or L("na")
            end
        end

        local killedByText = L("killedByAt", attackerName, timeStr)
        ClientAddText(client, Color(255, 255, 255), dateStr .. " - ", Color(255, 255, 255), killedByText)
        local logTimestamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
        local attackerDisplay = "unknown"
        if IsValid(resolvedAttacker) then
            if resolvedAttacker == client or resolvedAttacker:IsWorld() or resolvedAttacker:GetClass() == "worldspawn" then
                attackerDisplay = L("theEnvironment")
            elseif resolvedAttacker:IsPlayer() then
                attackerChar = attackerChar or resolvedAttacker:getChar()
                local steamId = resolvedAttacker:SteamID64()
                attackerDisplay = attackerChar and L("characterSteam64ID", attackerChar:getID(), steamId) or L("na")
            else
                attackerDisplay = resolvedAttacker:GetClass() or L("na")
            end
        end

        local deathMessage = L("staffLogDeathMessage", client:Name(), char:getID(), client:SteamID64(), attackerDisplay)
        local isStaff = client:isStaffOnDuty() or client:hasPrivilege("canSeeLogs")
        if not isStaff then ClientAddTextShadowed(client, Color(255, 0, 0), "DEATH", Color(255, 255, 255), " | " .. logTimestamp .. " | " .. deathMessage) end
        StaffAddTextShadowed(Color(255, 0, 0), "DEATH", Color(255, 255, 255), deathMessage)
    end

    local resolvedAttacker = ResolveDeathAttacker(client, inflictor, attacker)
    if IsValid(resolvedAttacker) and resolvedAttacker:IsPlayer() and lia.config.get("LoseItemsonDeathHuman", false) then RemovedDropOnDeathItems(client) end
    client:SetDSP(30, false)
    char:setLastPos(nil)
    if (not IsValid(resolvedAttacker) or not resolvedAttacker:IsPlayer()) and lia.config.get("LoseItemsonDeathNPC", false) or (IsValid(resolvedAttacker) and resolvedAttacker:IsWorld() and lia.config.get("LoseItemsonDeathWorld", false)) then RemovedDropOnDeathItems(client) end
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

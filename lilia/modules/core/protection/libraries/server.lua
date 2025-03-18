local MODULE = MODULE
function MODULE:CanPlayerSwitchChar(client, character)
    if not client:isStaffOnDuty() then
        local damageCooldown = lia.config.get("OnDamageCharacterSwitchCooldownTimer", 15)
        local switchCooldown = lia.config.get("CharacterSwitchCooldownTimer", 5)
        if damageCooldown > 0 and client.LastDamaged and client.LastDamaged > CurTime() - damageCooldown then return false, "You took damage too recently to switch characters!" end
        local loginTime = character:getData("loginTime", 0)
        if switchCooldown > 0 and loginTime + switchCooldown > os.time() then return false, "You are on cooldown!" end
    end
    return true
end

function MODULE:EntityTakeDamage(entity, dmgInfo)
    local inflictor = dmgInfo:GetInflictor()
    local attacker = dmgInfo:GetAttacker()
    local isValidClient = IsValid(entity) and entity:IsPlayer()
    local attackerIsHuman = IsValid(attacker) and attacker:IsPlayer()
    local notSameEntity = attacker ~= entity
    local isFallDamage = dmgInfo:IsFallDamage()
    local inflictorIsProp = IsValid(inflictor) and inflictor:isProp()
    if not isValidClient or isFallDamage then return end
    if inflictorIsProp then
        dmgInfo:SetDamage(0)
        return
    end

    if dmgInfo:IsExplosionDamage() and lia.config.get("ExplosionRagdoll", true) then
        dmgInfo:ScaleDamage(0.5)
        local dmgPos = dmgInfo:GetDamagePosition()
        local direction = (entity:GetPos() - dmgPos):GetNormalized()
        entity:SetVelocity(direction * 60 * dmgInfo:GetDamage())
        local damageAmount = dmgInfo:GetDamage()
        timer.Simple(0.05, function() if IsValid(entity) and not entity:hasRagdoll() and (entity:Health() - damageAmount) > 0 then entity:setRagdolled(true, 3) end end)
    end

    if notSameEntity then
        if entity:GetMoveType() == MOVETYPE_NOCLIP then return end
        if lia.config.get("OnDamageCharacterSwitchCooldownTimer", 15) > 0 then
            local applyCooldown = lia.config.get("SwitchCooldownOnAllEntities", false) or attackerIsHuman
            if applyCooldown then entity.LastDamaged = CurTime() end
        end

        if lia.config.get("CarRagdoll", true) and IsValid(inflictor) and inflictor:isSimfphysCar() and not (entity:GetVehicle() or (LVS and entity:lvsGetVehicle())) then
            dmgInfo:ScaleDamage(0)
            if not entity:hasRagdoll() and (entity:Health() - dmgInfo:GetDamage()) > 0 then entity:setRagdolled(true, 5) end
        end
    end
end

function MODULE:PlayerShouldAct()
    return lia.config.get("ActsActive", false)
end

function MODULE:PlayerAuthed(client, steamid)
    local KnownCheaters = {
        ["76561198095382821"] = true,
        ["76561198211231421"] = true,
        ["76561199121878196"] = true,
        ["76561199548880910"] = true,
        ["76561198218940592"] = true,
        ["76561198095156121"] = true,
        ["76561198281775968"] = true,
    }

    local steamID64 = util.SteamIDTo64(steamid)
    local ownerSteamID64 = client:OwnerSteamID64()
    local steamName = client:steamName()
    local steamID = client:SteamID()
    if KnownCheaters[steamID64] or KnownCheaters[ownerSteamID64] then
        client:Ban("You are banned from this server for using third-party cheats.\nIf you believe this is a mistake, please appeal by contacting the owner with this message.")
        self:NotifyAdmin(string.format("%s (%s) was banned for cheating or using an alt of a cheater.", steamName, steamID))
        return
    end

    if lia.config.get("AltsDisabled", false) and ownerSteamID64 ~= steamID64 then
        client:Kick("Sorry! We do not allow family-shared accounts on this server!")
        self:NotifyAdmin(string.format("%s (%s) was kicked for family sharing.", steamName, steamID))
    elseif WhitelistCore and WhitelistCore.BlacklistedSteamID64[ownerSteamID64] then
        client:Ban("You are using an account whose family share is blacklisted from this server!")
        self:NotifyAdmin(string.format("%s (%s) was banned for using a family-shared account that is blacklisted.", steamName, steamID))
    end
end

function MODULE:PlayerSay(client, message)
    local hasIPAddress = string.match(message, "%d+%.%d+%.%d+%.%d+(:%d*)?")
    local hasBadWords = string.find(string.upper(message), string.upper("clone")) and string.find(string.upper(message), string.upper("nutscript"))
    if hasIPAddress then
        self:ApplyPunishment(client, "Typing IP addresses in chat", true, false)
        return ""
    elseif hasBadWords then
        return ""
    end
end

function MODULE:PlayerLeaveVehicle(_, entity)
    if entity:GetClass() == "prop_vehicle_prisoner_pod" then
        local sName = "PodFix_" .. entity:EntIndex()
        hook.Add("Think", sName, function()
            if IsValid(entity) then
                if entity:GetInternalVariable("m_bEnterAnimOn") then
                    hook.Remove("Think", sName)
                elseif not entity:GetInternalVariable("m_bExitAnimOn") then
                    entity:AddEFlags(EFL_NO_THINK_FUNCTION)
                    hook.Remove("Think", sName)
                end
            else
                hook.Remove("Think", sName)
            end
        end)
    end
end

function MODULE:OnEntityCreated(entity)
    local class = entity:GetClass():lower():Trim()
    entity:SetCustomCollisionCheck(true)
    if class == "lua_run" and not lia.config.get("DisableLuaRun", false) then
        print("[Notify] lua_run entity detected and will be removed.")
        function entity:AcceptInput()
            return true
        end

        function entity:RunCode()
            return true
        end

        timer.Simple(0, function() entity:Remove() end)
    elseif class == "point_servercommand" then
        print("[Notify] point_servercommand entity detected and will be removed.")
        timer.Simple(0, function() entity:Remove() end)
    elseif class == "prop_vehicle_prisoner_pod" then
        entity:AddEFlags(EFL_NO_THINK_FUNCTION)
    end
end

function MODULE:OnPlayerDropWeapon(_, _, entity)
    local physObject = entity:GetPhysicsObject()
    if physObject then physObject:EnableMotion() end
    timer.Simple(lia.config.get("TimeUntilDroppedSWEPRemoved", 15), function() if entity and IsValid(entity) then entity:Remove() end end)
end

function MODULE:OnPlayerHitGround(client)
    local vel = client:GetVelocity()
    client:SetVelocity(Vector(-(vel.x * 0.45), -(vel.y * 0.45), 0))
end

function MODULE:ShouldCollide(ent1, ent2)
    local class1, class2 = ent1:GetClass(), ent2:GetClass()
    local blockedEntities = {
        ["lia_money"] = true,
        ["lia_item"] = true,
        ["prop_physics"] = true,
        ["func_tanktrain"] = true,
    }

    local isBlockedEntity1 = blockedEntities[class1]
    local isBlockedEntity2 = blockedEntities[class2]
    local isPlayerColliding = ent1:IsPlayer() or ent2:IsPlayer()
    if isPlayerColliding and isBlockedEntity1 and isBlockedEntity2 then return false end
    if self.BlockedCollideEntities[class1] and self.BlockedCollideEntities[class2] then return false end
    return true
end

function MODULE:PlayerEnteredVehicle(_, entity)
    if entity:GetClass() == "prop_vehicle_prisoner_pod" then entity:RemoveEFlags(EFL_NO_THINK_FUNCTION) end
end

function MODULE:NotifyAdmin(notification)
    for _, client in player.Iterator() do
        if IsValid(client) and client:hasPrivilege("Staff Permissions - Can See Alting Notifications") then client:ChatPrint(notification) end
    end
end

function MODULE:OnPhysgunPickup(_, entity)
    if (entity:isProp() or entity:isItem()) and entity:GetCollisionGroup() == COLLISION_GROUP_NONE then entity:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) end
end

function MODULE:PhysgunDrop(_, entity)
    if entity:isProp() and entity:isItem() then timer.Simple(5, function() if IsValid(entity) and entity:GetCollisionGroup() == COLLISION_GROUP_PASSABLE_DOOR then entity:SetCollisionGroup(COLLISION_GROUP_NONE) end end) end
end

function MODULE:ApplyPunishment(client, infraction, kick, ban, time)
    local bantime = time or 0
    if kick then client:Kick("Kicked for " .. infraction .. ".") end
    if ban then client:Ban(bantime, "Banned for " .. infraction .. ".") end
end

function MODULE:PlayerSpawnProp(client, model)
    if self.BlackListedProps[model] and not client:hasPrivilege("Spawn Permissions - Can Spawn Blacklisted Props") then return false end
    local weapon = client:GetActiveWeapon()
    if IsValid(weapon) and weapon:GetClass() == "gmod_tool" then
        local toolobj = weapon:GetToolObject()
        if toolobj ~= nil and (client.AdvDupe2 and client.AdvDupe2.Entities or client.CurrentDupe and client.CurrentDupe.Entities or toolobj.Entities) then return true end
    end
end

function MODULE:PlayerSpawnObject(client)
    if IsValid(client:GetActiveWeapon()) and client:GetActiveWeapon():GetClass() == "gmod_tool" then
        local toolobj = client:GetActiveWeapon():GetToolObject()
        if not isbool(toolobj) and client.AdvDupe2 and client.AdvDupe2.Entities or client.CurrentDupe and client.CurrentDupe.Entities or toolobj.Entities then return true end
    end
end

function MODULE:PlayerSpawnedNPC(_, entity)
    if not lia.config.get("NPCsDropWeapons", false) then entity:SetKeyValue("spawnflags", "8192") end
end

function MODULE:CanProperty(client, property, entity)
    local restrictedProperties = {
        persist = true,
        drive = true,
        bonemanipulate = true,
    }

    if restrictedProperties[property] then
        client:notify("This is disabled to avoid issues with Lilia's Core Features")
        return false
    end

    if entity:IsWorld() and IsValid(entity) then return client:hasPrivilege("Staff Permissions - Can Property World Entities") end
    local entityClass = entity:GetClass()
    if self.RemoverBlockedEntities[entityClass] or self.RestrictedEnts[entityClass] then return client:hasPrivilege("Staff Permissions - Use Entity Properties on Blocked Entities") end
end

function MODULE:PhysgunPickup(client, entity)
    local entityClass = entity:GetClass()
    if (client:hasPrivilege("Staff Permissions - Physgun Pickup") or client:isStaffOnDuty()) and self.RestrictedEnts[entityClass] then return client:hasPrivilege("Staff Permissions - Physgun Pickup on Restricted Entities") end
end

function MODULE:OnPhysgunFreeze(_, physObj, entity, client)
    if not IsValid(physObj) or not IsValid(entity) then return false end
    if not physObj:IsMoveable() or entity:GetUnFreezable() then return false end
    physObj:EnableMotion(false)
    if entity:GetClass() == "prop_vehicle_jeep" then
        local objects = entity:GetPhysicsObjectCount()
        for i = 0, objects - 1 do
            local physObjNum = entity:GetPhysicsObjectNum(i)
            if IsValid(physObjNum) then physObjNum:EnableMotion(false) end
        end
    end

    if IsValid(client) then
        client:AddFrozenPhysicsObject(entity, physObj)
        client:SendHint("PhysgunUnfreeze", 0.3)
        client:SuppressHint("PhysgunFreeze")
    end

    if lia.config.get("PassableOnFreeze", false) then
        entity:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    else
        entity:SetCollisionGroup(COLLISION_GROUP_NONE)
    end
    return true
end

function MODULE:PlayerSpawnVehicle(client, _, name)
    if self.RestrictedVehicles[name] and not client:hasPrivilege("Spawn Permissions - Can Spawn Restricted Cars") then
        client:notifyWarning("You can't spawn this vehicle since it's restricted!")
        return false
    end

    if not client:hasPrivilege("Spawn Permissions - No Car Spawn Delay") then client.NextVehicleSpawn = SysTime() + lia.config.get("PlayerSpawnVehicleDelay", 30) end
end

function MODULE:CheckDuplicationScale(client, entities)
    entities = entities or {}
    for _, v in pairs(entities) do
        if v.ModelScale and v.ModelScale > 10 then
            client:notifyWarning("A model within this duplication exceeds the size limit!")
            print("[Server Warning] Potential server crash using dupes attempt by player: " .. client:Name() .. " (" .. client:SteamID() .. ")")
            return false
        end

        v.ModelScale = 1
    end
    return true
end

function MODULE:PlayerNoClip(client, state)
    if not client:isStaffOnDuty() and client:hasPrivilege("Staff Permissions - No Clip Outside Staff Character") or client:isStaffOnDuty() then
        if state then
            client:SetNoDraw(true)
            client:SetNotSolid(true)
            client:DrawWorldModel(false)
            client:DrawShadow(false)
            client:SetNoTarget(true)
            client.liaObsData = {client:GetPos(), client:EyeAngles()}
            hook.Run("OnPlayerObserve", client, state)
        else
            if client.liaObsData then
                if client:GetInfoNum("lia_obstpback", 0) > 0 then
                    local position, angles = client.liaObsData[1], client.liaObsData[2]
                    timer.Simple(0, function()
                        client:SetPos(position)
                        client:SetEyeAngles(angles)
                        client:SetVelocity(Vector(0, 0, 0))
                    end)
                end

                client.liaObsData = nil
            end

            client:SetNoDraw(false)
            client:SetNotSolid(false)
            client:DrawWorldModel(true)
            client:DrawShadow(true)
            client:SetNoTarget(false)
            hook.Run("OnPlayerObserve", client, state)
        end
    end
end

function MODULE:PlayerSpawn(client)
    if not client:getChar() then return end
    net.Start("VerifyCheats")
    net.Send(client)
end

function net.Incoming(length, client)
    local i = net.ReadHeader()
    local strName = util.NetworkIDToString(i)
    if not strName then
        lia.log.add(client, "invalidNet")
        return
    end

    local func = net.Receivers[strName:lower()]
    if not func then
        lia.log.add(client, "invalidNet")
        return
    end

    length = length - 16
    func(length, client)
end
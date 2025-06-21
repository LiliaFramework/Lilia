local MODULE = MODULE
function MODULE:CanPlayerSwitchChar(client, character)
    if not client:isStaffOnDuty() then
        local damageCooldown = lia.config.get("OnDamageCharacterSwitchCooldownTimer", 15)
        local switchCooldown = lia.config.get("CharacterSwitchCooldownTimer", 5)
        if damageCooldown > 0 and client.LastDamaged and client.LastDamaged > CurTime() - damageCooldown then return false, L("tookDamageSwitchCooldown") end
        local loginTime = character:getData("loginTime", 0)
        if switchCooldown > 0 and loginTime + switchCooldown > os.time() then return false, L("switchCooldown") end
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
        timer.Simple(0.05, function() if IsValid(entity) and not entity:hasRagdoll() and entity:Health() - damageAmount > 0 then entity:setRagdolled(true, 3) end end)
    end

    if notSameEntity then
        if entity:GetMoveType() == MOVETYPE_NOCLIP then return end
        if lia.config.get("OnDamageCharacterSwitchCooldownTimer", 15) > 0 then
            local applyCooldown = lia.config.get("SwitchCooldownOnAllEntities", false) or attackerIsHuman
            if applyCooldown then entity.LastDamaged = CurTime() end
        end

        if lia.config.get("CarRagdoll", true) and IsValid(inflictor) and inflictor:isSimfphysCar() then
            local veh = entity:GetVehicle()
            local inSimCar = IsValid(veh) and veh:isSimfphysCar()
            if not inSimCar then
                dmgInfo:ScaleDamage(0)
                if not entity:hasRagdoll() and entity:Health() - dmgInfo:GetDamage() > 0 then entity:setRagdolled(true, 5) end
            end
        end
    end
end

function MODULE:PlayerShouldAct()
    return lia.config.get("ActsActive", false)
end

local function NotifyAdmin(notification)
    for _, client in player.Iterator() do
        if IsValid(client) and client:hasPrivilege("Staff Permissions - Can See Alting Notifications") then client:ChatPrint(notification) end
    end
end

local function ApplyPunishment(client, infraction, kick, ban, time)
    local bantime = time or 0
    if kick then
        if sam then
            sam.player.kick_id(client:SteamID64(), L("kickedForInfraction") .. infraction)
        elseif ULib then
            ULib.kick(client, L("kickedForInfraction") .. infraction)
        else
            client:Kick(L("kickedForInfraction") .. infraction)
        end
    end

    if ban then
        if sam then
            sam.player.ban_id(client:SteamID64(), bantime, L("bannedForInfraction") .. infraction)
        elseif ULib then
            ULib.ban(client, bantime, L("bannedForInfraction") .. infraction)
            ULib.kick(client, L("kickedForInfraction") .. infraction)
        else
            client:Ban(bantime, L("bannedForInfractionPeriod", infraction))
            client:Kick(L("bannedForInfractionPeriod", infraction))
        end
    end
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
        ["76561197960446376"] = true,
        ["76561199029065559"] = true,
        ["76561198234911980"] = true,
    }

    local steamID64 = util.SteamIDTo64(steamid)
    local ownerSteamID64 = client:OwnerSteamID64()
    local steamName = client:SteamName()
    local steamID = client:SteamID64()
    if KnownCheaters[steamID64] or KnownCheaters[ownerSteamID64] then
        ApplyPunishment(client, "using third-party cheats", false, true, 0)
        NotifyAdmin(L("bannedCheaterNotify", steamName, steamID))
        return
    end

    if lia.config.get("AltsDisabled", false) and ownerSteamID64 ~= steamID64 then
        ApplyPunishment(client, "family sharing (alts are disabled)", true, false)
        NotifyAdmin(L("kickedAltNotify", steamName, steamID))
    elseif lia.module.list["whitelist"] and lia.module.list["whitelist"].BlacklistedSteamID64[ownerSteamID64] then
        ApplyPunishment(client, "using a family-shared account that is blacklisted", false, true, 0)
        NotifyAdmin(L("bannedAltNotify", steamName, steamID))
    end
end

function MODULE:PlayerSay(client, message)
    local hasIPAddress = string.match(message, "%d+%.%d+%.%d+%.%d+(:%d*)?")
    local hasBadWords = string.find(string.upper(message), string.upper("clone")) and string.find(string.upper(message), string.upper("nutscript"))
    if hasIPAddress then
        ApplyPunishment(client, L("ipInChat"), true, false)
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
        print(L("notifyLuaRun"))
        function entity:AcceptInput()
            return true
        end

        function entity:RunCode()
            return true
        end

        timer.Simple(0, function() SafeRemoveEntity(entity) end)
    elseif class == "point_servercommand" then
        print(L("notifyPointServer"))
        timer.Simple(0, function() SafeRemoveEntity(entity) end)
    elseif class == "prop_vehicle_prisoner_pod" then
        entity:AddEFlags(EFL_NO_THINK_FUNCTION)
    end
end

function MODULE:OnPlayerDropWeapon(_, _, entity)
    local physObject = entity:GetPhysicsObject()
    if physObject then physObject:EnableMotion() end
    SafeRemoveEntityDelayed(entity, lia.config.get("TimeUntilDroppedSWEPRemoved", 15))
end

function MODULE:OnPlayerHitGround(client)
    local vel = client:GetVelocity()
    client:SetVelocity(Vector(-(vel.x * 0.45), -(vel.y * 0.45), 0))
end

function MODULE:ShouldCollide(ent1, ent2)
    local blocked = {
        lia_money = true,
        lia_item = true,
        prop_physics = true,
        func_tanktrain = true,
    }

    local c1, c2 = ent1:GetClass(), ent2:GetClass()
    local b1, b2 = blocked[c1], blocked[c2]
    if b1 and b2 then return false end
    return true
end

function MODULE:PlayerEnteredVehicle(_, entity)
    if entity:GetClass() == "prop_vehicle_prisoner_pod" then entity:RemoveEFlags(EFL_NO_THINK_FUNCTION) end
end

function MODULE:OnPhysgunPickup(_, entity)
    if (entity:isProp() or entity:isItem()) and entity:GetCollisionGroup() == COLLISION_GROUP_NONE then entity:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) end
end

function MODULE:PhysgunDrop(_, entity)
    if entity:isProp() and entity:isItem() then timer.Simple(5, function() if IsValid(entity) and entity:GetCollisionGroup() == COLLISION_GROUP_PASSABLE_DOOR then entity:SetCollisionGroup(COLLISION_GROUP_NONE) end end) end
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

function MODULE:PlayerInitialSpawn(client)
    if not client:getChar() then return end
    net.Start("VerifyCheats")
    net.Send(client)
end
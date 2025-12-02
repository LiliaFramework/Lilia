local MODULE = MODULE
function MODULE:CanPlayerSwitchChar(client, character, newCharacter)
    if not client:isStaffOnDuty() then
        local switchingToStaff = newCharacter and newCharacter:getFaction() == FACTION_STAFF
        local switchingFromStaff = character and character:getFaction() == FACTION_STAFF
        if not switchingToStaff and not switchingFromStaff then
            local damageCooldown = lia.config.get("OnDamageCharacterSwitchCooldownTimer", 15)
            local switchCooldown = lia.config.get("CharacterSwitchCooldownTimer", 5)
            if damageCooldown > 0 and client.LastDamaged and client.LastDamaged > CurTime() - damageCooldown then
                lia.log.add(client, "permissionDenied", L("logSwitchCharRecentDamage"))
                return false, L("tookDamageSwitchCooldown")
            end

            local loginTime = character:getLoginTime()
            if switchCooldown > 0 and loginTime + switchCooldown > os.time() then
                lia.log.add(client, "permissionDenied", L("logSwitchCharCooldown"))
                return false, L("switchCooldown")
            end
        end
    end
    return true
end

function MODULE:EntityTakeDamage(entity, dmgInfo)
    if IsValid(entity) and entity:IsVehicle() and entity:GetClass():find("prop_vehicle") then
        local driver = entity:GetDriver()
        if IsValid(driver) then
            local hitPos = dmgInfo:GetDamagePosition()
            if hitPos:Distance(driver:GetPos()) <= 53 then
                local newHealth = driver:Health() - dmgInfo:GetDamage() * 0.3
                if newHealth > 0 then
                    driver:SetHealth(newHealth)
                else
                    driver:Kill()
                end

                dmgInfo:SetDamage(0)
                return true
            end
        end
    end

    local inflictor = dmgInfo:GetInflictor()
    local attacker = dmgInfo:GetAttacker()
    if not IsValid(entity) or entity:IsPlayer() and dmgInfo:IsFallDamage() then return end
    if IsValid(inflictor) and inflictor:isProp() then
        dmgInfo:SetDamage(0)
        return
    end

    if dmgInfo:IsExplosionDamage() and lia.config.get("ExplosionRagdoll", false) then
        dmgInfo:ScaleDamage(0.5)
        local dmgPos = dmgInfo:GetDamagePosition()
        local dir = (entity:GetPos() - dmgPos):GetNormalized()
        entity:SetVelocity(dir * 60 * dmgInfo:GetDamage())
        local dmgAmt = dmgInfo:GetDamage()
        timer.Simple(0.05, function() if IsValid(entity) and entity:IsPlayer() and not IsValid(entity:getNetVar("ragdoll")) and entity:Health() - dmgAmt > 0 and not entity:InVehicle() then entity:setRagdolled(true, 3) end end)
    end

    if attacker ~= entity then
        if entity:GetMoveType() == MOVETYPE_NOCLIP then return end
        if lia.config.get("OnDamageCharacterSwitchCooldownTimer", 15) > 0 then
            local applyCd = lia.config.get("SwitchCooldownOnAllEntities", false) or attacker:IsPlayer()
            if applyCd then entity.LastDamaged = CurTime() end
        end

        if lia.config.get("CarRagdoll", false) and IsValid(inflictor) and inflictor:isSimfphysCar() then
            local veh = entity.GetVehicle and entity:GetVehicle() or nil
            if not (IsValid(veh) and veh:isSimfphysCar()) then
                dmgInfo:ScaleDamage(0)
                if entity:IsPlayer() and not IsValid(entity:getNetVar("ragdoll")) and entity:Health() > 0 then entity:setRagdolled(true, 5) end
            end
        end
    end
end

function MODULE:PlayerShouldAct()
    return lia.config.get("ActsActive", false)
end

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

local function collectSteamIDs(hookName)
    local collected = {}
    hook.Run(hookName, collected)
    local flattened = {}
    local function merge(tbl)
        for k, v in pairs(tbl) do
            if istable(v) then
                merge(v)
            else
                if isstring(k) then
                    flattened[k] = v
                else
                    flattened[v] = true
                end
            end
        end
    end

    merge(collected)
    return flattened
end

function MODULE:PlayerAuthed(client, steamid)
    local steamID64 = util.SteamIDTo64(steamid)
    local ownerSteamID64 = client:OwnerSteamID64()
    local steamName = client:SteamName()
    local steamID = steamid
    if KnownCheaters[steamID64] or KnownCheaters[ownerSteamID64] then
        lia.adminstrator.applyPunishment(client, L("usingThirdPartyCheats"), false, true, 0)
        lia.adminstrator.notifyAdmin(L("bannedCheaterNotify", steamName, steamID))
        lia.log.add(nil, "cheaterBanned", steamName, steamID)
        return
    end

    lia.db.selectOne({"reason"}, "bans", "playerSteamID = " .. ownerSteamID64):next(function(banRecord)
        if not IsValid(client) or not banRecord then return end
        lia.adminstrator.applyPunishment(client, L("familySharedAccountBlacklisted"), false, true, 0)
        lia.adminstrator.notifyAdmin(L("bannedAltNotify", steamName, steamID))
        lia.log.add(nil, "altBanned", steamName, steamID)
    end)

    local whitelistedSteamIDs = collectSteamIDs("GetWhitelistedSteamIDs")
    local blacklistedSteamIDs = collectSteamIDs("GetBlacklistedSteamIDs")
    local function punishIfBlacklisted(id, isAlt)
        local reason = blacklistedSteamIDs[id]
        if reason and not whitelistedSteamIDs[id] then
            reason = reason ~= true and reason or L("familySharedAccountBlacklisted")
            lia.adminstrator.applyPunishment(client, reason, false, true, 0)
            if isAlt then
                lia.adminstrator.notifyAdmin(L("bannedAltNotify", steamName, steamID))
                lia.log.add(nil, "altBanned", steamName, steamID)
            end
            return true
        end
    end

    if punishIfBlacklisted(steamID64) then return end
    if lia.config.get("AltsDisabled", false) and client:isFamilySharedAccount() then
        lia.adminstrator.applyPunishment(client, L("familySharingDisabled"), true, false)
        lia.adminstrator.notifyAdmin(L("kickedAltNotify", steamName, steamID))
    else
        punishIfBlacklisted(ownerSteamID64, true)
    end
end

function MODULE:PlayerSay(client, message)
    local hasIPAddress = string.match(message, "%d+%.%d+%.%d+%.%d+(:%d*)?")
    local hasBadWords = string.find(string.upper(message), string.upper("clone")) and string.find(string.upper(message), string.upper("nutscript"))
    if hasIPAddress then
        lia.adminstrator.applyPunishment(client, L("ipInChat"), true, false)
        return ""
    elseif hasBadWords then
        return ""
    end
end

function MODULE:PlayerLeaveVehicle(client, entity)
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

    lia.log.add(client, "vehicleExit", entity:GetClass(), entity:GetModel())
end

function MODULE:OnEntityCreated(entity)
    local class = entity:GetClass():lower():Trim()
    entity:SetCustomCollisionCheck(true)
    if class == "lua_run" and not lia.config.get("DisableLuaRun", false) then
        function entity:AcceptInput()
            return true
        end

        function entity:RunCode()
            return true
        end

        timer.Simple(0, function() if IsValid(entity) then SafeRemoveEntity(entity) end end)
    elseif class == "point_servercommand" then
        timer.Simple(0, function() if IsValid(entity) then SafeRemoveEntity(entity) end end)
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

local blocked = {
    lia_money = true,
    lia_item = true,
    prop_physics = true,
    func_tanktrain = true,
}

function MODULE:ShouldCollide(ent1, ent2)
    local c1, c2 = ent1:GetClass(), ent2:GetClass()
    local b1, b2 = blocked[c1], blocked[c2]
    if b1 and b2 then return false end
    return true
end

function MODULE:PlayerEnteredVehicle(client, entity)
    if entity:GetClass() == "prop_vehicle_prisoner_pod" then entity:RemoveEFlags(EFL_NO_THINK_FUNCTION) end
    lia.log.add(client, "vehicleEnter", entity:GetClass(), entity:GetModel())
end

function MODULE:OnPhysgunPickup(client, entity)
    if not lia.config.get("PropProtection", true) then return end
    if (entity:isProp() or entity:isItem()) and entity:GetCollisionGroup() == COLLISION_GROUP_NONE then entity:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) end
    lia.log.add(client, "physgunPickup", entity:GetClass(), entity:GetModel())
end

function MODULE:PhysgunDrop(client, entity)
    if not lia.config.get("PropProtection", true) then return end
    if entity:isProp() and entity:isItem() then timer.Simple(5, function() if IsValid(entity) and entity:GetCollisionGroup() == COLLISION_GROUP_PASSABLE_DOOR then entity:SetCollisionGroup(COLLISION_GROUP_NONE) end end) end
    lia.log.add(client, "physgunDrop", entity:GetClass(), entity:GetModel())
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

    if lia.config.get("PropProtection", true) and lia.config.get("PassableOnFreeze", false) then
        entity:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    else
        entity:SetCollisionGroup(COLLISION_GROUP_NONE)
    end

    lia.log.add(client, "physgunFreeze", entity:GetClass(), entity:GetModel())
    return true
end

function MODULE:PlayerInitialSpawn(client)
    if not client:getChar() then return end
    client.VerifyCheatsPending = true
    local timerName = "liaVerifyCheats:" .. client:SteamID64()
    client.VerifyCheatsTimer = timerName
    net.Start("liaVerifyCheats")
    net.Send(client)
    timer.Create(timerName, 10, 1, function()
        if IsValid(client) and client.VerifyCheatsPending then
            lia.log.add(client, "hackAttempt", "VerifyCheatsTimeout")
            hook.Run("PlayerCheatDetected", client)
            if IsValid(client) then
                lia.log.add(client, "cheaterDetected", client:Name(), client:SteamID())
                client:notifyErrorLocalized("caughtCheating")
                -- Warn staff
                for _, p in player.Iterator() do
                    if p:isStaffOnDuty() or p:hasPrivilege("receiveCheaterNotifications") then p:notifyWarningLocalized("cheaterDetectedStaff", client:Name(), client:SteamID()) end
                end

                if client:getChar() then
                    local warnsModule = lia.module.get("administration")
                    if warnsModule and warnsModule.AddWarning then
                        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
                        warnsModule:AddWarning(client:getChar():getID(), client:Nick(), client:SteamID(), timestamp, L("cheaterWarningReason"), "System", "SYSTEM")
                    end
                end
            end

            hook.Run("OnCheaterCaught", client)
        end
    end)
end

function MODULE:PlayerDisconnected(client)
    if client.VerifyCheatsTimer then
        timer.Remove(client.VerifyCheatsTimer)
        client.VerifyCheatsTimer = nil
    end
end
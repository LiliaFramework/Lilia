local GM = GM or GAMEMODE
local restrictedProperties = {
    persist = true,
    drive = true,
    bonemanipulate = true
}

function GM:PlayerSpawnProp(client, model)
    local list = lia.data.get("prop_blacklist", {})
    if table.HasValue(list, model) and not client:hasPrivilege("canSpawnBlacklistedProps") then
        lia.log.add(client, "spawnDenied", L("prop"), model)
        client:notifyLocalized("blacklistedProp")
        return false
    end

    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnProps") or client:hasFlags("e")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("prop"), model)
        client:notifyLocalized("noSpawnPropsPerm")
    end
    return canSpawn
end

function GM:CanProperty(client, property, entity)
    print("[TEST] CanProperty called with client:", client, "property:", property, "entity:", entity)
    if restrictedProperties[property] then
        print("[TEST] Property is restricted:", property)
        lia.log.add(client, "permissionDenied", L("useProperty", property))
        client:notifyLocalized("disabledFeature")
        return false
    end

    if entity:IsWorld() and IsValid(entity) then
        print("[TEST] Entity is world and valid.")
        if client:hasPrivilege("canPropertyWorldEntities") then
            print("[TEST] Client has canPropertyWorldEntities privilege.")
            return true
        end

        print("[TEST] Client does NOT have canPropertyWorldEntities privilege.")
        lia.log.add(client, "permissionDenied", L("modifyWorldProperty", property))
        client:notifyLocalized("noModifyWorldEntities")
        return false
    end

    if entity:GetCreator() == client and (property == "remover" or property == "collision") then
        print("[TEST] Client is creator and property is remover or collision.")
        return true
    end

    if client:hasPrivilege("property_" .. property) and client:isStaffOnDuty() then
        print("[TEST] Client has property privilege and is staff on duty.")
        return true
    end

    print("[TEST] Client does NOT have permission to modify property:", property)
    lia.log.add(client, "permissionDenied", L("modifyProperty", property))
    client:notifyLocalized("noModifyProperty")
    return false
end

function GM:DrawPhysgunBeam(client)
    if client:isNoClipping() then return false end
end

function GM:PhysgunPickup(client, entity)
    if (client:hasPrivilege("physgunPickup") or client:isStaffOnDuty()) and entity.NoPhysgun then
        if not client:hasPrivilege("physgunPickupRestrictedEntities") then
            lia.log.add(client, "permissionDenied", L("physgunRestrictedEntity"))
            client:notifyLocalized("noPickupRestricted")
            return false
        end
        return true
    end

    if entity:GetCreator() == client and (entity:isProp() or entity:isItem()) then return true end
    if client:hasPrivilege("physgunPickup") then
        if entity:IsVehicle() then
            if not client:hasPrivilege("physgunPickupVehicles") then
                lia.log.add(client, "permissionDenied", L("physgunVehicle"))
                client:notifyLocalized("noPickupVehicles")
                return false
            end
            return true
        elseif entity:IsPlayer() then
            if entity:hasPrivilege("cantBeGrabbedPhysgun") or not client:hasPrivilege("canGrabPlayers") then
                lia.log.add(client, "permissionDenied", L("physgunPlayer"))
                client:notifyLocalized("noPickupPlayer")
                return false
            end
            return true
        elseif entity:IsWorld() or entity:CreatedByMap() then
            if not client:hasPrivilege("canGrabWorldProps") then
                lia.log.add(client, "permissionDenied", L("physgunWorldProp"))
                client:notifyLocalized("noPickupWorld")
                return false
            end
            return true
        end
        return true
    end

    lia.log.add(client, "permissionDenied", L("physgunEntity"))
    client:notifyLocalized("noPickupEntity")
    return false
end

function GM:PlayerSpawnVehicle(client, model)
    if not client:hasPrivilege("noCarSpawnDelay") then client.NextVehicleSpawn = SysTime() + lia.config.get("PlayerSpawnVehicleDelay", 30) end
    local list = lia.data.get("carBlacklist", {})
    if model and table.HasValue(list, model) and not client:hasPrivilege("canSpawnBlacklistedCars") then
        lia.log.add(client, "spawnDenied", L("vehicle"), model)
        client:notifyLocalized("blacklistedVehicle")
        return false
    end

    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnCars") or client:hasFlags("C")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("vehicle"), model)
        client:notifyLocalized("noSpawnVehicles")
    end
    return canSpawn
end

function GM:PlayerNoClip(ply, enabled)
    if not (ply:isStaffOnDuty() or ply:hasPrivilege("noClipOutsideStaff")) then
        lia.log.add(ply, "permissionDenied", L("noclip"))
        ply:notifyLocalized("noNoclip")
        return false
    end

    ply:DrawShadow(not enabled)
    ply:SetNoTarget(enabled)
    ply:AddFlags(FL_NOTARGET)
    hook.Run("OnPlayerObserve", ply, enabled)
    return true
end

function GM:PlayerSpawnEffect(client)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnEffects") or client:hasFlags("L")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("effect"))
        client:notifyLocalized("noSpawnEffects")
    end
    return canSpawn
end

function GM:PlayerSpawnNPC(client)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnNPCs") or client:hasFlags("n")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("npc"))
        client:notifyLocalized("noSpawnNPCs")
    end
    return canSpawn
end

function GM:PlayerSpawnRagdoll(client)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnRagdolls") or client:hasFlags("r")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("ragdoll"))
        client:notifyLocalized("noSpawnRagdolls")
    end
    return canSpawn
end

function GM:PlayerSpawnSENT(client)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnSENTs") or client:hasFlags("E")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("sent"))
        client:notifyLocalized("noSpawnSents")
    end
    return canSpawn
end

function GM:PlayerSpawnSWEP(client)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnSWEPs") or client:hasFlags("z")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("swep"), tostring(swep))
        client:notifyLocalized("noSpawnSweps")
    end
    return canSpawn
end

function GM:PlayerGiveSWEP(client)
    local canGive = client:isStaffOnDuty() or client:hasPrivilege("canSpawnSWEPs") or client:hasFlags("W")
    if not canGive then
        lia.log.add(client, "permissionDenied", L("giveSwep"))
        client:notifyLocalized("noGiveSweps")
    end
    return canGive
end

function GM:OnPhysgunReload(_, client)
    local canReload = client:hasPrivilege("canPhysgunReload")
    if not canReload then
        lia.log.add(client, "permissionDenied", L("physgunReload"))
        client:notifyLocalized("noPhysgunReload")
    end
    return canReload
end

local DisallowedTools = {
    rope = true,
    light = true,
    lamp = true,
    dynamite = true,
    physprop = true,
    faceposer = true,
    stacker = true
}

function GM:CanTool(client, trace, tool)
    local function CheckDuplicationScale(ply, entities)
        entities = entities or {}
        for _, v in pairs(entities) do
            if v.ModelScale and v.ModelScale > 10 then
                ply:notifyLocalized("duplicationSizeLimit")
                lia.log.add(ply, "dupeCrashAttempt")
                return false
            end

            v.ModelScale = 1
        end
        return true
    end

    if DisallowedTools[tool] and not client:hasPrivilege("useDisallowedTools") then
        lia.log.add(client, "toolDenied", tool)
        client:notifyLocalized("toolNotAllowed", tool)
        return false
    end

    local formattedTool = tool:gsub("^%l", string.upper)
    local isStaffOrFlagged = client:isStaffOnDuty() or client:hasFlags("t")
    local hasPriv = client:hasPrivilege("tool_" .. tool)
    if not (isStaffOrFlagged and hasPriv) then
        local reasons = {}
        if not isStaffOrFlagged then table.insert(reasons, L("onDutyStaffOrFlagT")) end
        if not hasPriv then table.insert(reasons, L("privilege") .. " '" .. L("accessToolPrivilege", formattedTool) .. "'") end
        lia.log.add(client, "toolDenied", tool)
        client:notifyLocalized("toolNoPermission", tool, table.concat(reasons, ", "))
        return false
    end

    local entity = trace.Entity
    if IsValid(entity) then
        local entClass = entity:GetClass()
        if tool == "remover" then
            if entity.NoRemover then
                if not client:hasPrivilege("canRemoveBlockedEntities") then
                    lia.log.add(client, "permissionDenied", L("removeBlockedEntity"))
                    client:notifyLocalized("noRemoveBlockedEntities")
                    return false
                end
                return true
            elseif entity:IsWorld() then
                if not client:hasPrivilege("canRemoveWorldEntities") then
                    lia.log.add(client, "permissionDenied", L("removeWorldEntity"))
                    client:notifyLocalized("noRemoveWorldEntities")
                    return false
                end
                return true
            end
            return true
        end

        if (tool == "permaall" or tool == "blacklistandremove") and hook.Run("CanPersistEntity", entity) ~= false and (string.StartWith(entClass, "lia_") or entity:isLiliaPersistent() or entity:CreatedByMap()) then
            lia.log.add(client, "toolDenied", tool)
            client:notifyLocalized("toolCantUseEntity", tool)
            return false
        end

        if (tool == "duplicator" or tool == "blacklistandremove") and entity.NoDuplicate then
            lia.log.add(client, "toolDenied", tool)
            client:notifyLocalized("cannotDuplicateEntity", tool)
            return false
        end

        if tool == "weld" and entClass == "sent_ball" then
            lia.log.add(client, "toolDenied", tool)
            client:notifyLocalized("cannotWeldBall")
            return false
        end
    end

    if tool == "duplicator" and client.CurrentDupe and not CheckDuplicationScale(client, client.CurrentDupe.Entities) then return false end
    return true
end

function GM:PlayerSpawnedNPC(client, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedEffect(client, _, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedProp(client, _, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedRagdoll(client, _, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedSENT(client, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedSWEP(client, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnedVehicle(client, entity)
    entity:SetCreator(client)
end

function GM:CanPlayerUseChar(client)
    if GetGlobalBool("characterSwapLock", false) and not client:hasPrivilege("canBypassCharacterLock") then return false, L("serverEventCharLock") end
end
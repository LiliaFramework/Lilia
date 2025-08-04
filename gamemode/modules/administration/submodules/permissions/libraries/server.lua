local GM = GM or GAMEMODE
lia.administrator.registerPrivilege({
    Name = L("useDisallowedTools"),
    MinAccess = "superadmin",
    Category = L("categoryStaffTools")
})
local restrictedProperties = {
    persist = true,
    drive = true,
    bonemanipulate = true
}

function GM:PlayerSpawnProp(client, model)
    local list = lia.data.get("prop_blacklist", {})
    if table.HasValue(list, model) and not client:hasPrivilege("Can Spawn Blacklisted Props") then
        lia.log.add(client, "spawnDenied", "prop", model)
        client:notifyLocalized("blacklistedProp")
        return false
    end

    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("Can Spawn Props") or client:hasFlags("e")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", "prop", model)
        client:notifyLocalized("noSpawnPropsPerm")
    end
    return canSpawn
end

function GM:CanProperty(client, property, entity)
    if restrictedProperties[property] then
        lia.log.add(client, "permissionDenied", "use property " .. property)
        client:notifyLocalized("disabledFeature")
        return false
    end

    if entity:IsWorld() and IsValid(entity) then
        if client:hasPrivilege("Can Property World Entities") then return true end
        lia.log.add(client, "permissionDenied", "modify world property " .. property)
        client:notifyLocalized("noModifyWorldEntities")
        return false
    end

    if entity:GetCreator() == client and (property == "remover" or property == "collision") then return true end
    if client:hasPrivilege("Access Property " .. property:gsub("^%l", string.upper)) and client:isStaffOnDuty() then return true end
    lia.log.add(client, "permissionDenied", "modify property " .. property)
    client:notifyLocalized("noModifyProperty")
    return false
end

function GM:DrawPhysgunBeam(client)
    if client:isNoClipping() then return false end
end

function GM:PhysgunPickup(client, entity)
    if (client:hasPrivilege("Physgun Pickup") or client:isStaffOnDuty()) and entity.NoPhysgun then
        if not client:hasPrivilege("Physgun Pickup on Restricted Entities") then
            lia.log.add(client, "permissionDenied", "physgun restricted entity")
            client:notifyLocalized("noPickupRestricted")
            return false
        end
        return true
    end

    if entity:GetCreator() == client and (entity:isProp() or entity:isItem()) then return true end
    if client:hasPrivilege("Physgun Pickup") then
        if entity:IsVehicle() then
            if not client:hasPrivilege("Physgun Pickup on Vehicles") then
                lia.log.add(client, "permissionDenied", "physgun vehicle")
                client:notifyLocalized("noPickupVehicles")
                return false
            end
            return true
        elseif entity:IsPlayer() then
            if entity:hasPrivilege("Can't be Grabbed with PhysGun") or not client:hasPrivilege("Can Grab Players") then
                lia.log.add(client, "permissionDenied", "physgun player")
                client:notifyLocalized("noPickupPlayer")
                return false
            end
            return true
        elseif entity:IsWorld() or entity:CreatedByMap() then
            if not client:hasPrivilege("Can Grab World Props") then
                lia.log.add(client, "permissionDenied", "physgun world prop")
                client:notifyLocalized("noPickupWorld")
                return false
            end
            return true
        end
        return true
    end

    lia.log.add(client, "permissionDenied", "physgun entity")
    client:notifyLocalized("noPickupEntity")
    return false
end

function GM:PlayerSpawnVehicle(client, model)
    if not client:hasPrivilege("No Car Spawn Delay") then client.NextVehicleSpawn = SysTime() + lia.config.get("PlayerSpawnVehicleDelay", 30) end
    local list = lia.data.get("carBlacklist", {})
    if model and table.HasValue(list, model) and not client:hasPrivilege("Can Spawn Blacklisted Cars") then
        lia.log.add(client, "spawnDenied", "vehicle", model)
        client:notifyLocalized("blacklistedVehicle")
        return false
    end

    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("Can Spawn Cars") or client:hasFlags("C")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", "vehicle", model)
        client:notifyLocalized("noSpawnVehicles")
    end
    return canSpawn
end

function GM:PlayerNoClip(ply, enabled)
    if not (ply:isStaffOnDuty() or ply:hasPrivilege("No Clip Outside Staff Character")) then
        lia.log.add(ply, "permissionDenied", "noclip")
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
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("Can Spawn Effects") or client:hasFlags("L")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", "effect")
        client:notifyLocalized("noSpawnEffects")
    end
    return canSpawn
end

function GM:PlayerSpawnNPC(client)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("Can Spawn NPCs") or client:hasFlags("n")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", "npc")
        client:notifyLocalized("noSpawnNPCs")
    end
    return canSpawn
end

function GM:PlayerSpawnRagdoll(client)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("Can Spawn Ragdolls") or client:hasFlags("r")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", "ragdoll")
        client:notifyLocalized("noSpawnRagdolls")
    end
    return canSpawn
end

function GM:PlayerSpawnSENT(client)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("Can Spawn SENTs") or client:hasFlags("E")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", "sent")
        client:notifyLocalized("noSpawnSents")
    end
    return canSpawn
end

function GM:PlayerSpawnSWEP(client)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("Can Spawn SWEPs") or client:hasFlags("z")
    if not canSpawn then
        lia.log.add(client, "spawnDenied", "swep", tostring(swep))
        client:notifyLocalized("noSpawnSweps")
    end
    return canSpawn
end

function GM:PlayerGiveSWEP(client)
    local canGive = client:isStaffOnDuty() or client:hasPrivilege("Can Spawn SWEPs") or client:hasFlags("W")
    if not canGive then
        lia.log.add(client, "permissionDenied", "give swep")
        client:notifyLocalized("noGiveSweps")
    end
    return canGive
end

function GM:OnPhysgunReload(_, client)
    local canReload = client:hasPrivilege("Can Physgun Reload")
    if not canReload then
        lia.log.add(client, "permissionDenied", "physgun reload")
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

function GM:CanTool(client, _, tool)
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

    if DisallowedTools[tool] and not client:hasPrivilege("Use Disallowed Tools") then
        lia.log.add(client, "toolDenied", tool)
        client:notifyLocalized("toolNotAllowed", tool)
        return false
    end

    local formattedTool = tool:gsub("^%l", string.upper)
    local isStaffOrFlagged = client:isStaffOnDuty() or client:hasFlags("t")
    local hasPriv = client:hasPrivilege(L("accessToolPrivilege", formattedTool))
    if not (isStaffOrFlagged and hasPriv) then
        local reasons = {}
        if not isStaffOrFlagged then table.insert(reasons, "On-duty staff or flag 't'") end
        if not hasPriv then table.insert(reasons, "Privilege '" .. L("accessToolPrivilege", formattedTool) .. "'") end
        lia.log.add(client, "toolDenied", tool)
        client:notifyLocalized("toolNoPermission", tool, table.concat(reasons, ", "))
        return false
    end

    local entity = client:getTracedEntity()
    if IsValid(entity) then
        local entClass = entity:GetClass()
        if tool == "remover" then
            if entity.NoRemover then
                if not client:hasPrivilege("Can Remove Blocked Entities") then
                    lia.log.add(client, "permissionDenied", "remove blocked entity")
                    client:notifyLocalized("noRemoveBlockedEntities")
                    return false
                end
                return true
            elseif entity:IsWorld() then
                if not client:hasPrivilege("Can Remove World Entities") then
                    lia.log.add(client, "permissionDenied", "remove world entity")
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
    if GetGlobalBool("characterSwapLock", false) and not client:hasPrivilege("Can Bypass Character Lock") then return false, L("serverEventCharLock") end
end
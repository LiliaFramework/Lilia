local MODULE = MODULE
function MODULE:PlayerLoadedChar(client, character)
    if not IsValid(client) or not character or not client:isStaffOnDuty() then return end
    local configuredFlags = lia.staffCharacterFlags or lia.data.get("staffCharacterFlags", {})
    local missing = ""
    for flag, enabled in pairs(configuredFlags) do
        if enabled and lia.flag.list[flag] and not character:hasFlags(flag) then missing = missing .. flag end
    end

    if missing == "" then return end
    character:giveFlags(missing)
    character:save()
    lia.debug("[Permissions]", "Staff character flags applied", "player=", tostring(client), "flags=", missing, "finalResult=", "saved")
end

function MODULE:PlayerSay(client, text)
    if text and string.sub(text, 1, 1) == "@" then return end
    if client:getLiliaData("liaMuted", false) then
        if (client.liaNextMutedTalkNotice or 0) <= CurTime() then
            client.liaNextMutedTalkNotice = CurTime() + 2
            client:notifyWarningLocalized("mutedTryTalk")
        end
        return ""
    end
end

function MODULE:PlayerSpawn(client)
    if IsValid(client) and client:IsPlayer() then client:ConCommand("spawnmenu_reload") end
    lia.log.add(client, "playerSpawn")
end

function MODULE:PlayerShouldPermaKill(client)
    local character = client:getChar()
    if not character then return false end
    return character:getData("permakilled", false)
end

local GM = GM or GAMEMODE
local restrictedProperties = {
    persist = true,
    drive = true,
    bonemanipulate = true
}

function GM:PlayerSpawnProp(client, model)
    local list = lia.data.get("prop_blacklist", {})
    local modelBlacklisted = table.HasValue(list, model)
    local canSpawnBlacklistedProps = client:hasPrivilege("canSpawnBlacklistedProps")
    lia.debug("[Permissions]", "Permission Check for hook GM:PlayerSpawnProp blacklisted prop", "modelBlacklisted=", tostring(modelBlacklisted), "hasPrivilege(canSpawnBlacklistedProps)=", tostring(canSpawnBlacklistedProps), "finalResult=", tostring(not modelBlacklisted or canSpawnBlacklistedProps))
    if modelBlacklisted and not canSpawnBlacklistedProps then
        lia.log.add(client, "spawnDenied", L("prop"), model)
        client:notifyErrorLocalized("blacklistedProp")
        return false
    end

    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnProps") or client:hasFlags("e")
    lia.debug("[Permissions]", "Permission Check for hook GM:PlayerSpawnProp", "isStaffOnDuty=", tostring(client:isStaffOnDuty()), "hasPrivilege(canSpawnProps)=", tostring(client:hasPrivilege("canSpawnProps")), "hasFlags(e)=", tostring(client:hasFlags("e")), "finalResult=", tostring(canSpawn))
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("prop"), model)
        client:notifyErrorLocalized("noSpawnPropsPerm", model)
    end
    return canSpawn
end

local propertyPrivilegeEquivalents = {
    bodygroups = "property_bodygroups",
    bonemanipulate = "property_bonemanipulate",
    collision = "property_collision",
    drive = "property_drive",
    editentity = "canEditSimfphysCars",
    gravity = "property_gravity",
    ignite = "property_ignite",
    extinguish = "property_extinguish",
    keepupright = "property_keepupright",
    motioncontrol_ragdoll = "property_motioncontrol_ragdoll",
    npc_bigger = "property_npc_bigger",
    npc_smaller = "property_npc_smaller",
    persist = "property_persist",
    remover = "property_remove",
    skin = "property_skin",
    statue = "property_statue",
    unstatue = "property_unstatue",
    color = "property_color",
    material = "property_material"
}

function GM:CanProperty(client, property, entity)
    local privilegeName = propertyPrivilegeEquivalents[property] or "property_" .. property
    if restrictedProperties[property] then
        lia.log.add(client, "permissionDenied", L("useProperty", property))
        client:notifyErrorLocalized("disabledFeature")
        return false
    end

    if IsValid(entity) and entity:IsWorld() then
        local canPropertyWorldEntities = client:hasPrivilege("canPropertyWorldEntities")
        lia.debug("[Permissions]", "Permission Check for hook GM:CanProperty world entity", "property=", tostring(property), "hasPrivilege(canPropertyWorldEntities)=", tostring(canPropertyWorldEntities), "finalResult=", tostring(canPropertyWorldEntities))
        if canPropertyWorldEntities then return true end
        lia.log.add(client, "permissionDenied", L("modifyWorldProperty", property))
        client:notifyErrorLocalized("noModifyWorldEntities")
        return false
    end

    if IsValid(entity) and entity:GetCreator() == client and (property == "remove" or property == "collision") then return true end
    local hasPropertyPrivilege = client:hasPrivilege(privilegeName)
    local isStaffOnDuty = client:isStaffOnDuty()
    local permission = hasPropertyPrivilege or isStaffOnDuty
    lia.debug("[Permissions]", "Permission Check for hook GM:CanProperty", "property=", tostring(property), "privilegeName=", tostring(privilegeName), "hasPrivilege(dynamicPropertyPrivilege)=", tostring(hasPropertyPrivilege), "isStaffOnDuty=", tostring(isStaffOnDuty), "finalResult=", tostring(permission))
    if permission then return true end
    lia.log.add(client, "permissionDenied", L("modifyProperty", property))
    client:notifyErrorLocalized("noModifyProperty")
    return false
end

function GM:DrawPhysgunBeam(client)
    if client:GetMoveType() == MOVETYPE_NOCLIP then return false end
end

function GM:PlayerSpawnVehicle(client, model)
    lia.debug("[Permissions]", "Permission Check for hook GM:PlayerSpawnVehicle noCarSpawnDelay", "hasPrivilege(noCarSpawnDelay)=", tostring(client:hasPrivilege("noCarSpawnDelay")), "finalResult=", tostring(client:hasPrivilege("noCarSpawnDelay")))
    if not client:hasPrivilege("noCarSpawnDelay") then client.NextVehicleSpawn = SysTime() + lia.config.get("PlayerSpawnVehicleDelay", 30) end
    local list = lia.data.get("carBlacklist", {})
    local isBlacklistedModel = model and table.HasValue(list, model) or false
    local canSpawnBlacklistedCars = client:hasPrivilege("canSpawnBlacklistedCars")
    lia.debug("[Permissions]", "Permission Check for hook GM:PlayerSpawnVehicle blacklisted car", "modelBlacklisted=", tostring(isBlacklistedModel), "hasPrivilege(canSpawnBlacklistedCars)=", tostring(canSpawnBlacklistedCars), "finalResult=", tostring(not isBlacklistedModel or canSpawnBlacklistedCars))
    if model and isBlacklistedModel and not canSpawnBlacklistedCars then
        lia.log.add(client, "spawnDenied", L("vehicle"), model)
        client:notifyErrorLocalized("blacklistedVehicle")
        return false
    end

    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnCars") or client:hasFlags("C")
    lia.debug("[Permissions]", "Permission Check for hook GM:PlayerSpawnVehicle", "isStaffOnDuty=", tostring(client:isStaffOnDuty()), "hasPrivilege(canSpawnCars)=", tostring(client:hasPrivilege("canSpawnCars")), "hasFlags(C)=", tostring(client:hasFlags("C")), "finalResult=", tostring(canSpawn))
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("vehicle"), model)
        client:notifyErrorLocalized("noSpawnVehicles", model)
    end
    return canSpawn
end

function GM:PlayerSpawnEffect(client)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnEffects") or client:hasFlags("L")
    lia.debug("[Permissions]", "Permission Check for hook GM:PlayerSpawnEffect", "isStaffOnDuty=", tostring(client:isStaffOnDuty()), "hasPrivilege(canSpawnEffects)=", tostring(client:hasPrivilege("canSpawnEffects")), "hasFlags(L)=", tostring(client:hasFlags("L")), "finalResult=", tostring(canSpawn))
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("effect"))
        client:notifyErrorLocalized("noSpawnEffects")
    end
    return canSpawn
end

function GM:PlayerSpawnNPC(client)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnNPCs") or client:hasFlags("n")
    lia.debug("[Permissions]", "Permission Check for hook GM:PlayerSpawnNPC", "isStaffOnDuty=", tostring(client:isStaffOnDuty()), "hasPrivilege(canSpawnNPCs)=", tostring(client:hasPrivilege("canSpawnNPCs")), "hasFlags(n)=", tostring(client:hasFlags("n")), "finalResult=", tostring(canSpawn))
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("npc"))
        client:notifyErrorLocalized("noSpawnNPCs")
    end
    return canSpawn
end

function GM:PlayerSpawnRagdoll(client)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnRagdolls") or client:hasFlags("r")
    lia.debug("[Permissions]", "Permission Check for hook GM:PlayerSpawnRagdoll", "isStaffOnDuty=", tostring(client:isStaffOnDuty()), "hasPrivilege(canSpawnRagdolls)=", tostring(client:hasPrivilege("canSpawnRagdolls")), "hasFlags(r)=", tostring(client:hasFlags("r")), "finalResult=", tostring(canSpawn))
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("ragdoll"))
        client:notifyErrorLocalized("noSpawnRagdolls")
    end
    return canSpawn
end

function GM:PlayerSpawnSENT(client, class)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnSENTs") or client:hasFlags("E")
    lia.debug("[Permissions]", "Permission Check for hook GM:PlayerSpawnSENT", "isStaffOnDuty=", tostring(client:isStaffOnDuty()), "hasPrivilege(canSpawnSENTs)=", tostring(client:hasPrivilege("canSpawnSENTs")), "hasFlags(E)=", tostring(client:hasFlags("E")), "finalResult=", tostring(canSpawn))
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("sent"), tostring(class))
        client:notifyErrorLocalized("noSpawnSents", tostring(class))
    end
    return canSpawn
end

function GM:PlayerSpawnSWEP(client, weapon)
    local canSpawn = client:isStaffOnDuty() or client:hasPrivilege("canSpawnSWEPs") or client:hasFlags("z")
    lia.debug("[Permissions]", "Permission Check for hook GM:PlayerSpawnSWEP", "isStaffOnDuty=", tostring(client:isStaffOnDuty()), "hasPrivilege(canSpawnSWEPs)=", tostring(client:hasPrivilege("canSpawnSWEPs")), "hasFlags(z)=", tostring(client:hasFlags("z")), "finalResult=", tostring(canSpawn))
    if not canSpawn then
        lia.log.add(client, "spawnDenied", L("swep"), tostring(weapon))
        client:notifyErrorLocalized("noSpawnSweps", tostring(weapon))
    end
    return canSpawn
end

function GM:PlayerGiveSWEP(client)
    local canGive = client:isStaffOnDuty() or client:hasPrivilege("canSpawnSWEPs") or client:hasFlags("W")
    lia.debug("[Permissions]", "Permission Check for hook GM:PlayerGiveSWEP", "isStaffOnDuty=", tostring(client:isStaffOnDuty()), "hasPrivilege(canSpawnSWEPs)=", tostring(client:hasPrivilege("canSpawnSWEPs")), "hasFlags(W)=", tostring(client:hasFlags("W")), "finalResult=", tostring(canGive))
    if not canGive then
        lia.log.add(client, "permissionDenied", L("giveSwep"))
        client:notifyErrorLocalized("noGiveSweps")
    end
    return canGive
end

function GM:OnPhysgunReload(_, client)
    local canReload = client:hasPrivilege("canPhysgunReload")
    lia.debug("[Permissions]", "Permission Check for hook GM:OnPhysgunReload", "hasPrivilege(canPhysgunReload)=", tostring(canReload), "finalResult=", tostring(canReload))
    if not canReload then
        lia.log.add(client, "permissionDenied", L("physgunReload"))
        client:notifyErrorLocalized("noPhysgunReload")
    end
    return canReload
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
    local isLocked = GetGlobalBool("characterSwapLock", false)
    local canBypass = client:hasPrivilege("canBypassCharacterLock")
    lia.debug("[Permissions]", "Permission Check for hook GM:CanPlayerUseChar", "characterSwapLock=", tostring(isLocked), "hasPrivilege(canBypassCharacterLock)=", tostring(canBypass), "finalResult=", tostring(not isLocked or canBypass))
    if isLocked and not canBypass then return false, L("serverEventCharLock") end
end

hook.Add("PhysgunPickup", "Lilia.PhysgunPickup", function(client, entity)
    if client:InVehicle() then
        client:notifyErrorLocalized("cmdVehicle")
        return false
    end

    local hasPhysgunPickup = client:hasPrivilege("physgunPickup")
    local isStaffOnDuty = client:isStaffOnDuty()
    lia.debug("[Permissions]", "Permission Check for hook PhysgunPickup restricted entity gate", "hasPrivilege(physgunPickup)=", tostring(hasPhysgunPickup), "isStaffOnDuty=", tostring(isStaffOnDuty), "entityNoPhysgun=", tostring(entity.NoPhysgun == true), "finalResult=", tostring((hasPhysgunPickup or isStaffOnDuty) and entity.NoPhysgun ~= nil))
    if (hasPhysgunPickup or isStaffOnDuty) and entity.NoPhysgun then
        local hasRestrictedEntitiesPrivilege = client:hasPrivilege("physgunPickupRestrictedEntities")
        lia.debug("[Permissions]", "Permission Check for hook PhysgunPickup restricted entity override", "hasPrivilege(physgunPickupRestrictedEntities)=", tostring(hasRestrictedEntitiesPrivilege), "finalResult=", tostring(hasRestrictedEntitiesPrivilege))
        if not hasRestrictedEntitiesPrivilege then
            lia.log.add(client, "permissionDenied", L("physgunRestrictedEntity"))
            client:notifyErrorLocalized("noPickupRestricted")
            return false
        end
        return true
    end

    if entity:GetCreator() == client and (entity:isProp() or entity:isItem()) then return true end
    lia.debug("[Permissions]", "Permission Check for hook PhysgunPickup base gate", "hasPrivilege(physgunPickup)=", tostring(hasPhysgunPickup), "finalResult=", tostring(hasPhysgunPickup))
    if hasPhysgunPickup then
        if entity:IsVehicle() then
            local hasVehiclePrivilege = client:hasPrivilege("physgunPickupVehicles")
            lia.debug("[Permissions]", "Permission Check for hook PhysgunPickup vehicle", "hasPrivilege(physgunPickupVehicles)=", tostring(hasVehiclePrivilege), "finalResult=", tostring(hasVehiclePrivilege))
            if not hasVehiclePrivilege then
                lia.log.add(client, "permissionDenied", L("physgunVehicle"))
                client:notifyErrorLocalized("noPickupVehicles")
                return false
            end
            return true
        elseif entity:IsPlayer() then
            local targetProtected = entity:hasPrivilege("cantBeGrabbedPhysgun")
            local canGrabPlayers = client:hasPrivilege("canGrabPlayers")
            lia.debug("[Permissions]", "Permission Check for hook PhysgunPickup player", "targetHasPrivilege(cantBeGrabbedPhysgun)=", tostring(targetProtected), "hasPrivilege(canGrabPlayers)=", tostring(canGrabPlayers), "finalResult=", tostring(not targetProtected and canGrabPlayers))
            if targetProtected or not canGrabPlayers then
                lia.log.add(client, "permissionDenied", L("physgunPlayer"))
                client:notifyErrorLocalized("noPickupPlayer")
                return false
            end
            return true
        elseif entity:IsWorld() or entity:CreatedByMap() then
            local canGrabWorldProps = client:hasPrivilege("canGrabWorldProps")
            lia.debug("[Permissions]", "Permission Check for hook PhysgunPickup world", "hasPrivilege(canGrabWorldProps)=", tostring(canGrabWorldProps), "finalResult=", tostring(canGrabWorldProps))
            if not canGrabWorldProps then
                lia.log.add(client, "permissionDenied", L("physgunWorldProp"))
                client:notifyErrorLocalized("noPickupWorld")
                return false
            end
            return true
        end
        return true
    end

    lia.log.add(client, "permissionDenied", L("physgunEntity"))
    client:notifyErrorLocalized("noPickupEntity")
    return false
end)

local DisallowedTools = {
    rope = true,
    light = true,
    lamp = true,
    dynamite = true,
    physprop = true,
    faceposer = true,
    stacker = true
}

local function getToolPermissionTier(tool)
    tool = string.lower(tostring(tool or ""))
    local tiers = lia.data.get("toolPermissionTiers", {})
    local tier = istable(tiers) and tiers[tool] or nil
    if tier == "disabled" or tier == "staff" or tier == "basic" then return tier end
    if DisallowedTools[tool] then return "disabled" end
    if tool == "remover" then return "basic" end
    return "staff"
end

hook.Add("CanTool", "Lilia.CanTool", function(client, trace, tool)
    if client:InVehicle() then
        client:notifyErrorLocalized("cmdVehicle")
        return false
    end

    local function CheckDuplicationScale(ply, entities)
        entities = entities or {}
        for _, v in pairs(entities) do
            if v.ModelScale and v.ModelScale > 10 then
                ply:notifyErrorLocalized("duplicationSizeLimit")
                lia.log.add(ply, "dupeCrashAttempt")
                return false
            end

            v.ModelScale = 1
        end
        return true
    end

    local hasToolgunFlag = client:hasFlags("t")
    local isStaffWithToolgunFlag = client:isStaffOnDuty() and hasToolgunFlag
    local hasToolPrivilege = client:hasPrivilege("tool_" .. tool)
    local hasUseDisallowedTools = client:hasPrivilege("useDisallowedTools")
    local tier = getToolPermissionTier(tool)
    local permitted = hasToolPrivilege or tier == "basic" and hasToolgunFlag or tier == "staff" and isStaffWithToolgunFlag or tier == "disabled" and hasToolgunFlag and hasUseDisallowedTools
    lia.debug("[Permissions]", "Permission Check for hook CanTool tier", "tool=", tostring(tool), "tier=", tier, "hasToolgunFlag=", tostring(hasToolgunFlag), "isStaffWithToolgunFlag=", tostring(isStaffWithToolgunFlag), "hasToolPrivilege=", tostring(hasToolPrivilege), "hasUseDisallowedTools=", tostring(hasUseDisallowedTools), "finalResult=", tostring(permitted))
    if not permitted then
        local reasons = {}
        if tier == "disabled" then
            if not hasUseDisallowedTools then table.insert(reasons, L("privilege") .. " '" .. L("useDisallowedTools") .. "'") end
            if not hasToolgunFlag then table.insert(reasons, "flag 't'") end
        elseif tier == "staff" then
            if not client:isStaffOnDuty() then table.insert(reasons, "on-duty staff") end
            if not hasToolgunFlag then table.insert(reasons, "flag 't'") end
        elseif tier == "basic" and not hasToolgunFlag then
            table.insert(reasons, "flag 't'")
        end

        lia.log.add(client, "toolDenied", tool)
        client:notifyErrorLocalized(tier == "disabled" and "toolNoPermission" or "toolNotAllowed", tool, table.concat(reasons, ", "))
        return false
    end

    local entity = trace.Entity
    if IsValid(entity) then
        local entClass = entity:GetClass()
        if tool == "remover" then
            if entity.NoRemover then
                local canRemoveBlockedEntities = client:hasPrivilege("canRemoveBlockedEntities")
                lia.debug("[Permissions]", "Permission Check for hook CanTool remover blocked entity", "hasPrivilege(canRemoveBlockedEntities)=", tostring(canRemoveBlockedEntities), "finalResult=", tostring(canRemoveBlockedEntities))
                if not canRemoveBlockedEntities then
                    lia.log.add(client, "permissionDenied", L("removeBlockedEntity"))
                    client:notifyErrorLocalized("noRemoveBlockedEntities")
                    return false
                end
                return true
            elseif entity:IsWorld() then
                local canRemoveWorldEntities = client:hasPrivilege("canRemoveWorldEntities")
                lia.debug("[Permissions]", "Permission Check for hook CanTool remover world entity", "hasPrivilege(canRemoveWorldEntities)=", tostring(canRemoveWorldEntities), "finalResult=", tostring(canRemoveWorldEntities))
                if not canRemoveWorldEntities then
                    lia.log.add(client, "permissionDenied", L("removeWorldEntity"))
                    client:notifyErrorLocalized("noRemoveWorldEntities")
                    return false
                end
                return true
            end
            return true
        end

        if (tool == "permaall" or tool == "blacklistandremove") and hook.Run("CanPersistEntity", entity) ~= false and (string.StartWith(entClass, "lia_") or entity.IsPersistent or entity:CreatedByMap()) then
            lia.log.add(client, "toolDenied", tool)
            client:notifyErrorLocalized("toolCantUseEntity", tool)
            return false
        end

        if (tool == "duplicator" or tool == "blacklistandremove") and entity.NoDuplicate then
            lia.log.add(client, "toolDenied", tool)
            client:notifyErrorLocalized("cannotDuplicateEntity", tool)
            return false
        end

        if tool == "weld" and entClass == "sent_ball" then
            lia.log.add(client, "toolDenied", tool)
            client:notifyErrorLocalized("cannotWeldBall")
            return false
        end
    end

    if tool == "duplicator" and client.CurrentDupe and not CheckDuplicationScale(client, client.CurrentDupe.Entities) then return false end
    return true
end)

hook.Add("GravGunPickupAllowed", "Lilia.GravGunPickupAllowed", function(client)
    if client:InVehicle() then
        client:notifyErrorLocalized("cmdVehicle")
        return false
    end
end)

hook.Add("PlayerNoClip", "Lilia.PlayerNoClip", function(ply, enabled)
    local isStaffOnDuty = ply:isStaffOnDuty()
    local hasNoClipOutsideStaff = ply:hasPrivilege("noClipOutsideStaff")
    local permission = isStaffOnDuty or hasNoClipOutsideStaff
    lia.debug("[Permissions]", "Permission Check for hook PlayerNoClip", "isStaffOnDuty=", tostring(isStaffOnDuty), "hasPrivilege(noClipOutsideStaff)=", tostring(hasNoClipOutsideStaff), "finalResult=", tostring(permission))
    if not permission then
        lia.log.add(ply, "permissionDenied", L("noclip"))
        ply:notifyErrorLocalized("noNoclip")
        return false
    end

    ply:SetNoDraw(enabled)
    ply:SetNotSolid(enabled)
    ply:DrawWorldModel(not enabled)
    ply:DrawShadow(enabled)
    ply:SetNoTarget(enabled)
    if enabled then
        ply:GodEnable()
        ply:AddFlags(FL_NOTARGET)
    else
        ply:GodDisable()
        ply:RemoveFlags(FL_NOTARGET)
    end

    hook.Run("OnPlayerObserve", ply, enabled)
    return true
end)

local GM = GM or GAMEMODE
function GM:PhysgunPickup(client, entity)
    if entity:GetCreator() == client and (entity:isProp() or entity:isItem()) then return true end
    if client:IsSuperAdmin() then return true end
    if CAMI.PlayerHasAccess(client, "Staff Permissions - Physgun Pickup", nil) or client:isStaffOnDuty() then
        if table.HasValue(PermissionCore.RestrictedEnts, entity:GetClass()) then
            return CAMI.PlayerHasAccess(client, "Staff Permissions - Physgun Pickup on Restricted Entities", nil)
        elseif entity:IsVehicle() then
            return CAMI.PlayerHasAccess(client, "Staff Permissions - Physgun Pickup on Vehicles", nil)
        elseif entity:IsPlayer() then
            return not CAMI.PlayerHasAccess(entity, "Staff Permissions - Can't be Grabbed with PhysGun", nil) and CAMI.PlayerHasAccess(client, "Staff Permissions - Can Grab Players", nil)
        elseif entity:IsWorld() or entity:CreatedByMap() then
            return CAMI.PlayerHasAccess(client, "Staff Permissions - Can Grab World Props", nil)
        end
        return true
    end
    return false
end

function GM:OnPhysgunPickup(_, entity)
    if (entity:isProp() or entity:isItem()) and entity:GetCollisionGroup() == COLLISION_GROUP_NONE then entity:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) end
end

function GM:OnPhysgunReload(_, client)
    if not CAMI.PlayerHasAccess(client, "Staff Permissions - Can Physgun Reload", nil) then return false end
end

function GM:PhysgunDrop(_, entity)
    if not entity:isProp() or not entity:isItem() then return end
    timer.Simple(5, function() if IsValid(entity) and entity:GetCollisionGroup() == COLLISION_GROUP_PASSABLE_DOOR then entity:SetCollisionGroup(COLLISION_GROUP_NONE) end end)
end

function GM:OnPhysgunFreeze(_, physObj, entity, client)
    if not IsValid(physObj) or not IsValid(entity) then return false end
    if not physObj:IsMoveable() then return false end
    if entity:GetUnFreezable() then return false end
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

    if PermissionCore.PassableOnFreeze then
        entity:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    else
        entity:SetCollisionGroup(COLLISION_GROUP_NONE)
    end
    return true
end

function GM:CanProperty(client, property, entity)
    if (property == "persist") or (property == "drive") or (property == "bonemanipulate") then
        client:notify("This is disabled to avoid issues with Lilia's Core Features")
        return false
    end

    if entity:GetCreator() == client and (property == "remover" or property == "collision") then return true end
    if CAMI.PlayerHasAccess(client, "Staff Permissions - Access Property " .. property:gsub("^%l", string.upper), nil) or client:isStaffOnDuty() then
        if entity:IsWorld() and IsValid(entity) then return CAMI.PlayerHasAccess(client, "Staff Permissions - Can Property World Entities", nil) end
        if table.HasValue(PermissionCore.RemoverBlockedEntities, entity:GetClass()) or table.HasValue(PermissionCore.RestrictedEnts, entity:GetClass()) then return CAMI.PlayerHasAccess(client, "Staff Permissions - Use Entity Properties on Blocked Entities", nil) end
        return true
    end
    return false
end
function GM:PlayerSpawnedSENT(client, entity)
    entity:SetCreator(client)
end

function GM:PlayerSpawnNPC(client)
    if IsValid(client) and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn NPCs", nil) or client:getChar():hasFlags("n") then return true end
    return false
end

function GM:PlayerSpawnObject(client, _, _)
    if not client.NextSpawn then client.NextSpawn = CurTime() end
    if IsValid(client:GetActiveWeapon()) and client:GetActiveWeapon():GetClass() == "gmod_tool" then
        local toolobj = client:GetActiveWeapon():GetToolObject()
        if (client.AdvDupe2 and client.AdvDupe2.Entities) or (client.CurrentDupe and client.CurrentDupe.Entities) or toolobj.Entities then return true end
    end

    if CAMI.PlayerHasAccess(client, "Spawn Permissions - No Spawn Delay", nil) then return true end
    if client.NextSpawn < CurTime() then
        client.NextSpawn = CurTime() + 0.75
    else
        client:notify("You can't spawn props that fast!")
        return false
    end
    return true
end

function GM:PlayerSpawnRagdoll(client)
    return (client:isStaffOnDuty() and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Ragdolls", nil)) or client:getChar():hasFlags("r")
end

function GM:PlayerSpawnProp(client, model)
    local isBlacklistedProp = table.HasValue(PermissionCore.BlackListedProps, model)
    if isBlacklistedProp and not CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Blacklisted Props", nil) then return false end
    if IsValid(client:GetActiveWeapon()) and client:GetActiveWeapon():GetClass() == "gmod_tool" then
        local toolobj = client:GetActiveWeapon():GetToolObject()
        if (client.AdvDupe2 and client.AdvDupe2.Entities) or (client.CurrentDupe and client.CurrentDupe.Entities) or toolobj.Entities then return true end
    end
    return (client:isStaffOnDuty() and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Props", nil)) or client:getChar():hasFlags("e")
end

function GM:PlayerSpawnSWEP(client)
    if IsValid(client) and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn SWEPs", nil) or client:getChar():hasFlags("z") then return true end
end

function GM:PlayerGiveSWEP(client)
    if IsValid(client) and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn SWEPs", nil) or client:getChar():hasFlags("W") then return true end
    return false
end

function GM:PlayerSpawnEffect(client)
    if IsValid(client) and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Effects", nil) or client:getChar():hasFlags("L") then return true end
    return false
end

function GM:PlayerSpawnSENT(client)
    if IsValid(client) and CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn SENTs", nil) or client:getChar():hasFlags("E") then return true end
    return false
end

function GM:PlayerSpawnVehicle(client, _, name, _)
    local delay = PermissionCore.PlayerSpawnVehicleDelay
    if IsValid(client) and client:getChar():hasFlags("C") or CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Cars", nil) then
        if table.HasValue(PermissionCore.RestrictedVehicles, name) and not CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Restricted Cars", nil) then
            client:notify("You can't spawn this vehicle since it's restricted!")
            return false
        end

        if not CAMI.PlayerHasAccess(client, "Spawn Permissions - No Car Spawn Delay", nil) then client.NextVehicleSpawn = SysTime() + delay end
        return true
    end
    return false
end

function GM:PlayerSpawnedNPC(client, entity)
    if PermissionCore.NPCsDropWeapons then entity:SetKeyValue("spawnflags", "8192") end
    self:PlayerSpawnedEntity(client, entity, entity:GetClass(), "NPC", true)
end

function GM:PlayerSpawnedVehicle(client, entity)
    self:PlayerSpawnedEntity(client, entity, entity:GetClass(), "Vehicle", true)
end

function GM:PlayerSpawnedEffect(client, _, entity)
    self:PlayerSpawnedEntity(client, entity, entity:GetClass(), "Effect", true)
end

function GM:PlayerSpawnedRagdoll(client, _, entity)
    self:PlayerSpawnedEntity(client, entity, entity:GetClass(), "Ragdoll", false)
end

function GM:PlayerSpawnedProp(client, _, entity)
    self:PlayerSpawnedEntity(client, entity, entity:GetClass(), "Model", false)
    if entity:GetMaterial() and string.lower(entity:GetMaterial()) == "pp/copy" then entity:Remove() end
end

function GM:PlayerSpawnedEntity(client, entity, class, group, hasName)
    local entityName = entity:GetName() or "Unnamed"
    local entityModel = entity:GetModel() or "Unknown Model"
    entity:SetCreator(client)
    entity:SetNW2Entity("creator", client)
end

function GM:CanTool(client, _, tool)
    local privilege = "Staff Permissions - Access Tool " .. tool:gsub("^%l", string.upper)
    local toolobj = client:GetActiveWeapon():GetToolObject()
    local entity = client:GetTracedEntity()
    local validEntity = IsValid(entity)
    local isUser = client:IsUserGroup("user")
    if not client.ToolInterval then client.ToolInterval = CurTime() end
    if CurTime() < client.ToolInterval then
        client:notify("Tool on Cooldown!")
        return false
    end

    if validEntity then
        local entClass = entity:GetClass()
        local clientOwned = entity:GetCreator() == client
        local basePermission = (client:getChar():hasFlags("t") and isUser and clientOwned) or (client:isStaffOnDuty() and CAMI.PlayerHasAccess(client, privilege, nil)) or client:IsSuperAdmin()
        if tool == "remover" then
            if table.HasValue(PermissionCore.RemoverBlockedEntities, entClass) then
                return CAMI.PlayerHasAccess(client, "Staff Permissions - Can Remove Blocked Entities", nil)
            elseif entity:IsWorld() then
                return CAMI.PlayerHasAccess(client, "Staff Permissions - Can Remove World Entities", nil)
            end
            return basePermission
        end

        if tool == "inflator" then return basePermission end
        if tool == "nocollide" then return basePermission end
        if tool == "colour" then return basePermission end
        if tool == "material" or tool == "submaterial" then
            if entClass == "prop_vehicle_jeep" or (tool:GetClientInfo("override") and string.lower(tool:GetClientInfo("override")) == "pp/copy") then return false end
            return basePermission
        end

        if (tool == "permaall" or tool == "permaprops" or tool == "blacklistandremove") and (string.StartsWith(entClass, "lia_") or table.HasValue(PermissionCore.CanNotPermaProp, entClass) or entity.IsLeonNPC) then return false end
        if (tool == "adv_duplicator" or tool == "advdupe2" or tool == "duplicator" or tool == "blacklistandremove") and (table.HasValue(PermissionCore.DuplicatorBlackList, entity) or entity.NoDuplicate) then return false end
        if tool == "weld" and entClass == "sent_ball" then return false end
    end

    if tool == "duplicator" and client.CurrentDupe and client.CurrentDupe.Entities then
        for _, v in pairs(client.CurrentDupe.Entities) do
            if v.ModelScale and v.ModelScale > 10 then
                client:notify("A model within this duplication exceeds the size limit!")
                print("[Server Warning] Potential server crash using dupes attempt by player: " .. client:Name() .. " (" .. client:SteamID() .. ")")
                return false
            end

            v.ModelScale = 1
        end
    end

    if tool == "advdupe2" and client.AdvDupe2 and client.AdvDupe2.Entities then
        for _, v in pairs(client.AdvDupe2.Entities) do
            if v.ModelScale and v.ModelScale > 10 then
                client:notify("A model within this duplication exceeds the size limit!")
                print("[Server Warning] Potential server crash using dupes attempt by player: " .. client:Name() .. " (" .. client:SteamID() .. ")")
                return false
            end

            v.ModelScale = 1
        end
    end

    if tool == "adv_duplicator" and toolobj.Entities then
        for _, v in pairs(toolobj.Entities) do
            if v.ModelScale and v.ModelScale > 10 then
                client:notify("A model within this duplication exceeds the size limit!")
                print("[Server Warning] Potential server crash using dupes attempt by player: " .. client:Name() .. " (" .. client:SteamID() .. ")")
                return false
            end

            v.ModelScale = 1
        end
    end

    if tool == "button" and not table.HasValue(PermissionCore.ButtonList, client:GetInfo("button_model")) then
        client:ConCommand("button_model models/maxofs2d/button_05.mdl")
        client:ConCommand("button_model")
        return false
    end

    client.ToolInterval = CurTime() + PermissionCore.ToolInterval
    return (client:isStaffOnDuty() or client:getChar():hasFlags("t")) and CAMI.PlayerHasAccess(client, privilege, nil)
end

function MODULE:PlayerNoClip(client, state)
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

function MODULE:OnPlayerObserve(client, state)
    lia.log.add(client, (state and "observerEnter") or "observerExit")
end

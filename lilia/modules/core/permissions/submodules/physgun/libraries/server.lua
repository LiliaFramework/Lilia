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
    if not physObj:IsMoveable() then return false end
    if entity:GetUnFreezable() then return false end
    physObj:EnableMotion(false)
    if entity:GetClass() == "prop_vehicle_jeep" then
        local objects = entity:GetPhysicsObjectCount()
        for i = 0, objects - 1 do
            entity:GetPhysicsObjectNum(i):EnableMotion(false)
        end
    end

    client:AddFrozenPhysicsObject(entity, physObj)
    client:SendHint("PhysgunUnfreeze", 0.3)
    client:SuppressHint("PhysgunFreeze")
    if PermissionCore.PassableOnFreeze then
        entity:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    else
        entity:SetCollisionGroup(COLLISION_GROUP_NONE)
    end
    return true
end
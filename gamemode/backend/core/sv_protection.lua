lia.config.TimeUntilDroppedSWEPRemoved = 15
lia.config.PlayerSpawnVehicleDelay = 30
lia.config.NPCsDropWeapons = true
lia.config.DrawEntityShadows = true

function GM:OnPlayerDropWeapon(client, item, entity)
    timer.Simple(lia.config.TimeUntilDroppedSWEPRemoved, function()
        if entity and entity:IsValid() then
            entity:Remove()
        end
    end)
end

function GM:CanDeleteChar(ply, char)
    if char:getMoney() < lia.config.DefaultMoney or ply:getNetVar("restricted") then return true end
end

function GM:OnEntityCreated(ent)
    if lia.config.DrawEntityShadows then
        ent:DrawShadow(false)
    end

    if not ent:IsRagdoll() then return end
    if ent:getNetVar("player", nil) then return end

    timer.Simple(300, function()
        if not IsValid(ent) then return end
        ent:SetSaveValue("m_bFadingOut", true)

        timer.Simple(3, function()
            if not IsValid(ent) then return end
            ent:Remove()
        end)
    end)
end

function GM:CheckValidSit(ply, trace)
    local ent = trace.Entity
    if ply:getNetVar("restricted") or ent:IsPlayer() then return false end
end

function GM:PlayerSpawnedVehicle(ply, ent)
    local delay = lia.config.PlayerSpawnVehicleDelay

    if not ply:IsSuperAdmin() then
        ply.NextVehicleSpawn = SysTime() + delay
    end
end

function GM:OnPhysgunFreeze(weapon, physObj, entity, client)
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

    return true
end

function GM:PlayerSpawnedNPC(client, entity)
    entity:SetCreator(client)
    entity:SetNWString("Creator_Nick", client:Nick())
    if lia.config.NPCsDropWeapons then  
    entity:SetKeyValue("spawnflags", "8192")
    end
end

function GM:PlayerDisconnected(client)
    client:saveLiliaData()
    local character = client:getChar()

    if character then
        local charEnts = character:getVar("charEnts") or {}

        for _, v in ipairs(charEnts) do
            if v and IsValid(v) then
                v:Remove()
            end
        end

        hook.Run("OnCharDisconnect", client, character)
        character:save()
    end

    if IsValid(client.liaRagdoll) then
        client.liaRagdoll.liaNoReset = true
        client.liaRagdoll.liaIgnoreDelete = true
        client.liaRagdoll:Remove()
    end

    lia.char.cleanUpForPlayer(client)

    for _, entity in pairs(ents.GetAll()) do
        if entity:GetCreator() == client then
            entity:Remove()
        end
    end
end

function GM:OnPhysgunPickup(ply, ent)
    if ent:GetClass() == "prop_physics" and ent:GetCollisionGroup() == COLLISION_GROUP_NONE then
        ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    end
end

function GM:PlayerSpawnObject(client, model, skin)
    if client:IsSuperAdmin() then return true end

    if (client.liaNextSpawn or 0) < CurTime() then
        if client.AdvDupe2 and client.AdvDupe2.Pasting then
            client.liaNextSpawn = CurTime() + 5
        else
            client.liaNextSpawn = CurTime() + 0.75
        end
    else
        if client.AdvDupe2 and client.AdvDupe2.Pasting then return true end

        return false
    end
end

function GM:PhysgunDrop(ply, ent)
    if ent:GetClass() ~= "prop_physics" then return end

    timer.Simple(5, function()
        if IsValid(ent) and ent:GetCollisionGroup() == COLLISION_GROUP_PASSABLE_DOOR then
            ent:SetCollisionGroup(COLLISION_GROUP_NONE)
        end
    end)
end

function GM:PlayerSpawnedProp(client, model, entity)
    -- Removes Problematic Models
    for _, gredwitch in pairs(file.Find("models/gredwitch/bombs/*.mdl", "GAME")) do
        if model == "models/gredwitch/bombs/" .. gredwitch then
            entity:Remove()

            return
        end
    end

    for _, gbombs in pairs(file.Find("models/gbombs/*.mdl", "GAME")) do
        if model == "models/gbombs/" .. gbombs then
            entity:Remove()

            return
        end
    end

    for _, phx in pairs(file.Find("models/props_phx/*.mdl", "GAME")) do
        if model == "models/props_phx/" .. phx then
            entity:Remove()

            return
        end
    end

    for _, mikeprops in pairs(file.Find("models/mikeprops/*.mdl", "GAME")) do
        if model == "models/mikeprops/" .. mikeprops then
            entity:Remove()

            return
        end
    end

    if table.HasValue(lia.config.PropBlacklist, model:lower()) then
        client:notify("You cannot spawn this prop.")
        entity:Remove()

        return
    end

    self:PlayerSpawnedEntity(client, entity)
end

function GM:PlayerSpawnedEntity(client, entity)
    entity:SetNWString("Creator_Nick", client:Nick())
    entity:SetCreator(client)
end
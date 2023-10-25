--------------------------------------------------------------------------------------------------------------------------
function GM:OnPlayerDropWeapon(client, item, entity)
    local physObject = entity:GetPhysicsObject()
    if physObject then
        physObject:EnableMotion()
    end

    timer.Simple(
        lia.config.TimeUntilDroppedSWEPRemoved,
        function()
            if entity and entity:IsValid() then
                entity:Remove()
            end
        end
    )
end

--------------------------------------------------------------------------------------------------------------------------
function GM:CanDeleteChar(client, char)
    if char:getMoney() < lia.config.DefaultMoney then return true end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:OnEntityCreated(entity)
    if lia.config.DrawEntityShadows then
        entity:DrawShadow(false)
    end

    if entity:GetClass() == "prop_vehicle_prisoner_pod" then
        entity:AddEFlags(EFL_NO_THINK_FUNCTION)
        entity.nicoSeat = true
    end

    if entity:IsWidget() then
        hook.Add(
            "PlayerTick",
            "GODisableEntWidgets2",
            function(entity, n)
                widgets.PlayerTick(entity, n)
            end
        )
    end

    if not entity:IsRagdoll() then return end
    if entity:getNetVar("player", nil) then return end
    timer.Simple(
        300,
        function()
            if not IsValid(entity) then return end
            entity:SetSaveValue("m_bFadingOut", true)
            timer.Simple(
                3,
                function()
                    if not IsValid(entity) then return end
                    entity:Remove()
                end
            )
        end
    )
end

--------------------------------------------------------------------------------------------------------------------------
function GM:CheckValidSit(client, trace)
    local entity = client:GetTracedEntity()
    if entity:IsPlayer() then return false end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnedVehicle(client, entity)
    local delay = lia.config.PlayerSpawnVehicleDelay
    if not client:IsSuperAdmin() then
        client.NextVehicleSpawn = SysTime() + delay
    end

    self:PlayerSpawnedEntity(client, entity)
end

--------------------------------------------------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnedNPC(client, entity)
    if lia.config.NPCsDropWeapons then
        entity:SetKeyValue("spawnflags", "8192")
    end

    self:PlayerSpawnedEntity(client, entity)
end

--------------------------------------------------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------------------------------------------
function GM:OnPhysgunPickup(client, entity)
    if entity:GetClass() == "prop_physics" and entity:GetCollisionGroup() == COLLISION_GROUP_NONE then
        entity:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnObject(client, model, skin)
    local bEditLimit = ents.GetEdictCount() >= 7900
    if bEditLimit then
        ErrorNoHalt(string.format("[Lilia] %s attempted to spawn an entity but edict limit is too high!\n", client:Name()))
        client:notify("The server is too close to the edict limit to spawn this!")

        return false
    end

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

--------------------------------------------------------------------------------------------------------------------------
function GM:PhysgunDrop(client, entity)
    if entity:GetClass() ~= "prop_physics" then return end
    timer.Simple(
        5,
        function()
            if IsValid(entity) and entity:GetCollisionGroup() == COLLISION_GROUP_PASSABLE_DOOR then
                entity:SetCollisionGroup(COLLISION_GROUP_NONE)
            end
        end
    )
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnedEffect(client, model, entity)
    self:PlayerSpawnedEntity(client, entity)
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnedRagdoll(client, model, entity)
    self:PlayerSpawnedEntity(client, entity)
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnedSENT(client, entity)
    self:PlayerSpawnedEntity(client, entity)
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnedProp(client, model, entity)
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

    self:PlayerSpawnedEntity(client, entity)
end

--------------------------------------------------------------------------------------------------------------------------
function GM:PlayerSpawnedEntity(client, entity)
    entity:SetNW2String("Creator_Nick", client:Nick())
    entity:SetCreator(client)
end
--------------------------------------------------------------------------------------------------------------------------
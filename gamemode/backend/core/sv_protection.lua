function GM:OnPlayerDropWeapon(client, item, entity)
    local timer = lia.config.TimeUntilDroppedSWEPRemoved
    timer.Simple(timer, function() if entity and entity:IsValid() then entity:Remove() end end)
end

function GM:CanDeleteChar(ply, char)
    if char:getMoney() < lia.config.DefaultMoney or ply:getNetVar("restricted") then return true end
end

function GM:OnEntityCreated(ent)
    if not ent:IsRagdoll() then return end
    if ent:getNetVar("player", nil) then return end
    timer.Simple(
        300,
        function()
            if not IsValid(ent) then return end
            ent:SetSaveValue("m_bFadingOut", true)
            timer.Simple(
                3,
                function()
                    if not IsValid(ent) then return end
                    ent:Remove()
                end
            )
        end
    )
end

function GM:CheckValidSit(ply, trace)
    local ent = trace.Entity
    if ply:getNetVar("restricted") or ent:IsPlayer() then return false end
end

function GM:PlayerSpawnedVehicle(ply, ent)
    local timer = lia.config.PlayerSpawnVehicleDelay
    if not ply:IsSuperAdmin() then ply.NextVehicleSpawn = SysTime() + timer end
end

function GM:PlayerSpawnedNPC(ply, ent)
    if lia.config.NPCsDropWeapons then return end
    ent:SetKeyValue("spawnflags", "8192")
end

function GM:PlayerDisconnected(client)
    for _, entity in pairs(ents.GetAll()) do
        if entity:GetCreator() == client then entity:Remove() end
    end
end

function GM:OnPhysgunPickup(ply, ent)
    if ent:GetClass() == "prop_physics" and ent:GetCollisionGroup() == COLLISION_GROUP_NONE then ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) end
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
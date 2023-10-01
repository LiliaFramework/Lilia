--------------------------------------------------------------------------------------------------------
function GM:ModuleShouldLoad(module)
    return not lia.module.isDisabled(module)
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerDeathSound()
    return true
end

--------------------------------------------------------------------------------------------------------
function GM:CanPlayerSuicide(client)
    return false
end

--------------------------------------------------------------------------------------------------------
function GM:AllowPlayerPickup(client, entity)
    return false
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerShouldTakeDamage(client, attacker)
    return client:getChar() ~= nil
end

--------------------------------------------------------------------------------------------------------
function GM:EntityTakeDamage(entity, dmgInfo)
    local inflictor = dmgInfo:GetInflictor()
    local attacker = dmgInfo:GetAttacker()
    if attacker:GetClass() == "prop_physics" then return true end
    if inflictor:GetClass() == "prop_physics" then return true end
    if not IsValid(entity) or not entity:IsPlayer() then return end
    if IsValid(entity) and entity:IsPlayer() and dmgInfo:IsDamageType(DMG_CRUSH) and not IsValid(entity.liaRagdoll) then return true end
    if IsValid(entity.liaPlayer) then
        if dmgInfo:IsDamageType(DMG_CRUSH) then
            if (entity.liaFallGrace or 0) < CurTime() then
                if dmgInfo:GetDamage() <= 10 then
                    dmgInfo:SetDamage(0)
                end

                entity.liaFallGrace = CurTime() + 0.5
            else
                return
            end
        end

        entity.liaPlayer:TakeDamageInfo(dmgInfo)
    end

    if not dmgInfo:IsFallDamage() and IsValid(attacker) and attacker:IsPlayer() and attacker ~= entity and entity:Team() ~= FACTION_STAFF then
        entity.LastDamaged = CurTime()
    end

    if lia.config.CarRagdoll and IsValid(inflictor) and (inflictor:GetClass() == "gmod_sent_vehicle_fphysics_base" or inflictor:GetClass() == "gmod_sent_vehicle_fphysics_wheel") and not IsValid(entity:GetVehicle()) then
        dmgInfo:ScaleDamage(0)
        if not IsValid(entity.liaRagdoll) then
            entity:setRagdolled(true, 5)
        end
    end
end

--------------------------------------------------------------------------------------------------------
function GM:ScalePlayerDamage(ply, hitgroup, dmgInfo)
    if hitgroup == HITGROUP_HEAD then
        dmgInfo:ScaleDamage(lia.config.HeadShotDamage)
    end
end

--------------------------------------------------------------------------------------------------------
function GM:PreCleanupMap()
    lia.shuttingDown = true
    hook.Run("SaveData")
    hook.Run("PersistenceSave")
end

--------------------------------------------------------------------------------------------------------
function GM:PostCleanupMap()
    lia.shuttingDown = false
    hook.Run("LoadData")
    hook.Run("PostLoadData")
end

--------------------------------------------------------------------------------------------------------
function GM:OnItemSpawned(ent)
    ent.health = 250
end

--------------------------------------------------------------------------------------------------------
hook.Remove("PlayerInitialSpawn", "VJBaseSpawn")
--------------------------------------------------------------------------------------------------------
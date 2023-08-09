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
hook.Add("InitializedModules", "PerfomanceInitializedModules", function()
    timer.Simple(3, function()
        RunConsoleCommand("ai_serverragdolls", "1")
    end)
end)
--------------------------------------------------------------------------------------------------------
hook.Remove("PlayerInitialSpawn", "VJBaseSpawn")
--------------------------------------------------------------------------------------------------------
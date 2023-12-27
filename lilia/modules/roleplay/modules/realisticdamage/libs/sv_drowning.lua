--------------------------------------------------------------------------------------------------------------------------
local function HandleDrowning(client)
    if not client:getChar() or not client:Alive() or hook.Run("ShouldclientDrown", client) == false then return end
    if client:WaterLevel() >= 3 then
        client.drowningTime = client.drowningTime or (CurTime() + lia.config.DrownTime)
        client.nextDrowning = client.nextDrowning or CurTime()
        client.drownDamage = client.drownDamage or 0
        if client.drowningTime < CurTime() and client.nextDrowning < CurTime() then
            client:ScreenFade(1, Color(0, 0, 255, 100), 1, 0)
            client:TakeDamage(lia.config.DrownDamage)
            client.drownDamage = client.drownDamage + lia.config.DrownDamage
            client.nextDrowning = CurTime() + 1
        end
    else
        client.drowningTime = nil
        client.nextDrowning = nil
        if client.nextRecover and client.nextRecover < CurTime() and client.drownDamage > 0 then
            client.drownDamage = client.drownDamage - lia.config.DrownDamage
            client:SetHealth(math.Clamp(client:Health() + lia.config.DrownDamage, 0, client:GetMaxHealth()))
            client.nextRecover = CurTime() + 1
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------
timer.Create(
    "LifeGuard",
    1,
    0,
    function()
        if not lia.config.DrowningEnabled then return end
        for _, client in ipairs(player.GetAll()) do
            HandleDrowning(client)
        end
    end
)
--------------------------------------------------------------------------------------------------------------------------

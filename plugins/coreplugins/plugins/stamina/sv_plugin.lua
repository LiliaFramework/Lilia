function PLUGIN:PostPlayerLoadout(client)
    client:setLocalVar("stm", lia.config.get("defaultStamina", 100))
    local uniqueID = "liaStam" .. client:SteamID()
    local offset = 0
    local runSpeed = client:GetRunSpeed() - 5

    timer.Create(uniqueID, 0.25, 0, function()
        if not IsValid(client) then
            timer.Remove(uniqueID)

            return
        end

        local character = client:getChar()
        if client:GetMoveType() == MOVETYPE_NOCLIP or not character then return end
        local bonus = character.getAttrib and character:getAttrib("stm", 0) or 0
        runSpeed = lia.config.get("runSpeed") + bonus

        if client:WaterLevel() > 1 then
            runSpeed = runSpeed * 0.775
        end

        if client:isRunning() then
            bonus = character.getAttrib and character:getAttrib("end", 0) or 0
            offset = -2 + (bonus / 60)
        elseif offset > 0.5 then
            offset = 1 * lia.config.get("staminaRegenMultiplier", 1)
        else
            offset = 1.75 * lia.config.get("staminaRegenMultiplier", 1)
        end

        if client:Crouching() then
            offset = offset + 1
        end

        local current = client:getLocalVar("stm", 0)
        local value = math.Clamp(current + offset, 0, lia.config.get("defaultStamina", 100))

        if current ~= value then
            client:setLocalVar("stm", value)

            if value == 0 and not client:getNetVar("brth", false) then
                client:SetRunSpeed(lia.config.get("walkSpeed"))
                client:setNetVar("brth", true)
                hook.Run("PlayerStaminaLost", client)
            elseif value >= 50 and client:getNetVar("brth", false) then
                client:SetRunSpeed(runSpeed)
                client:setNetVar("brth", nil)
            end
        end
    end)
end

local playerMeta = FindMetaTable("Player")

function playerMeta:restoreStamina(amount)
    local current = self:getLocalVar("stm", 0)
    local value = math.Clamp(current + amount, 0, lia.config.get("defaultStamina", 100))
    self:setLocalVar("stm", value)
end

-------------------------------------------------------------------------------------------------------------------------~
function PLUGIN:PlayerStaminaLost(client)
    if client.isBreathing then return end -- Bail out if the player is already breathing
    client:EmitSound("player/breathe1.wav", 35, 100)
    client.isBreathing = true

    -- Stop breathing heavily when the player has recharged his stamina
    timer.Create("liaStamBreathCheck" .. client:SteamID(), 1, 0, function()
        if client:getLocalVar("stm", 0) < 50 then return end
        client:StopSound("player/breathe1.wav")
        client.isBreathing = nil
        timer.Remove("liaStamBreathCheck" .. client:SteamID())
    end)
end
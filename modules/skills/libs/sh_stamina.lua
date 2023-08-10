-------------------------------------------------------------------------------------------------------------------------~
function MODULE:CalcStaminaChange(client)
    local character = client:GetCharacter()
    if not character or client:GetMoveType() == MOVETYPE_NOCLIP then return 0 end
    local walkSpeed = client:GetWalkSpeed()
    local offset = 0
    if not client:GetNetVar("brth", false) and client:KeyDown(IN_SPEED) and client:GetVelocity():LengthSqr() >= walkSpeed * walkSpeed then
        offset = -1
        offset = hook.Run("AdjustStaminaOffsetRunning", client, offset) or -1
    else
        offset = hook.Run("AdjustStaminaRegeneration", client, offset) or 2
    end

    offset = hook.Run("AdjustStaminaOffset", client, offset) or offset
    if CLIENT then
        return offset
    else
        local maxStamina = character:getMaxStamina()
        local current = client:GetLocalVar("stamina", 0)
        local value = math.Clamp(current + offset, 0, maxStamina)
        if current ~= value then
            client:SetLocalVar("stamina", value)
            if value == 0 and not client:GetNetVar("brth", false) then
                client:SetNetVar("brth", true)
                hook.Run("PlayerStaminaLost", client)
            elseif value >= (maxStamina * 0.5) and client:GetNetVar("brth", false) then
                client:SetNetVar("brth", nil)
                hook.Run("PlayerStaminaGained", client)
            end
        end
    end
end
-------------------------------------------------------------------------------------------------------------------------~
function MODULE:SetupMove(client, cMoveData)
    if not lia.config.StaminaSlowdown then return end
    if client:GetNetVar("brth", false) then
        cMoveData:SetMaxClientSpeed(client:GetWalkSpeed())
    elseif client:WaterLevel() > 1 then
        cMoveData:SetMaxClientSpeed(client:GetRunSpeed() * 0.775)
    end
end
-------------------------------------------------------------------------------------------------------------------------~
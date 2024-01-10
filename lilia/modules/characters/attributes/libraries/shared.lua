function AttributesCore:CalcStaminaChange(client)
    local character = client:getChar()
    if not character or client:IsNoClipping() then return 0 end
    local walkSpeed = client:GetWalkSpeed()
    local offset = 0
    if not client:getNetVar("brth", false) and client:KeyDown(IN_SPEED) and client:GetVelocity():LengthSqr() >= walkSpeed * walkSpeed then
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
        local current = client:getLocalVar("stamina", 0)
        local value = math.Clamp(current + offset, 0, maxStamina)
        if current ~= value then
            client:setLocalVar("stamina", value)
            if value == 0 and not client:getNetVar("brth", false) then
                client:setNetVar("brth", true)
                hook.Run("PlayerStaminaLost", client)
            elseif value >= (maxStamina * 0.5) and client:getNetVar("brth", false) then
                client:setNetVar("brth", nil)
                hook.Run("PlayerStaminaGained", client)
            end
        end
    end
end

function AttributesCore:StartCommand(client, cmd)
    if self.StaminaSlowdown and (not client:IsNoClipping() and client:getNetVar("brth", false) and cmd:KeyDown(IN_JUMP)) then cmd:RemoveKey(IN_JUMP) end
end

function AttributesCore:SetupMove(client, cMoveData)
    if not self.StaminaSlowdown then return end
    if client:getNetVar("brth", false) then
        cMoveData:SetMaxClientSpeed(client:GetWalkSpeed())
    elseif client:WaterLevel() > 1 then
        cMoveData:SetMaxClientSpeed(client:GetRunSpeed() * 0.775)
    end
end

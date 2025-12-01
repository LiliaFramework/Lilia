function MODULE:CalcStaminaChange(client)
    local char = client:getChar()
    if not char then return 1 end
    local draining = client:GetMoveType() ~= MOVETYPE_NOCLIP and not client:InVehicle() and client:KeyDown(IN_SPEED) and client:OnGround() and (client:GetVelocity():Length2D() > client:GetWalkSpeed())
    local offset = draining and -lia.config.get("StaminaDrain") or lia.config.get("StaminaRegeneration")
    offset = hook.Run("AdjustStaminaOffset", client, offset) or offset
    if CLIENT then return offset end
    local max = hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)
    local current = client:getNetVar("stamina", max)
    local value = math.Clamp(current + offset, 0, max)
    if current ~= value then
        client:setNetVar("stamina", value)
        if value == 0 and not client:getNetVar("brth", false) then
            hook.Run("PlayerStaminaLost", client)
        elseif value >= max * 0.25 and client:getNetVar("brth", false) then
            client:setNetVar("brth", nil)
            hook.Run("PlayerStaminaGained", client)
        end
    end
end

function MODULE:PlayerBindPress(client, bind, pressed)
    if not pressed then return end
    local char = client:getChar()
    if not char then return end
    local stamina = client:getNetVar("stamina", hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100))
    local maxStamina = hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)
    local runThreshold = maxStamina * 0.25
    if bind == "+speed" and stamina <= runThreshold then
        client:ConCommand("-speed")
        return true
    end
end

function MODULE:CanPlayerThrowPunch(client)
    local required = lia.config.get("PunchPlaytime", 7200)
    if required > 0 then
        if not IsValid(client) or client:GetUserGroup() ~= "user" then return end
        if not client:playTimeGreaterThan(required) then return false, L("needMorePlaytimeBeforePunch") end
    end

    local staminaUse = lia.config.get("PunchStamina", 0)
    if staminaUse > 0 then
        local char = client:getChar()
        if not char then return false, L("invalidCharacter") end
        local currentStamina = client:getNetVar("stamina", hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100))
        if currentStamina < staminaUse then return false, L("notEnoughStaminaToPunch") end
    end
end

function MODULE:SetupMove(client, cMoveData)
    if not lia.config.get("StaminaSlowdown", true) then return end
    if client:getNetVar("brth", false) then cMoveData:SetMaxClientSpeed(client:GetWalkSpeed()) end
end

function MODULE:CalcStaminaChange(client)
    local char = client:getChar()
    if not char then return 0 end
    local walkSpeed = lia.config.get("WalkSpeed", 100)
    local maxAttributes = lia.config.get("maxAttributes", 100)
    local inNoClip = client:GetMoveType() == MOVETYPE_NOCLIP
    local inVehicle = client:InVehicle()
    local offset
    local isRunning = client:KeyDown(IN_SPEED) and client:GetVelocity():LengthSqr() >= (walkSpeed * walkSpeed) and client:OnGround() and not inNoClip and not inVehicle
    if isRunning then
        offset = -lia.config.get("StaminaDrain", 1) + math.min(char:getAttrib("end", 0), maxAttributes) / 100
    else
        offset = client:Crouching() and lia.config.get("StaminaCrouchRegeneration", 2) or lia.config.get("StaminaRegeneration", 1.75)
    end

    offset = hook.Run("AdjustStaminaOffset", client, offset) or offset
    if CLIENT then
        return offset
    else
        local max = hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)
        local current = client:getLocalVar("stamina", max)
        local value = math.Clamp(current + offset, 0, max)
        if current ~= value then
            client:setLocalVar("stamina", value)
            if value == 0 and not client:getLocalVar("brth", false) then
                client:setLocalVar("brth", true)
                client.liaBrthCache = true
                char:updateAttrib("end", 0.1)
                char:updateAttrib("stm", 0.01)
                hook.Run("PlayerStaminaLost", client)
            elseif value >= 50 and client:getLocalVar("brth", false) then
                client:setLocalVar("brth", nil)
                client.liaBrthCache = false
                hook.Run("PlayerStaminaGained", client)
            end
        end
    end
end

function MODULE:PlayerBindPress(client, bind, pressed)
    if not pressed then return end
    local char = client:getChar()
    if not char then return end
    local maxStamina = hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)
    local stamina = client:getLocalVar("stamina", maxStamina)
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

    local staminaUse = lia.config.get("PunchStamina", 10)
    if staminaUse > 0 then
        local char = client:getChar()
        if not char then return false, L("invalidCharacter") end
        local currentStamina = CLIENT and predictedStamina or client:getLocalVar("stamina", hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100))
        if currentStamina < staminaUse then return false, L("notEnoughStaminaToPunch") end
    end
end

function MODULE:SetupMove(client, cMoveData)
    if not lia.config.get("StaminaSlowdown", true) then return end
    if not client.liaBrthCache then client.liaBrthCache = client:getLocalVar("brth", false) end
    if client.liaBrthCache then cMoveData:SetMaxClientSpeed(client:GetWalkSpeed()) end
end

function MODULE:NetVarChanged(client, key, _, value)
    if key == "brth" then client.liaBrthCache = value or false end
end

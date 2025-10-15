function MODULE:calcStaminaChange(client)
    local char = client:getChar()
    if not char then return 1 end
    local walkSpeed = lia.config.get("WalkSpeed", client:GetWalkSpeed())
    local offset
    local draining = not (client:GetMoveType() == MOVETYPE_NOCLIP) and client:KeyDown(IN_SPEED) and (client:GetVelocity():LengthSqr() >= walkSpeed * walkSpeed or client:InVehicle() and not client:OnGround())
    if draining then
        offset = -lia.config.get("StaminaDrain")
    else
        offset = client:Crouching() and lia.config.get("StaminaCrouchRegeneration") or lia.config.get("StaminaRegeneration")
    end

    offset = hook.Run("AdjustStaminaOffset", client, offset) or offset
    if CLIENT then return offset end
    local max = hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)
    local current = client:getNetVar("stamina", hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100))
    local value = math.Clamp(current + offset, 0, max)
    if current ~= value then
        client:setNetVar("stamina", value)
        if value == 0 and not client:getNetVar("brth", false) then
            client:setNetVar("brth", true)
            hook.Run("PlayerStaminaLost", client)
        elseif value >= max * 0.25 and client:getNetVar("brth", false) then
            client:setNetVar("brth", nil)
            hook.Run("PlayerStaminaGained", client)
        end
    end
end

function MODULE:SetupMove(client, cMoveData)
    if not lia.config.get("StaminaSlowdown", true) then return end
    if client:getNetVar("brth", false) then cMoveData:SetMaxClientSpeed(client:GetWalkSpeed()) end
end

function MODULE:GetAttributeMax(_, attribute)
    local attribTable = lia.attribs.list[attribute]
    if not attribTable then return lia.config.get("MaxAttributePoints") end
    if istable(attribTable) and isnumber(attribTable.maxValue) then return attribTable.maxValue end
    return lia.config.get("MaxAttributePoints")
end

function MODULE:GetAttributeStartingMax(_, attribute)
    local attribTable = lia.attribs.list[attribute]
    if not attribTable then return lia.config.get("MaxStartingAttributes") end
    if istable(attribTable) and isnumber(attribTable.startingMax) then return attribTable.startingMax end
    return lia.config.get("MaxStartingAttributes")
end

function MODULE:GetMaxStartingAttributePoints()
    return lia.config.get("StartingAttributePoints")
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

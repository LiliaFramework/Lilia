function MODULE:CalcStaminaChange(client)
    local character = client:getChar()
    if not character or client:isNoClipping() then return 0 end

    local walkSpeed = lia.config.get("WalkSpeed", client:GetWalkSpeed())
    local maxAttributes = lia.config.get("MaxAttributePoints", 100)
    local offset

    if client:KeyDown(IN_SPEED) and client:GetVelocity():LengthSqr() >= walkSpeed * walkSpeed then
        offset = -lia.config.get("StaminaDrain", 1) + math.min(character:getAttrib("endurance", 0), maxAttributes) / 100
    else
        offset = client:Crouching() and lia.config.get("StaminaCrouchRegeneration", 2) or lia.config.get("StaminaRegeneration", 1.75)
    end

    offset = hook.Run("AdjustStaminaOffset", client, offset) or offset

    if CLIENT then
        return offset
    end

    local max = character:getMaxStamina()
    local current = client:getLocalVar("stamina", 0)
    local value = math.Clamp(current + offset, 0, max)

    if current ~= value then
        client:setLocalVar("stamina", value)

        if value == 0 and not client:getNetVar("brth", false) then
            client:setNetVar("brth", true)
            character:updateAttrib("endurance", 0.1)
            character:updateAttrib("stamina", 0.01)
            hook.Run("PlayerStaminaLost", client)
        elseif value >= max * 0.5 and client:getNetVar("brth", false) then
            client:setNetVar("brth", nil)
            hook.Run("PlayerStaminaGained", client)
        end
    end
end

function MODULE:SetupMove(client, cMoveData)
    if not lia.config.get("StaminaSlowdown", true) then return end
    if client:getNetVar("brth", false) then
        cMoveData:SetMaxClientSpeed(client:GetWalkSpeed())
    end
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

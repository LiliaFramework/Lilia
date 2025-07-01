function MODULE:CalcStaminaChange(client)
    local char = client:getChar()
    if not char or client:isNoClipping() then return 0 end
    local walk = client:GetWalkSpeed()
    local offset
    if not client:getNetVar("brth", false) and client:KeyDown(IN_SPEED) and client:GetVelocity():LengthSqr() >= walk * walk and client:OnGround() then
        local runCost = -4
        offset = hook.Run("AdjustStaminaOffsetRunning", client, runCost) or runCost
    else
        local regen = 2
        offset = hook.Run("AdjustStaminaRegeneration", client, regen) or regen
    end

    offset = hook.Run("AdjustStaminaOffset", client, offset) or offset
    if CLIENT then return offset end
    local max = char:getMaxStamina()
    local cur = client:getLocalVar("stamina", 0)
    local new = math.Clamp(cur + offset, 0, max)
    if cur ~= new then
        client:setLocalVar("stamina", new)
        if new == 0 and not client:getNetVar("brth", false) then
            client:setNetVar("brth", true)
            hook.Run("PlayerStaminaLost", client)
        elseif new >= max * 0.5 and client:getNetVar("brth", false) then
            client:setNetVar("brth", nil)
            hook.Run("PlayerStaminaGained", client)
        end
    end
end

function MODULE:SetupMove(client, cMoveData)
    if not lia.config.get("StaminaSlowdown", true) then return end
    if client:getNetVar("brth", false) then
        cMoveData:SetMaxClientSpeed(client:GetWalkSpeed())
    elseif client:WaterLevel() > 1 then
        cMoveData:SetMaxClientSpeed(client:GetRunSpeed() * 0.775)
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

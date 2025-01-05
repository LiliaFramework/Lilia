function MODULE:CalcStaminaChange(client)
    local character = client:getChar()
    if not character or client:isNoClipping() then return 0 end
    local walkSpeed = client:GetWalkSpeed()
    local offset = 0
    if not client:getNetVar("brth", false) and (client:KeyDown(IN_SPEED) and client:GetVelocity():LengthSqr() >= (walkSpeed * walkSpeed) and client:OnGround()) then
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

function MODULE:StartCommand(client, cmd)
    if self.StaminaSlowdown and (not client:isNoClipping() and client:getNetVar("brth", false) and cmd:KeyDown(IN_JUMP)) then cmd:RemoveKey(IN_JUMP) end
end

function MODULE:SetupMove(client, cMoveData)
    if not self.StaminaSlowdown then return end
    if client:getNetVar("brth", false) then
        cMoveData:SetMaxClientSpeed(client:GetWalkSpeed())
    elseif client:WaterLevel() > 1 then
        cMoveData:SetMaxClientSpeed(client:GetRunSpeed() * 0.775)
    end
end

function MODULE:GetAttributeMax(_, attribute)
    local attribTable = lia.attribs.list[attribute]
    if not attribTable then return lia.config.MaxAttributePoints end
    if istable(attribTable) and isnumber(attribTable.maxValue) then return attribTable.maxValue end
    return lia.config.MaxAttributePoints
end

function MODULE:GetAttributeStartingMax(_, attribute)
    local attribTable = lia.attribs.list[attribute]
    if not attribTable then return lia.config.MaxStartingAttributes end
    if istable(attribTable) and isnumber(attribTable.startingMax) then return attribTable.startingMax end
    return lia.config.MaxStartingAttributes
end

function MODULE:GetMaxStartingAttributePoints()
    return lia.config.StartingAttributePoints
end

lia.char.registerVar("attribs", {
    field = "_attribs",
    default = {},
    isLocal = true,
    index = 4,
    onValidate = function(value, _, client)
        if value ~= nil then
            if istable(value) then
                local count = 0
                for k, v in pairs(value) do
                    local max = hook.Run("GetAttributeStartingMax", client, k)
                    if max and v > max then return false, lia.attribs.list[k].name .. " too high" end
                    count = count + v
                end

                local points = hook.Run("GetMaxStartingAttributePoints", client, count)
                if count > points then return false, "unknownError" end
            else
                return false, "unknownError"
            end
        end
    end,
    shouldDisplay = function() return table.Count(lia.attribs.list) > 0 end
})

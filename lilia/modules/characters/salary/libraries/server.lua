function MODULE:CreateSalaryTimer(client)
    if not (IsValid(client) and client:getChar()) then return end
    local character = client:getChar()
    local timerID = "liaSalary" .. client:SteamID64()
    local faction = lia.faction.indices[character:getFaction()]
    local class = lia.class.list[character:getClass()]
    local delay = (class and class.payTimer) or (faction and faction.payTimer) or lia.config.get("SalaryInterval", 3600)
    timer.Remove(timerID)
    timer.Create(timerID, delay, 0, function()
        if not (IsValid(client) and client:getChar() == character) then
            timer.Remove(timerID)
            return
        end

        local payAmount = hook.Run("GetSalaryAmount", client, faction, class)
        payAmount = (isnumber(payAmount) and payAmount) or (class and class.pay) or (faction and faction.pay) or 0
        local salaryLimit = hook.Run("GetSalaryLimit", client, faction, class)
        salaryLimit = (isnumber(salaryLimit) and salaryLimit) or (class and class.payLimit) or (faction and faction.payLimit) or lia.config.get("SalaryThreshold", 0)
        if hook.Run("CanPlayerEarnSalary", client, faction, class) and payAmount > 0 then
            local currentMoney = character:getMoney()
            if salaryLimit > 0 and (currentMoney + payAmount > salaryLimit) then
                client:notifyLocalized("SalaryLimitReached")
                character:setMoney(salaryLimit)
            else
                character:giveMoney(payAmount)
                client:notifyLocalized("salary", lia.currency.get(payAmount))
            end
        end
    end)
end

function MODULE:PlayerDisconnected(client)
    timer.Remove("liaSalary" .. client:SteamID64())
end

function MODULE:PlayerLoadedChar(client)
    self:CreateSalaryTimer(client)
end

function MODULE:OnTransferred(client)
    self:CreateSalaryTimer(client)
end

function MODULE:OnPlayerSwitchClass(client)
    self:CreateSalaryTimer(client)
end

function MODULE:OnPlayerJoinClass(client)
    self:CreateSalaryTimer(client)
end

function MODULE:OnReloaded()
    for _, client in player.Iterator() do
        self:CreateSalaryTimer(client)
    end
end

function MODULE:CanPlayerEarnSalary(client)
    return not client:isStaffOnDuty()
end

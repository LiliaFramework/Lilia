function MODULE:CreateSalaryTimer(client)
    if not IsValid(client) or not client:getChar() then return end
    local character = client:getChar()
    local timerID = "liaSalary" .. client:SteamID64()
    local faction = lia.faction.indices[character:getFaction()]
    local class = lia.class.list[character:getClass()]
    local delay = (class and class.payTimer) or (faction and faction.payTimer) or lia.config.get("SalaryInterval", 3600)
    if timer.Exists(timerID) then timer.Remove(timerID) end
    timer.Create(timerID, delay, 0, function()
        if not IsValid(client) or client:getChar() ~= character then
            timer.Remove(timerID)
            return
        end

        local salaryHook = hook.Run("GetSalaryAmount", client, faction, class)
        local PayAmount = (isnumber(salaryHook) and salaryHook) or (class and class.pay) or (faction and faction.pay) or 0
        local limitHook = hook.Run("GetSalaryLimit", client, faction, class)
        local SalaryLimit = (isnumber(limitHook) and limitHook) or (class and class.payLimit) or (faction and faction.payLimit) or lia.config.get("SalaryThreshold", 0)
        local SalaryAllowed = hook.Run("CanPlayerEarnSalary", client, faction, class)
        if SalaryAllowed and PayAmount > 0 then
            if SalaryLimit > 0 and (character:getMoney() + PayAmount > SalaryLimit) then
                client:notifyLocalized("SalaryLimitReached")
                character:setMoney(SalaryLimit)
                return
            end

            character:giveMoney(PayAmount)
            client:notifyLocalized("salary", lia.currency.get(PayAmount))
        end
    end)
end

function PlayerDisconnected(client)
    timer.Remove("liaSalary" .. client:SteamID64())
end

function MODULE:PlayerLoadedChar(client)
    hook.Run("CreateSalaryTimer", client)
end

function MODULE:OnReloaded()
    for _, client in player.Iterator() do
        hook.Run("CreateSalaryTimer", client)
    end
end

function MODULE:CanPlayerEarnSalary(client)
    if client:isStaffOnDuty() then return false end
    return true
end

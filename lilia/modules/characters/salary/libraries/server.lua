function MODULE:CreateSalaryTimer(client)
    if not client:getChar() then return end
    local character = client:getChar()
    local timerID = "liaSalary" .. client:SteamID()
    local faction = lia.faction.indices[character:getFaction()]
    local class = lia.class.list[character:getClass()]
    local PayAmount = hook.Run("GetSalaryAmount", client, faction, class) or (class and class.pay) or (faction and faction.pay) or 0
    local SalaryLimit = hook.Run("GetSalaryLimit", client, faction, class) or (class and class.payLimit) or (faction and faction.payLimit) or self.SalaryThreshold
    local SalaryAllowed = hook.Run("CanPlayerEarnSalary", client, faction, class)
    local timerFunc = timer.Exists(timerID) and timer.Adjust or timer.Create
    local delay = (class and class.payTimer) or (faction and faction.payTimer) or self.SalaryInterval
    if SalaryAllowed and PayAmount > 0 then
        timerFunc(timerID, delay, 0, function()
            if not IsValid(client) or client:getChar() ~= character then
                timer.Remove(timerID)
                return
            end

            if SalaryLimit > 0 and SalaryLimit > (character:getMoney() + PayAmount) then
                client:notify("You reached the limit of your salary! You can't get more money!")
                character:setMoney(SalaryLimit)
                return
            end

            character:giveMoney(PayAmount)
            client:notifyLocalized("salary", lia.currency.get(PayAmount))
        end)
    end
end

function MODULE:PlayerLoadedChar(client, _, _)
    hook.Run("CreateSalaryTimer", client)
end

function MODULE:OnReloaded()
    for _, client in ipairs(player.GetAll()) do
        hook.Run("CreateSalaryTimer", client)
    end
end

function MODULE:CanPlayerEarnSalary(client)
    if client:Team() == FACTION_STAFF or client.HasWarning then return false end
    return true
end

function MODULE:GetSalaryAmount(client, faction, class)
    return IsValid(client) and (faction and faction.pay ~= nil and faction.pay) or (class and class.pay ~= nil and class.pay)
end
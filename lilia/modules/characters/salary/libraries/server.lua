function SalaryCore:CreateSalaryTimer(client)
    if not client:getChar() then return end
    local character = client:getChar()
    local timerID = "liaSalary" .. client:SteamID()
    local faction = lia.faction.indices[character:getFaction()]
    local class = lia.class.list[character:getClass()]
    local PayAmount = hook.Run("GetSalaryAmount", client, faction, class) or (class and class.pay) or (faction and faction.pay) or 0
    local SalaryLimit = hook.Run("GetSalaryLimit", client, faction, class) or (class and class.payLimit) or (faction and faction.payLimit) or SalaryCore.SalaryThreshold
    local timerFunc = timer.Exists(timerID) and timer.Adjust or timer.Create
    local delay = (class and class.payTimer) or (faction and faction.payTimer) or self.SalaryInterval
    if PayAmount > 0 then
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

function SalaryCore:PlayerLoadedChar(client, _, _)
    hook.Run("CreateSalaryTimer", client)
end

function SalaryCore:OnReloaded()
    for _, client in ipairs(player.GetAll()) do
        hook.Run("CreateSalaryTimer", client)
    end
end

function SalaryCore:GetSalaryAmount(client, faction, _)
    if faction.index == FACTION_STAFF or client.HasWarning then return 0 end
end

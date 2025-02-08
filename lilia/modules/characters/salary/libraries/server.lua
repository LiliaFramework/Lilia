function MODULE:CreateSalaryTimer(client)
    if not client:getChar() then return end
    local character = client:getChar()
    local timerID = "liaSalary" .. client:SteamID()
    local faction = lia.faction.indices[character:getFaction()]
    local class = lia.class.list[character:getClass()]
    local PayAmount = hook.Run("GetSalaryAmount", client, faction, class) or class and class.pay or faction and faction.pay or 0
    local SalaryLimit = hook.Run("GetSalaryLimit", client, faction, class) or class and class.payLimit or faction and faction.payLimit or lia.config.get("SalaryThreshold", 0)
    local SalaryAllowed = hook.Run("CanPlayerEarnSalary", client, faction, class)
    local timerFunc = timer.Exists(timerID) and timer.Adjust or timer.Create
    local delay = class and class.payTimer or faction and faction.payTimer or lia.config.get("SalaryInterval", 3600)
    if SalaryAllowed and PayAmount > 0 then
        timerFunc(timerID, delay, 0, function()
            if not IsValid(client) or client:getChar() ~= character then
                timer.Remove(timerID)
                return
            end

            if SalaryLimit > 0 and SalaryLimit > character:getMoney() + PayAmount then
                client:notifyLocalized("SalaryLimitReached")
                character:setMoney(SalaryLimit)
                return
            end

            character:giveMoney(PayAmount)
            client:notifyLocalized("salary", lia.currency.get(PayAmount))
        end)
    end
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
    if client:isStaffOnDuty() or client.HasWarning then return false end
    return true
end

function MODULE:GetSalaryAmount(client, faction, class)
    return IsValid(client) and faction and faction.pay ~= nil and faction.pay or class and class.pay ~= nil and class.pay
end
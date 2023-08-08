function GM:CreateSalaryTimer(client)
    local character = client:getChar()
    if not character then return end
    local faction = lia.faction.indices[character:getFaction()]
    local class = lia.class.list[character:getClass()]
    local pay = hook.Run("GetSalaryAmount", client, faction, class) or (class and class.pay) or (faction and faction.pay) or nil
    local limit = hook.Run("GetSalaryLimit", client, faction, class) or (class and class.payLimit) or (faction and faction.playLimit) or nil
    if not pay then return end
    local timerID = "liaSalary" .. client:SteamID()
    local timerFunc = timer.Exists(timerID) and timer.Adjust or timer.Create
    local delay = lia.config.SalaryInterval

    timerFunc(timerID, delay, 0, function()
        if not IsValid(client) or client:getChar() ~= character then
            timer.Remove(timerID)

            return
        end

        if limit and character:getMoney() >= limit then return end
        character:giveMoney(pay)
        client:notifyLocalized("salary", lia.currency.get(pay))
    end)
end

function GM:PlayerLoadedChar(client, character, lastChar)
    if not lia.config.SalaryOverride then
        hook.Run("CreateSalaryTimer", client)
    end
end
local function CreateSalaryTimer(client)
    if not (IsValid(client) and client:getChar()) then return end
    local char = client:getChar()
    local timerID = "liaSalary" .. client:SteamID64()
    local faction = lia.faction.indices[char:getFaction()]
    local class = lia.class.list[char:getClass()]
    local delay = class and class.payTimer or faction and faction.payTimer or lia.config.get("SalaryInterval", 3600)
    timer.Remove(timerID)
    timer.Create(timerID, delay, 0, function()
        if not (IsValid(client) and client:getChar() == char) then
            timer.Remove(timerID)
            return
        end

        local pay = hook.Run("GetSalaryAmount", client, faction, class)
        pay = isnumber(pay) and pay or class and class.pay or faction and faction.pay or 0
        local limit = hook.Run("GetSalaryLimit", client, faction, class)
        limit = isnumber(limit) and limit or class and class.payLimit or faction and faction.payLimit or lia.config.get("SalaryThreshold", 0)
        if hook.Run("CanPlayerEarnSalary", client, faction, class) and pay > 0 then
            local money = char:getMoney()
            if limit > 0 and money + pay > limit then
                client:notifyLocalized("salaryLimitReached")
                char:setMoney(limit)
            else
                char:giveMoney(pay)
                client:notifyLocalized("salary", lia.currency.get(pay))
            end
        end
    end)
end

hook.Add("OnReloaded", "liaSalaryOnReloaded", function()
    for _, client in player.Iterator() do
        CreateSalaryTimer(client)
    end
end)

hook.Add("PlayerLoadedChar", "liaSalaryPlayerLoadedChar", CreateSalaryTimer)
hook.Add("OnTransferred", "liaSalaryOnTransferred", CreateSalaryTimer)
hook.Add("OnPlayerSwitchClass", "liaSalaryOnPlayerSwitchClass", CreateSalaryTimer)
hook.Add("OnPlayerJoinClass", "liaSalaryOnPlayerJoinClass", CreateSalaryTimer)
hook.Add("PlayerDisconnected", "liaSalaryPlayerDisconnected", function(client) timer.Remove("liaSalary" .. client:SteamID64()) end)
hook.Add("CreateSalaryTimer", "liaSalaryCreateSalaryTimer", CreateSalaryTimer)
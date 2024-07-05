netstream.Hook("transferMoneyFromP2P", function(client, value, target)
    local amount = tonumber(value)
    if not amount or amount <= 0 then
        client:notify("Invalid amount specified.", NOT_CORRECT)
        return
    end

    if not IsValid(client) or not IsValid(target) or not client:getChar() or not target:getChar() then
        client:notify("Invalid client or target specified.", NOT_CORRECT)
        return
    end

    if not client:getChar():hasMoney(amount) then
        client:notify("You don't have enough money to transfer.", NOT_CORRECT)
        return
    end

    target:getChar():giveMoney(amount)
    client:getChar():takeMoney(amount)
    local clientDisplayName = hook.Run("GetDisplayedName", client) or client:getChar():getName()
    local targetDisplayName = hook.Run("GetDisplayedName", target) or target:getChar():getName()
    client:notify("You transferred " .. lia.currency.symbol .. amount .. " to " .. targetDisplayName, NOT_CORRECT)
    target:notify("You received " .. lia.currency.symbol .. amount .. " from " .. clientDisplayName, NOT_CORRECT)
    lia.log.add(client, "moneyGiven", target:Name(), amount)
end)

netstream.Hook("PIMRunOption", function(client, name)
    local opt = PIM.options[name]
    if opt.runServer then opt.onRun(client, client:GetEyeTrace().Entity) end
end)
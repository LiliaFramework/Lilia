netstream.Hook("transferMoneyFromP2P", function(client, amount, target, targetName, clientName)
    if amount <= 0 or not client:getChar():hasMoney(amount) or not client or not target then return end
    target:getChar():giveMoney(amount)
    client:getChar():takeMoney(amount)
    client:notify("You transferred " .. lia.currency.symbol .. amount .. " to " .. targetName, NOT_CORRECT)
    target:notify("You received " .. lia.currency.symbol .. amount .. " from " .. clientName, NOT_CORRECT)
    lia.log.add(client, "moneyGiven", target:Name(), amount)
end)

netstream.Hook("PIMRunOption", function(client, name)
    local opt = PIM.options[name]
    if opt.runServer then opt.onRun(client, client:GetTracedEntity()) end
end)
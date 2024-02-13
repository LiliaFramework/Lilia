---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("transferMoneyFromP2P", function(client, amount, target)
    if amount <= 0 and not client:getChar():hasMoney(amount) and not client or not target then return end
    target:getChar():giveMoney(amount)
    client:getChar():takeMoney(amount)
    client:notify("You transfered " .. lia.currency.symbol .. amount .. " to " .. target:Nick(), NOT_CORRECT)
    target:notify("You received " .. lia.currency.symbol .. amount .. " from " .. client:Nick(), NOT_CORRECT)
    lia.log.add("moneyGivenTAB", client, target:Name(), amount)
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("PIMRunOption", function(client, name)
    local opt = PIM.options[name]
    if opt.runServer then opt.onRun(client, client:GetEyeTrace().Entity) end
end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------

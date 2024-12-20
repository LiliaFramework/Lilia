netstream.Hook("transferMoneyFromP2P", function(client, amount, target, targetName, clientName)
    if amount <= 0 or not client:getChar():hasMoney(amount) or not client or not target then return end
    target:getChar():giveMoney(amount)
    client:getChar():takeMoney(amount)
    client:notify("You transferred " .. lia.currency.symbol .. amount .. " to " .. targetName)
    target:notify("You received " .. lia.currency.symbol .. amount .. " from " .. clientName)
    lia.log.add(client, "moneyGiven", target:Name(), amount)
end)

netstream.Hook("PIMRunOption", function(client, name)
    local opt = PIM.Options[name]
    if opt then
        if opt.runServer then
            opt.onRun(client, client:GetTracedEntity())
            lia.log.add(client, "P2PAction", "Executed P2P Action '%s' on entity '%s'.", name, tostring(client:GetTracedEntity()))
        end
    else
        lia.log.add(client, "P2PAction", "Attempted to run non-existent P2P Action '%s'.", name)
    end
end)

netstream.Hook("PIMRunLocalOption", function(client, name)
    local opt = PIM.SelfOptions[name]
    if opt then
        if opt.runServer then
            opt.onRun(client)
            lia.log.add(client, "PersonalAction", "Executed Personal Action '%s'.", name)
        end
    else
        lia.log.add(client, "PersonalAction", "Attempted to run non-existent Personal Action '%s'.", name)
    end
end)

lia.log.addType("P2PAction", function(client, message, name, entity) return string.format("[%s] %s ran a P2P Action '%s' on entity '%s'.", client:SteamID(), client:Name(), name, entity) end, "P2P Actions", Color(255, 165, 0))
lia.log.addType("PersonalAction", function(client, message, name) return string.format("[%s] %s ran a Personal Action '%s'.", client:SteamID(), client:Name(), name) end, "Personal Actions", Color(255, 140, 0))
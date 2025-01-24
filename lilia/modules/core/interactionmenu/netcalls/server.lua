net.Receive("TransferMoneyFromP2P", function(_, sender)
    local amount = net.ReadUInt(32)
    local target = net.ReadEntity()
    if not IsValid(sender) or not sender:getChar() then return end
    if not IsValid(target) or not target:IsPlayer() or not target:getChar() then return end
    if amount <= 0 or not sender:getChar():hasMoney(amount) then return end
    target:getChar():giveMoney(amount)
    sender:getChar():takeMoney(amount)
    local senderName = hook.Run("GetDisplayedName", sender) or sender:getChar():getName()
    local targetName = hook.Run("GetDisplayedName", target) or target:getChar():getName()
    sender:notify("You transferred " .. lia.currency.symbol .. amount .. " to " .. targetName)
    target:notify("You received " .. lia.currency.symbol .. amount .. " from " .. senderName)
end)

netstream.Hook("PIMRunOption", function(client, name)
    local opt = PIM.Options[name]
    local tracedEntity = client:getTracedEntity()
    if opt and opt.runServer and IsValid(tracedEntity) then opt.onRun(client, tracedEntity) end
end)

netstream.Hook("PIMRunLocalOption", function(client, name)
    local opt = PIM.SelfOptions[name]
    if opt and opt.runServer then opt.onRun(client) end
end)
local MODULE = MODULE
net.Receive("TransferMoneyFromP2P", function(_, sender)
    local amount = net.ReadUInt(32)
    local target = net.ReadEntity()
    if lia.config.get("DisableCheaterActions", true) and sender:getNetVar("cheater", false) then
        lia.log.add(sender, "cheaterAction", L("cheaterActionTransferMoney"))
        sender:notify("Maybe you shouldn't have cheated")
        return
    end

    if not IsValid(sender) or not sender:getChar() then return end
    if sender:IsFamilySharedAccount() and not lia.config.get("AltsDisabled", false) then
        sender:notifyLocalized("familySharedMoneyTransferDisabled")
        return
    end

    if not IsValid(target) or not target:IsPlayer() or not target:getChar() then return end
    if amount <= 0 or not sender:getChar():hasMoney(amount) then return end
    target:getChar():giveMoney(amount)
    sender:getChar():takeMoney(amount)
    local senderName = sender:getChar():getDisplayedName(target)
    local targetName = sender:getChar():getDisplayedName(sender)
    sender:notifyLocalized("moneyTransferSent", lia.currency.get(amount), targetName)
    target:notifyLocalized("moneyTransferReceived", lia.currency.get(amount), senderName)
end)

local function isWithinRange(client, entity)
    if not IsValid(client) or not IsValid(entity) then return false end
    return entity:GetPos():DistToSqr(client:GetPos()) < 250 * 250
end

net.Receive("RunOption", function(_, ply)
    if lia.config.get("DisableCheaterActions", true) and ply:getNetVar("cheater", false) then
        lia.log.add(ply, "cheaterAction", L("cheaterActionUseInteractionMenu"))
        ply:notify("Maybe you shouldn't have cheated")
        return
    end

    local name = net.ReadString()
    local opt = MODULE.Interactions[name]
    local tracedEntity = net.ReadEntity()
    if opt and opt.runServer and IsValid(tracedEntity) and tracedEntity:IsPlayer() and isWithinRange(ply, tracedEntity) then opt.onRun(ply, tracedEntity) end
end)

net.Receive("RunLocalOption", function(_, ply)
    if lia.config.get("DisableCheaterActions", true) and ply:getNetVar("cheater", false) then
        lia.log.add(ply, "cheaterAction", L("cheaterActionUseInteractionMenu"))
        ply:notify("Maybe you shouldn't have cheated")
        return
    end

    local name = net.ReadString()
    local opt = MODULE.Actions[name]
    if opt and opt.runServer then opt.onRun(ply) end
end)
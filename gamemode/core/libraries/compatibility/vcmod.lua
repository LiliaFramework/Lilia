if SERVER then
    hook.Add("VC_canAddMoney", "liaVCMOD", function(client, amount)
        client:getChar():giveMoney(amount)
        return false
    end)

    hook.Add("VC_canRemoveMoney", "liaVCMOD", function(client, amount)
        client:getChar():takeMoney(amount)
        return false
    end)
end

hook.Add("VC_canAfford", "liaVCMOD", function(client, amount)
    if client:getChar():hasMoney(amount) then return true end
    return false
end)
--[[
    VCMod monetary compatibility.
    Redirects VCMod money hooks to a character's funds so vehicle
    transactions use Lilia's economy.
]]
if SERVER then
    hook.Add("VC_canAddMoney", "VCMOD_VC_canAfford", function(client, amount)
        client:getChar():giveMoney(amount)
        return false
    end)

    hook.Add("VC_canRemoveMoney", "VCMOD_VC_canAfford", function(client, amount)
        client:getChar():takeMoney(amount)
        return false
    end)
end

hook.Add("VC_canAfford", "VCMOD_VC_canAfford", function(client, amount)
    if client:getChar():hasMoney(amount) then return true end
    return false
end)

if SERVER then
    hook.Add("VC_canAddMoney", "VCMOD_VC_canAfford", function(client, amount)
        client:getChar():giveMoney(amount)
        return false
    end)

    hook.Add("VC_canRemoveMoney", "VCMOD_VC_canAfford", function(client, amount)
        client:getChar():takeMoney(amount)
        return false
    end)
end

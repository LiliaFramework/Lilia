
function VCModCompatibility:VC_canAfford(client, amount)
    if client:getChar():hasMoney(amount) then return true end
    return false
end


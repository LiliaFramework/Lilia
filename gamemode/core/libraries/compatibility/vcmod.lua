--[[
    Folder: Compatibility
    File:  vcmod.md
]]
--[[
    VCMOD Compatibility

    Provides compatibility with VCMOD (VCMod) addon for vehicle customization and money management within the Lilia framework.
]]
--[[
    Improvements Done:
        The VCMOD compatibility module enables seamless integration with the VCMOD vehicle customization system, handling money transactions between VCMOD and Lilia's currency system.
        The module operates on both server and client sides to manage money addition, removal, and affordability checks for vehicle-related purchases.
        It includes proper integration with Lilia's character money system to ensure consistent currency handling across vehicle customization features.
        The module prevents VCMOD from handling money directly, instead routing all transactions through Lilia's economy system.
]]
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

local MODULE = MODULE
local EDITOR = include(MODULE.path .. "/libs/sv_vendor.lua")
net.Receive("VendorExit", function(_, client)
    local vendor = client.liaVendor
    if IsValid(vendor) then vendor:removeReceiver(client, true) end
end)

net.Receive("VendorEdit", function(_, client)
    local key = net.ReadString()
    if not client:CanEditVendor() then return end
    local vendor = client.liaVendor
    if not IsValid(vendor) or not EDITOR[key] then return end
    lia.log.add(client, "vendorEdit", vendor, key)
    EDITOR[key](vendor, client, key)
    hook.Run("UpdateEntityPersistence", vendor)
end)

net.Receive("VendorTrade", function(_, client)
    local uniqueID = net.ReadString()
    local isSellingToVendor = net.ReadBool()
    if not client:getChar() or not client:getChar():getInv() then return end
    if (client.liaVendorTry or 0) < CurTime() then
        client.liaVendorTry = CurTime() + 0.1
    else
        return
    end

    local entity = client.liaVendor
    if not IsValid(entity) or client:GetPos():Distance(entity:GetPos()) > 192 then return end
    if not hook.Run("CanPlayerAccessVendor", client, entity) then return end
    hook.Run("VendorTradeEvent", client, entity, uniqueID, isSellingToVendor)
end)
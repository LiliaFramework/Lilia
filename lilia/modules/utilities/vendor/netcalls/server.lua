local MODULE = MODULE
local EDITOR = include(MODULE.path .. "/libs/sv_vendor.lua")
util.AddNetworkString("VendorAllowClass")
util.AddNetworkString("VendorAllowFaction")
util.AddNetworkString("VendorExit")
util.AddNetworkString("VendorEdit")
util.AddNetworkString("VendorMode")
util.AddNetworkString("VendorMoney")
util.AddNetworkString("VendorOpen")
util.AddNetworkString("VendorPrice")
util.AddNetworkString("VendorStock")
util.AddNetworkString("VendorMaxStock")
util.AddNetworkString("VendorSync")
util.AddNetworkString("VendorTrade")
net.Receive("VendorExit", function(_, client)
    local vendor = client.liaVendor
    if IsValid(vendor) then vendor:removeReceiver(client, true) end
end)

net.Receive("VendorEdit", function(_, client)
    local key = net.ReadString()
    if not client:CanEditVendor() then return end
    local vendor = client.liaVendor
    if not IsValid(vendor) or not EDITOR[key] then return end
    EDITOR[key](vendor, client, key)
    MODULE:SaveData()
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

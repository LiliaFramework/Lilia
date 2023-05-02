local PLUGIN = PLUGIN
local EDITOR = lia.util.include("sv_editor.lua")
util.AddNetworkString("liaVendorAllowClass")
util.AddNetworkString("liaVendorAllowFaction")
util.AddNetworkString("liaVendorExit")
util.AddNetworkString("liaVendorEdit")
util.AddNetworkString("liaVendorMode")
util.AddNetworkString("liaVendorMoney")
util.AddNetworkString("liaVendorOpen")
util.AddNetworkString("liaVendorPrice")
util.AddNetworkString("liaVendorStock")
util.AddNetworkString("liaVendorMaxStock")
util.AddNetworkString("liaVendorSync")
util.AddNetworkString("liaVendorTrade")

net.Receive("liaVendorExit", function(_, client)
    local vendor = client.liaVendor

    if IsValid(vendor) then
        vendor:removeReceiver(client, true)
    end
end)

local owner2 = {
    root = true,
    communitymanager = true,
    superadmin = true,
    headadmin = true,
}

net.Receive("liaVendorEdit", function(_, client)
    local key = net.ReadString()
    local uniqueID = client:GetUserGroup()
    if not client:IsSuperAdmin() then return end
    local vendor = client.liaVendor
    if not IsValid(vendor) or not EDITOR[key] then return end
    EDITOR[key](vendor, client, key)
    PLUGIN:saveVendors()
end)

net.Receive("liaVendorTrade", function(_, client)
    local uniqueID = net.ReadString()
    local isSellingToVendor = net.ReadBool()
    if not client:getChar() or not client:getChar():getInv() then return end

    if (client.liaVendorTry or 0) < CurTime() then
        client.liaVendorTry = CurTime() + 0.1
    else
        return
    end

    local found
    local entity = client.liaVendor
    if not IsValid(entity) or client:GetPos():Distance(entity:GetPos()) > 192 then return end
    if not hook.Run("CanPlayerAccessVendor", client, entity) then return end
    hook.Run("VendorTradeAttempt", client, entity, uniqueID, isSellingToVendor)
end)
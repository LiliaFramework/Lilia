MODULE.name = "vendorModuleName"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "npcVendorDescription"
MODULE.Privileges = {
    {
        Name = "canEditVendors",
        ID = "canEditVendors",
        MinAccess = "superadmin",
        Category = "vendors",
    },
    {
        Name = "canCreateVendorPresets",
        ID = "canCreateVendorPresets",
        MinAccess = "admin",
        Category = "vendors",
    },
}
VENDOR_WELCOME = 1
VENDOR_LEAVE = 2
VENDOR_NOTRADE = 3
VENDOR_PRICE = 1
VENDOR_STOCK = 2
VENDOR_MODE = 3
VENDOR_MAXSTOCK = 4
VENDOR_SELLANDBUY = 1
VENDOR_SELLONLY = 2
VENDOR_BUYONLY = 3
lia.config.add("vendorSaleScale", "vendorSaleScale", 0.5, function(value)
    local num = tonumber(value)
    if not num then return false, L("configValueMustBeNumber") end
    if num < 0.1 or num > 2.0 then return false, L("configValueMustBeBetween", 0.1, 2.0) end
    return true
end, {
    desc = L("vendorSaleScaleDesc"),
    category = "Vendors",
    type = "Float",
    min = 0.1,
    max = 2.0,
    decimals = 2
})
MODULE.name = "@vendor"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@npcVendorDescription"
MODULE.NetworkStrings = {"liaVendorAllowClass", "liaVendorAllowFaction", "liaVendorBuyPrice", "liaVendorDeletePreset", "liaVendorExit", "liaVendorFaction", "liaVendorFactionBuyScale", "liaVendorFactionSellScale", "liaVendorInitialSync", "liaVendorLoadPreset", "liaVendorMaxStock", "liaVendorMode", "liaVendorOpen", "liaVendorRequestData", "liaVendorSavePreset", "liaVendorSellPrice", "liaVendorStock", "liaVendorSync", "liaVendorSyncMessages", "liaVendorTrade",}
MODULE.Privileges = {
    ["canEditVendors"] = {
        Name = "@canEditVendors",
        MinAccess = "superadmin",
        Category = "@vendors",
    },
    ["canCreateVendorPresets"] = {
        Name = "@canCreateVendorPresets",
        MinAccess = "admin",
        Category = "@vendors",
    },
}

VENDOR_WELCOME = 1
VENDOR_LEAVE = 2
VENDOR_NOTRADE = 3
VENDOR_PRICE = 1
VENDOR_STOCK = 2
VENDOR_MODE = 3
VENDOR_MAXSTOCK = 4
VENDOR_BUYPRICE = 5
VENDOR_SELLPRICE = 6
VENDOR_SELLANDBUY = 1
VENDOR_SELLONLY = 2
VENDOR_BUYONLY = 3

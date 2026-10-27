MODULE.name = "Vendor"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Provides NPC vendors who can buy and sell items with stock management and dialogue-driven transactions."
MODULE.NetworkStrings = {"liaVendorAllowClass", "liaVendorAllowFaction", "liaVendorDeletePreset", "liaVendorExit", "liaVendorFactionBuyScale", "liaVendorFactionSellScale", "liaVendorInitialSync", "liaVendorLoadPreset", "liaVendorMaxStock", "liaVendorMode", "liaVendorOpen", "liaVendorRequestData", "liaVendorSavePreset", "liaVendorStock", "liaVendorSync", "liaVendorSyncMessages", "liaVendorTrade", "liaVendorEdit", "liaVendorPropertySync", "liaVendorSyncPresets",}
MODULE.Privileges = {
    ["canEditVendors"] = {
        Name = "Can Edit Vendors",
        MinAccess = "superadmin",
        Category = "Vendors",
    },
    ["canCreateVendorPresets"] = {
        Name = "Can Create Vendor Presets",
        MinAccess = "admin",
        Category = "Vendors",
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

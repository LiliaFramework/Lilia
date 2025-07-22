MODULE.name = "Grid Inventory"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Implements a modular grid-based inventory with item stacking, weight limits, and support for hot-loading additional modules."
MODULE.Dependencies = {
    {
        File = "gridinv.lua",
        Realm = "shared"
    },
}

lia.vendor.addPreset("utility_vendor", {
    manhack_welder = {
        mode = VENDOR_SELLANDBUY
    },
    item_suit = {
        mode = VENDOR_SELLANDBUY
    },
    universalammo3 = {
        mode = VENDOR_SELLANDBUY
    },
})

MODULE.name = "Vendors"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Provides NPC vendors who can buy and sell items with stock management and dialogue-driven transactions."
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Can Edit Vendors",
        MinAccess = "admin"
    },
}

lia.config.add("vendorDefaultMoney", "Default Vendor Money", 500, nil, {
    desc = "Sets the default amount of money a vendor starts with",
    category = "Vendors",
    type = "Int",
    min = 0,
    max = 100000
})

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
VENDOR_TEXT = {
    [VENDOR_SELLANDBUY] = "buyOnlynSell",
    [VENDOR_BUYONLY] = "buyOnly",
    [VENDOR_SELLONLY] = "sellOnly",
}

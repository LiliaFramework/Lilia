MODULE.Name = "@warnsModuleName"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@warnsModuleName"
MODULE.NetworkStrings = {
    "liaAllWarnings",
    "liaPlayerWarnings",
    "liaRequestAllWarnings",
    "liaRequestRemoveWarning",
    "liaRequestWarningsCount",
    "liaWarningsCount",
}
MODULE.Privileges = {
    ["viewPlayerWarnings"] = {
        Name = "@viewPlayerWarnings",
        MinAccess = "admin",
        Category = "@warning",
    },
    ["canRemoveWarns"] = {
        Name = "@canRemoveWarns",
        MinAccess = "superadmin",
        Category = "@warning",
    },
}

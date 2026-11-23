MODULE.Name = "Admin Stick"
MODULE.author = "Samael"
MODULE.discord = "liliaplayer"
MODULE.desc = "\nReload switches tool sections \nAdmin: Left click selects target, right click freezes player \nMap Configurer: Left click sets aim position, right click uses your position \nShift + Reload uses the active section's alternate action"
MODULE.NetworkStrings = {"liaAdminStickRequestPlayerState", "liaAdminStickPlayerState"}
MODULE.Privileges = {
    ["alwaysSpawnAdminStick"] = {
        Name = "Always Spawn w/ Admin Stick",
        MinAccess = "superadmin",
        Category = "Admin Stick",
    },
}

MODULE.name = "Storage"
MODULE.author = "Samael"
MODULE.discord = "liliaplayer"
MODULE.desc = "Adds persistent storage containers and player vaults that integrate with the inventory for item management."
MODULE.NetworkStrings = {"liaStorageExit", "liaStorageSetPassword", "liaStorageUnlock", "liaStorageOpen",}
MODULE.Privileges = {
    ["canSpawnStorage"] = {
        Name = "Can Spawn Storage",
        MinAccess = "superadmin",
        Category = "Spawn Permissions",
    }
}

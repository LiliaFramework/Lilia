MODULE.name = "@storage"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@storageSystemDescription"
MODULE.NetworkStrings = {
    "liaStorageExit",
    "liaStorageSetPassword",
    "liaStorageTransfer",
    "liaStorageUnlock",
    "liaTrunkInitStorage",
}
MODULE.Privileges = {
    ["canSpawnStorage"] = {
        Name = "@canSpawnStorage",
        MinAccess = "superadmin",
        Category = "@spawnPermissions",
    }
}

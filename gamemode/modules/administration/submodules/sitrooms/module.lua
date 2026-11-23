MODULE.Name = "Admin Sitrooms"
MODULE.author = "Samael"
MODULE.discord = "liliaplayer"
MODULE.desc = "Provides administration room management, teleportation, configuration, and UI."
MODULE.NetworkStrings = {"liaManagesitrooms", "liaManagesitroomsAction"}
MODULE.Privileges = {
    ["manageSitRooms"] = {
        Name = "Manage Administration Rooms",
        MinAccess = "admin",
        Category = "Staff: Management",
    },
}
MODULE.DataKey = "sitrooms"
MODULE.PositionType = "sit_room"
MODULE.PositionColor = Color(123, 104, 238)

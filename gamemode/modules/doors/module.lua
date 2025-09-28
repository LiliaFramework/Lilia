lia.doors = lia.doors or {}
lia.doors.presets = lia.doors.presets or {}
DOOR_OWNER = 3
DOOR_TENANT = 2
DOOR_GUEST = 1
DOOR_NONE = 0
MODULE.name = "Doors"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Manages door ownership, access control, and door-related permissions."
lia.doors.AccessLabels = {
    [DOOR_NONE] = "doorAccessNone",
    [DOOR_GUEST] = "doorAccessGuest",
    [DOOR_TENANT] = "doorAccessTenant",
    [DOOR_OWNER] = "doorAccessOwner"
}


ACCESS_LABELS = {}

MODULE.name = "Doors"
MODULE.author = "Chessnut"
MODULE.desc = "A simple door system."

lia.util.include("sv_module.lua")
lia.util.include("cl_module.lua")

lia.config.DoorCost = 10
lia.config.DoorSellRatio = 0.5
lia.config.DoorLockTime = 0.5

DOOR_OWNER = 3
DOOR_TENANT = 2
DOOR_GUEST = 1
DOOR_NONE = 0

ACCESS_LABELS[DOOR_OWNER] = "owner"
ACCESS_LABELS[DOOR_TENANT] = "tenant"
ACCESS_LABELS[DOOR_GUEST] = "guest"
ACCESS_LABELS[DOOR_NONE] = "none"

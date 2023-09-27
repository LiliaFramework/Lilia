--------------------------------------------------------------------------------------------------------
MODULE.name = "In-Development Hud"
MODULE.author = "STEAM_0:1:176123778"
MODULE.desc = "Implements a small hud for players to see at all times, admins will have access to a dev varient as well."
--------------------------------------------------------------------------------------------------------
lia.util.include("cl_module.lua")
--------------------------------------------------------------------------------------------------------
CAMI.RegisterPrivilege(
    {
        Name = "Lilia - Management - Development HUD",
        MinAccess = "superadmin",
        Description = "Allows access to Development HUD.",
    }
)

--------------------------------------------------------------------------------------------------------
CAMI.RegisterPrivilege(
    {
        Name = "Lilia - Management - Staff HUD",
        MinAccess = "superadmin",
        Description = "Allows access to Staff HUD.",
    }
)
--------------------------------------------------------------------------------------------------------
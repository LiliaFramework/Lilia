--------------------------------------------------------------------------------------------------------
MODULE.name = "Scoreboard"
MODULE.author = "STEAM_0:1:176123778"
MODULE.desc = "A simple scoreboard that supports recognition."
--------------------------------------------------------------------------------------------------------
lia.util.include("cl_module.lua")
--------------------------------------------------------------------------------------------------------
lia.config.sbWidth = 0.325
lia.config.sbHeight = 0.825
lia.config.sbTitle = GetHostName()
--------------------------------------------------------------------------------------------------------
CAMI.RegisterPrivilege(
    {
        Name = "Lilia - Can Access Scoreboard Admin Options",
        MinAccess = "admin",
        Description = "Allows access to Scoreboard Admin Options.",
    }
)
--------------------------------------------------------------------------------------------------------
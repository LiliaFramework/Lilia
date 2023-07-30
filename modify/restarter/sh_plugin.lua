local MODULE = MODULE
MODULE.name = "Server Restarter"
MODULE.author = "Verne/Leonheart#7476"
MODULE.desc = "GMOD CurTime() becomes inaccurate and we have to restart to reset it."
MODULE.TimeRemainingTable = {30, 15, 5, 1, 0}
MODULE.NextRestart = 0
MODULE.NextNotificationTime = 0
MODULE.IsRestarting = false
lia.util.include("sv_module.lua")
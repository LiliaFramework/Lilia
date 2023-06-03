local PLUGIN = PLUGIN
PLUGIN.name = "Server Restarter"
PLUGIN.author = "Verne/Leonheart#7476"
PLUGIN.desc = "GMOD CurTime() becomes inaccurate and we have to restart to reset it."
PLUGIN.TimeRemainingTable = {30, 15, 5, 1, 0}
PLUGIN.NextRestart = 0
PLUGIN.NextNotificationTime = 0
PLUGIN.IsRestarting = false
lia.util.include("sv_plugin.lua")
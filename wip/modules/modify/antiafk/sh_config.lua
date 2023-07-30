AFKKick = AFKKick or {}
AFKKick.Config = AFKKick.Config or {}
AFKKick.Config.WarningTime = 570 --How many seconds do they need to be AFK for before they receive the warning
AFKKick.Config.KickTime = 30 --How many seconds do they need to be AFK for, after the warning, to be kicked
AFKKick.Config.KickMessage = "Automatically kicked for being AFK for too long."
AFKKick.Config.WarningHead = "WARNING!"
AFKKick.Config.WarningSub = "You are going to be sent back to the character menu/kicked for being AFK!\nPress any key to abort!"

AFKKick.Config.AllowedPlayers = {
    ["STEAM_0:0:0000000"] = true,
}
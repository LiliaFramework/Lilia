local CONFIG = CONFIG
CONFIG.SchemaYear = 2023
CONFIG.contentURL = "https://discord.gg/HmfaJ9brfz"
CONFIG.PKActive = false
CONFIG.PKWorld = false
CONFIG.MoneyModel = "models/props_lab/box01a.mdl"
CONFIG.StaminaSlowdown = true
--///////////////////////////
CONFIG.RespawnButton = true
CONFIG.AFKKickEnabled = true
CONFIG.AllowVoice = true
CONFIG.CarRagdoll = true
CONFIG.CharacterSwitchCooldown = true
CONFIG.PlayerSprayEnabled = true
CONFIG.FlashlightEnabled = true
CONFIG.FlashlightItemNeeded = false
CONFIG.CentsCompatibility = true
CONFIG.WepAlwaysRaised = true
CONFIG.WeaponRaiseTimer = 1
CONFIG.DefaultStamina = 100
CONFIG.IntroEnabled = false
CONFIG.AlwaysPlayIntro = false
CONFIG.introFont = "Cambria"
CONFIG.ServerVersionDisplayerEnabled = true
CONFIG.VoiceDistance = 600
CONFIG.AFKTime = 300
CONFIG.Year = tonumber(os.date("%Y"))
CONFIG.Month = tonumber(os.date("%m"))
CONFIG.Day = tonumber(os.date("%d"))
CONFIG.StaminaBlur = false
CONFIG.CrosshairEnabled = false
CONFIG.DrawEntityShadows = true
CONFIG.Vignette = true
CONFIG.BarsDisabled = false
CONFIG.AmmoDrawEnabled = true
CONFIG.DarkTheme = true
CONFIG.Color = Color(75, 119, 190)
CONFIG.Font = "Arial"
CONFIG.PlayerInteractSpeed = 1
CONFIG.FontScale = 1
CONFIG.GenericFont = "Segoe UI"
CONFIG.ChatSizeDiff = false
CONFIG.MaxChars = 5
CONFIG.SpawnTime = 5
CONFIG.invW = 6
CONFIG.invH = 4
CONFIG.MinDescLen = 16
CONFIG.WalkSpeed = 130
CONFIG.RunSpeed = 235
CONFIG.WalkRatio = 0.5
CONFIG.PunchStamina = 10
CONFIG.DefaultMoney = 0
CONFIG.SaveInterval = 300
CONFIG.SaveInterval = 300

CONFIG.StaminaRegenMultiplier = 1

CONFIG.StaffAutoRecognize = false
CONFIG.FactionAutoRecognize = false
CONFIG.AllowExistNames = false
CONFIG.StrMultiplier = 0.1
CONFIG.CustomChatSound = ""
CONFIG.F1MenuLaunchUnanchor = "buttons/lightswitch2.wav"
CONFIG.MenuButtonRollover = "ui/buttonrollover.wav"
CONFIG.SoundMenuButtonPressed = "ui/buttonclickrelease.wav"
CONFIG.Notify = {"garrysmod/content_downloaded.wav", 50, 250}
CONFIG.CharHover = {"buttons/button15.wav", 35, 250}
CONFIG.CharClick = {"buttons/button14.wav", 35, 255}
CONFIG.CharWarning = {"friends/friend_join.wav", 40, 255}
CONFIG.CharAttrib = {"buttons/button16.wav", 30, 255}
CONFIG.VendorClick = {"buttons/button15.wav", 30, 250}
--///////////////////////////
CONFIG.OOCDelay = 10
CONFIG.MaxChatLength = 200
CONFIG.OOCLimit = 150
CONFIG.ChatColor = Color(255, 239, 150)
CONFIG.ChatListenColor = Color(168, 240, 170)
CONFIG.OOCDelayAdmin = false
CONFIG.AllowGlobalOOC = true
CONFIG.LOOCDelayAdmin = false
CONFIG.LOOCDelay = 6
CONFIG.ChatShowTime = false
CONFIG.ChatRange = 280
CONFIG.RecognitionEnabled = true
CONFIG.sbWidth = 0.325
CONFIG.sbHeight = 0.825
CONFIG.sbTitle = GetHostName()
CONFIG.SalaryOverride = true
CONFIG.SalaryInterval = 300

CONFIG.TimeUntilDroppedSWEPRemoved = 30
CONFIG.PlayerSpawnVehicleDelay = 30
CONFIG.CharacterSwitchCooldownTimer = 5
CONFIG.MaxAttributes = 30
CONFIG.BHOPStamina = 10
CONFIG.MapCleanerEnabled = true
CONFIG.ItemCleanupTime = 7200
CONFIG.MapCleanupTime = 21600
CONFIG.SaveStorage = true
CONFIG.PasswordDelay = 1

CONFIG.LegsEnabled = false
CONFIG.LegsInVehicle = false
CONFIG.m_tblPlayers = CONFIG.m_tblPlayers or {}
CONFIG.m_intSpawnDelay = 8 --Delay initial pvs update by this amount on player spawn
CONFIG.m_intUpdateDistance = 5500 --Entities in this range are sent to the player, all others do not send
CONFIG.m_intUpdateRate = 1 --Entity transmit update rate
CONFIG.m_intUpdateAmount = 512

CONFIG.m_tblAlwaysSend = {
    ["player"] = true,
    ["func_lod"] = true,
    ["gmod_hands"] = true,
    ["worldspawn"] = true,
    ["player_manager"] = true,
    ["gmod_gamerules"] = true,
    ["bodyque"] = true,
    ["network"] = true,
    ["soundent"] = true,
    ["prop_door_rotating"] = true,
    ["phys_slideconstraint"] = true,
    ["phys_bone_follower"] = true,
    ["class C_BaseEntity"] = true,
    ["func_physbox"] = true,
    ["logic_auto"] = true,
    ["env_tonemap_controller"] = true,
    ["shadow_control"] = true,
    ["env_sun"] = true,
    ["lua_run"] = true,
    ["func_useableladder"] = true,
    ["info_ladder_dismount"] = true,
    ["func_illusionary"] = true,
    ["env_fog_controller"] = true,
    ["prop_vehicle_jeep"] = false,
}

CONFIG.TimeRemainingTable = {30, 15, 5, 1, 0}
CONFIG.NextRestart = 0
CONFIG.NextNotificationTime = 0
CONFIG.IsRestarting = false
CONFIG.whitelistEnabled = false
CONFIG.AllowedOverride = {
    ["STEAM_0:0:12345678"] = true,
    ["STEAM_0:1:98765432"] = true,
    ["STEAM_0:2:54321098"] = true,
    ["STEAM_0:3:11111111"] = true,
}
CONFIG.KeepAmmoOnDeath = false
CONFIG.DeathPopupEnabled = true
CONFIG.LoseWeapononDeathNPC = false
CONFIG.LoseWeapononDeathHuman = false

CONFIG.TposingModels = {
    "models/kerry/ag_player/male_03.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
    "model/path/xd.mdl",
}
CONFIG.cooldown = 0.5
CONFIG.CanSpawnMenuItems = {
    ["superadmin"] = true,
    ["admin"] = false,
    ["user"] = false,
}

CONFIG.BlacklistedIPAddress = {
    "86.172.101.19",
    "0.0.0.0",
    "1.1.1.1",
}

CONFIG.BlacklistedSteamID = {
    "STEAM_0:0:539872789",
    "STEAM_0:1:67558546",
}
GM:InitializedConfig()

CONFIG.entities = CONFIG.entities or {}

CONFIG.blacklist = CONFIG.blacklist or {
    ["func_button"] = true,
    ["class C_BaseEntity"] = true,
    ["func_brush"] = true,
    ["func_tracktrain"] = true,
    ["func_door"] = true,
    ["func_door_rotating"] = true,
    ["prop_door_rotating"] = true,
    ["prop_static"] = true,
    ["prop_dynamic"] = true,
    ["prop_physics_override"] = true,
}

CONFIG.WarningTime = 570 --How many seconds do they need to be AFK for before they receive the warning
CONFIG.KickTime = 30 --How many seconds do they need to be AFK for, after the warning, to be kicked
CONFIG.KickMessage = "Automatically kicked for being AFK for too long."
CONFIG.WarningHead = "WARNING!"
CONFIG.WarningSub = "You are going to be sent back to the character menu/kicked for being AFK!\nPress any key to abort!"

CONFIG.AllowedPlayers = {
    ["STEAM_0:0:0000000"] = true,
}
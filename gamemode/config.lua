--------------------------------------------------------------------------------------------------------
lia.config = lia.config or {}
lia.config.list = lia.config.list or {}
--------------------------------------------------------------------------------------------------------
lia.config.contentURL = "https://discord.gg/HmfaJ9brfz"
lia.config.PKActive = false
lia.config.PKWorld = false
lia.config.MoneyModel = "models/props_lab/box01a.mdl"
lia.config.StaminaSlowdown = true
lia.config.BranchWarning = true
lia.config.VersionEnabled = true
lia.config.ThirdPersonEnabled = true
lia.config.Musicvolume = 0.25
lia.config.Music = "music/hl2_song2.mp3"
lia.config.BackgroundURL = "music/hl2_song2.mp3"
lia.config.CharMenuBGInputDisabled = true
--///////////////////////////
lia.config.RespawnButton = true
lia.config.AFKKickEnabled = true
lia.config.AllowVoice = true
lia.config.CarRagdoll = true
lia.config.CharacterSwitchCooldown = true
lia.config.PlayerSprayEnabled = true
lia.config.FlashlightEnabled = true
lia.config.FlashlightItemNeeded = false
lia.config.CentsCompatibility = true
lia.config.WepAlwaysRaised = true
lia.config.WeaponRaiseTimer = 1
lia.config.DefaultStamina = 100
lia.config.ServerVersionDisplayerEnabled = true
lia.config.VoiceDistance = 600
lia.config.AFKTime = 300
lia.config.Year = tonumber(os.date("%Y"))
lia.config.Month = tonumber(os.date("%m"))
lia.config.Day = tonumber(os.date("%d"))
lia.config.StaminaBlur = false
lia.config.CrosshairEnabled = false
lia.config.DrawEntityShadows = true
lia.config.Vignette = true
lia.config.BarsDisabled = false
lia.config.AmmoDrawEnabled = true
lia.config.DarkTheme = true
lia.config.Color = Color(75, 119, 190)
lia.config.Font = "Arial"
lia.config.PlayerInteractSpeed = 1
lia.config.FontScale = 1
lia.config.GenericFont = "Segoe UI"
lia.config.ChatSizeDiff = false
lia.config.MaxChars = 5
lia.config.SpawnTime = 5
lia.config.invW = 6
lia.config.invH = 4
lia.config.MinDescLen = 16
lia.config.WalkSpeed = 130
lia.config.RunSpeed = 235
lia.config.WalkRatio = 0.5
lia.config.PunchStamina = 10
lia.config.DefaultMoney = 0
lia.config.DataSaveInterval = 600
lia.config.CharacterSaveInterval = 300
lia.config.StaminaRegenMultiplier = 1
lia.config.StaffAutoRecognize = false
lia.config.FactionAutoRecognize = false
lia.config.AllowExistNames = false
lia.config.StrMultiplier = 0.1
lia.config.CustomChatSound = ""
lia.config.F1MenuLaunchUnanchor = "buttons/lightswitch2.wav"
lia.config.MenuButtonRollover = "ui/buttonrollover.wav"
lia.config.SoundMenuButtonPressed = "ui/buttonclickrelease.wav"

lia.config.Notify = {"garrysmod/content_downloaded.wav", 50, 250}

lia.config.CharHover = {"buttons/button15.wav", 35, 250}

lia.config.CharClick = {"buttons/button14.wav", 35, 255}

lia.config.CharWarning = {"friends/friend_join.wav", 40, 255}

lia.config.CharAttrib = {"buttons/button16.wav", 30, 255}

lia.config.VendorClick = {"buttons/button15.wav", 30, 250}

--///////////////////////////
lia.config.OOCDelay = 10
lia.config.MaxChatLength = 200
lia.config.OOCLimit = 150
lia.config.ChatColor = Color(255, 239, 150)
lia.config.ChatListenColor = Color(168, 240, 170)
lia.config.OOCDelayAdmin = false
lia.config.AllowGlobalOOC = true
lia.config.LOOCDelayAdmin = false
lia.config.LOOCDelay = 6
lia.config.ChatShowTime = false
lia.config.ChatRange = 280
lia.config.RecognitionEnabled = true
lia.config.sbWidth = 0.325
lia.config.sbHeight = 0.825
lia.config.sbTitle = GetHostName()
lia.config.SalaryOverride = true
lia.config.SalaryInterval = 300
lia.config.TimeUntilDroppedSWEPRemoved = 30
lia.config.PlayerSpawnVehicleDelay = 30
lia.config.CharacterSwitchCooldownTimer = 5
lia.config.MaxAttributes = 30
lia.config.BHOPStamina = 10
lia.config.MapCleanerEnabled = true
lia.config.ItemCleanupTime = 7200
lia.config.MapCleanupTime = 21600
lia.config.SaveStorage = true
lia.config.PasswordDelay = 1
lia.config.LegsEnabled = false
lia.config.LegsInVehicle = false
lia.config.tblPlayers = lia.config.tblPlayers or {}
lia.config.intSpawnDelay = 8 --Delay initial pvs update by this amount on player spawn
lia.config.intUpdateDistance = 5500 --Entities in this range are sent to the player, all others do not send
lia.config.intUpdateRate = 1 --Entity transmit update rate
lia.config.intUpdateAmount = 512

lia.config.tblAlwaysSend = {
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

lia.config.TimeRemainingTable = {30, 15, 5, 1, 0}

lia.config.NextRestart = 0
lia.config.NextNotificationTime = 0
lia.config.IsRestarting = false
lia.config.whitelistEnabled = false

lia.config.AllowedOverride = {
    ["STEAM_0:0:12345678"] = true,
    ["STEAM_0:1:98765432"] = true,
    ["STEAM_0:2:54321098"] = true,
    ["STEAM_0:3:11111111"] = true,
}

lia.config.KeepAmmoOnDeath = false
lia.config.DeathPopupEnabled = true
lia.config.LoseWeapononDeathNPC = false
lia.config.LoseWeapononDeathHuman = false

lia.config.PlayerModelTposingFixer = {
    ["path/to/model.mdl"] = "player",
    ["path/to/model.mdl"] = "player",
    ["path/to/model.mdl"] = "player",
    ["path/to/model.mdl"] = "player",
}

lia.config.DefaultTposingFixer = {
    ["models/police.mdl"] = "metrocop",
    ["models/combine_super_soldier.mdl"] = "overwatch",
    ["models/combine_soldier_prisonGuard.mdl"] = "overwatch",
    ["models/combine_soldier.mdl"] = "overwatch",
    ["models/vortigaunt.mdl"] = "vort",
    ["models/vortigaunt_blue.mdl"] = "vort",
    ["models/vortigaunt_doctor.mdl"] = "vort",
    ["models/vortigaunt_slave.mdl"] = "vort",
    ["models/vortigaunt_slave.mdl"] = "vort",
    ["models/alyx.mdl"] = "citizen_female",
    ["models/mossman.mdl"] = "citizen_female",
}

lia.config.cooldown = 0.5

lia.config.CanSpawnMenuItems = {
    ["superadmin"] = true,
    ["admin"] = false,
    ["user"] = false,
}

lia.config.BlacklistedIPAddress = {"86.172.101.19", "0.0.0.0", "1.1.1.1",}

lia.config.BlacklistedSteamID = {"STEAM_0:0:539872789", "STEAM_0:1:67558546",}

lia.config.entities = lia.config.entities or {}

lia.config.blacklist = lia.config.blacklist or {
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

lia.config.WarningTime = 570 --How many seconds do they need to be AFK for before they receive the warning
lia.config.KickTime = 30 --How many seconds do they need to be AFK for, after the warning, to be kicked
lia.config.KickMessage = "Automatically kicked for being AFK for too long."
lia.config.WarningHead = "WARNING!"
lia.config.WarningSub = "You are going to be sent back to the character menu/kicked for being AFK!\nPress any key to abort!"

lia.config.AllowedPlayers = {
    ["STEAM_0:0:0000000"] = true,
}

lia.config.PermaRaisedWeapons = {
    ["weapon_physgun"] = true,
    ["gmod_tool"] = true,
    ["lia_poshelper"] = true,
}

lia.config.DevPrinting = false
lia.config.Language = "english"

lia.config.PlayerModelTposingFixer = {
    ["path/to/model.mdl"] = "player",
    ["path/to/model.mdl"] = "player",
    ["path/to/model.mdl"] = "player",
    ["path/to/model.mdl"] = "player",
}

lia.config.HiddenHUDElements = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudHistoryResource"] = true
}

lia.config.InjuryTextTable = {
    [.2] = {"Critical Injury", Color(255, 0, 0)},
    [.4] = {"Severe Injury", Color(255, 165, 0)},
    [.7] = {"Moderate Injury", Color(255, 215, 0)},
    [.9] = {"Minor Injury", Color(255, 255, 0)},
    [1] = {"Healthy", Color(0, 255, 0)},
}
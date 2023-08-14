function lia.config.load_core()
    lia.config.version = "1.0"
    lia.config.MaxAttributes = 30
    lia.config.DefaultGamemodeName = "Lilia - Skeleton"
    lia.config.Color = Color(75, 119, 190)
    lia.config.VersionEnabled = true
    lia.config.DarkTheme = true
    lia.config.DataSaveInterval = 600
    lia.config.CharacterSaveInterval = 300
    lia.config.Font = "Arial"
    lia.config.GenericFont = "Segoe UI"
    lia.config.WhitelistEnabled = false
    lia.config.MoneyModel = "models/props_lab/box01a.mdl"
    lia.config.BranchWarning = true
    lia.config.AllowVoice = true
    lia.config.ThirdPersonEnabled = true
    lia.config.CrosshairEnabled = false
    lia.config.BarsDisabled = false
    lia.config.AmmoDrawEnabled = true
    lia.config.jumpcooldown = 0.8
    lia.config.HeadShotDamage = 2
    lia.config.PermaClass = true
    lia.config.AutoWorkshopDownloader = false
    lia.config.DefaultStaff = {
        ["STEAM_0:1:176123778"] = "superadmin",
    }
    lia.config.urls = {
        ["Discord"] = "",
        ["Workshop"] = ""
    }
    lia.config.FactionBroadcastEnabled = true
lia.config.AdvertisementEnabled = true
lia.config.AdvertisementPrice = 25
lia.config.DrawEntityShadows = true
--------------------------------------------------------------------------------------------------
    lia.config.MapCleanerEnabled = true
    lia.config.ItemCleanupTime = 7200
    lia.config.MapCleanupTime = 21600
--------------------------------------------------------------------------------------------------
    lia.config.MaxCharacters = 5
    lia.config.Vignette = true
--------------------------------------------------------------------------------------------------
    lia.config.StaminaSlowdown = true
    lia.config.SalaryOverride = true
    lia.config.SalaryInterval = 300
--------------------------------------------------------------------------------------------------
    lia.config.invW = 6
    lia.config.invH = 4
--------------------------------------------------------------------------------------------------
    lia.config.AutoRegen = false
    lia.config.HealingAmount = 10
    lia.config.HealingTimer = 60
--------------------------------------------------------------------------------------------------
    lia.config.MusicKiller = true
--------------------------------------------------------------------------------------------------
    lia.config.WalkSpeed = 130
    lia.config.RunSpeed = 235
    lia.config.WalkRatio = 0.5
--------------------------------------------------------------------------------------------------
    lia.config.PunchStamina = 10
    lia.config.DefaultMoney = 0
--------------------------------------------------------------------------------------------------
    lia.config.HiddenHUDElements = {
        ["CHudHealth"] = true,
        ["CHudCrosshair"] = true,
        ["CHudBattery"] = true,
        ["CHudAmmo"] = true,
        ["CHudSecondaryAmmo"] = true,
        ["CHudHistoryResource"] = true
    }
--------------------------------------------------------------------------------------------------
    lia.config.InjuryTextTable = {
        [.2] = {"Critical Injury", Color(255, 0, 0)},
        [.4] = {"Severe Injury", Color(255, 165, 0)},
        [.7] = {"Moderate Injury", Color(255, 215, 0)},
        [.9] = {"Minor Injury", Color(255, 255, 0)},
        [1] = {"Healthy", Color(0, 255, 0)},
    }
--------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------------------
lia.config.Ranges = {
    {
        name = "Whispering",
        range = 120
    },
    {
        name = "Talking",
        range = 300
    },
    {
        name = "Yelling",
        range = 600
    }
}
lia.config.DisallowedBagForbiddenActions = {
    ["Equip"] = true,
    ["EquipUn"] = true,
}

lia.config.TimeUntilDroppedSWEPRemoved = 30
lia.config.PlayerSpawnVehicleDelay = 30
lia.config.CharacterSwitchCooldownTimer = 5
lia.config.NPCsDropWeapons = true
lia.config.CarRagdoll = true
lia.config.CharacterSwitchCooldown = true
lia.config.FlashlightEnabled = true
lia.config.FlashlightItemNeeded = false

end
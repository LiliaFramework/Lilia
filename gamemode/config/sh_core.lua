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
    lia.config.DefaultMoney = 0
    --------------------------------------------------------------------------------------------------
    lia.config.TimeUntilDroppedSWEPRemoved = 30
    lia.config.PlayerSpawnVehicleDelay = 30
    lia.config.CharacterSwitchCooldownTimer = 5
    lia.config.NPCsDropWeapons = true
    lia.config.CarRagdoll = true
    lia.config.CharacterSwitchCooldown = true
end
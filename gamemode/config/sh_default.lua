function lia.config.load.default()
    lia.config.MapCleanerEnabled = true
    lia.config.ItemCleanupTime = 7200
    lia.config.MapCleanupTime = 21600
    lia.config.StaminaRegenMultiplier = 1
    lia.config.StrMultiplier = 0.1
    lia.config.MaxCharacters = 5
    lia.config.Vignette = true
    lia.config.StaminaSlowdown = true
    lia.config.SalaryOverride = true
    lia.config.StaminaBlur = false
    lia.config.StaminaSlowdown = true
    lia.config.WeaponRaiseTimer = 1
    lia.config.DefaultStamina = 100
    lia.config.VoiceDistance = 600
    lia.config.invW = 6
    lia.config.invH = 4
    lia.config.MinDescLen = 16
    lia.config.SalaryInterval = 300
    lia.config.AutoRegen = false
    lia.config.HealingAmount = 10
    lia.config.HealingTimer = 60
    lia.config.MusicKiller = true
    lia.config.WalkSpeed = 130
    lia.config.RunSpeed = 235
    lia.config.WalkRatio = 0.5
    lia.config.PunchStamina = 10
    lia.config.DefaultMoney = 0
    lia.config.HiddenHUDElements = {
        ["CHudHealth"] = true,
        ["CHudCrosshair"] = true,
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
end
function lia.config.load_default()
    lia.config.DisallowedBagForbiddenActions = {
        ["Equip"] = true,
        ["EquipUn"] = true,
    }

    lia.config.Ranges = {
        ["Whispering"] = 120,
        ["Talking"] = 300,
        ["Yelling"] = 600,
    }

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
end
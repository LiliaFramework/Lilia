function lia.config.LoadCore()
    lia.config.version = "1.0"
    lia.config.MaxAttributes = 30
    lia.config.DefaultGamemodeName = "Lilia - Skeleton"
    lia.config.Color = Color(75, 119, 190)
    lia.config.VersionEnabled = true
    lia.config.DarkTheme = true
    lia.config.DataSaveInterval = 600
    lia.config.Font = "Arial"
    lia.config.GenericFont = "Segoe UI"
    lia.config.WhitelistEnabled = false
    lia.config.MoneyModel = "models/props_lab/box01a.mdl"
    lia.config.BranchWarning = true
    lia.config.AllowVoice = true
    lia.config.AutoWorkshopDownloader = false
    lia.config.DefaultStaff = {
        ["STEAM_0:1:176123778"] = "superadmin",
    }

    lia.config.urls = {
        ["Discord"] = "",
        ["Workshop"] = ""
    }

    lia.config.MaxCharacters = 5
    lia.config.SalaryOverride = true
    lia.config.SalaryInterval = 300
    lia.config.invW = 6
    lia.config.invH = 4
    lia.config.WalkSpeed = 130
    lia.config.RunSpeed = 235
    lia.config.WalkRatio = 0.5
    lia.config.DefaultMoney = 0
end
--------------------------------------------------------------------------------------------------------
function lia.config.LoadCore()
    print("CONFIG: Loaded Core")
    lia.config.DefaultGamemodeName = "Lilia - Skeleton"
    lia.config.Color = Color(75, 119, 190)
    lia.config.DarkTheme = true
    lia.config.Font = "Arial"
    lia.config.GenericFont = "Segoe UI"
    lia.config.WhitelistEnabled = false
    lia.config.MoneyModel = "models/props_lab/box01a.mdl"
    lia.config.AutoWorkshopDownloader = false
    lia.config.MaxCharacters = 5
    lia.config.invW = 6
    lia.config.invH = 4
    lia.config.DefaultMoney = 0
    lia.currency.singular = "Dollar"
    lia.currency.plural = "Dollars"
    lia.currency.symbol = "$"
    lia.config.Ranges = {
        ["Whispering"] = 120,
        ["Talking"] = 300,
        ["Yelling"] = 600,
    }
    
    lia.config.DefaultStaff = {}
end

function lia.config.LoadSchemaConfig()
    print("CONFIG: Loaded Schema Config")
end
--------------------------------------------------------------------------------------------------------
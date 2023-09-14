--------------------------------------------------------------------------------------------------------
function GM:LoadCoreConfig()
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
    
    lia.config.UnLoadedPlugins = {
        ammosave = false,
        bodygrouper = false,
        chatbox = false,
        cmenu = false,
        corefiles = false,
        crashscreen = false,
        doors = false,
        f1menu = false,
        flashlight = false,
        gridinventory = false,
        interactionmenu = false,
        mainmenu = false,
        observer = false,
        pac = false,
        permakill = false,
        radio = false,
        raiseweapons = false,
        recognition = false,
        saveitems = false,
        scoreboard = false,
        serverblacklister = false,
        skills = false,
        spawnmenuitems = false,
        spawns = false,
        storage = false,
        tying = false,
        vendor = false,
        weaponselector = false,
        whitelist = false,
    }
    
    
    lia.config.DefaultStaff = {}
end
--------------------------------------------------------------------------------------------------------
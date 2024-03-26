local GM = GM or GAMEMODE

--- Helper library for creating/setting config options.
-- @module lia.config
lia.config = lia.config or {}

if not ConfigWasInitialized then
    lia.config = {
        --- How fast characters walk.
        -- @realm shared
        -- @int Default Walk Speed
        WalkSpeed = 130,

        --- How fast characters run.
        -- @realm shared
        -- @int Default Running Speed
        RunSpeed = 235,

        --- Walk speed ratio when holding Alt.
        -- @realm shared
        -- @float Default Walk Speed Ratio
        WalkRatio = 0.5,

        --- Maximum number of characters per player.
        -- @realm shared
        -- @int Default Character Amount
        MaxCharacters = 5,

        --- Period between data saves.
        -- @realm shared
        -- @int Time in Seconds
        DataSaveInterval = 600,

        --- Time between character data saves.
        -- @realm shared
        -- @int Time in Seconds
        CharacterDataSaveInterval = 300,

        --- The limit of money you can have on yourself at a given time.
        -- @realm shared
        -- @int Limit Of Money (0 = infinite)
        MoneyLimit = 0,

        --- Default inventory width.
        -- @realm shared
        -- @int Inventory Width
        invW = 6,

        --- Default inventory height.
        -- @realm shared
        -- @int Inventory Height
        invH = 4,

        --- Default money amount.
        -- @realm shared
        -- @int Default Money Amount
        DefaultMoney = 0,

        --- Maximum chat message length.
        -- @realm shared
        -- @int Max Chat Length
        MaxChatLength = 256,

        --- Currency symbol.
        -- @realm shared
        -- @string Currency Symbol
        CurrencySymbol = "$",

        --- Time to respawn after death.
        -- @realm shared
        -- @int Time to Respawn
        SpawnTime = 5,

        --- Maximum attributes one can have.
        -- @realm shared
        -- @int Maximum Attributes
        MaxAttributes = 30,

        --- Year in the gamemode's schema.
        -- @realm shared
        -- @int Schema Year
        SchemaYear = 2023,

        --- Minimum length of a character's description.
        -- @realm shared
        -- @int Minimum Description Length
        MinDescLen = 16,

        --- Time required to enter a vehicle.
        -- @realm shared
        -- @int Time to Enter Vehicle
        TimeToEnterVehicle = 1,

        --- Allow duplicated character names.
        -- @realm shared
        -- @bool AllowExistNames
        AllowExistNames = true,

        --- Name of the gamemode.
        -- @realm shared
        -- @string Gamemode Name
        GamemodeName = "A Lilia Gamemode",

        --- Theme color.
        -- @realm shared
        -- @color Color
        Color = Color(34, 139, 34),

        --- Core font.
        -- @realm shared
        -- @string Font
        Font = "Arial",

        --- Secondary font.
        -- @realm shared
        -- @string Generic Font
        GenericFont = "Segoe UI",

        --- Money model.
        -- @realm shared
        -- @string Money Model
        MoneyModel = "models/props_lab/box01a.mdl",

        --- Singular currency name.
        -- @realm shared
        -- @string Currency Singular Name
        CurrencySingularName = "Dollar",

        --- Plural currency name.
        -- @realm shared
        -- @string Currency Plural Name
        CurrencyPluralName = "Dollars",

        --- Use American date format.
        -- @realm shared
        -- @bool American Dates
        AmericanDates = true,

        --- Use American timestamp format.
        -- @realm shared
        -- @bool American TimeStamp
        AmericanTimeStamp = true,

        --- If Car Entry Delay is Applicable.
        -- @realm shared
        -- @bool Car Entry Delay Enabled
        CarEntryDelayEnabled = true,

        --- Notification sound and volume.
        -- @realm shared
        -- @table Notify
        Notify = {
            "garrysmod/content_downloaded.wav", -- Notification Sound
            50, -- Notification Volume
            250 -- Notification Pitch
        }
    }
    
    hook.Run("InitializedConfig")
    ConfigWasInitialized = true
end

function GM:InitializedConfig()
    hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
end
--[[--
Configuration options for Lilia.

This library contains various configuration options used in the Lilia gamemode. Each option in the **lia.config** table serves a specific purpose and defines various aspects of the gamemode's functionality.

These configuration options control various aspects of the gamemode's mechanics, user interface, and gameplay experience.
]]
-- @library lia.config
local GM = GM or GAMEMODE
lia.config = lia.config or {}
--- A list of available commands for use within the game.
-- Each command is represented by a table with fields defining its functionality.
-- @realm shared
-- @table ConfigList
-- @field WalkSpeed Controls how fast characters walk | **integer**
-- @field RunSpeed Controls how fast characters run | **integer**
-- @field WalkRatio Defines the walk speed ratio when holding the Alt key | **number**.
-- @field AllowExistNames Determines whether duplicated character names are allowed | **bool**ean.
-- @field GamemodeName Specifies the name of the gamemode | **string**.
-- @field Color Sets the theme color used throughout the gamemode | **color**.
-- @field Font Specifies the core font used for UI elements | **string**.
-- @field GenericFont Specifies the secondary font used for UI elements | **string**.
-- @field MoneyModel Defines the model used for representing money in the game | **string**.
-- @field MaxCharacters Sets the maximum number of characters per player | **integer**
-- @field DataSaveInterval Time interval between data saves | **integer**
-- @field CharacterDataSaveInterval Time interval between character data saves.
-- @field MoneyLimit Sets the limit of money a player can have **[0 for infinite] | **integer**
-- @field invW Defines the width of the default inventory | **integer**
-- @field invH Defines the height of the default inventory | **integer**
-- @field DefaultMoney Specifies the default amount of money a player starts with | **integer**
-- @field MaxChatLength Sets the maximum length of chat messages | **integer**
-- @field CurrencySymbol Specifies the currency symbol used in the game | **string**.
-- @field SpawnTime Time to respawn after death | **integer**
-- @field MaxAttributes Maximum attributes a character can have | **integer**
-- @field EquipDelay Time delay between equipping items | **integer**
-- @field DropDelay Time delay between dropping items | **integer**
-- @field TakeDelay Time delay between taking items | **integer**
-- @field CurrencySingularName Singular name of the in-game currency | **string**.
-- @field CurrencyPluralName Plural name of the in-game currency | **string**.
-- @field SchemaYear Year in the gamemode's schema | **integer**
-- @field AmericanDates Determines whether to use the American date format | **bool**ean.
-- @field AmericanTimeStamp Determines whether to use the American timestamp format | **bool**ean.
-- @field MinDescLen Minimum length required for a character's description | **integer**
-- @field TimeToEnterVehicle Time **[in seconds]** required to enter a vehicle | **integer**
-- @field CarEntryDelayEnabled Determines if the car entry delay is applicable | **bool**ean.
-- @field Notify Contains notification sound and volume settings | **table**.
-- @field Notify Argument 1 Notification sound file path | **string**.
-- @field Notify Argument 2 Notification volume | **integer**
-- @field Notify Argument 3 Notification pitch | **integer**
if not ConfigWasInitialized then
    lia.config = {
        WalkSpeed = 130,
        RunSpeed = 235,
        WalkRatio = 0.5,
        AllowExistNames = true,
        GamemodeName = "A Lilia Gamemode",
        Color = Color(34, 139, 34),
        Font = "Arial",
        GenericFont = "Segoe UI",
        MoneyModel = "models/props_lab/box01a.mdl",
        MaxCharacters = 5,
        DataSaveInterval = 600,
        CharacterDataSaveInterval = 300,
        MoneyLimit = 0,
        invW = 6,
        invH = 4,
        DefaultMoney = 0,
        MaxChatLength = 256,
        CurrencySymbol = "$",
        SpawnTime = 5,
        MaxAttributes = 30,
        EquipDelay = 2,
        UnequipDelay = 2,
        DropDelay = 2,
        TakeDelay = 2,
        CurrencySingularName = "Dollar",
        CurrencyPluralName = "Dollars",
        SchemaYear = 2023,
        AmericanDates = true,
        AmericanTimeStamp = true,
        MinDescLen = 16,
        TimeToEnterVehicle = 1,
        AdminConsoleNetworkLogs = false,
        CarEntryDelayEnabled = true,
        Notify = {"garrysmod/content_downloaded.wav", 50, 250},
    }

    hook.Run("InitializedConfig")
    ConfigWasInitialized = true
end

function GM:InitializedConfig()
    hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
end

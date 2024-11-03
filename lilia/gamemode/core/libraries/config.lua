--[[--
Configuration options for Lilia.

This library contains various configuration options used in the Lilia gamemode. Each option in the **lia.config** table serves a specific purpose and defines various aspects of the gamemode's functionality.

These configuration options control various aspects of the gamemode's mechanics, user interface, and gameplay experience.
]]
-- @library lia.config
lia.config = lia.config or {}
--- A list of available configuration options for use within the game.
-- Each option is represented by a field with a specific data type and functionality.
-- @realm shared
-- @table ConfigList
-- @field WalkSpeed Controls how fast characters walk | **integer**
-- @field RunSpeed Controls how fast characters run | **integer**
-- @field WalkRatio Defines the walk speed ratio when holding the Alt key | **number**
-- @field AllowExistNames Determines whether duplicate character names are allowed | **boolean**
-- @field GamemodeName Specifies the name of the gamemode | **string**
-- @field Color Sets the theme color used throughout the gamemode | **color**
-- @field Font Specifies the core font used for UI elements | **string**
-- @field Language Determines the language setting for the game | **string**
-- @field GenericFont Specifies the secondary font used for UI elements | **string**
-- @field MoneyModel Defines the model used for representing money in the game | **string**
-- @field MaxCharacters Sets the maximum number of characters per player | **integer**
-- @field DataSaveInterval Time interval between data saves | **integer**
-- @field CharacterDataSaveInterval Time interval between character data saves | **integer**
-- @field MoneyLimit Sets the limit of money a player can have **[0 for infinite]** | **integer**
-- @field invW Defines the width of the default inventory | **integer**
-- @field invH Defines the height of the default inventory | **integer**
-- @field DefaultMoney Specifies the default amount of money a player starts with | **integer**
-- @field MaxChatLength Sets the maximum length of chat messages | **integer**
-- @field CurrencySymbol Specifies the currency symbol used in the game | **string**
-- @field SpawnTime Time to respawn after death | **integer**
-- @field MaxAttributePoints Maximum number of points that can be allocated across an attribute | **integer**
-- @field MaxStartingAttributes Maximum value of each attribute at character creation | **integer**
-- @field StartingAttributePoints Total number of points available for starting attribute allocation | **integer**
-- @field EquipDelay Time delay between equipping items | **integer**
-- @field DropDelay Time delay between dropping items | **integer**
-- @field TakeDelay Time delay between taking items | **integer**
-- @field CurrencySingularName Singular name of the in-game currency | **string**
-- @field CurrencyPluralName Plural name of the in-game currency | **string**
-- @field SchemaYear Year of the gamemode's schema | **integer**
-- @field AmericanDates Determines whether to use the American date format | **boolean**
-- @field AmericanTimeStamp Determines whether to use the American timestamp format | **boolean**
-- @field MinDescLen Minimum length required for a character's description | **integer**
-- @field AdminConsoleNetworkLogs Specifies if the logging system should replicate to admins' consoles | **boolean**
-- @field TimeToEnterVehicle Time **[in seconds]** required to enter a vehicle | **integer**
-- @field CarEntryDelayEnabled Determines if the car entry delay is applicable | **boolean**
-- @field Notify Contains notification sound and volume settings | **table**
-- @field Notify.Sound Notification sound file path | **string**
-- @field Notify.Volume Notification volume | **integer**
-- @field Notify.Pitch Notification pitch | **integer**
if not ConfigWasInitialized then
    lia.config = {
        WalkSpeed = 130,
        RunSpeed = 235,
        WalkRatio = 0.5,
        AllowExistNames = true,
        GamemodeName = "A Lilia Gamemode",
        Color = Color(103, 58, 183),
        Font = "Arial",
        Language = "english",
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
        MaxAttributePoints = 30,
        MaxStartingAttributes = 30,
        StartingAttributePoints = 30,
        EquipDelay = 2,
        UnequipDelay = 2,
        DropDelay = 2,
        TakeDelay = 0,
        CurrencySingularName = "Dollar",
        CurrencyPluralName = "Dollars",
        SchemaYear = 2023,
        AmericanDates = true,
        AmericanTimeStamp = true,
        MinDescLen = 16,
        AdminConsoleNetworkLogs = false,
        TimeToEnterVehicle = 1,
        CarEntryDelayEnabled = true,
        Notify = {"garrysmod/content_downloaded.wav", 50, 250},
    }

    hook.Run("InitializedConfig")
    ConfigWasInitialized = true
end

--- Retrieves a value from the configuration table.
-- @string key The configuration key to retrieve.
-- @param default The default value to return if the key is not found.
-- @return The value of the configuration key or the default value if the key is not found.
-- @realm shared
function lia.config.get(key, default)
    return lia.config[key] ~= nil and lia.config[key] or default
end
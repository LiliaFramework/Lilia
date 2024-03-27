--[[--
Configuration options for Lilia.

This module contains various configuration options used in the Lilia gamemode. Each option in the **lia.config** table serves a specific purpose and defines various aspects of the gamemode's functionality.

- **WalkSpeed**: Controls how fast characters walk | **[integer]**.
- **RunSpeed**: Controls how fast characters run | **[integer]**.
- **WalkRatio**: Defines the walk speed ratio when holding the Alt key | **[float]**.
- **AllowExistNames**: Determines whether duplicated character names are allowed | **[boolean]**.
- **GamemodeName**: Specifies the name of the gamemode | **[string]**.
- **Color**: Sets the theme color used throughout the gamemode | **[color]**.
- **Font**: Specifies the core font used for UI elements | **[string]**.
- **GenericFont**: Specifies the secondary font used for UI elements | **[string]**.
- **MoneyModel**: Defines the model used for representing money in the game | **[string]**.
- **MaxCharacters**: Sets the maximum number of characters per player | **[integer]**.
- **DataSaveInterval**: Time interval between data saves | **[integer]**.
- **CharacterDataSaveInterval**: Time interval between character data saves.
- **MoneyLimit**: Sets the limit of money a player can have **[0 for infinite] | **[integer]**.
- **invW**: Defines the width of the default inventory | **[integer]**.
- **invH**: Defines the height of the default inventory | **[integer]**.
- **DefaultMoney**: Specifies the default amount of money a player starts with | **[integer]**.
- **MaxChatLength**: Sets the maximum length of chat messages | **[integer]**.
- **CurrencySymbol**: Specifies the currency symbol used in the game | **[string]**.
- **SpawnTime**: Time to respawn after death | **[integer]**.
- **MaxAttributes**: Maximum attributes a character can have | **[integer]**.
- **CurrencySingularName**: Singular name of the in-game currency | **[string]**.
- **CurrencyPluralName**: Plural name of the in-game currency | **[string]**.
- **SchemaYear**: Year in the gamemode's schema | **[integer]**.
- **AmericanDates**: Determines whether to use the American date format | **[boolean]**.
- **AmericanTimeStamp**: Determines whether to use the American timestamp format | **[boolean]**.
- **MinDescLen**: Minimum length required for a character's description | **[integer]**.
- **TimeToEnterVehicle**: Time **[in seconds]** required to enter a vehicle | **[integer]**.
- **CarEntryDelayEnabled**: Determines if the car entry delay is applicable | **[boolean]**.
- **Notify**: Contains notification sound and volume settings | **[table]**.
  - **Notify[1]**: Notification sound file path | **[string]**.
  - **Notify[2]**: Notification volume | **[integer]**.
  - **Notify[3]**: Notification pitch | **[integer]**.

These configuration options control various aspects of the gamemode's mechanics, user interface, and gameplay experience.
]]
-- @module lia.config
local GM = GM or GAMEMODE
lia.config = lia.config or {}
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
        CurrencySingularName = "Dollar",
        CurrencyPluralName = "Dollars",
        SchemaYear = 2023,
        AmericanDates = true,
        AmericanTimeStamp = true,
        MinDescLen = 16,
        TimeToEnterVehicle = 1,
        CarEntryDelayEnabled = true,
        Notify = {"garrysmod/content_downloaded.wav", 50, 250},
    }

    hook.Run("InitializedConfig")
    ConfigWasInitialized = true
end

function GM:InitializedConfig()
    hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
end
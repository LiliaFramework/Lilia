--[[--
Configuration options for Lilia.

This module contains various configuration options used in the Lilia gamemode. Each option in the **lia.config** table serves a specific purpose and defines various aspects of the gamemode's functionality.

- **WalkSpeed**: **[integer]**Controls how fast characters walk.
- **RunSpeed**: **[integer]**Controls how fast characters run.
- **WalkRatio**: **[float]**Defines the walk speed ratio when holding the Alt key.
- **AllowExistNames**: **[boolean]**Determines whether duplicated character names are allowed.
- **GamemodeName**: **[string]**Specifies the name of the gamemode.
- **Color**: **[color]**Sets the theme color used throughout the gamemode.
- **Font**: **[string]**Specifies the core font used for UI elements.
- **GenericFont**: **[string]**Specifies the secondary font used for UI elements.
- **MoneyModel**: **[string]**Defines the model used for representing money in the game.
- **MaxCharacters**: **[integer]**Sets the maximum number of characters per player.
- **DataSaveInterval**: **[integer]**Time interval between data saves.
- **CharacterDataSaveInterval**: **[integer]**Time interval between character data saves.
- **MoneyLimit**: **[integer]**Sets the limit of money a player can have **[0 for infinite].
- **invW**: **[integer]**Defines the width of the default inventory.
- **invH**: **[integer]**Defines the height of the default inventory.
- **DefaultMoney**: **[integer]**Specifies the default amount of money a player starts with.
- **MaxChatLength**: **[integer]**Sets the maximum length of chat messages.
- **CurrencySymbol**: **[string]**Specifies the currency symbol used in the game.
- **SpawnTime**: **[integer]**Time to respawn after death.
- **MaxAttributes**: **[integer]**Maximum attributes a character can have.
- **CurrencySingularName**: **[string]**Singular name of the in-game currency.
- **CurrencyPluralName**: **[string]**Plural name of the in-game currency.
- **SchemaYear**: **[integer]**Year in the gamemode's schema.
- **AmericanDates**: **[boolean]**Determines whether to use the American date format.
- **AmericanTimeStamp**: **[boolean]**Determines whether to use the American timestamp format.
- **MinDescLen**: **[integer]**Minimum length required for a character's description.
- **TimeToEnterVehicle**: **[integer]**Time **[in seconds]**required to enter a vehicle.
- **CarEntryDelayEnabled**: **[boolean]**Determines if the car entry delay is applicable.
- **Notify**: **[table]**Contains notification sound and volume settings.
  - **Notify[1]**: **[string]**Notification sound file path.
  - **Notify[2]**: **[integer]**Notification volume.
  - **Notify[3]**: **[integer]**Notification pitch.

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
        Color = Color[34, 139, 34],
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

    hook.Run["InitializedConfig"]
    ConfigWasInitialized = true
end

function GM:InitializedConfig[]
    hook.Run["LoadLiliaFonts", lia.config.Font, lia.config.GenericFont]
end
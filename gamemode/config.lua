--------------------------------------------------------------------------------------------------------
lia.config = lia.config or {}
--------------------------------------------------------------------------------------------------------
lia.config = {
    -- General Gameplay Settings
    AmericanDates = true, -- American Date Formatting?
    AmericanTimeStamp = true, -- American Time Formatting?
    CarRagdoll = true, -- Enable car ragdolls
    HeadShotDamage = 2, -- Damage multiplier for headshots
    TimeUntilDroppedSWEPRemoved = 15, -- Time until dropped weapons are removed (in seconds)
    PlayerSpawnVehicleDelay = 30, -- Delay before players can spawn vehicles (in seconds)
    NPCsDropWeapons = true, -- NPCs drop weapons when killed
    DrawEntityShadows = true, -- Enable entity shadows
    WalkSpeed = 130, -- Player walk speed
    RunSpeed = 235, -- Player run speed
    CharacterSwitchCooldownTimer = 5, -- Cooldown timer for character switching (in seconds)
    CharacterSwitchCooldown = true, -- Enable character switch cooldown
    AutoRegen = false, -- Enable automatic health regeneration
    HealingAmount = 10, -- Amount of health regenerated per tick when AutoRegen is enabled
    HealingTimer = 60, -- Time interval between health regeneration ticks (in seconds)
    PermaClass = true, -- Enable permanent player classes
    -- Cleanup Settings
    MapCleanerEnabled = true, -- Enable map cleaning functionality
    ItemCleanupTime = 7200, -- Time interval for cleaning up items on the ground (in seconds)
    MapCleanupTime = 21600, -- Time interval for cleaning up maps (in seconds)
    -- Server Settings
    DevServerIP = "45.61.170.66", -- Development server IP address
    DevServerPort = "27270", -- Development server port
    -- Player Interaction Settings
    WalkRatio = 0.5, -- Walk speed ratio (used in certain interactions)
    SalaryOverride = true, -- Enable salary override
    SalaryInterval = 300, -- Salary interval (in seconds)
    TimeToEnterVehicle = 1, -- Time required to enter a vehicle (in seconds)
    JumpCooldown = 0.8, -- Cooldown time between jumps (in seconds)
    MaxAttributes = 30, -- Maximum number of player attributes
    AllowExistNames = true, -- Allow existing character names
    -- Communication and Interaction Settings
    FactionBroadcastEnabled = true, -- Enable faction broadcasts
    AdvertisementEnabled = true, -- Enable player advertisements
    AdvertisementPrice = 25, -- Price for player advertisements
    DefaultGamemodeName = "Lilia - Skeleton", -- Default server gamemode name
    -- Visual Settings
    Color = Color(75, 119, 190), -- Default color used for UI elements
    DarkTheme = true, -- Enable dark theme
    Font = "Arial", -- Default font used for UI elements
    GenericFont = "Segoe UI", -- Default generic font used for UI elements
    -- Inventory and Currency Settings
    WhitelistEnabled = false, -- Enable whitelist functionality
    MoneyModel = "models/props_lab/box01a.mdl", -- Model for in-game currency
    AutoWorkshopDownloader = false, -- Automatically download missing workshop content
    MaxCharacters = 5, -- Maximum number of characters per player
    invW = 6, -- Inventory width
    invH = 4, -- Inventory height
    DefaultMoney = 0, -- Default starting amount of in-game currency
    CurrencyPluralName = "Dollars", -- Plural name for in-game currency
    CurrencySingularName = "Dollar", -- Singular name for in-game currency
    CurrencySymbol = "$", -- Currency symbol
    -- Player Attribute Settings
    LoseWeapononDeathNPC = false, -- NPCs do not lose weapons on death
    LoseWeapononDeathHuman = false, -- Players do not lose weapons on death
    BranchWarning = true, -- Enable warnings for branching in code
    VersionEnabled = true, -- Enable version tracking
    version = "1.0", -- Server version
    -- Voice and Audio Settings
    AllowVoice = true, -- Enable voice communication
    CharAttrib = {
        "buttons/button16.wav", -- Character attribute settings
        30,
        255
    },
    -- UI and HUD Settings
    ThirdPersonEnabled = true, -- Enable third-person perspective
    CrosshairEnabled = false, -- Enable crosshair
    BarsDisabled = false, -- Disable certain UI bars
    AmmoDrawEnabled = true, -- Enable ammo drawing
    Vignette = true, -- Enable vignette effect
    CustomUIEnabled = true, -- Enable custom UI elements
    -- Talk Ranges
    TalkRanges = {
        ["Whispering"] = 120, -- Whispering talk range
        ["Talking"] = 300, -- Normal talking talk range
        ["Yelling"] = 600, -- Yelling talk range
    },
    -- Entities to Be Removed
    EntitiesToBeRemoved = {
        ["env_fire"] = true,
        ["trigger_hurt"] = true,
        ["prop_ragdoll"] = true,
        ["prop_physics"] = true,
        ["spotlight_end"] = true,
        ["light"] = true,
        ["point_spotlight"] = true,
        ["beam"] = true,
        ["env_sprite"] = true,
        ["light_spot"] = true,
        ["func_tracktrain"] = true,
        ["point_template"] = true,
    },
    -- Player Model T-posing Fixer
    PlayerModelTposingFixer = {
        ["models/player/Group03/female_03.mdl"] = "citizen_female",
        ["models/player/Group01/male_02.mdl"] = "citizen_male",
    },
    -- Default Staff Ranks
    DefaultStaff = {
        ["STEAMID"] = "RANK",
    },
    -- Restricted Entity List for PhysGun
    PhysGunMoveRestrictedEntityList = {"prop_door_rotating", "lia_vendor"},
    -- Blocked Entities for Remover Tool
    RemoverBlockedEntities = {"lia_bodygroupcloset", "lia_vendor",},
    -- Blacklisted Entities for Duplicator Tool
    DuplicatorBlackList = {"lia_storage", "lia_money"},
    -- Blocked Collide Entities
    BlockedCollideEntities = {"lia_item", "lia_money"},
    -- Restricted Vehicles
    RestrictedVehicles = {},
    -- Unloaded Plugins
    UnLoadedPlugins = {
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
    },
}

hook.Run("InitializedConfig")
--------------------------------------------------------------------------------------------------------
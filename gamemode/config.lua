--------------------------------------------------------------------------------------------------------
lia.config = lia.config or {}
--------------------------------------------------------------------------------------------------------
if not lia.config.WasInitialized then
    lia.config = {
        -- General Gameplay Settings
        EquipDelay = 1, -- Delay OnEquip
        DropDelay = 1, -- Delay OnDrop
        TakeDelay = 1, -- Delay OnTake
        SchemaYear = 2023, -- Year When Schema Happens
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
        CharAttrib = {"buttons/button16.wav", 30, 255},
        -- Character attribute settings -- UI and HUD Settings
        ThirdPersonEnabled = true, -- Enable third-person perspective
        CrosshairEnabled = false, -- Enable crosshair
        BarsDisabled = false, -- Disable certain UI bars
        AmmoDrawEnabled = true, -- Enable ammo drawing
        Vignette = true, -- Enable vignette effect
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
            inventory = false,
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
        CAMIPrivileges = {
            {
                Name = "Lilia - Management - Admin Chat",
                MinAccess = "admin",
                Description = "Allows access to Admin Chat.",
            },
            {
                Name = "Lilia - Management - One Punch Man",
                MinAccess = "superadmin",
                Description = "Allows access to OPM to Ragdoll Minges.",
            },
            {
                Name = "Lilia - Management - Can Spawn Ragdolls",
                MinAccess = "admin",
                Description = "Allows access to spawning ."
            },
            {
                Name = "Lilia - Management - Can Spawn SWEPs",
                MinAccess = "superadmin",
                Description = "Allows access to spawning SWEPs."
            },
            {
                Name = "Lilia - Management - Can Spawn Effects",
                MinAccess = "admin",
                Description = "Allows access to spawning Effects."
            },
            {
                Name = "Lilia - Management - Can Spawn Props",
                MinAccess = "user",
                Description = "Allows access to spawning Props."
            },
            {
                Name = "Lilia - Management - Can Spawn NPCs",
                MinAccess = "superadmin",
                Description = "Allows access to spawning NPCs."
            },
            {
                Name = "Lilia - Management - Physgun Pickup",
                MinAccess = "admin",
                Description = "Allows access to picking up entities with Physgun."
            },
            {
                Name = "Lilia - Management - Physgun Pickup on Restricted Entities",
                MinAccess = "superadmin",
                Description = "Allows access to picking up restricted entities with Physgun."
            },
            {
                Name = "Lilia - Management - Physgun Pickup on Vehicles",
                MinAccess = "admin",
                Description = "Allows access to picking up Vehicles with Physgun."
            },
            {
                Name = "Lilia - Management - Use Entity Properties on Blocked Entities",
                MinAccess = "admin",
                Description = "Allows access to using Entity Properties on Blocked Entities."
            },
            {
                Name = "Lilia - Management - Can Remove Blocked Entities",
                MinAccess = "admin",
                Description = "Allows access to removing blocked entities."
            },
            {
                Name = "Lilia - Management - Can Spawn Cars",
                MinAccess = "admin",
                Description = "Allows access to Spawning Cars."
            },
            {
                Name = "Lilia - Management - Can Spawn Restricted Cars",
                MinAccess = "superadmin",
                Description = "Allows access to Spawning Restricted Cars."
            },
            {
                Name = "Lilia - Management - Can Spawn SENTs",
                MinAccess = "admin",
                Description = "Allows access to Spawning SENTs."
            },
        },
        StartupConsoleCommand = {
            ["cl_resend"] = "11",
            ["cl_jiggle_bone_framerate_cutoff"] = "4",
            ["ragdoll_sleepaftertime"] = "40.0f",
            ["cl_timeout"] = "3000",
            ["gmod_mcore_test"] = "1",
            ["r_shadows"] = "0",
            ["cl_detaildist"] = "0",
            ["cl_threaded_client_leaf_system"] = "1",
            ["cl_threaded_bone_setup"] = "2",
            ["r_threaded_renderables"] = "1",
            ["r_threaded_particles"] = "1",
            ["r_queued_ropes"] = "1",
            ["r_queued_decals"] = "1",
            ["r_queued_post_processing"] = "1",
            ["r_threaded_client_shadow_manager"] = "1",
            ["studio_queue_mode"] = "1",
            ["mat_queue_mode"] = "-2",
            ["fps_max"] = "0",
            ["fov_desired"] = "100",
            ["mat_specular"] = "0",
            ["r_drawmodeldecals"] = "0",
            ["r_lod"] = "-1",
            ["lia_cheapblur"] = "1",
        },
        RemovableHooks = {
            ["StartChat"] = {"StartChatIndicator",},
            ["FinishChat"] = {"EndChatIndicator",},
            ["PostPlayerDraw"] = {"DarkRP_ChatIndicator",},
            ["CreateClientsideRagdoll"] = {"DarkRP_ChatIndicator",},
            ["player_disconnect"] = {"DarkRP_ChatIndicator",},
            ["PostDrawEffects"] = {"RenderWidgets", "RenderHalos",},
            ["PlayerTick"] = {"TickWidgets",},
            ["PlayerInitialSpawn"] = {"PlayerAuthSpawn",},
            ["RenderScene"] = {"RenderStereoscopy", "RenderSuperDoF",},
            ["LoadGModSave"] = {"LoadGModSave",},
            ["RenderScreenspaceEffects"] = {"RenderColorModify", "RenderBloom", "RenderToyTown", "RenderTexturize", "RenderSunbeams", "RenderSobel", "RenderSharpen", "RenderMaterialOverlay", "RenderMotionBlur", "RenderBokeh",},
            ["GUIMousePressed"] = {"SuperDOFMouseDown",},
            ["GUIMouseReleased"] = {"SuperDOFMouseUp",},
            ["PreventScreenClicks"] = {"SuperDOFPreventClicks",},
            ["PostRender"] = {"RenderFrameBlend",},
            ["PreRender"] = {"PreRenderFrameBlend",},
            ["Think"] = {"DOFThink",},
            ["NeedsDepthPass"] = {"NeedsDepthPass_Bokeh",},
        },
        ServerURLs = {
            ["Discord"] = "https://discord.gg/52MSnh39vw",
            ["Workshop"] = "https://steamcommunity.com/sharedfiles/filedetails/?id=2959728255"
        },
    }
end

lia.config.WasInitialized = true
hook.Run("InitializedConfig")
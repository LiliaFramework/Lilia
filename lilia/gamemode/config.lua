--------------------------------------------------------------------------------------------------------------------------
lia.config = lia.config or {}
--------------------------------------------------------------------------------------------------------------------------
if not lia.config.WasInitialized then
    lia.config = {
        -- General Gameplay Settings
        EquipDelay = 2, -- Delay OnEquip
        DropDelay = 2, -- Delay OnDrop
        TakeDelay = 2, -- Delay OnTake
        SchemaYear = 2023, -- Year When Schema Happens
        AmericanDates = true, -- American Date Formatting?
        AmericanTimeStamp = true, -- American Time Formatting?
        CarRagdoll = true, -- Enable car ragdolls
        KickOnEnteringMainMenu = true, -- Do you get kicked when going into the Characters Menu?
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
        DevServer = false, -- Is it a Development Server?
        -- Player Interaction Settings
        WalkRatio = 0.5, -- Walk speed ratio (used in certain interactions)
        SalaryInterval = 300, -- Salary interval (in seconds)
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
        LoseWeapononDeathWorld = false, -- Players do not lose weapons on word related deaths
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
        PlayerModelTposingFixer = {"models/player/Group03/female_03.mdl", "models/player/Group01/male_02.mdl", "models/player/player.mdl",},
        -- Default Staff Ranks
        DefaultStaff = {
            ["STEAMID"] = "RANK",
        },
        -- Restricted Prop List
        BlackListedProps = {"models/props_combine/combinetrain02b.mdl", "models/props_combine/combinetrain02a.mdl", "models/props_combine/combinetrain01.mdl", "models/cranes/crane_frame.mdl", "models/props_wasteland/cargo_container01.mdl", "models/props_junk/trashdumpster02.mdl", "models/props_c17/oildrum001_explosive.mdl", "models/props_canal/canal_bridge02.mdl", "models/props_canal/canal_bridge01.mdl", "models/props_canal/canal_bridge03a.mdl", "models/props_canal/canal_bridge03b.mdl", "models/props_wasteland/cargo_container01.mdl", "models/props_wasteland/cargo_container01c.mdl", "models/props_wasteland/cargo_container01b.mdl", "models/props_combine/combine_mine01.mdl", "models/props_junk/glassjug01.mdl", "models/props_c17/paper01.mdl", "models/props_junk/garbage_takeoutcarton001a.mdl", "models/props_c17/trappropeller_engine.mdl", "models/props/cs_office/microwave.mdl", "models/items/item_item_crate.mdl", "models/props_junk/gascan001a.mdl", "models/props_c17/consolebox01a.mdl", "models/props_buildings/building_002a.mdl", "models/props_phx/mk-82.mdl", "models/props_phx/cannonball.mdl", "models/props_phx/ball.mdl", "models/props_phx/amraam.mdl", "models/props_phx/misc/flakshell_big.mdl", "models/props_phx/ww2bomb.mdl", "models/props_phx/torpedo.mdl", "models/props/de_train/biohazardtank.mdl", "models/props_buildings/project_building01.mdl", "models/props_combine/prison01c.mdl", "models/props/cs_militia/silo_01.mdl", "models/props_phx/huge/evildisc_corp.mdl", "models/props_phx/misc/potato_launcher_explosive.mdl", "models/props_combine/combine_citadel001.mdl", "models/props_phx/oildrum001_explosive.mdl"},
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
        -- Unloaded Modules
        UnLoadedModules = {
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
                Name = "Lilia - Staff Permissions - Admin Chat",
                MinAccess = "admin",
                Description = "Allows access to Admin Chat.",
            },
            {
                Name = "Lilia - Staff Permissions - One Punch Man",
                MinAccess = "superadmin",
                Description = "Allows access to OPM to Ragdoll Minges.",
            },
            {
                Name = "Lilia - Spawn Permissions - Can Spawn Ragdolls",
                MinAccess = "admin",
                Description = "Allows access to spawning ."
            },
            {
                Name = "Lilia - Spawn Permissions - Can Spawn SWEPs",
                MinAccess = "superadmin",
                Description = "Allows access to spawning SWEPs."
            },
            {
                Name = "Lilia - Spawn Permissions - Can Spawn Effects",
                MinAccess = "admin",
                Description = "Allows access to spawning Effects."
            },
            {
                Name = "Lilia - Spawn Permissions - Can Spawn Props",
                MinAccess = "user",
                Description = "Allows access to spawning Props."
            },
            {
                Name = "Lilia - Spawn Permissions - Can Spawn NPCs",
                MinAccess = "superadmin",
                Description = "Allows access to spawning NPCs."
            },
            {
                Name = "Lilia - Staff Permissions - Physgun Pickup",
                MinAccess = "admin",
                Description = "Allows access to picking up entities with Physgun."
            },
            {
                Name = "Lilia - Staff Permissions - Physgun Pickup on Restricted Entities",
                MinAccess = "superadmin",
                Description = "Allows access to picking up restricted entities with Physgun."
            },
            {
                Name = "Lilia - Staff Permissions - Physgun Pickup on Vehicles",
                MinAccess = "admin",
                Description = "Allows access to picking up Vehicles with Physgun."
            },
            {
                Name = "Lilia - Staff Permissions - Use Entity Properties on Blocked Entities",
                MinAccess = "admin",
                Description = "Allows access to using Entity Properties on Blocked Entities."
            },
            {
                Name = "Lilia - Staff Permissions - Can Remove Blocked Entities",
                MinAccess = "admin",
                Description = "Allows access to removing blocked entities."
            },
            {
                Name = "Lilia - Spawn Permissions - No Spawn Delay",
                MinAccess = "admin",
                Description = "Allows a user to not have spawn delay."
            },
            {
                Name = "Lilia - Spawn Permissions - Can Spawn Cars",
                MinAccess = "admin",
                Description = "Allows access to Spawning Cars."
            },
            {
                Name = "Lilia - UserGroups - Staff Group",
                MinAccess = "admin",
                Description = "Defines Player as Staff."
            },
            {
                Name = "Lilia - UserGroups - VIP Group",
                MinAccess = "superadmin",
                Description = "Defines Player as VIP."
            },
            {
                Name = "Lilia - Staff Permissions - Local Event Chat",
                MinAccess = "admin",
                Description = "Allows access to Local Event Chat."
            },
            {
                Name = "Lilia - Staff Permissions - Event Chat",
                MinAccess = "admin",
                Description = "Allows access to Event Chat."
            },
            {
                Name = "Lilia - Spawn Permissions - Can Spawn Restricted Cars",
                MinAccess = "superadmin",
                Description = "Allows access to Spawning Restricted Cars."
            },
            {
                Name = "Lilia - Spawn Permissions - Can Spawn SENTs",
                MinAccess = "admin",
                Description = "Allows access to Spawning SENTs."
            },
        },
        StormFox2ConsoleCommands = {
            ["sf_time_speed"] = "1",
            ["sf_addnight_temp"] = "4",
            ["sf_windmove_props"] = "0",
            ["sf_windmove_props_break"] = "0",
            ["sf_windmove_props_unfreeze"] = "0",
            ["sf_windmove_props_unweld"] = "0",
            ["sf_windmove_props_makedebris"] = "0",
        },
        VJBaseConsoleCommands = {
            ["vj_npc_processtime"] = "1",
            ["vj_npc_corpsefade"] = "1",
            ["vj_npc_corpsefadetime"] = "5",
            ["vj_npc_nogib"] = "1",
            ["vj_npc_nosnpcchat"] = "1",
            ["vj_npc_slowplayer"] = "1",
            ["vj_npc_noproppush"] = "1",
            ["vj_npc_nothrowgrenade"] = "1",
            ["vj_npc_fadegibstime"] = "5",
            ["vj_npc_knowenemylocation"] = "1",
            ["vj_npc_dropweapon"] = "0",
            ["vj_npc_plypickupdropwep"] = "0",
        },
        TFAConsoleCommands = {
            ["cl_tfa_hud_crosshair_enable_custom"] = "0",
            ["cl_tfa_hud_hitmarker_scale"] = "0.5",
            ["cl_tfa_hud_hitmarker_color_r"] = "255",
            ["cl_tfa_hud_hitmarker_color_g"] = "178",
            ["cl_tfa_hud_hitmarker_color_b"] = "0",
            ["cl_tfa_hud_hitmarker_color_a"] = "200",
            ["cl_tfa_fx_gasblur"] = "0",
            ["cl_tfa_fx_muzzlesmoke"] = "0",
            ["cl_tfa_fx_ejectionsmoke"] = "0",
            ["cl_tfa_fx_impact_enabled"] = "0",
        },
        ArcCWConsoleCommands = {
            ["arccw_override_crosshair_off"] = "0",
            ["arccw_crosshair"] = "1",
            ["arccw_shake"] = "0",
            ["arccw_vm_bob_sprint"] = "2.80",
            ["arccw_vm_sway_sprint"] = "1.85",
            ["arccw_vm_right"] = "1.16",
            ["arccw_vm_forward"] = "3.02",
            ["arccw_vm_up"] = "0",
            ["arccw_vm_lookxmult"] = "-2.46",
            ["arccw_vm_lookymult"] = "7",
            ["arccw_vm_accelmult"] = "0.85",
            ["arccw_crosshair_clr_a"] = "61",
            ["arccw_crosshair_clr_b"] = "255",
            ["arccw_crosshair_clr_g"] = "242",
            ["arccw_crosshair_clr_r"] = "0",
            ["arccw_crosshair_outline"] = "0",
            ["arccw_crosshair_shotgun"] = "1",
        },
        ServerStartupConsoleCommand = {
            ["ai_serverragdolls"] = "1",
            ["mem_max_heapsize"] = "131072",
            ["mem_max_heapsize_dedicated"] = "131072",
            ["mem_min_heapsize"] = "131072",
            ["threadpool_affinity"] = "64",
            ["decalfrequency"] = "10",
            ["gmod_physiterations"] = "2",
            ["sv_minrate"] = "1048576",
            ["mat_antialias"] = "2",
        },
        ClientStartupConsoleCommand = {
            ["fast_fogvolume"] = "0",
            ["mat_managedtextures"] = "1",
            ["net_maxpacketdrop"] = "5000",
            ["net_chokeloop"] = "0",
            ["net_splitpacket_maxrate"] = "1048576",
            ["net_compresspackets_minsize"] = "1024",
            ["net_maxfragments"] = "1260",
            ["net_maxfilesize"] = "16",
            ["net_maxcleartime"] = "4",
            ["cl_lagcompensation"] = "0",
            ["cl_timeout"] = "30",
            ["cl_smoothtime"] = "0.1",
            ["cl_localnetworkbackdoor"] = "0",
            ["cl_cmdrate"] = "30",
            ["cl_updaterate"] = "20",
            ["ai_expression_optimization"] = "1",
            ["filesystem_max_stdio_read"] = "64",
            ["in_usekeyboardsampletime"] = "1",
            ["r_radiosity"] = "4",
            ["rate"] = "1048576",
            ["filesystem_unbuffered_io"] = "1",
            ["snd_mix_async"] = "0",
            ["snd_async_fullyasync"] = "0",
            ["snd_async_minsize"] = "262144",
            ["cl_forcepreload"] = "0",
            ["cl_playerspraydisable"] = "1",
            ["pac_debug_clmdl"] = "1",
            ["cl_resend"] = "11",
            ["cl_jiggle_bone_framerate_cutoff"] = "4",
            ["ragdoll_sleepaftertime"] = "40.0f",
            ["cl_timeout"] = "3000",
            ["gmod_mcore_test"] = "1",
            ["r_shadows"] = "1",
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
            ["mat_queue_mode"] = "2",
            ["fov_desired"] = "100",
            ["mat_specular"] = "0",
            ["r_drawmodeldecals"] = "0",
            ["r_lod"] = "-1",
            ["lia_cheapblur"] = "1",
        },
        ToolRequiresEntity = {"rb655_easy_bodygroup", "eyeposer", "remover", "thruster", "weld", "nocollide", "simfphyseditor", "simfphysduplicator", "colour", "precision", "stacker_improved", "advmat", "permaprops", "inflator", "physprop", "simfphyswheeleditor", "simfphysfueleditor", "paint", "simfphysgeareditor", "simfphyssuspensioneditor", "finger", "editentity", "material", "duplicator", "advdupe2", "simfphyssoundeditor", "faceposer", "simfphysmiscsoundeditor",},
        RemovableHooks = {
            ["StartChat"] = {"StartChatIndicator",},
            ["FinishChat"] = {"EndChatIndicator",},
            ["PostPlayerDraw"] = {"DarkRP_ChatIndicator",},
            ["CreateClientsideRagdoll"] = {"DarkRP_ChatIndicator",},
            ["player_disconnect"] = {"DarkRP_ChatIndicator",},
            ["PostDrawEffects"] = {"RenderWidgets", "RenderHalos",},
            ["PlayerTick"] = {"TickWidgets",},
            ["PlayerSay"] = {"ULXMeCheck",},
            ["OnEntityCreated"] = {"WidgetInit",},
            ["PlayerInitialSpawn"] = {"PlayerAuthSpawn", "VJBaseSpawn"},
            ["RenderScene"] = {"RenderStereoscopy", "RenderSuperDoF",},
            ["LoadGModSave"] = {"LoadGModSave",},
            ["RenderScreenspaceEffects"] = {"RenderColorModify", "RenderBloom", "RenderToyTown", "RenderTexturize", "RenderSunbeams", "RenderSobel", "RenderSharpen", "RenderMaterialOverlay", "RenderMotionBlur", "RenderBokeh",},
            ["GUIMousePressed"] = {"SuperDOFMouseDown",},
            ["GUIMouseReleased"] = {"SuperDOFMouseUp",},
            ["PreventScreenClicks"] = {"SuperDOFPreventClicks",},
            ["PostRender"] = {"RenderFrameBlend",},
            ["PreRender"] = {"PreRenderFrameBlend",},
            ["Think"] = {"DOFThink", "CheckSchedules"},
            ["NeedsDepthPass"] = {"NeedsDepthPass_Bokeh",},
        },
        ClientTimersToRemove = {"HintSystem_OpeningMenu", "HintSystem_Annoy1", "HintSystem_Annoy2", "HostnameThink", "CheckHookTimes"},
        ServerTimersToRemove = {"HostnameThink", "CheckHookTimes",},
        NoDrawCrosshairWeapon = {"weapon_crowbar", "weapon_stunstick", "weapon_bugbait",},
        ServerURLs = {
            ["Discord"] = "https://discord.gg/52MSnh39vw",
            ["Workshop"] = "https://steamcommunity.com/sharedfiles/filedetails/?id=2959728255"
        },
    }
end

lia.config.WasInitialized = true
hook.Run("InitializedConfig")

--------------------------------------------------------------------------------------------------------
function lia.config.LoadCore()
    lia.currency.singular = "Dollar"
    lia.currency.plural = "Dollars"
    lia.currency.symbol = "$"
    lia.config.version = "1.0"
    lia.config.MaxAttributes = 30
    lia.config.DefaultGamemodeName = "Lilia - Skeleton"
    lia.config.Color = Color(75, 119, 190)
    lia.config.VersionEnabled = true
    lia.config.DarkTheme = true
    lia.config.Font = "Arial"
    lia.config.GenericFont = "Segoe UI"
    lia.config.WhitelistEnabled = false
    lia.config.MoneyModel = "models/props_lab/box01a.mdl"
    lia.config.BranchWarning = true
    lia.config.AllowVoice = true
    lia.config.AutoWorkshopDownloader = false

    lia.config.DefaultStaff = {
        ["STEAM_0:1:176123778"] = "superadmin",
    }


    lia.config.MaxCharacters = 5
    lia.config.SalaryOverride = true
    lia.config.SalaryInterval = 300
    lia.config.invW = 6
    lia.config.invH = 4
    lia.config.WalkSpeed = 130
    lia.config.RunSpeed = 235
    lia.config.WalkRatio = 0.5
    lia.config.DefaultMoney = 0

    lia.config.Ranges = {
        ["Whispering"] = 120,
        ["Talking"] = 300,
        ["Yelling"] = 600,
    }

    lia.config.RestrictedVehicles = {"sim_fphys_chaos126p", "sim_fphys_hedgehog", "sim_fphys_ratmobile", "sim_fphys_tank2", "sim_fphys_tank", "sim_fphys_conscriptapc_armed", "sim_fphys_combineapc_armed", "sim_fphys_jeep_armed2", "sim_fphys_jeep_armed", "sim_fphys_tank3", "sim_fphys_v8elite_armed2", "sim_fphys_v8elite_armed", "sim_fphys_tank4", "sim_fphys_couch", "sim_fphys_couch", "sim_fphys_tank_sdkfz_halftrack", "sim_fphys_opel_blitz_ww2", "gred_simfphys_panzerivd", "gred_simfphys_panzerivf1", "gred_simfphys_panzerivf2", "sim_fphys_pwavia", "sim_fphys_pwgaz52", "sim_fphys_pwhatchback", "sim_fphys_pwhatchback", "sim_fphys_pwmoskvich", "sim_fphys_pwtrabant", "sim_fphys_pwtrabant02", "sim_fphys_pwvan", "sim_fphys_pwvolga", "sim_fphys_pwzaz", "sim_fphys_conscriptapc", "sim_fphys_combineapc", "sim_fphys_jeep", "sim_fphys_jalopy", "sim_fphys_v8elite", "sim_fphys_van", "sim_fphys_chaos126p", "sim_fphys_hedgehog", "sim_fphys_ratmobile", "sim_fphys_tank2", "sim_fphys_tank", "sim_fphys_conscriptapc_armed", "sim_fphys_combineapc_armed", "sim_fphys_jeep_armed2", "sim_fphys_jeep_armed", "sim_fphys_tank3", "sim_fphys_v8elite_armed2", "sim_fphys_v8elite_armed", "sim_fphys_tank4", "sim_fphys_couch", "sim_fphys_dukes", "sim_fphys_tank_sdkfz_halftrack", "sim_fphys_opel_blitz_ww2", "gred_simfphys_panzerivd", "gred_simfphys_panzerivf1", "gred_simfphys_panzerivf2", "sim_fphys_pwavia", "sim_fphys_pwgaz52", "sim_fphys_pwhatchback", "sim_fphys_pwliaz", "sim_fphys_pwmoskvich", "sim_fphys_pwtrabant", "sim_fphys_pwtrabant02", "sim_fphys_pwvan", "sim_fphys_pwvolga", "sim_fphys_pwzaz", "sim_fphys_conscriptapc", "sim_fphys_combineapc", "sim_fphys_jeep", "sim_fphys_jalopy", "sim_fphys_v8elite", "sim_fphys_van", "gred_simfphys_panzerivd", "avx_t-34-85", "sim_fphys_chaos126p", "sim_fphys_hedgehog", "sim_fphys_ratmobile", "sim_fphys_tank2", "sim_fphys_tank", "sim_fphys_conscriptapc_armed", "sim_fphys_combineapc_armed", "sim_fphys_jeep_armed2", "sim_fphys_jeep_armed", "sim_fphys_tank3", "sim_fphys_v8elite_armed2", "sim_fphys_v8elite_armed", "sim_fphys_tank4", "sim_fphys_couch", "sim_fphys_dukes", "sim_fphys_conscriptapc", "sim_fphys_combineapc", "sim_fphys_jeep", "sim_fphys_jalopy", "sim_fphys_v8elite", "sim_fphys_van", "gred_panzerivd", "gred_simfphys_panzerivf1", "gred_simfphys_panzerivf2", "T34rp", "t34_76rp", "T34_85rp", "T34", "t34_76", "sdkfz_234", "ps_sdkfz_251_armed", "gb_bomb_cbu", "gb_bomb_1000gp", "gb_bomb_2000gp", "gb_bomb_fab250", "gb_bomb_gbu12", "gb_bomb_250gp", "gb_bomb_500gp", "gb_bomb_gbu38", "gb_bomb_mk77", "gb_bomb_mk82", "gb_bomb_sc100", "gb_bomb_sc1000", "gb_bomb_sc250", "gb_bomb_sc500", "gb_rocket_hvar", "gb_rocket_hydra", "gb_rocket_nebel", "gb_rocket_rp3", "gb_rocket_v1", "gred_ammobox", "sdkfz", "sdkfz2w", "sim_fphys_tank2", "Airboat", "Jeep", "Pod", "sim_fphys_chaos126p", "sim_fphys_hedgehog", "sim_fphys_ratmobile", "sim_fphys_tank2", "sim_fphys_tank", "sim_fphys_conscriptapc_armed", "sim_fphys_combineapc_armed", "sim_fphys_jeep_armed2", "sim_fphys_jeep_armed", "sim_fphys_tank3", "sim_fphys_v8elite_armed2", "sim_fphys_v8elite_armed", "sim_fphys_tank4", "sim_fphys_couch", "sim_fphys_dukes", "sim_fphys_tank_sdkfz_halftrack", "sim_fphys_opel_blitz_ww2", "gred_simfphys_panzerivd", "gred_simfphys_panzerivf1", "gred_simfphys_panzerivf2", "sim_fphys_pwavia", "sim_fphys_pwgaz52", "sim_fphys_pwhatchback", "sim_fphys_pwhatchback", "sim_fphys_pwmoskvich", "sim_fphys_pwtrabant", "sim_fphys_pwtrabant02", "sim_fphys_pwvan", "sim_fphys_pwvolga", "sim_fphys_pwzaz", "sim_fphys_conscriptapc", "sim_fphys_conscriptapc", "sim_fphys_jeep", "sim_fphys_jalopy ", "sim_fphys_v8elite", "sim_fphys_van", "T34_85"}

    lia.config.PropBlacklist = {"models/opelww2/ww2_opel_blitz.mdl", "models/w150.mdl", "models/track_test2.mdl", "models/track_test.mdl", "models/willys_cod.mdl", "models/comradebear/veh/ww2/fra/simca5.mdl", "models/comradebear/veh/ww2/ger/mercedes/_g4/_w31.mdl", "models/comradebear/veh/ww2/ger/mercedes/_g4/_w31_frontwheel.mdl", "models/comradebear/veh/ww2/ger/opelomnibus.mdl", "models/comradebear/veh/ww2/ger/opelomnibus_frontwheel.mdl", "models/comradebear/veh/ww2/ger/opelomnibus_rearwheel.mdl", "models/comradebear/veh/ww2/usa/cckw6x6.mdl", "models/comradebear/veh/ww2/usa/cckw6x6_frontwheel.mdl", "models/comradebear/veh/ww2/usa/cckw6x6_rearwheel.mdl", "models/indian/codww2_indian.mdl", "models/william/bussing_nag.mdl", "models/william/wc54.mdl", "models/sdkfz_9.mdl", "models/sdfkz/_10/_3.mdl", "models/sdfkz/_10/_2.mdl", "models/sdfkz_10.mdl", "models/m3_halftrack.mdl", "models/kettenkrad_2.mdl", "models/codww2vw38.mdl", "models/codww2ss100.mdl", "models/codww2peugeottruck.mdl", "models/codww2kubelwagen_2.mdl", "models/codww2kubelwagen.mdl", "models/codww2fiat_orpo.mdl", "models/codww2bussingnag_tow.mdl", "models/codww2boxer_tractor2.mdl", "models/codww2boxer_tractor.mdl", "models/codww2blitz_fuel.mdl", "models/codww2blitz/_civ/_fb.mdl", "models/codww2blitz_civ2.mdl", "models/codww2blitz_civ.mdl", "models/codww2blitz.mdl", "models/codww2_renault.mdl", "models/codww2_opelkadett.mdl", "models/citroenu23_v2.mdl", "models/citroen_traction.mdl", "models/props_c17/trappropeller_blade.mdl", "models/props_junk/propane_tank001a.mdl", "models/props_phx/cannonball.mdl", "models/gbombs/2501bgp.mdl", "models/gbombs/bomb_jdam.mdl", "models/xqm/jetbody3_s2.mdl", "models/hunter/blocks/cube8x8x8.mdl", "models/props_junk/gascan001a.mdl", "models/props_junk/propane_tank001a.mdl", "models/props_canal/canal_bridge01.mdl", "models/props_canal/canal_bridge02.mdl", "models/props_canal/canal_bridge03a.mdl", "models/props_canal/canal_bridge03b.mdl", "models/props_c17/oildrum001_explosive.mdl", "models/props_canal/canal_bridge04.mdl", "models/props_citizen_tech/windmill_blade002a.mdl", "models/props_citizen_tech/windmill_blade004a.mdl", "models/xqm/jetbody3.mdl", "models/xqm/jetbody2.mdl", "models/xqm/jetbody1.mdl", "models/xqm/jetbody.mdl", "models/doi/ty_missile.mdl", "models/combine_helicopter/helicopter_bomb01.mdl", "models/william/smoke_shell.mdl", "models/grendwitch/granatwerfer_tube.mdl", "models/props_vehicles/car005a_physics.mdl", "models/mikeprops/reichpillars1.mdl", "models/combine_helicopter/helicopter_bomb01.mdl", "models/items/item_item_crate.mdl", "models/props/cs_militia/silo_01.mdl", "models/props/cs_office/microwave.mdl", "models/props/de_train/biohazardtank.mdl", "models/props_buildings/building_002a.mdl", "models/props_buildings/collapsedbuilding01a.mdl", "models/props_buildings/project_building01.mdl", "models/props_buildings/project_building02.mdl", "models/props_buildings/project_building03.mdl", "models/props_buildings/project_destroyedbuildings01.mdl", "models/props_buildings/row_church_fullscale.mdl", "models/props_buildings/row_corner_1_fullscale.mdl", "models/props_buildings/row_res_1_fullscale.mdl", "models/props_buildings/row_res_2_ascend_fullscale.mdl", "models/props_buildings/row_res_2_fullscale.mdl", "models/props_c17/consolebox01a.mdl", "models/props_c17/oildrum001_explosive.mdl", "models/props_c17/paper01.mdl", "models/props_c17/trappropeller_engine.mdl", "models/props_canal/canal_bridge01.mdl", "models/props_canal/canal_bridge02.mdl", "models/props_canal/canal_bridge03a.mdl", "models/props_canal/canal_bridge03b.mdl", "models/props_combine/combine_citadel001.mdl", "models/props_combine/combine_mine01.mdl", "models/props_combine/combinetrain01.mdl", "models/props_combine/combinetrain02a.mdl", "models/props_combine/combinetrain02b.mdl", "models/props_combine/prison01.mdl", "models/props_combine/prison01b.mdl", "models/props_combine/prison01c.mdl", "models/props_industrial/bridge.mdl", "models/props_junk/garbage_takeoutcarton001a.mdl", "models/props_junk/gascan001a.mdl", "models/props_junk/glassjug01.mdl", "models/props_junk/trashdumpster02.mdl", "models/props_phx/amraam.mdl", "models/props_phx/ball.mdl", "models/props_phx/cannonball.mdl", "models/props_phx/huge/evildisc_corp.mdl", "models/props_phx/misc/flakshell_big.mdl", "models/props_phx/misc/potato_launcher_explosive.mdl", "models/props_phx/mk-82.mdl", "models/props_phx/oildrum001_explosive.mdl", "models/props_phx/torpedo.mdl", "models/props_phx/ww2bomb.mdl", "models/props_wasteland/cargo_container01.mdl", "models/props_wasteland/cargo_container01.mdl", "models/props_wasteland/cargo_container01b.mdl", "models/props_wasteland/cargo_container01c.mdl", "models/props_wasteland/depot.mdl", "models/xqm/coastertrack/special_full_corkscrew_left_4.mdl", "models/props_junk/propane_tank001a.mdl", "Models/props_c17/metalladder003.mdl", "models/props_c17/oildrum001_explosive.mdl", "models/props_phx/oildrum001_explosive.mdl", "models/props_combine/combinetrain02b.mdl", "models/props_combine/combinetrain02a.mdl", "models/props_combine/combinetrain01.mdl", "models/cranes/crane_frame.mdl", "models/props_wasteland/cargo_container01.mdl", "models/props_junk/trashdumpster02.mdl", "models/props_c17/oildrum001_explosive.mdl", "models/props_canal/canal_bridge02.mdl", "models/props_canal/canal_bridge01.mdl", "models/props_canal/canal_bridge03a.mdl", "models/props_canal/canal_bridge03b.mdl", "models/props_wasteland/cargo_container01.mdl", "models/props_wasteland/cargo_container01c.mdl", "models/props_wasteland/cargo_container01b.mdl", "models/props_combine/combine_mine01.mdl", "models/props_junk/glassjug01.mdl", "models/props_c17/paper01.mdl", "models/props_junk/garbage_takeoutcarton001a.mdl", "models/props_c17/trappropeller_engine.mdl", "models/props/cs_office/microwave.mdl", "models/items/item_item_crate.mdl", "models/props_junk/gascan001a.mdl", "models/props_c17/consolebox01a.mdl", "models/props_buildings/building_002a.mdl", "models/props_phx/mk-82.mdl", "models/props_phx/cannonball.mdl", "models/props_phx/ball.mdl", "models/props_phx/amraam.mdl", "models/props_phx/misc/flakshell_big.mdl", "models/props_phx/ww2bomb.mdl", "models/props_phx/torpedo.mdl", "models/props/de_train/biohazardtank.mdl", "models/props_buildings/project_building01.mdl", "models/props_combine/prison01c.mdl", "models/props/cs_militia/silo_01.mdl", "models/props_phx/huge/evildisc_corp.mdl", "models/props_phx/misc/potato_launcher_explosive.mdl", "models/props_combine/combine_citadel001.mdl", "models/props_phx/oildrum001_explosive.mdl", "models/props_wasteland/medbridge_base01.mdl", "models/props_wasteland/medbridge_post01.mdl", "models/props_wasteland/medbridge_strut01.mdl", "models/props_wasteland/rockcliff01e.mdl", "models/props_wasteland/rockcliff01f.mdl", "models/props_wasteland/rockcliff01g.mdl", "models/props_wasteland/rockcliff01k.mdl", "models/props_wasteland/rockcliff05a.mdl", "models/props_wasteland/rockcliff05b.mdl", "models/props_wasteland/rockcliff05e.mdl", "models/props_wasteland/rockcliff05f.mdl", "models/props_wasteland/rockcliff06d.mdl", "models/props_wasteland/rockcliff06i.mdl", "models/props_wasteland/rockcliff07b.mdl", "models/props_wasteland/rockcliff_cluster01b.mdl", "models/props_wasteland/rockcliff_cluster02a.mdl", "models/props_wasteland/rockcliff_cluster02b.mdl", "models/props_wasteland/rockcliff_cluster02c.mdl", "models/props_wasteland/rockcliff_cluster03a.mdl", "models/props_wasteland/rockcliff_cluster03b.mdl", "models/props_wasteland/rockcliff_cluster03c.mdl", "models/props_wasteland/rockcgranite01a.mdl", "models/props_wasteland/rockcgranite01c.mdl", "models/props_wasteland/rockcgranite02a.mdl", "models/props_wasteland/rockcgranite02b.mdl", "models/props_wasteland/rockcgranite02c.mdl", "models/props_wasteland/rockcgranite03a.mdl", "models/props_wasteland/rockcgranite03b.mdl", "models/props_wasteland/rockcgranite03c.mdl", "models/props_wasteland/rockcgranite04a.mdl", "models/props_wasteland/rockcgranite04b.mdl", "models/props_combine/combine_train02a.mdl", "models/props_combine/combine_train02b.mdl", "models/props_combine/combine_train01a.mdl", "models/props_combine/combinethumper001a.mdl", "models/props_combine/combinethumper002.mdl", "models/props_combine/combinetower001.mdl", "models/props_combine/combineinnerwall001a.mdl", "models/props_combine/combineinnerwall001c.mdl", "models/props_combine/pipes01_cluster02a.mdl", "models/props_combine/pipes01_cluster02b.mdl", "models/props_combine/pipes01_cluster02c.mdl", "models/props_combine/pipes01_single01a.mdl", "models/props_combine/pipes01_single01b.mdl", "models/props_combine/pipes01_single01c.mdl", "models/props_combine/pipes01_single02a.mdl", "models/props_combine/pipes01_single02b.mdl", "models/props_combine/pipes01_single02c.mdl", "models/props_combine/pipes02_single01a.mdl", "models/props_combine/pipes02_single01b.mdl", "models/props_combine/pipes02_single01c.mdl", "models/props_combine/pipes03_single01a.mdl", "models/props_combine/pipes03_single01b.mdl", "models/props_combine/pipes03_single01c.mdl", "models/props_combine/pipes03_single02a.mdl", "models/props_combine/pipes03_single02b.mdl", "models/props_combine/pipes03_single02c.mdl", "models/props_combine/pipes03_single03a.mdl", "models/props_combine/pipes03_single03b.mdl", "models/props_combine/pipes03_single03c.mdl", "models/props_combine/portalskydome.mdl", "models/props_combine/stasisfield.mdl", "models/props_combine/stasisshield.mdl", "models/props_combine/combineinnerwallcluster1024_001a.mdl", "models/props_combine/combineinnerwallcluster1024_002a.mdl", "models/props_combine/combineinnerwallcluster1024_003a.mdl", "models/props_combine/combine_citadel001.mdl", "models/props_combine/combine_citadel001b.mdl", "models/props_combine/combine_citadel001b_open.mdl", "models/props_combine/combine_citadel001_open.mdl", "models/props_wasteland/cargo_container01.mdl"}

    lia.config.StaffTitles = {
        ["Owner"] = {"Owner", Color(174, 0, 0)},
        ["Upper Administration"] = {"Upper Administration", Color(2, 0, 121)},
        ["Senior Administrator"] = {"Senior Administrator", Color(255, 165, 0)},
        ["Administrator"] = {"Administrator", Color(255, 165, 0)},
        ["Junior Administrator"] = {"Junior Administrator", Color(255, 165, 0)},
        ["Senior Moderator"] = {"Senior Moderator", Color(255, 255, 0)},
        ["Moderator"] = {"Moderator", Color(255, 255, 0)},
        ["Junior Moderator"] = {"Junior Moderator", Color(255, 255, 0)},
        ["Senior Gamemaster"] = {"Senior Gamemaster", Color(150, 75, 0)},
        ["Experienced Gamemaster"] = {"Experienced Gamemaster", Color(150, 75, 0)},
        ["Gamemaster"] = {"Gamemaster", Color(150, 75, 0)},
        ["Junior Gamemaster"] = {"Junior Gamemaster", Color(150, 75, 0)},
    }
    lia.config.ConsoleCommand = {
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
    }
    
    lia.config.RemovableHooks = {
        ["StartChat"] = "StartChatIndicator",
        ["FinishChat"] = "EndChatIndicator",
        ["PostPlayerDraw"] = "DarkRP_ChatIndicator",
        ["CreateClientsideRagdoll"] = "DarkRP_ChatIndicator",
        ["player_disconnect"] = "DarkRP_ChatIndicator",
        ["RenderScene"] = "RenderSuperDoF",
        ["RenderScene"] = "RenderStereoscopy",
        ["Think"] = "DOFThink",
        ["GUIMouseReleased"] = "SuperDOFMouseUp",
        ["GUIMousePressed"] = "SuperDOFMouseDown",
        ["PreRender"] = "PreRenderFrameBlend",
        ["PostRender"] = "RenderFrameBlend",
        ["NeedsDepthPass"] = "NeedsDepthPass_Bokeh",
        ["PreventScreenClicks"] = "SuperDOFPreventClicks",
        ["RenderScreenspaceEffects"] = "RenderBokeh",
        ["RenderScreenspaceEffects"] = "RenderBokeh",
        ["PostDrawEffects"] = "RenderWidgets",
        ["PlayerTick"] = "TickWidgets",
        ["PlayerInitialSpawn"] = "PlayerAuthSpawn",
        ["RenderScene"] = "RenderStereoscopy",
        ["LoadGModSave"] = "LoadGModSave",
        ["RenderScreenspaceEffects"] = "RenderColorModify",
        ["RenderScreenspaceEffects"] = "RenderBloom",
        ["RenderScreenspaceEffects"] = "RenderToyTown",
        ["RenderScreenspaceEffects"] = "RenderTexturize",
        ["RenderScreenspaceEffects"] = "RenderSunbeams",
        ["RenderScreenspaceEffects"] = "RenderSobel",
        ["RenderScreenspaceEffects"] = "RenderSharpen",
        ["RenderScreenspaceEffects"] = "RenderMaterialOverlay",
        ["RenderScreenspaceEffects"] = "RenderMotionBlur",
        ["RenderScene"] = "RenderSuperDoF",
        ["GUIMousePressed"] = "SuperDOFMouseDown",
        ["GUIMouseReleased"] = "SuperDOFMouseUp",
        ["PreventScreenClicks"] = "SuperDOFPreventClicks",
        ["PostRender"] = "RenderFrameBlend",
        ["PreRender"] = "PreRenderFrameBlend",
        ["Think"] = "DOFThink",
        ["RenderScreenspaceEffects"] = "RenderBokeh",
        ["NeedsDepthPass"] = "NeedsDepthPass_Bokeh",
        ["PostDrawEffects"] = "RenderWidgets",
        ["PostDrawEffects"] = "RenderHalos",
    }

    lia.config.RemoveEntities = {
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
    }
    
    lia.config.DevServerIP = "45.61.170.66"
    lia.config.DevServerPort = "27270"
    --[[
    This allows you to make reduced cooldowns or certain scenarios only happen on the Dev server. Example:
    
    function GM:PlayerSpawn(ply)
        if not ply:getChar() then return end -- If the character isn't loaded, the function won't run
    
        -- will load after the default spawn
        timer.Simple(0.5, function()
            -- if it detects it is the Dev Server, the HP will be set to 69420, otherwise, it will be 100
            if DEV then
                ply:SetMaxHealth(69420)
                ply:SetHealth(69420)
            else
                ply:SetMaxHealth(100)
                ply:SetHealth(100)
            end
        end)
    end
    --]]
end
--------------------------------------------------------------------------------------------------------
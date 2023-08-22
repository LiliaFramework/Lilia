--------------------------------------------------------------------------------------------------------
function lia.config.LoadPermissions()
    print("CONFIG: Loaded Custom Tool and Hook Access")
    lia.config.CustomPermissions = false
    lia.config.CustomToolAccess = true
    lia.config.BlockedProperties = {"persist", "bonemanipulate", "drive"}
    lia.config.RestrictedEntityList = {"prop_door_rotating", "lia_vendor",}
    lia.config.BlockedEntities = {"ent_chess_board", "ent_draughts_board", "rock_big", "rock_medium", "rock_small ", "lia_bodygroupcloset", "lia_craftingtable", "carvendor", "sh_teller", "permaweapons", "stockbook", "lia_stash", "valet", "lia_vendor", "telephone", "lia_salary", "spruce", "pinetree", "oaktree", "beechtree", "npc_import_drug", "cardealer", "delivery_crate", "npcdelivery", "housing_npc", "jailer_npc", "sergeant_dornan", "npctaxi",}
    lia.config.DisallowedTools = {"rope", "light", "lamp", "dynamite", "physprop", "faceposer",}
    lia.config.DuplicatorBlackList = {"lia_storage", "lia_money"}
    lia.config.RestrictedVehicles = {"sim_fphys_chaos126p", "sim_fphys_hedgehog", "sim_fphys_ratmobile", "sim_fphys_tank2", "sim_fphys_tank", "sim_fphys_conscriptapc_armed", "sim_fphys_combineapc_armed", "sim_fphys_jeep_armed2", "sim_fphys_jeep_armed", "sim_fphys_tank3", "sim_fphys_v8elite_armed2", "sim_fphys_v8elite_armed", "sim_fphys_tank4", "sim_fphys_couch", "sim_fphys_couch", "sim_fphys_tank_sdkfz_halftrack", "sim_fphys_opel_blitz_ww2", "gred_simfphys_panzerivd", "gred_simfphys_panzerivf1", "gred_simfphys_panzerivf2", "sim_fphys_pwavia", "sim_fphys_pwgaz52", "sim_fphys_pwhatchback", "sim_fphys_pwhatchback", "sim_fphys_pwmoskvich", "sim_fphys_pwtrabant", "sim_fphys_pwtrabant02", "sim_fphys_pwvan", "sim_fphys_pwvolga", "sim_fphys_pwzaz", "sim_fphys_conscriptapc", "sim_fphys_combineapc", "sim_fphys_jeep", "sim_fphys_jalopy", "sim_fphys_v8elite", "sim_fphys_van", "sim_fphys_chaos126p", "sim_fphys_hedgehog", "sim_fphys_ratmobile", "sim_fphys_tank2", "sim_fphys_tank", "sim_fphys_conscriptapc_armed", "sim_fphys_combineapc_armed", "sim_fphys_jeep_armed2", "sim_fphys_jeep_armed", "sim_fphys_tank3", "sim_fphys_v8elite_armed2", "sim_fphys_v8elite_armed", "sim_fphys_tank4", "sim_fphys_couch", "sim_fphys_dukes", "sim_fphys_tank_sdkfz_halftrack", "sim_fphys_opel_blitz_ww2", "gred_simfphys_panzerivd", "gred_simfphys_panzerivf1", "gred_simfphys_panzerivf2", "sim_fphys_pwavia", "sim_fphys_pwgaz52", "sim_fphys_pwhatchback", "sim_fphys_pwliaz", "sim_fphys_pwmoskvich", "sim_fphys_pwtrabant", "sim_fphys_pwtrabant02", "sim_fphys_pwvan", "sim_fphys_pwvolga", "sim_fphys_pwzaz", "sim_fphys_conscriptapc", "sim_fphys_combineapc", "sim_fphys_jeep", "sim_fphys_jalopy", "sim_fphys_v8elite", "sim_fphys_van", "gred_simfphys_panzerivd", "avx_t-34-85", "sim_fphys_chaos126p", "sim_fphys_hedgehog", "sim_fphys_ratmobile", "sim_fphys_tank2", "sim_fphys_tank", "sim_fphys_conscriptapc_armed", "sim_fphys_combineapc_armed", "sim_fphys_jeep_armed2", "sim_fphys_jeep_armed", "sim_fphys_tank3", "sim_fphys_v8elite_armed2", "sim_fphys_v8elite_armed", "sim_fphys_tank4", "sim_fphys_couch", "sim_fphys_dukes", "sim_fphys_conscriptapc", "sim_fphys_combineapc", "sim_fphys_jeep", "sim_fphys_jalopy", "sim_fphys_v8elite", "sim_fphys_van", "gred_panzerivd", "gred_simfphys_panzerivf1", "gred_simfphys_panzerivf2", "T34rp", "t34_76rp", "T34_85rp", "T34", "t34_76", "sdkfz_234", "ps_sdkfz_251_armed", "gb_bomb_cbu", "gb_bomb_1000gp", "gb_bomb_2000gp", "gb_bomb_fab250", "gb_bomb_gbu12", "gb_bomb_250gp", "gb_bomb_500gp", "gb_bomb_gbu38", "gb_bomb_mk77", "gb_bomb_mk82", "gb_bomb_sc100", "gb_bomb_sc1000", "gb_bomb_sc250", "gb_bomb_sc500", "gb_rocket_hvar", "gb_rocket_hydra", "gb_rocket_nebel", "gb_rocket_rp3", "gb_rocket_v1", "gred_ammobox", "sdkfz", "sdkfz2w", "sim_fphys_tank2", "Airboat", "Jeep", "Pod", "sim_fphys_chaos126p", "sim_fphys_hedgehog", "sim_fphys_ratmobile", "sim_fphys_tank2", "sim_fphys_tank", "sim_fphys_conscriptapc_armed", "sim_fphys_combineapc_armed", "sim_fphys_jeep_armed2", "sim_fphys_jeep_armed", "sim_fphys_tank3", "sim_fphys_v8elite_armed2", "sim_fphys_v8elite_armed", "sim_fphys_tank4", "sim_fphys_couch", "sim_fphys_dukes", "sim_fphys_tank_sdkfz_halftrack", "sim_fphys_opel_blitz_ww2", "gred_simfphys_panzerivd", "gred_simfphys_panzerivf1", "gred_simfphys_panzerivf2", "sim_fphys_pwavia", "sim_fphys_pwgaz52", "sim_fphys_pwhatchback", "sim_fphys_pwhatchback", "sim_fphys_pwmoskvich", "sim_fphys_pwtrabant", "sim_fphys_pwtrabant02", "sim_fphys_pwvan", "sim_fphys_pwvolga", "sim_fphys_pwzaz", "sim_fphys_conscriptapc", "sim_fphys_conscriptapc", "sim_fphys_jeep", "sim_fphys_jalopy ", "sim_fphys_v8elite", "sim_fphys_van", "T34_85"}
    lia.config.PropBlacklist = {"models/opelww2/ww2_opel_blitz.mdl", "models/w150.mdl", "models/track_test2.mdl", "models/track_test.mdl", "models/willys_cod.mdl", "models/comradebear/veh/ww2/fra/simca5.mdl", "models/comradebear/veh/ww2/ger/mercedes/_g4/_w31.mdl", "models/comradebear/veh/ww2/ger/mercedes/_g4/_w31_frontwheel.mdl", "models/comradebear/veh/ww2/ger/opelomnibus.mdl", "models/comradebear/veh/ww2/ger/opelomnibus_frontwheel.mdl", "models/comradebear/veh/ww2/ger/opelomnibus_rearwheel.mdl", "models/comradebear/veh/ww2/usa/cckw6x6.mdl", "models/comradebear/veh/ww2/usa/cckw6x6_frontwheel.mdl", "models/comradebear/veh/ww2/usa/cckw6x6_rearwheel.mdl", "models/indian/codww2_indian.mdl", "models/william/bussing_nag.mdl", "models/william/wc54.mdl", "models/sdkfz_9.mdl", "models/sdfkz/_10/_3.mdl", "models/sdfkz/_10/_2.mdl", "models/sdfkz_10.mdl", "models/m3_halftrack.mdl", "models/kettenkrad_2.mdl", "models/codww2vw38.mdl", "models/codww2ss100.mdl", "models/codww2peugeottruck.mdl", "models/codww2kubelwagen_2.mdl", "models/codww2kubelwagen.mdl", "models/codww2fiat_orpo.mdl", "models/codww2bussingnag_tow.mdl", "models/codww2boxer_tractor2.mdl", "models/codww2boxer_tractor.mdl", "models/codww2blitz_fuel.mdl", "models/codww2blitz/_civ/_fb.mdl", "models/codww2blitz_civ2.mdl", "models/codww2blitz_civ.mdl", "models/codww2blitz.mdl", "models/codww2_renault.mdl", "models/codww2_opelkadett.mdl", "models/citroenu23_v2.mdl", "models/citroen_traction.mdl", "models/props_c17/trappropeller_blade.mdl", "models/props_junk/propane_tank001a.mdl", "models/props_phx/cannonball.mdl", "models/gbombs/2501bgp.mdl", "models/gbombs/bomb_jdam.mdl", "models/xqm/jetbody3_s2.mdl", "models/hunter/blocks/cube8x8x8.mdl", "models/props_junk/gascan001a.mdl", "models/props_junk/propane_tank001a.mdl", "models/props_canal/canal_bridge01.mdl", "models/props_canal/canal_bridge02.mdl", "models/props_canal/canal_bridge03a.mdl", "models/props_canal/canal_bridge03b.mdl", "models/props_c17/oildrum001_explosive.mdl", "models/props_canal/canal_bridge04.mdl", "models/props_citizen_tech/windmill_blade002a.mdl", "models/props_citizen_tech/windmill_blade004a.mdl", "models/xqm/jetbody3.mdl", "models/xqm/jetbody2.mdl", "models/xqm/jetbody1.mdl", "models/xqm/jetbody.mdl", "models/doi/ty_missile.mdl", "models/combine_helicopter/helicopter_bomb01.mdl", "models/william/smoke_shell.mdl", "models/grendwitch/granatwerfer_tube.mdl", "models/props_vehicles/car005a_physics.mdl", "models/mikeprops/reichpillars1.mdl", "models/combine_helicopter/helicopter_bomb01.mdl", "models/items/item_item_crate.mdl", "models/props/cs_militia/silo_01.mdl", "models/props/cs_office/microwave.mdl", "models/props/de_train/biohazardtank.mdl", "models/props_buildings/building_002a.mdl", "models/props_buildings/collapsedbuilding01a.mdl", "models/props_buildings/project_building01.mdl", "models/props_buildings/project_building02.mdl", "models/props_buildings/project_building03.mdl", "models/props_buildings/project_destroyedbuildings01.mdl", "models/props_buildings/row_church_fullscale.mdl", "models/props_buildings/row_corner_1_fullscale.mdl", "models/props_buildings/row_res_1_fullscale.mdl", "models/props_buildings/row_res_2_ascend_fullscale.mdl", "models/props_buildings/row_res_2_fullscale.mdl", "models/props_c17/consolebox01a.mdl", "models/props_c17/oildrum001_explosive.mdl", "models/props_c17/paper01.mdl", "models/props_c17/trappropeller_engine.mdl", "models/props_canal/canal_bridge01.mdl", "models/props_canal/canal_bridge02.mdl", "models/props_canal/canal_bridge03a.mdl", "models/props_canal/canal_bridge03b.mdl", "models/props_combine/combine_citadel001.mdl", "models/props_combine/combine_mine01.mdl", "models/props_combine/combinetrain01.mdl", "models/props_combine/combinetrain02a.mdl", "models/props_combine/combinetrain02b.mdl", "models/props_combine/prison01.mdl", "models/props_combine/prison01b.mdl", "models/props_combine/prison01c.mdl", "models/props_industrial/bridge.mdl", "models/props_junk/garbage_takeoutcarton001a.mdl", "models/props_junk/gascan001a.mdl", "models/props_junk/glassjug01.mdl", "models/props_junk/trashdumpster02.mdl", "models/props_phx/amraam.mdl", "models/props_phx/ball.mdl", "models/props_phx/cannonball.mdl", "models/props_phx/huge/evildisc_corp.mdl", "models/props_phx/misc/flakshell_big.mdl", "models/props_phx/misc/potato_launcher_explosive.mdl", "models/props_phx/mk-82.mdl", "models/props_phx/oildrum001_explosive.mdl", "models/props_phx/torpedo.mdl", "models/props_phx/ww2bomb.mdl", "models/props_wasteland/cargo_container01.mdl", "models/props_wasteland/cargo_container01.mdl", "models/props_wasteland/cargo_container01b.mdl", "models/props_wasteland/cargo_container01c.mdl", "models/props_wasteland/depot.mdl", "models/xqm/coastertrack/special_full_corkscrew_left_4.mdl", "models/props_junk/propane_tank001a.mdl", "Models/props_c17/metalladder003.mdl", "models/props_c17/oildrum001_explosive.mdl", "models/props_phx/oildrum001_explosive.mdl", "models/props_combine/combinetrain02b.mdl", "models/props_combine/combinetrain02a.mdl", "models/props_combine/combinetrain01.mdl", "models/cranes/crane_frame.mdl", "models/props_wasteland/cargo_container01.mdl", "models/props_junk/trashdumpster02.mdl", "models/props_c17/oildrum001_explosive.mdl", "models/props_canal/canal_bridge02.mdl", "models/props_canal/canal_bridge01.mdl", "models/props_canal/canal_bridge03a.mdl", "models/props_canal/canal_bridge03b.mdl", "models/props_wasteland/cargo_container01.mdl", "models/props_wasteland/cargo_container01c.mdl", "models/props_wasteland/cargo_container01b.mdl", "models/props_combine/combine_mine01.mdl", "models/props_junk/glassjug01.mdl", "models/props_c17/paper01.mdl", "models/props_junk/garbage_takeoutcarton001a.mdl", "models/props_c17/trappropeller_engine.mdl", "models/props/cs_office/microwave.mdl", "models/items/item_item_crate.mdl", "models/props_junk/gascan001a.mdl", "models/props_c17/consolebox01a.mdl", "models/props_buildings/building_002a.mdl", "models/props_phx/mk-82.mdl", "models/props_phx/cannonball.mdl", "models/props_phx/ball.mdl", "models/props_phx/amraam.mdl", "models/props_phx/misc/flakshell_big.mdl", "models/props_phx/ww2bomb.mdl", "models/props_phx/torpedo.mdl", "models/props/de_train/biohazardtank.mdl", "models/props_buildings/project_building01.mdl", "models/props_combine/prison01c.mdl", "models/props/cs_militia/silo_01.mdl", "models/props_phx/huge/evildisc_corp.mdl", "models/props_phx/misc/potato_launcher_explosive.mdl", "models/props_combine/combine_citadel001.mdl", "models/props_phx/oildrum001_explosive.mdl", "models/props_wasteland/medbridge_base01.mdl", "models/props_wasteland/medbridge_post01.mdl", "models/props_wasteland/medbridge_strut01.mdl", "models/props_wasteland/rockcliff01e.mdl", "models/props_wasteland/rockcliff01f.mdl", "models/props_wasteland/rockcliff01g.mdl", "models/props_wasteland/rockcliff01k.mdl", "models/props_wasteland/rockcliff05a.mdl", "models/props_wasteland/rockcliff05b.mdl", "models/props_wasteland/rockcliff05e.mdl", "models/props_wasteland/rockcliff05f.mdl", "models/props_wasteland/rockcliff06d.mdl", "models/props_wasteland/rockcliff06i.mdl", "models/props_wasteland/rockcliff07b.mdl", "models/props_wasteland/rockcliff_cluster01b.mdl", "models/props_wasteland/rockcliff_cluster02a.mdl", "models/props_wasteland/rockcliff_cluster02b.mdl", "models/props_wasteland/rockcliff_cluster02c.mdl", "models/props_wasteland/rockcliff_cluster03a.mdl", "models/props_wasteland/rockcliff_cluster03b.mdl", "models/props_wasteland/rockcliff_cluster03c.mdl", "models/props_wasteland/rockcgranite01a.mdl", "models/props_wasteland/rockcgranite01c.mdl", "models/props_wasteland/rockcgranite02a.mdl", "models/props_wasteland/rockcgranite02b.mdl", "models/props_wasteland/rockcgranite02c.mdl", "models/props_wasteland/rockcgranite03a.mdl", "models/props_wasteland/rockcgranite03b.mdl", "models/props_wasteland/rockcgranite03c.mdl", "models/props_wasteland/rockcgranite04a.mdl", "models/props_wasteland/rockcgranite04b.mdl", "models/props_combine/combine_train02a.mdl", "models/props_combine/combine_train02b.mdl", "models/props_combine/combine_train01a.mdl", "models/props_combine/combinethumper001a.mdl", "models/props_combine/combinethumper002.mdl", "models/props_combine/combinetower001.mdl", "models/props_combine/combineinnerwall001a.mdl", "models/props_combine/combineinnerwall001c.mdl", "models/props_combine/pipes01_cluster02a.mdl", "models/props_combine/pipes01_cluster02b.mdl", "models/props_combine/pipes01_cluster02c.mdl", "models/props_combine/pipes01_single01a.mdl", "models/props_combine/pipes01_single01b.mdl", "models/props_combine/pipes01_single01c.mdl", "models/props_combine/pipes01_single02a.mdl", "models/props_combine/pipes01_single02b.mdl", "models/props_combine/pipes01_single02c.mdl", "models/props_combine/pipes02_single01a.mdl", "models/props_combine/pipes02_single01b.mdl", "models/props_combine/pipes02_single01c.mdl", "models/props_combine/pipes03_single01a.mdl", "models/props_combine/pipes03_single01b.mdl", "models/props_combine/pipes03_single01c.mdl", "models/props_combine/pipes03_single02a.mdl", "models/props_combine/pipes03_single02b.mdl", "models/props_combine/pipes03_single02c.mdl", "models/props_combine/pipes03_single03a.mdl", "models/props_combine/pipes03_single03b.mdl", "models/props_combine/pipes03_single03c.mdl", "models/props_combine/portalskydome.mdl", "models/props_combine/stasisfield.mdl", "models/props_combine/stasisshield.mdl", "models/props_combine/combineinnerwallcluster1024_001a.mdl", "models/props_combine/combineinnerwallcluster1024_002a.mdl", "models/props_combine/combineinnerwallcluster1024_003a.mdl", "models/props_combine/combine_citadel001.mdl", "models/props_combine/combine_citadel001b.mdl", "models/props_combine/combine_citadel001b_open.mdl", "models/props_combine/combine_citadel001_open.mdl", "models/props_wasteland/cargo_container01.mdl"}
    lia.config.PermissionTable = {
        ["PlayerSpawnNPC"] = {
            IsAdmin = false,
            IsSuperAdmin = true,
            CustomCheck = function(client)
                return client:IsAdmin() or (client:getChar():hasFlags("n") or client:getChar():hasFlags("E"))
            end,
        },
        ["PlayerSpawnProp"] = {
            IsAdmin = false,
            IsSuperAdmin = true,
            CustomCheck = function(client)
                return client:IsAdmin() or client:getChar():hasFlags("e")
            end,
        },
        ["PlayerSpawnRagdoll"] = {
            IsAdmin = false,
            IsSuperAdmin = true,
            CustomCheck = function(client)
                return client:IsAdmin() or client:getChar():hasFlags("r")
            end,
        },
        ["PlayerSpawnSWEP"] = {
            IsAdmin = false,
            IsSuperAdmin = true,
            CustomCheck = function(client)
                return client:IsSuperAdmin() or client:getChar():hasFlags("W")
            end,
        },
        ["PlayerSpawnEffect"] = {
            IsAdmin = false,
            IsSuperAdmin = true,
            CustomCheck = function(client)
                return client:IsAdmin() or (client:getChar():hasFlags("n") or client:getChar():hasFlags("E"))
            end,
        },
        ["PlayerSpawnSENT"] = {
            IsAdmin = false,
            IsSuperAdmin = true,
            CustomCheck = function(client)
                return client:IsAdmin() or client:getChar():hasFlags("E")
            end,
        },
        ["PlayerSpawnVehicle"] = {
            IsAdmin = false,
            IsSuperAdmin = true,
            CustomCheck = function(client, model, name, data)
                if client:IsSuperAdmin() then return true end

                if table.HasValue(lia.config.RestrictedVehicles, name) then
                    ply:notify("You can't spawn this vehicle since it's restricted!")

                    return false
                else
                    if data.Category == "Chairs" then
                        return client:getChar():hasFlags("c")
                    else
                        return client:getChar():hasFlags("C")
                    end
                end

                return false
            end,
        },

        lia.config.CustomToolAccessTable = {
            ["remover"] = {
                IsAdmin = false,
                IsSuperAdmin = false,
                ToolAllowedUsergroup = {"superadmin", "admin", "user"},
                ExtraCheck = function(client, trace, tool, entity)
                    if client:IsSuperAdmin() then return true end
    
                    if table.HasValue(lia.config.BlockedEntities, entity:GetClass()) then
                        return false
                    else
                        if entity:GetCreator() == client then
                            return true
                        else
                            if client:Team() ~= FACTION_STAFF and not client:IsAdmin() then
                                return false
                            elseif client:Team() == FACTION_STAFF or client:IsAdmin() then
                                return true
                            end
                        end
                    end
    
                    return false
                end,
            },
            ["editentity"] = {
                IsAdmin = true,
                IsSuperAdmin = true,
                ToolAllowedUsergroup = {"superadmin", "admin"},
                ExtraCheck = function(client, trace, tool)
                    return true
                end,
            },
            ["collision"] = {
                IsAdmin = true,
                IsSuperAdmin = true,
                ToolAllowedUsergroup = {"superadmin"},
                ExtraCheck = function(client, trace, tool)
                    return true
                end,
            },
            ["advdupe2"] = {
                IsAdmin = false,
                IsSuperAdmin = false,
                ToolAllowedUsergroup = {"superadmin"},
                ExtraCheck = function(client, trace, tool)
                    if client:IsSuperAdmin() then return true end
    
                    if table.HasValue(lia.config.DuplicatorBlackList, entity:GetClass()) then
                        return false
                    else
                        return true
                    end
                end,
            },
        }
    }
end
--------------------------------------------------------------------------------------------------------
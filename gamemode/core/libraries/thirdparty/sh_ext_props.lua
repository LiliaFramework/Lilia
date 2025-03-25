local function rb655_property_filter(filtor, ent, client)
    if isstring(filtor) and filtor ~= ent:GetClass() then return false end
    if istable(filtor) and not table.HasValue(filtor, ent:GetClass()) then return false end
    if isfunction(filtor) and not filtor(ent, client) then return false end
    return true
end

function AddEntFunctionProperty(name, label, pos, filtor, func, icon)
    properties.Add(name, {
        MenuLabel = label,
        MenuIcon = icon,
        Order = pos,
        Filter = function(self, ent, client)
            if not IsValid(ent) or not gamemode.Call("CanProperty", client, name, ent) then return false end
            if not rb655_property_filter(filtor, ent, client) then return false end
            return true
        end,
        Action = function(self, ent)
            self:MsgStart()
            net.WriteEntity(ent)
            self:MsgEnd()
        end,
        Receive = function(self, length, client)
            local ent = net.ReadEntity()
            if not IsValid(client) or not IsValid(ent) or not self:Filter(ent, client) then return false end
            func(ent, client)
        end
    })
end

function AddEntFireProperty(name, label, pos, filtor, input, icon)
    AddEntFunctionProperty(name, label, pos, filtor, function(e) e:Fire(unpack(string.Explode(" ", input))) end, icon)
end

if SERVER then
    local SyncFuncs = {}
    SyncFuncs.prop_door_rotating = function(ent)
        ent:setNetVar("Locked", ent:GetInternalVariable("m_bLocked"))
        local state = ent:GetInternalVariable("m_eDoorState")
        ent:setNetVar("Closed", state == 0 or state == 3)
    end

    SyncFuncs.func_door = function(ent) ent:setNetVar("Locked", ent:GetInternalVariable("m_bLocked")) end
    SyncFuncs.func_door_rotating = function(ent) ent:setNetVar("Locked", ent:GetInternalVariable("m_bLocked")) end
    SyncFuncs.prop_vehicle_jeep = function(ent)
        ent:setNetVar("Locked", ent:GetInternalVariable("VehicleLocked"))
        ent:setNetVar("HasDriver", IsValid(ent:GetDriver()))
        ent:setNetVar("m_bRadarEnabled", ent:GetInternalVariable("m_bRadarEnabled"))
    end

    SyncFuncs.prop_vehicle_airboat = function(ent)
        ent:setNetVar("Locked", ent:GetInternalVariable("VehicleLocked"))
        ent:setNetVar("HasDriver", IsValid(ent:GetDriver()))
    end

    SyncFuncs.func_tracktrain = function(ent)
        ent:setNetVar("m_dir", ent:GetInternalVariable("m_dir"))
        ent:setNetVar("m_moving", ent:GetInternalVariable("speed") ~= 0)
    end

    local nextSync = 0
    hook.Add("Tick", "rb655_propperties_sync", function()
        if nextSync > CurTime() then return end
        nextSync = CurTime() + 1
        for id, ent in ents.Iterator() do
            if SyncFuncs[ent:GetClass()] then SyncFuncs[ent:GetClass()](ent) end
        end
    end)
end

local ExplodeIcon = "icon16/bomb.png"
local EnableIcon = "icon16/tick.png"
local DisableIcon = "icon16/cross.png"
local ToggleIcon = "icon16/arrow_switch.png"
AddEntFireProperty("rb655_door_open", "Open", 655, function(ent, client)
    if not ent:getNetVar("Closed") and ent:GetClass() == "prop_door_rotating" then return false end
    return rb655_property_filter({"prop_door_rotating", "func_door_rotating", "func_door"}, ent, client)
end, "Open", "icon16/door_open.png")

AddEntFireProperty("rb655_door_close", "Close", 656, function(ent, client)
    if ent:getNetVar("Closed") and ent:GetClass() == "prop_door_rotating" then return false end
    return rb655_property_filter({"prop_door_rotating", "func_door_rotating", "func_door"}, ent, client)
end, "Close", "icon16/door.png")

AddEntFireProperty("rb655_door_lock", "Lock", 657, function(ent, client)
    if ent:getNetVar("Locked") and ent:GetClass() ~= "prop_vehicle_prisoner_pod" then return false end
    return rb655_property_filter({"prop_door_rotating", "func_door_rotating", "func_door", "prop_vehicle_jeep", "prop_vehicle_airboat", "prop_vehicle_prisoner_pod"}, ent, client)
end, "Lock", "icon16/lock.png")

AddEntFireProperty("rb655_door_unlock", "Unlock", 658, function(ent, client)
    if not ent:getNetVar("Locked") and ent:GetClass() ~= "prop_vehicle_prisoner_pod" then return false end
    return rb655_property_filter({"prop_door_rotating", "func_door_rotating", "func_door", "prop_vehicle_jeep", "prop_vehicle_airboat", "prop_vehicle_prisoner_pod"}, ent, client)
end, "Unlock", "icon16/lock_open.png")

AddEntFireProperty("rb655_func_movelinear_open", "Start", 655, "func_movelinear", "Open", "icon16/arrow_right.png")
AddEntFireProperty("rb655_func_movelinear_close", "Return", 656, "func_movelinear", "Close", "icon16/arrow_left.png")
AddEntFireProperty("rb655_func_tracktrain_StartForward", "Start Forward", 655, function(ent, client)
    if ent:getNetVar("m_dir") == 1 then return false end
    return rb655_property_filter("func_tracktrain", ent, client)
end, "StartForward", "icon16/arrow_right.png")

AddEntFireProperty("rb655_func_tracktrain_StartBackward", "Start Backward", 656, function(ent, client)
    if ent:getNetVar("m_dir") == -1 then return false end
    return rb655_property_filter("func_tracktrain", ent, client)
end, "StartBackward", "icon16/arrow_left.png")

AddEntFireProperty("rb655_func_tracktrain_Stop", "Stop", 658, function(ent, client)
    if not ent:getNetVar("m_moving") then return false end
    return rb655_property_filter("func_tracktrain", ent, client)
end, "Stop", "icon16/shape_square.png")

AddEntFireProperty("rb655_func_tracktrain_Resume", "Resume", 659, function(ent, client)
    if ent:getNetVar("m_moving") then return false end
    return rb655_property_filter("func_tracktrain", ent, client)
end, "Resume", "icon16/resultset_next.png")

AddEntFireProperty("rb655_breakable_break", "Break", 655, function(ent, client)
    if ent:Health() < 1 then return false end
    return rb655_property_filter({"func_breakable", "func_physbox", "prop_physics", "func_pushable"}, ent, client)
end, "Break", ExplodeIcon)

local dissolve_id = 0
local dissolver
function rb655_dissolve(ent)
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then phys:EnableGravity(false) end
    if not IsValid(dissolver) then
        dissolver = ents.Create("env_entity_dissolver")
        dissolver:SetPos(ent:GetPos())
        dissolver:Spawn()
        dissolver:Activate()
        dissolver:SetKeyValue("magnitude", 100)
        dissolver:SetKeyValue("dissolvetype", 0)
    end

    ent:SetName("rb655_dissolve" .. dissolve_id)
    dissolver:Fire("Dissolve", "rb655_dissolve" .. dissolve_id)
    dissolve_id = dissolve_id + 1

    SafeRemoveEntityDelayed(dissolver, 60)
end

AddEntFunctionProperty("rb655_dissolve", "Disintegrate", 657, function(ent, client)
    if ent:GetModel() and ent:GetModel():StartWith("*") then return false end
    if ent:IsPlayer() then return false end
    return true
end, function(ent) rb655_dissolve(ent) end, "icon16/wand.png")

AddEntFireProperty("rb655_turret_toggle", "Toggle", 655, {"npc_combine_camera", "npc_turret_ceiling", "npc_turret_floor"}, "Toggle", ToggleIcon)
AddEntFireProperty("rb655_self_destruct", "Self Destruct", 656, {"npc_turret_floor", "npc_helicopter"}, "SelfDestruct", ExplodeIcon)
AddEntFunctionProperty("rb655_turret_ammo_remove", "Deplete Ammo", 657, function(ent)
    if bit.band(ent:GetSpawnFlags(), 256) == 256 then return false end
    if ent:GetClass() == "npc_turret_floor" or ent:GetClass() == "npc_turret_ceiling" then return true end
    return false
end, function(ent)
    ent:SetKeyValue("spawnflags", bit.bor(ent:GetSpawnFlags(), 256))
    ent:Activate()
end, "icon16/delete.png")

AddEntFunctionProperty("rb655_turret_ammo_restore", "Restore Ammo", 658, function(ent)
    if bit.band(ent:GetSpawnFlags(), 256) == 0 then return false end
    if ent:GetClass() == "npc_turret_floor" or ent:GetClass() == "npc_turret_ceiling" then return true end
    return false
end, function(ent)
    ent:SetKeyValue("spawnflags", bit.bxor(ent:GetSpawnFlags(), 256))
    ent:Activate()
end, "icon16/add.png")

AddEntFunctionProperty("rb655_turret_make_friendly", "Make Friendly", 659, function(ent)
    if bit.band(ent:GetSpawnFlags(), 512) == 512 then return false end
    if ent:GetClass() == "npc_turret_floor" then return true end
    return false
end, function(ent)
    ent:SetKeyValue("spawnflags", bit.bor(ent:GetSpawnFlags(), SF_FLOOR_TURRET_CITIZEN))
    ent:Activate()
end, "icon16/user_green.png")

AddEntFunctionProperty("rb655_turret_make_hostile", "Make Hostile", 660, function(ent)
    if bit.band(ent:GetSpawnFlags(), 512) == 0 then return false end
    if ent:GetClass() == "npc_turret_floor" then return true end
    return false
end, function(ent)
    ent:SetKeyValue("spawnflags", bit.bxor(ent:GetSpawnFlags(), SF_FLOOR_TURRET_CITIZEN))
    ent:Activate()
end, "icon16/user_red.png")

AddEntFireProperty("rb655_suitcharger_recharge", "Recharge", 655, "item_suitcharger", "Recharge", "icon16/arrow_refresh.png")
AddEntFireProperty("rb655_manhack_jam", "Jam", 655, "npc_manhack", "InteractivePowerDown", ExplodeIcon)
AddEntFireProperty("rb655_scanner_mineadd", "Equip Mine", 655, "npc_clawscanner", "EquipMine", "icon16/add.png")
AddEntFireProperty("rb655_scanner_minedeploy", "Deploy Mine", 656, "npc_clawscanner", "DeployMine", "icon16/arrow_down.png")
AddEntFireProperty("rb655_scanner_disable_spotlight", "Disable Spotlight", 658, {"npc_clawscanner", "npc_cscanner"}, "DisableSpotlight", DisableIcon)
AddEntFireProperty("rb655_rollermine_selfdestruct", "Self Destruct", 655, "npc_rollermine", "InteractivePowerDown", ExplodeIcon)
AddEntFireProperty("rb655_rollermine_turnoff", "Turn Off", 656, "npc_rollermine", "TurnOff", DisableIcon)
AddEntFireProperty("rb655_rollermine_turnon", "Turn On", 657, "npc_rollermine", "TurnOn", EnableIcon)
AddEntFireProperty("rb655_helicopter_gun_on", "Enable Turret", 655, "npc_helicopter", "GunOn", EnableIcon)
AddEntFireProperty("rb655_helicopter_gun_off", "Disable Turret", 656, "npc_helicopter", "GunOff", DisableIcon)
AddEntFireProperty("rb655_helicopter_dropbomb", "Drop Bomb", 657, "npc_helicopter", "DropBomb", "icon16/arrow_down.png")
AddEntFireProperty("rb655_helicopter_norm_shoot", "Start Normal Shooting", 660, "npc_helicopter", "StartNormalShooting", "icon16/clock.png")
AddEntFireProperty("rb655_helicopter_long_shoot", "Start Long Cycle Shooting", 661, "npc_helicopter", "StartLongCycleShooting", "icon16/clock_red.png")
AddEntFireProperty("rb655_helicopter_deadly_on", "Enable Deadly Shooting", 662, "npc_helicopter", "EnableDeadlyShooting", EnableIcon)
AddEntFireProperty("rb655_helicopter_deadly_off", "Disable Deadly Shooting", 663, "npc_helicopter", "DisableDeadlyShooting", DisableIcon)
AddEntFireProperty("rb655_gunship_OmniscientOn", "Enable Omniscient", 655, "npc_combinegunship", "OmniscientOn", EnableIcon)
AddEntFireProperty("rb655_gunship_OmniscientOff", "Disable Omniscient", 656, "npc_combinegunship", "OmniscientOff", DisableIcon)
AddEntFireProperty("rb655_gunship_BlindfireOn", "Enable Blindfire", 657, "npc_combinegunship", "BlindfireOn", EnableIcon)
AddEntFireProperty("rb655_gunship_BlindfireOff", "Disable Blindfire", 658, "npc_combinegunship", "BlindfireOff", DisableIcon)
AddEntFireProperty("rb655_alyx_HolsterWeapon", "Holster Weapon", 655, function(ent)
    if not ent:IsNPC() or ent:GetClass() ~= "npc_alyx" or not IsValid(ent:GetActiveWeapon()) then return false end
    return true
end, "HolsterWeapon", "icon16/gun.png")

AddEntFireProperty("rb655_alyx_UnholsterWeapon", "Unholster Weapon", 656, "npc_alyx", "UnholsterWeapon", "icon16/gun.png")
AddEntFireProperty("rb655_alyx_HolsterAndDestroyWeapon", "Holster And Destroy Weapon", 657, function(ent)
    if not ent:IsNPC() or ent:GetClass() ~= "npc_alyx" or not IsValid(ent:GetActiveWeapon()) then return false end
    return true
end, "HolsterAndDestroyWeapon", "icon16/gun.png")

AddEntFireProperty("rb655_antlion_burrow", "Burrow", 655, {"npc_antlion", "npc_antlion_worker"}, "BurrowAway", "icon16/arrow_down.png")
AddEntFireProperty("rb655_barnacle_free", "Free Target", 655, "npc_barnacle", "LetGo", "icon16/heart.png")
AddEntFireProperty("rb655_zombine_suicide", "Suicide", 655, "npc_zombine", "PullGrenade", ExplodeIcon)
AddEntFireProperty("rb655_zombine_sprint", "Sprint", 656, "npc_zombine", "StartSprint", "icon16/flag_blue.png")
AddEntFireProperty("rb655_thumper_enable", "Enable", 655, "prop_thumper", "Enable", EnableIcon)
AddEntFireProperty("rb655_thumper_disable", "Disable", 656, "prop_thumper", "Disable", DisableIcon)
AddEntFireProperty("rb655_dog_fetch_on", "Start Playing Fetch", 655, "npc_dog", "StartCatchThrowBehavior", "icon16/accept.png")
AddEntFireProperty("rb655_dog_fetch_off", "Stop Playing Fetch", 656, "npc_dog", "StopCatchThrowBehavior", "icon16/cancel.png")
AddEntFireProperty("rb655_soldier_look_off", "Enable Blindness", 655, "npc_combine_s", "LookOff", "icon16/user_green.png")
AddEntFireProperty("rb655_soldier_look_on", "Disable Blindness", 656, "npc_combine_s", "LookOn", "icon16/user_gray.png")
AddEntFireProperty("rb655_citizen_wep_pick_on", "Permit Weapon Upgrade Pickup", 655, "npc_citizen", "EnableWeaponPickup", EnableIcon)
AddEntFireProperty("rb655_citizen_wep_pick_off", "Restrict Weapon Upgrade Pickup", 656, "npc_citizen", "DisableWeaponPickup", DisableIcon)
AddEntFireProperty("rb655_citizen_panic", "Start Panicking", 658, {"npc_citizen", "npc_alyx", "npc_barney"}, "SetReadinessPanic", "icon16/flag_red.png")
AddEntFireProperty("rb655_citizen_panic_off", "Stop Panicking", 659, {"npc_citizen", "npc_alyx", "npc_barney"}, "SetReadinessHigh", "icon16/flag_green.png")
AddEntFireProperty("rb655_camera_angry", "Make Angry", 656, "npc_combine_camera", "SetAngry", "icon16/flag_red.png")
AddEntFireProperty("rb655_combine_mine_disarm", "Disarm", 655, "combine_mine", "Disarm", "icon16/wrench.png")
AddEntFireProperty("rb655_hunter_enable", "Enable Shooting", 655, "npc_hunter", "EnableShooting", EnableIcon)
AddEntFireProperty("rb655_hunter_disable", "Disable Shooting", 656, "npc_hunter", "DisableShooting", DisableIcon)
AddEntFireProperty("rb655_vortigaunt_enable", "Enable Armor Recharge", 655, "npc_vortigaunt", "EnableArmorRecharge", EnableIcon)
AddEntFireProperty("rb655_vortigaunt_disable", "Disable Armor Recharge", 656, "npc_vortigaunt", "DisableArmorRecharge", DisableIcon)
AddEntFireProperty("rb655_antlion_enable", "Enable Jump", 655, {"npc_antlion", "npc_antlion_worker"}, "EnableJump", EnableIcon)
AddEntFireProperty("rb655_antlion_disable", "Disable Jump", 656, {"npc_antlion", "npc_antlion_worker"}, "DisableJump", DisableIcon)
AddEntFireProperty("rb655_antlion_hear", "Hear Bugbait", 657, {"npc_antlion", "npc_antlion_worker"}, "HearBugbait", EnableIcon)
AddEntFireProperty("rb655_antlion_ignore", "Ignore Bugbait", 658, {"npc_antlion", "npc_antlion_worker"}, "IgnoreBugbait", DisableIcon)
AddEntFireProperty("rb655_antlion_grub_squash", "Squash", 655, "npc_antlion_grub", "Squash", "icon16/bug.png")
AddEntFireProperty("rb655_antlionguard_bark_on", "Enable Antlion Summon", 655, "npc_antlionguard", "EnableBark", EnableIcon)
AddEntFireProperty("rb655_antlionguard_bark_off", "Disable Antlion Summon", 656, "npc_antlionguard", "DisableBark", DisableIcon)
AddEntFireProperty("rb655_headcrab_burrow", "Burrow", 655, "npc_headcrab", "BurrowImmediate", "icon16/arrow_down.png")
AddEntFireProperty("rb655_strider_stand", "Force Stand", 655, "npc_strider", "Stand", "icon16/arrow_up.png")
AddEntFireProperty("rb655_strider_crouch", "Force Crouch", 656, "npc_strider", "Crouch", "icon16/arrow_down.png")
AddEntFireProperty("rb655_strider_break", "Destroy", 657, {"npc_strider", "npc_clawscanner", "npc_cscanner"}, "Break", ExplodeIcon)
AddEntFireProperty("rb655_patrol_on", "Start Patrolling", 660, {"npc_citizen", "npc_combine_s"}, "StartPatrolling", "icon16/flag_green.png")
AddEntFireProperty("rb655_patrol_off", "Stop Patrolling", 661, {"npc_citizen", "npc_combine_s"}, "StopPatrolling", "icon16/flag_red.png")
AddEntFireProperty("rb655_strider_aggressive_e", "Make More Aggressive", 658, "npc_strider", "EnableAggressiveBehavior", EnableIcon)
AddEntFireProperty("rb655_strider_aggressive_d", "Make Less Aggressive", 659, "npc_strider", "DisableAggressiveBehavior", DisableIcon)
AddEntFunctionProperty("rb655_healthcharger_recharge", "Recharge", 655, "item_healthcharger", function(ent)
    local n = ents.Create("item_healthcharger")
    n:SetPos(ent:GetPos())
    n:SetAngles(ent:GetAngles())
    n:Spawn()
    n:Activate()
    n:EmitSound("items/suitchargeok1.wav")
    undo.ReplaceEntity(ent, n)
    cleanup.ReplaceEntity(ent, n)
    SafeRemoveEntity(ent)
end, "icon16/arrow_refresh.png")

AddEntFunctionProperty("rb655_vehicle_exit", "Kick Driver", 655, function(ent)
    if ent:IsVehicle() and ent:getNetVar("HasDriver") then return true end
    return false
end, function(ent)
    if not IsValid(ent:GetDriver()) or not ent:GetDriver().ExitVehicle then return end
    ent:GetDriver():ExitVehicle()
end, "icon16/car.png")

AddEntFireProperty("rb655_vehicle_radar", "Enable Radar", 655, function(ent)
    if not ent:IsVehicle() or ent:GetClass() ~= "prop_vehicle_jeep" then return false end
    if ent:LookupAttachment("controlpanel0_ll") == 0 then return false end
    if ent:LookupAttachment("controlpanel0_ur") == 0 then return false end
    if ent:getNetVar("m_bRadarEnabled", false) then return false end
    return true
end, "EnableRadar", "icon16/application_add.png")

AddEntFireProperty("rb655_vehicle_radar_off", "Disable Radar", 655, function(ent)
    if not ent:IsVehicle() or ent:GetClass() ~= "prop_vehicle_jeep" then return false end
    if not ent:getNetVar("m_bRadarEnabled", false) then return false end
    return true
end, "DisableRadar", "icon16/application_delete.png")

AddEntFunctionProperty("rb655_vehicle_enter", "Enter Vehicle", 656, function(ent)
    if ent:IsVehicle() and not ent:getNetVar("HasDriver") then return true end
    return false
end, function(ent, client)
    client:ExitVehicle()
    client:EnterVehicle(ent)
end, "icon16/car.png")

AddEntFunctionProperty("rb655_vehicle_add_gun", "Mount Gun", 657, function(ent)
    if not ent:IsVehicle() then return false end
    if ent:getNetVar("EnableGun", false) then return false end
    if ent:GetBodygroup(1) == 1 then return false end
    if ent:LookupSequence("aim_all") > 0 then return true end
    if ent:LookupSequence("weapon_yaw") > 0 and ent:LookupSequence("weapon_pitch") > 0 then return true end
    return false
end, function(ent)
    ent:SetKeyValue("EnableGun", "1")
    ent:Activate()
    ent:SetBodygroup(1, 1)
    ent:setNetVar("EnableGun", true)
end, "icon16/gun.png")

AddEntFunctionProperty("rb655_baloon_break", "Pop", 655, "gmod_balloon", function(ent, client)
    local dmginfo = DamageInfo()
    dmginfo:SetAttacker(client)
    ent:OnTakeDamage(dmginfo)
end, ExplodeIcon)

AddEntFunctionProperty("rb655_dynamite_activate", "Explode", 655, "gmod_dynamite", function(ent, client) ent:Explode(0, client) end, ExplodeIcon)
AddEntFunctionProperty("rb655_emitter_on", "Start Emitting", 655, function(ent)
    if ent:GetClass() == "gmod_emitter" and not ent:GetOn() then return true end
    return false
end, function(ent, client) ent:SetOn(true) end, EnableIcon)

AddEntFunctionProperty("rb655_emitter_off", "Stop Emitting", 656, function(ent)
    if ent:GetClass() == "gmod_emitter" and ent:GetOn() then return true end
    return false
end, function(ent, client) ent:SetOn(false) end, DisableIcon)

AddEntFunctionProperty("rb655_lamp_on", "Enable", 655, function(ent)
    if ent:GetClass() == "gmod_lamp" and not ent:GetOn() then return true end
    return false
end, function(ent, client) ent:Switch(true) end, EnableIcon)

AddEntFunctionProperty("rb655_lamp_off", "Disable", 656, function(ent)
    if ent:GetClass() == "gmod_lamp" and ent:GetOn() then return true end
    return false
end, function(ent, client) ent:Switch(false) end, DisableIcon)

AddEntFunctionProperty("rb655_light_on", "Enable", 655, function(ent)
    if ent:GetClass() == "gmod_light" and not ent:GetOn() then return true end
    return false
end, function(ent, client) ent:SetOn(true) end, EnableIcon)

AddEntFunctionProperty("rb655_light_off", "Disable", 656, function(ent)
    if ent:GetClass() == "gmod_light" and ent:GetOn() then return true end
    return false
end, function(ent, client) ent:SetOn(false) end, DisableIcon)

AddEntFireProperty("rb655_func_rotating_forward", "Start Forward", 655, "func_rotating", "StartForward", "icon16/arrow_right.png")
AddEntFireProperty("rb655_func_rotating_backward", "Start Backward", 656, "func_rotating", "StartBackward", "icon16/arrow_left.png")
AddEntFireProperty("rb655_func_rotating_reverse", "Reverse", 657, "func_rotating", "Reverse", "icon16/arrow_undo.png")
AddEntFireProperty("rb655_func_rotating_stop", "Stop", 658, "func_rotating", "Stop", "icon16/shape_square.png")
AddEntFireProperty("rb655_func_platrot_up", "Go Up", 655, "func_platrot", "GoUp", "icon16/arrow_up.png")
AddEntFireProperty("rb655_func_platrot_down", "Go Down", 656, "func_platrot", "GoDown", "icon16/arrow_down.png")
AddEntFireProperty("rb655_func_platrot_toggle", "Toggle", 657, "func_platrot", "Toggle", ToggleIcon)
AddEntFireProperty("rb655_func_train_start", "Start", 655, "func_train", "Start", "icon16/arrow_right.png")
AddEntFireProperty("rb655_func_train_stop", "Stop", 656, "func_train", "Stop", "icon16/arrow_left.png")
AddEntFireProperty("rb655_func_train_toggle", "Toggle", 657, "func_train", "Toggle", ToggleIcon)

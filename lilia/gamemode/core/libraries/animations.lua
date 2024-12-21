--[[--
Player model animation.

Lilia comes with support for using Player-Models, although, there are
a few standard animation sets that are built-in that should cover most non-player models:
	citizen_male
	citizen_female
	metrocop
	overwatch
	vortigaunt
	player
	zombie
	fastZombie

If you find that your models are T-posing when they work elsewhere, you'll probably need to set the model class for your
model with `lia.anim.setModelClass` in order for the correct animations to be used. If you'd like to add your own animation
class, simply add to the `lia.anim` table with a model class name and the required animation translation table.
]]
-- @library lia.anim
local translations = {}
lia.anim = lia.anim or {}
player_manager.anim = player_manager.anim or {}
TranslateModel = TranslateModel or player_manager.TranslateToPlayerModelName
--- This table defines the default model-to-animation type mappings used by citizen_male models.
-- @realm shared
lia.anim.citizen_male = {
    normal = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
        [ACT_MP_WALK] = {ACT_WALK, ACT_WALK},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
        [ACT_MP_RUN] = {ACT_RUN, ACT_RUN}
    },
    fist = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
        [ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
        [ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_RANGE_ATTACK_PISTOL},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_ATTACK_PISTOL_LOW},
        [ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
        [ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED},
        attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
        reload = ACT_RELOAD_PISTOL
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
        [ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE},
        [ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
        attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
        reload = ACT_GESTURE_RELOAD_SMG1
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
        [ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
        [ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
        attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
        [ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
        [ACT_MP_RUN] = {ACT_RUN, ACT_RUN_RIFLE_STIMULATED},
        attack = ACT_RANGE_ATTACK_THROW
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_MELEE},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
        [ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
        [ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
        attack = ACT_MELEE_ATTACK_SWING
    },
    glide = ACT_GLIDE,
    vehicle = {
        ["prop_vehicle_prisoner_pod"] = {"podpose", Vector(-3, 0, 0)},
        ["prop_vehicle_jeep"] = {ACT_BUSY_SIT_CHAIR, Vector(14, 0, -14)},
        ["prop_vehicle_airboat"] = {ACT_BUSY_SIT_CHAIR, Vector(8, 0, -20)},
        chair = {ACT_BUSY_SIT_CHAIR, Vector(1, 0, -23)}
    },
}

--- This table defines the default model-to-animation type mappings used by citizen_female models.
-- @realm shared
lia.anim.citizen_female = {
    normal = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
        [ACT_MP_WALK] = {ACT_WALK, ACT_WALK},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
        [ACT_MP_RUN] = {ACT_RUN, ACT_RUN}
    },
    fist = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
        [ACT_MP_WALK] = {ACT_WALK, ACT_RANGE_AIM_SMG1_LOW},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
        [ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
        [ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_PISTOL},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
        [ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_PISTOL},
        attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
        reload = ACT_RELOAD_PISTOL
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
        [ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE},
        [ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
        attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
        reload = ACT_GESTURE_RELOAD_SMG1
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
        [ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE},
        [ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
        attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
        [ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_PISTOL},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
        [ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_PISTOL},
        attack = ACT_RANGE_ATTACK_THROW
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
        [ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
        [ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
        attack = ACT_MELEE_ATTACK_SWING
    },
    glide = ACT_GLIDE,
    vehicle = lia.anim.citizen_male.vehicle
}

--- This table defines the default model-to-animation type mappings used by metrocop models.
-- @realm shared
lia.anim.metrocop = {
    normal = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW},
        [ACT_MP_WALK] = {ACT_WALK, ACT_WALK},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
        [ACT_MP_RUN] = {ACT_RUN, ACT_RUN}
    },
    fist = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_PISTOL_LOW, ACT_COVER_SMG1_LOW},
        [ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
        [ACT_MP_RUN] = {ACT_RUN, ACT_RUN}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW},
        [ACT_MP_WALK] = {ACT_WALK_PISTOL, ACT_WALK_AIM_PISTOL},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
        [ACT_MP_RUN] = {ACT_RUN_PISTOL, ACT_RUN_AIM_PISTOL},
        attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
        reload = ACT_GESTURE_RELOAD_PISTOL
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW},
        [ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
        [ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW},
        [ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
        [ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_MELEE},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW},
        [ACT_MP_WALK] = {ACT_WALK, ACT_WALK_ANGRY},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
        [ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
        attack = ACT_COMBINE_THROW_GRENADE
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_MELEE},
        [ACT_MP_CROUCH_IDLE] = {ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW},
        [ACT_MP_WALK] = {ACT_WALK, ACT_WALK_ANGRY},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
        [ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
        attack = ACT_MELEE_ATTACK_SWING_GESTURE
    },
    glide = ACT_GLIDE,
    vehicle = {
        chair = {ACT_COVER_PISTOL_LOW, Vector(5, 0, -5)},
        ["prop_vehicle_airboat"] = {ACT_COVER_PISTOL_LOW, Vector(10, 0, 0)},
        ["prop_vehicle_jeep"] = {ACT_COVER_PISTOL_LOW, Vector(18, -2, 4)},
        ["prop_vehicle_prisoner_pod"] = {ACT_IDLE, Vector(-4, -0.5, 0)}
    }
}

--- This table defines the default model-to-animation type mappings used by overwatch models.
-- @realm shared
lia.anim.overwatch = {
    normal = {
        [ACT_MP_STAND_IDLE] = {"idle_unarmed", "idle_unarmed"},
        [ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
        [ACT_MP_WALK] = {"walkunarmed_all", "walkunarmed_all"},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
        [ACT_MP_RUN] = {ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE}
    },
    fist = {
        [ACT_MP_STAND_IDLE] = {"idle_unarmed", ACT_IDLE_ANGRY},
        [ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
        [ACT_MP_WALK] = {"walkunarmed_all", ACT_WALK_RIFLE},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
        [ACT_MP_RUN] = {ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {"idle_unarmed", ACT_IDLE_ANGRY_SMG1},
        [ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
        [ACT_MP_WALK] = {"walkunarmed_all", ACT_WALK_RIFLE},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
        [ACT_MP_RUN] = {ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1},
        [ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
        [ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
        [ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SHOTGUN},
        [ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
        [ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_SHOTGUN},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
        [ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_SHOTGUN}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {"idle_unarmed", ACT_IDLE_ANGRY},
        [ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
        [ACT_MP_WALK] = {"walkunarmed_all", ACT_WALK_RIFLE},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
        [ACT_MP_RUN] = {ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {"idle_unarmed", ACT_IDLE_ANGRY},
        [ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
        [ACT_MP_WALK] = {"walkunarmed_all", ACT_WALK_RIFLE},
        [ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
        [ACT_MP_RUN] = {ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE},
        attack = ACT_MELEE_ATTACK_SWING_GESTURE
    },
    glide = ACT_GLIDE
}

--- This table defines the default model-to-animation type mappings used by vortigaunt models.
-- @realm shared
lia.anim.vort = {
    normal = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE},
        [ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
        [ACT_MP_WALK] = {ACT_WALK, ACT_WALK},
        [ACT_MP_CROUCHWALK] = {ACT_WALK, ACT_WALK},
        [ACT_MP_RUN] = {ACT_RUN, ACT_RUN}
    },
    fist = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, "actionidle"},
        [ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
        [ACT_MP_WALK] = {ACT_WALK, "walk_all_holdgun"},
        [ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdgun"},
        [ACT_MP_RUN] = {ACT_RUN, ACT_RUN}
    },
    pistol = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, "tcidle"},
        [ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
        [ACT_MP_WALK] = {ACT_WALK, "walk_all_holdgun"},
        [ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdgun"},
        [ACT_MP_RUN] = {ACT_RUN, "run_all_tc"}
    },
    smg = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, "tcidle"},
        [ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
        [ACT_MP_WALK] = {ACT_WALK, "walk_all_holdgun"},
        [ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdgun"},
        [ACT_MP_RUN] = {ACT_RUN, "run_all_tc"}
    },
    shotgun = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, "tcidle"},
        [ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
        [ACT_MP_WALK] = {ACT_WALK, "walk_all_holdgun"},
        [ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdgun"},
        [ACT_MP_RUN] = {ACT_RUN, "run_all_tc"}
    },
    grenade = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, "tcidle"},
        [ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
        [ACT_MP_WALK] = {ACT_WALK, "walk_all_holdgun"},
        [ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdgun"},
        [ACT_MP_RUN] = {ACT_RUN, "run_all_tc"}
    },
    melee = {
        [ACT_MP_STAND_IDLE] = {ACT_IDLE, "tcidle"},
        [ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
        [ACT_MP_WALK] = {ACT_WALK, "walk_all_holdgun"},
        [ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdgun"},
        [ACT_MP_RUN] = {ACT_RUN, "run_all_tc"}
    },
    glide = ACT_GLIDE
}

--- This table defines the default model-to-animation type mappings used by player models.
-- @realm shared
lia.anim.player = {
    normal = {
        [ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE,
        [ACT_MP_CROUCH_IDLE] = ACT_HL2MP_IDLE_CROUCH,
        [ACT_MP_WALK] = ACT_HL2MP_WALK,
        [ACT_MP_RUN] = ACT_HL2MP_RUN
    },
    passive = {
        [ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE_PASSIVE,
        [ACT_MP_WALK] = ACT_HL2MP_WALK_PASSIVE,
        [ACT_MP_CROUCHWALK] = ACT_HL2MP_WALK_CROUCH_PASSIVE,
        [ACT_MP_RUN] = ACT_HL2MP_RUN_PASSIVE
    }
}

--- This table defines the default model-to-animation type mappings used by zombie models.
-- @realm shared
lia.anim.zombie = {
    [ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE_ZOMBIE,
    [ACT_MP_CROUCH_IDLE] = ACT_HL2MP_IDLE_CROUCH_ZOMBIE,
    [ACT_MP_CROUCHWALK] = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01,
    [ACT_MP_WALK] = ACT_HL2MP_WALK_ZOMBIE_02,
    [ACT_MP_RUN] = ACT_HL2MP_RUN_ZOMBIE
}

--- This table defines the default model-to-animation type mappings used by fastZombie models.
-- @realm shared
lia.anim.fastZombie = {
    [ACT_MP_STAND_IDLE] = ACT_HL2MP_WALK_ZOMBIE,
    [ACT_MP_CROUCH_IDLE] = ACT_HL2MP_IDLE_CROUCH_ZOMBIE,
    [ACT_MP_CROUCHWALK] = ACT_HL2MP_WALK_CROUCH_ZOMBIE_05,
    [ACT_MP_WALK] = ACT_HL2MP_WALK_ZOMBIE_06,
    [ACT_MP_RUN] = ACT_HL2MP_RUN_ZOMBIE_FAST
}

-- This table defines the animation hold type translations for various weapon types in the game.
-- These translations determine the animation style a character will use when holding a particular weapon.
-- @realm shared
lia.anim.HoldTypeTranslator = {
    [""] = "normal",
    ["physgun"] = "smg",
    ["ar2"] = "smg",
    ["crossbow"] = "shotgun",
    ["rpg"] = "shotgun",
    ["slam"] = "normal",
    ["grenade"] = "grenade",
    ["melee2"] = "melee",
    ["passive"] = "smg",
    ["knife"] = "melee",
    ["duel"] = "pistol",
    ["camera"] = "smg",
    ["magic"] = "normal",
    ["revolver"] = "pistol"
}

-- This table defines the player hold type translations for various weapon types in the game.
-- These translations determine the default animation style a character will use for certain player actions.
-- @realm shared
lia.anim.PlayerHoldTypeTranslator = {
    [""] = "normal",
    ["normal"] = "normal",
    ["revolver"] = "normal",
    ["fist"] = "normal",
    ["pistol"] = "normal",
    ["grenade"] = "normal",
    ["melee"] = "normal",
    ["slam"] = "normal",
    ["melee2"] = "normal",
    ["knife"] = "normal",
    ["duel"] = "normal",
    ["bugbait"] = "normal"
}

--- This table defines the default model-to-animation type mappings used to fix T-posing issues in Lilia.
-- You can override these settings by placing a modified version in your config folder within the schema.
-- @realm shared
lia.anim.DefaultTposingFixer = {
    ["models/Zombie/Classic.mdl"] = "zombie",
    ["models/Zombie/Classic_legs.mdl"] = "zombie",
    ["models/Zombie/Classic_torso.mdl"] = "zombie",
    ["models/Gibs/Fast_Zombie_Torso.mdl"] = "fastZombie",
    ["models/Zombie/Fast.mdl"] = "fastZombie",
    ["models/Gibs/Fast_Zombie_Legs.mdl"] = "fastZombie",
    ["models/Police.mdl"] = "metrocop",
    ["models/Combine_Soldier.mdl"] = "overwatch",
    ["models/Combine_Soldier_PrisonGuard.mdl"] = "overwatch",
    ["models/Combine_Super_Soldier.mdl"] = "overwatch",
    ["models/vortigaunt.mdl"] = "vort",
    ["models/vortigaunt_blue.mdl"] = "vort",
    ["models/vortigaunt_doctor.mdl"] = "vort",
    ["models/vortigaunt_slave.mdl"] = "vort",
    ["models/alyx.mdl"] = "citizen_female",
    ["models/mossman.mdl"] = "citizen_female",
    ["models/Barney.mdl"] = "citizen_male",
    ["models/breen.mdl"] = "citizen_male",
    ["models/Eli.mdl"] = "citizen_male",
    ["models/gman_high.mdl"] = "citizen_male",
    ["models/Kleiner.mdl"] = "citizen_male",
    ["models/monk.mdl"] = "citizen_male",
}

--- This table defines the default paths for citizen models in Lilia.
-- These paths are used to determine which models should use citizen animations.
-- You can override these settings by placing a modified version in your config folder within the schema.
-- @realm shared
lia.anim.CitizenModelPaths = {"models/humans/factory", "models/betacz/group01", "models/thespireroleplay/humans", "models/suits/humans", "models/humans/group01", "models/humans/group02", "models/humans/group03", "models/humans/group03m",}
--- Sets a model's animation class.
-- @realm shared
-- @string model Model name to set the animation class for
-- @string class Animation class to assign to the model
-- @usage lia.anim.setModelClass("models/police.mdl", "metrocop")
function lia.anim.setModelClass(model, class)
    if not lia.anim[class] then error("'" .. tostring(class) .. "' is not a valid animation class!") end
    translations[model:lower()] = class
end

--- Gets a model's animation class.
-- @realm shared
-- @string model Model to get the animation class for
-- @treturn[1] string Animation class of the model
-- @treturn[2] nil If there was no animation associated with the given model
-- @usage lia.anim.getModelClass("models/police.mdl")
-- > metrocop
function lia.anim.getModelClass(model)
    model = string.lower(model)
    local class = translations[model] or "player"
    if class ~= "player" then return class end
    return class
end

function player_manager.TranslateToPlayerModelName(model)
    model = model:lower():gsub("\\", "/")
    local result = TranslateModel(model)
    if result == "kleiner" and not model:find("kleiner") then
        local model2 = model:gsub("models/", "models/player/")
        result = TranslateModel(model2)
        if result ~= "kleiner" then return result end
        model2 = model:gsub("models/humans", "models/player")
        result = TranslateModel(model2)
        if result ~= "kleiner" then return result end
        model2 = model:gsub("models/zombie/", "models/player/zombie_")
        result = TranslateModel(model2)
        if result ~= "kleiner" then return result end
    end
    return result
end
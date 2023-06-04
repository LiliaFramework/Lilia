local translations = {}
lia.anim = lia.anim or {}
CachedModels = CachedModels or {}

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

lia.anim.zombie = {
    [ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE_ZOMBIE,
    [ACT_MP_CROUCH_IDLE] = ACT_HL2MP_IDLE_CROUCH_ZOMBIE,
    [ACT_MP_CROUCHWALK] = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01,
    [ACT_MP_WALK] = ACT_HL2MP_WALK_ZOMBIE_02,
    [ACT_MP_RUN] = ACT_HL2MP_RUN_ZOMBIE
}

lia.anim.fastZombie = {
    [ACT_MP_STAND_IDLE] = ACT_HL2MP_WALK_ZOMBIE,
    [ACT_MP_CROUCH_IDLE] = ACT_HL2MP_IDLE_CROUCH_ZOMBIE,
    [ACT_MP_CROUCHWALK] = ACT_HL2MP_WALK_CROUCH_ZOMBIE_05,
    [ACT_MP_WALK] = ACT_HL2MP_WALK_ZOMBIE_06,
    [ACT_MP_RUN] = ACT_HL2MP_RUN_ZOMBIE_FAST
}

ModelTranslations = {
    male_shared = "citizen_male",
    female_shared = "citizen_female",
    police_animations = "metrocop",
    combine_soldier_anims = "overwatch",
    vortigaunt_anims = "vortigaunt",
    m_anm = "player",
    f_anm = "player",
}

local function UpdateAnimationTable(client)
    local baseTable = lia.anim[client.liaAnimModelClass] or {}
    client.liaAnimTable = baseTable[client.liaAnimHoldType]
    client.liaAnimGlide = baseTable["glide"]
end

function lia.anim.setModelClass(model, class)
    if not lia.anim[class] then return end
    CachedModels[model] = class
    lia.anim.setModelClass(model, class)
end

function GM:PlayerModelChanged(ply, model)
    if not IsValid(ply) then return end

    timer.Simple(0, function()
        if not IsValid(ply) then return end

        if not self.cached[model] then
            local submodels = ply:GetSubModels()

            for k, v in pairs(submodels) do
                local class = v.name:gsub(".*/([^/]+)%.%w+$", "%1"):lower()

                if ModelTranslations[class] then
                    lia.anim.setModelClass(model, ModelTranslations[class])
                    break
                end
            end
        end

        ply.liaAnimModelClass = lia.anim.getModelClass(model)
        UpdateAnimationTable(ply)
    end)
end

function lia.anim.setModelClass(model, class)
    if not lia.anim[class] then
        error("'" .. tostring(class) .. "' is not a valid animation class!")
    end

    translations[model:lower()] = class
end

-- Micro-optimization since the get class function gets called a lot.
local stringLower = string.lower
local stringFind = string.find

function lia.anim.getModelClass(model)
    model = stringLower(model)
    local class = translations[model]
    if class then return class end

    if model:find("/player") then
        class = "player"
    elseif stringFind(model, "female") then
        class = "citizen_female"
    else
        class = "citizen_male"
    end

    lia.anim.setModelClass(model, class)

    return class
end

lia.anim.setModelClass("models/police.mdl", "metrocop")
lia.anim.setModelClass("models/combine_super_soldier.mdl", "overwatch")
lia.anim.setModelClass("models/combine_soldier_prisonGuard.mdl", "overwatch")
lia.anim.setModelClass("models/combine_soldier.mdl", "overwatch")
lia.anim.setModelClass("models/vortigaunt.mdl", "vort")
lia.anim.setModelClass("models/vortigaunt_blue.mdl", "vort")
lia.anim.setModelClass("models/vortigaunt_doctor.mdl", "vort")
lia.anim.setModelClass("models/vortigaunt_slave.mdl", "vort")
lia.anim.setModelClass("models/vortigaunt_slave.mdl", "vort")
lia.anim.setModelClass("models/alyx.mdl", "citizen_female")
lia.anim.setModelClass("models/mossman.mdl", "citizen_female")

do
    local playerMeta = FindMetaTable("Player")

    function playerMeta:forceSequence(sequence, callback, time, noFreeze)
        hook.Run("OnPlayerEnterSequence", self, sequence, callback, time, noFreeze)
        if not sequence then return netstream.Start(nil, "seqSet", self) end
        local sequence = self:LookupSequence(sequence)

        if sequence and sequence > 0 then
            time = time or self:SequenceDuration(sequence)
            self.liaSeqCallback = callback
            self.liaForceSeq = sequence

            if not noFreeze then
                self:SetMoveType(MOVETYPE_NONE)
            end

            if time > 0 then
                timer.Create("liaSeq" .. self:EntIndex(), time, 1, function()
                    if IsValid(self) then
                        self:leaveSequence()
                    end
                end)
            end

            netstream.Start(nil, "seqSet", self, sequence)

            return time
        end

        return false
    end

    function playerMeta:leaveSequence()
        hook.Run("OnPlayerLeaveSequence", self)
        netstream.Start(nil, "seqSet", self)
        self:SetMoveType(MOVETYPE_WALK)
        self.liaForceSeq = nil

        if self.liaSeqCallback then
            self:liaSeqCallback()
        end
    end

    if CLIENT then
        netstream.Hook("seqSet", function(entity, sequence)
            if IsValid(entity) then
                if not sequence then
                    entity.liaForceSeq = nil

                    return
                end

                entity:SetCycle(0)
                entity:SetPlaybackRate(1)
                entity.liaForceSeq = sequence
            end
        end)
    end
end
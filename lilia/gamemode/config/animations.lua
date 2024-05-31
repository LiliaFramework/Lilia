--- Default animation configurations for Lilia.
-- @configurationgeneral Animations

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
lia.anim.CitizenModelPaths = {"models/humans/factory","models/betacz/group01", "models/thespireroleplay/humans", "models/suits/humans", "models/humans/group01", "models/humans/group02", "models/humans/group03", "models/humans/group03m",}
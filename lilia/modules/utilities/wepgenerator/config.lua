MODULE.WeaponOverrides = {
    ["weapon_pistol"] = {
        name = "Custom Pistol",
        desc = "A custom description for the pistol.",
        model = "models/weapons/w_custom_pistol.mdl",
        class = "weapon_pistol",
        height = 2,
        width = 2,
        category = "weapons",
        weaponCategory = "sidearm",
        RequiredSkillLevels = nil,
    },
}

MODULE.RegisterWeaponsBlackList = {
    sf2_tool = true,
    weapon_fists = true,
    weapon_medkit = true,
    gmod_camera = true,
    gmod_tool = true,
    lightning_gun = true,
    lia_hands = true,
    lia_keys = true,
}
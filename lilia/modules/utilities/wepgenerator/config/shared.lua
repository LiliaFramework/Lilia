MODULE.AutomaticWeaponRegister = true
MODULE.NotifyWeaponRegister = false
MODULE.RegisterWeaponsBlackList = {"sf2_tool", "weapon_fists", "weapon_medkit", "gmod_camera", "gmod_tool", "lightning_gun", "lia_hands", "lia_keys",}
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
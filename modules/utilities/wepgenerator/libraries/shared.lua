local AutomaticWeaponRegister = true
local WeaponOverrides = {
    ["weapon_pistol"] = {
        name = "Custom Pistol",
        desc = "A custom description for the pistol.",
        model = "models/weapons/w_custom_pistol.mdl",
        class = "weapon_pistol",
        height = 1,
        width = 1,
        category = "weapons",
        weaponCategory = "sidearm",
        RequiredSkillLevels = nil,
    },
}

local RegisterWeaponsBlackList = {
    sf2_tool = true,
    weapon_fists = true,
    weapon_medkit = true,
    gmod_camera = true,
    gmod_tool = true,
    lightning_gun = true,
    lia_hands = true,
    lia_keys = true,
}

local holdTypeToWeaponCategory = {
    grenade = "grenade",
    pistol = "sidearm",
    smg = "primary",
    ar2 = "primary",
    rpg = "primary",
    shotgun = "primary",
    crossbow = "primary",
    normal = "primary",
    melee = "secondary",
    melee2 = "secondary",
    fist = "secondary",
    knife = "secondary",
    physgun = "secondary",
    slam = "secondary",
    passive = "secondary",
}

local holdTypeSizeMapping = {
    grenade = {
        width = 1,
        height = 1
    },
    pistol = {
        width = 1,
        height = 1
    },
    smg = {
        width = 2,
        height = 1
    },
    ar2 = {
        width = 2,
        height = 2
    },
    rpg = {
        width = 1,
        height = 2
    },
    shotgun = {
        width = 2,
        height = 1
    },
    crossbow = {
        width = 1,
        height = 2
    },
    normal = {
        width = 2,
        height = 1
    },
    melee = {
        width = 1,
        height = 1
    },
    melee2 = {
        width = 1,
        height = 1
    },
    fist = {
        width = 1,
        height = 1
    },
    knife = {
        width = 1,
        height = 1
    },
    physgun = {
        width = 2,
        height = 1
    },
    slam = {
        width = 1,
        height = 2
    },
    passive = {
        width = 1,
        height = 1
    },
}

local function RegisterWeapons()
    for _, wep in ipairs(weapons.GetList()) do
        local className = wep.ClassName
        if not className or className:find("_base") or RegisterWeaponsBlackList[className] then continue end
        local override = WeaponOverrides and WeaponOverrides[className] or {}
        local holdType = wep.HoldType or "normal"
        local isGrenade = holdType == "grenade"
        local baseType = isGrenade and "base_grenade" or "base_weapons"
        local ITEM = lia.item.register(className, baseType, nil, nil, true)
        ITEM.name = override.name or wep.PrintName or className
        ITEM.desc = override.desc or "A Weapon"
        ITEM.model = override.model or wep.WorldModel or wep.WM or "models/props_c17/suitcase_passenger_physics.mdl"
        ITEM.class = override.class or className
        local sizeMapping = holdTypeSizeMapping[holdType] or {
            width = 2,
            height = 1
        }

        ITEM.width = override.width or sizeMapping.width
        ITEM.height = override.height or sizeMapping.height
        ITEM.weaponCategory = override.weaponCategory or holdTypeToWeaponCategory[holdType] or "primary"
        ITEM.category = isGrenade and "grenade" or "weapons"
    end
end

function MODULE:InitializedModules()
    if AutomaticWeaponRegister then RegisterWeapons() end
end
local AutomaticWeaponRegister = true
local NotifyWeaponRegister = false
local WeaponOverrides = {
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

local function RegisterWeapons()
    for _, wep in ipairs(weapons.GetList()) do
        local className = wep.ClassName
        if not className or className:find("_base") or RegisterWeaponsBlackList[className] then continue end
        local override = WeaponOverrides and WeaponOverrides[className] or {}
        local ITEM = lia.item.register(className, "base_weapons", nil, nil, true)
        ITEM.name = override.name or wep.PrintName or className
        ITEM.desc = override.desc or "A Weapon"
        ITEM.model = override.model or wep.WorldModel or "models/props_c17/oildrum001.mdl"
        ITEM.class = override.class or className
        ITEM.height = override.height or 2
        ITEM.width = override.width or 2
        ITEM.weaponCategory = override.weaponCategory
        ITEM.RequiredSkillLevels = override.RequiredSkillLevels or {}
        ITEM.category = override.category or "Weapons"
        if ITEM.name ~= className and NotifyWeaponRegister then LiliaInformation("Generated weapon: " .. ITEM.name) end
    end
end

function MODULE:InitializedModules()
    if AutomaticWeaponRegister then RegisterWeapons() end
end

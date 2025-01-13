local AutomaticWeaponRegister = true
local NotifyWeaponRegister = false
function MODULE:InitializedModules()
    if AutomaticWeaponRegister then self:RegisterWeapons() end
end

function MODULE:RegisterWeapons()
    for _, wep in ipairs(weapons.GetList()) do
        local className = wep.ClassName
        if not className or className:find("_base") or self.RegisterWeaponsBlackList[className] then continue end
        local override = self.WeaponOverrides and self.WeaponOverrides[className] or {}
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
function MODULE:InitializedModules()
    if self.AutomaticWeaponRegister then self:RegisterWeapons() end
end

function MODULE:RegisterWeapons()
    for _, wep in ipairs(weapons.GetList()) do
        if string.find(wep.ClassName, "_base") or table.HasValue(self.RegisterWeaponsBlackList, wep.ClassName) or not wep.ClassName then continue end
        local ITEM = lia.item.register(wep.ClassName, "base_weapons", nil, nil, true)
        local override = self.WeaponOverrides[wep.ClassName]
        ITEM.name = override and override.name or wep.PrintName or wep.ClassName
        ITEM.desc = override and override.desc or "A Weapon"
        ITEM.model = override and override.model or wep.WorldModel
        ITEM.class = override and override.class or wep.ClassName
        ITEM.height = override and override.height or 2
        ITEM.width = override and override.width or 2
        ITEM.weaponCategory = override and override.weaponCategory or nil
        ITEM.RequiredSkillLevels = override and override.RequiredSkillLevels or {}
        ITEM.category = override and override.category or "Weapons"
        if ITEM.name ~= wep.ClassName and self.NotifyWeaponRegister then LiliaInformation("Generated weapon: " .. ITEM.name) end
    end
end

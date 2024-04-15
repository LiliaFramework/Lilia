function MODULE:InitializedModules()
    if self.AutomaticWeaponRegister then self:RegisterWeapons() end
end

function MODULE:RegisterWeapons()
    for _, wep in ipairs(weapons.GetList()) do
        if table.HasValue(self.RegisterWeaponsBlackList, wep.ClassName) or not wep.ClassName then continue end
        local ITEM = lia.item.register(wep.ClassName, "base_weapons", nil, nil, true)
        ITEM.name = (wep.PrintName or self.WeaponNameOverrides[wep.ClassName]) or wep.ClassName
        ITEM.desc = "A Weapon"
        ITEM.model = wep.WorldModel
        ITEM.class = wep.ClassName
        ITEM.weaponCategory = "primary"
        ITEM.height = 2
        ITEM.width = 2
        ITEM.category = "Weapons"
        if ITEM.name ~= wep.ClassName then print("Generated weapon:", ITEM.name) end
    end
end

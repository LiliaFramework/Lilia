--------------------------------------------------------------------------------------------------------
lia.EasyRegister = lia.EasyRegister or {}
--------------------------------------------------------------------------------------------------------
function MODULE:RegisterWeapons()
    for _, wep in ipairs(weapons.GetList()) do
        if table.HasValue(lia.config.RegisterWeaponsBlackList, wep.ClassName) then continue end
        local ITEM = lia.item.register(wep.ClassName, "base_weapons", nil, nil, true)
        ITEM.name = wep.PrintName
        ITEM.desc = "A Weapon"
        ITEM.model = wep.WorldModel
        ITEM.class = wep.ClassName
        ITEM.weaponCategory = "primary"
        ITEM.height = 2
        ITEM.width = 2
        ITEM.category = "Weapons"
    end
end

--------------------------------------------------------------------------------------------------------
function MODULE:RegisterMelee(id, data, category)
    local ITEM = lia.item.register(id, "base_weapons", nil, nil, true)
    ITEM.name = data["name"]
    ITEM.desc = data["desc"]
    ITEM.model = data["model"]
    ITEM.class = data["class"]
    ITEM.weaponCategory = "melee"
    ITEM.width = data["width"] or 1
    ITEM.height = data["height"] or 1
    ITEM.price = data["price"]
    ITEM.category = "Weapons"
end

--------------------------------------------------------------------------------------------------------
function MODULE:RegisterAmmo(id, data)
    local ITEM = lia.item.register(id, "base_ammo", nil, nil, true)
    ITEM.name = data["name"]
    ITEM.desc = data["desc"]
    ITEM.ammo = data["ammo"]
    ITEM.model = data["model"]
    ITEM.price = data["price"]
    ITEM.width = data["width"] or 1
    ITEM.height = data["height"] or 1
    ITEM.category = "Ammo"
    ITEM.ammoAmount = data["amount"] or 30
    ITEM.ammoDesc = data["ammoDesc"]
end

--------------------------------------------------------------------------------------------------------
function MODULE:RegisterEnts(id, data, base)
    local ITEM = lia.item.register(id, "base_ents", nil, nil, true)
    ITEM.name = data["name"]
    ITEM.desc = data["desc"]
    ITEM.model = data["model"]
    ITEM.price = data["price"]
    ITEM.width = data["width"] or 1
    ITEM.height = data["height"] or 1
    ITEM.category = "Entities"
    ITEM.entdrop = data["entity"]
end

--------------------------------------------------------------------------------------------------------
function MODULE:RegisterItem(id, data, base)
    local ITEM = lia.item.register(id, "base_junk", nil, nil, true)
    ITEM.name = data["name"]
    ITEM.desc = data["desc"]
    ITEM.model = data["model"]
    ITEM.price = data["price"]
    ITEM.width = data["width"] or 1
    ITEM.height = data["height"] or 1
end

--------------------------------------------------------------------------------------------------------
function MODULE:RegisterWeapon(id, data, category)
    local ITEM = lia.item.register(id, "base_weapons", nil, nil, true)
    ITEM.name = data["name"]
    ITEM.desc = data["desc"]
    ITEM.model = data["model"]
    ITEM.class = data["class"]
    ITEM.weaponCategory = category or "primary"
    ITEM.width = data["width"] or 1
    ITEM.height = data["height"] or 1
    ITEM.price = data["price"]
    ITEM.category = "Weapons"
end

--------------------------------------------------------------------------------------------------------
function MODULE:InitializedModules()
    if lia.config.EasyItemRegisterEnabled then
        for i, v in pairs(lia.EasyRegister) do
            if i == "primary" or i == "secondary" then
                for x, y in pairs(v) do
                    self:RegisterWeapon(x, y, i)
                end
            elseif i == "melee" then
                for x, y in pairs(v) do
                    self:RegisterMelee(x, y, i)
                end
            elseif i == "ammo" then
                for x, y in pairs(v) do
                    self:RegisterAmmo(x, y)
                end
            elseif i == "entities" then
                for x, y in pairs(v) do
                    self:RegisterEnts(x, y)
                end
            else
                for x, y in pairs(v) do
                    self:RegisterItem(x, y, i)
                end
            end
        end
    end

    if lia.config.AutomaticWeaponRegister then
        self:RegisterWeapons()
    end
end
--------------------------------------------------------------------------------------------------------
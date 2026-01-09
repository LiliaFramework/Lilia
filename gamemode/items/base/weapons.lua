--[[
    Folder: Definitions
    File:  weapons.md
]]
--[[
    Weapons Item Definition

    Weapon item system for the Lilia framework.
]]
--[[
    Weapon items are equippable weapons that can be given to players.
    They support ammo tracking, weapon categories, and visual indicators.

    PLACEMENT:
    - Place in: ModuleFolder/items/weapons/ItemHere.lua (for module-specific items)
    - Place in: SchemaFolder/items/weapons/ItemHere.lua (for schema-specific items)

    USAGE:
    - Weapon items are equipped by using them
    - They give the weapon specified in ITEM.class
    - Items remain in inventory when equipped
    - Can be unequipped to remove weapons
    - Weapons drop on death if ITEM.DropOnDeath is true
]]
--[[
    Purpose:
        Sets the display name shown to players

    Example Usage:
        ```lua
        -- Set the weapon name
        ITEM.name = "Pistol"
        ```
]]
ITEM.name = "weaponsName"
--[[
    Purpose:
        Sets the description text shown to players

    Example Usage:
        ```lua
        -- Set the weapon description
        ITEM.desc = "A standard 9mm pistol with moderate damage"
        ```
]]
ITEM.desc = "weaponsDesc"
--[[
    Purpose:
        Sets the category for inventory sorting and organization

    Example Usage:
        ```lua
        -- Set inventory category
        ITEM.category = "weapons"
        ```
]]
ITEM.category = "weapons"
--[[
    Purpose:
        Sets the 3D model used for the item

    Example Usage:
        ```lua
        -- Set the weapon model
        ITEM.model = "models/weapons/w_pistol.mdl"
        ```
]]
ITEM.model = "models/weapons/w_pistol.mdl"
--[[
    Purpose:
        Sets the weapon entity class that gets given to players

    Example Usage:
        ```lua
        -- Set the weapon class
        ITEM.class = "weapon_pistol"
        ```
]]
ITEM.class = "weapon_pistol"
--[[
    Purpose:
        Sets the inventory width in slots

    Example Usage:
        ```lua
        -- Set inventory width
        ITEM.width = 2
        ```
]]
ITEM.width = 2
--[[
    Purpose:
        Sets the inventory height in slots

    Example Usage:
        ```lua
        -- Set inventory height
        ITEM.height = 2
        ```
]]
ITEM.height = 2
--[[
    Purpose:
        Marks this item as a weapon for special handling

    Example Usage:
        ```lua
        -- Mark as weapon item
        ITEM.isWeapon = true
        ```
]]
ITEM.isWeapon = true
--[[
    Purpose:
        Sets required skill levels to equip this weapon

    Example Usage:
        ```lua
        -- Set required skill levels
        ITEM.RequiredSkillLevels = {
            ["guns"] = 5
        }
        ```
]]
ITEM.RequiredSkillLevels = {}
--[[
    Purpose:
        Determines whether weapon drops on player death

    Example Usage:
        ```lua
        -- Make weapon drop on death
        ITEM.DropOnDeath = true
        ```
]]
ITEM.DropOnDeath = true
function ITEM.postHooks:drop()
    local client = self.player
    if not client or not IsValid(client) then return end
    if client:HasWeapon(self.class) then
        client:notifyErrorLocalized("invalidWeapon")
        client:StripWeapon(self.class)
    end
end

ITEM:hook("drop", function(item)
    local client = item.player
    if not client or not IsValid(client) then return false end
    if IsValid(client:GetRagdollEntity()) then
        client:notifyErrorLocalized("noRagdollAction")
        return false
    end

    if item:getData("equip") then
        item:setData("equip", nil)
        local weapon = client:GetWeapon(item.class)
        if IsValid(weapon) then
            item:setData("ammo", weapon:Clip1())
            client:StripWeapon(item.class)
            client:EmitSound(item.unequipSound or "items.unequipSound", 80)
        end
    end
end)

ITEM.functions.Unequip = {
    name = "unequip",
    tip = "equipTip",
    icon = "icon16/cross.png",
    onRun = function(item)
        local client = item.player
        if not client or not IsValid(client) then return false end
        if IsValid(client:GetRagdollEntity()) then
            client:notifyErrorLocalized("noRagdollAction")
            return false
        end

        local weapon = client:GetWeapon(item.class)
        if weapon and IsValid(weapon) then
            item:setData("ammo", weapon:Clip1())
            client:StripWeapon(item.class)
        else
            lia.error(L("weaponDoesNotExist", item.class))
        end

        client:EmitSound(item.unequipSound or "items/ammo_pickup.wav", 80)
        item:setData("equip", nil)
        if item.onUnequipWeapon then item:onUnequipWeapon(client, weapon) end
        return false
    end,
    onCanRun = function(item) return not IsValid(item.entity) and item:getData("equip", false) end
}

ITEM.functions.Equip = {
    name = "equip",
    tip = "equipTip",
    icon = "icon16/tick.png",
    onRun = function(item)
        local client = item.player
        if not client or not IsValid(client) then return false end
        if IsValid(client:GetRagdollEntity()) then
            client:notifyErrorLocalized("noRagdollAction")
            return false
        end

        local items = client:getChar():getInv():getItems()
        if item.weaponCategory then
            for _, v in pairs(items) do
                if v.id ~= item.id and v.isWeapon and v.weaponCategory == item.weaponCategory and v:getData("equip") then
                    client:notifyErrorLocalized("weaponSlotFilled")
                    return false
                end
            end
        end

        if client:HasWeapon(item.class) then client:StripWeapon(item.class) end
        local weapon = client:Give(item.class, true)
        if IsValid(weapon) then
            timer.Simple(0, function() client:SelectWeapon(weapon:GetClass()) end)
            client:EmitSound(item.equipSound or "items/ammo_pickup.wav", 80)
            local ammoCount = client:GetAmmoCount(weapon:GetPrimaryAmmoType())
            if ammoCount == weapon:Clip1() and item:getData("ammo", 0) == 0 then client:RemoveAmmo(weapon:Clip1(), weapon:GetPrimaryAmmoType()) end
            item:setData("equip", true)
            weapon:SetClip1(item:getData("ammo", 0))
            if item.onEquipWeapon then item:onEquipWeapon(client, weapon) end
        else
            lia.error(L("weaponDoesNotExist", item.class))
        end
        return false
    end,
    onCanRun = function(item) return not IsValid(item.entity) and not item:getData("equip", false) end
}

function ITEM:OnCanBeTransfered(_, newInventory)
    if newInventory and self:getData("equip") then return false end
    return true
end

function ITEM:onLoadout()
    if self:getData("equip") then
        local client = self.player
        if not client or not IsValid(client) then return end
        local weapon = client:Give(self.class, true)
        if IsValid(weapon) then
            client:RemoveAmmo(weapon:Clip1(), weapon:GetPrimaryAmmoType())
            weapon:SetClip1(self:getData("ammo", 0))
        else
            lia.error(L("weaponDoesNotExist", self.class))
        end
    end
end

function ITEM:OnSave()
    local client = self.player
    if not client or not IsValid(client) then return end
    local weapon = client:GetWeapon(self.class)
    if IsValid(weapon) then self:setData("ammo", weapon:Clip1()) end
end

if CLIENT then
    function ITEM:getName()
        local weapon = weapons.GetStored(self.class)
        if weapon and weapon.PrintName then return language.GetPhrase(weapon.PrintName) end
        return self.name
    end

    function ITEM:paintOver(item, w, h)
        if item:getData("equip") then
            surface.SetDrawColor(110, 255, 110, 100)
            surface.DrawRect(w - 14, h - 14, 8, 8)
        end
    end
end

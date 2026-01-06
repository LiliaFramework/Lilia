--[[
    Folder: Items/Base
    File:  weapons.lua
]]
--[[
    Weapons Item Base

    Base weapon item implementation for the Lilia framework.

    Weapon items are equippable weapons that can be given to players.
    They support ammo tracking, weapon categories, and visual indicators.
]]
--[[
    Overview:
        Weapon items provide the foundation for all equippable firearms and melee weapons in Lilia. They enable players to equip weapons
        from their inventory with support for ammo preservation, death dropping, skill requirements, and proper weapon management.
        The base implementation includes equip/unequip mechanics, ammo saving/loading, ragdoll prevention, and integration with
        Garry's Mod's weapon system.

        The base weapon item supports:
        - Weapon equipping and unequipping with ammo preservation
        - Death drop mechanics with configurable behavior
        - Ragdoll action prevention during weapon operations
        - Skill level requirements for weapon usage
        - Visual equip indicators in inventory
        - Automatic weapon stripping on invalid drops
        - Integration with Lilia's inventory and character systems
]]

-- Basic item identification
--[[
    Purpose:
        Sets the display name of the weapon item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.name = "Pistol"
        ```
]]
ITEM.name = "weaponsName"
--[[
    Purpose:
        Sets the description of the weapon item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.desc = "A standard issue pistol"
        ```
]]
ITEM.desc = "weaponsDesc"
--[[
    Purpose:
        Sets the category for the weapon item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.category = "weapons"
        ```
]]
ITEM.category = "weapons"
--[[
    Purpose:
        Sets the 3D model for the weapon item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.model = "models/weapons/w_pistol.mdl"
        ```
]]
ITEM.model = "models/weapons/w_pistol.mdl"
--[[
    Purpose:
        Sets the weapon class name

    When Called:
        During item definition (used in equip/unequip functions)

    Example Usage:
        ```lua
        ITEM.class = "weapon_pistol"
        ```
]]
ITEM.class = "weapon_pistol"
--[[
    Purpose:
        Sets the inventory width of the weapon item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.width = 2  -- Takes 2 slot width
        ```
]]
ITEM.width = 2
--[[
    Purpose:
        Sets the inventory height of the weapon item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.height = 2  -- Takes 2 slot height
        ```
]]
ITEM.height = 2
--[[
    Purpose:
        Marks the item as a weapon

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.isWeapon = true
        ```
]]
ITEM.isWeapon = true
--[[
    Purpose:
        Sets required skill levels for the weapon

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.RequiredSkillLevels = {}  -- No skill requirements
        ```
]]
ITEM.RequiredSkillLevels = {}
--[[
    Purpose:
        Sets whether the weapon drops when player dies

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.DropOnDeath = true  -- Drops on death
        ```
]]
ITEM.DropOnDeath = true
--[[
    Purpose:
        Sets the health value for the item when it's dropped as an entity in the world

    When Called:
        During item definition (used when item is spawned as entity)

    Notes:
        - Defaults to 100 if not specified
        - When the item entity takes damage, its health decreases
        - Item is destroyed when health reaches 0
        - Only applies if ITEM.CanBeDestroyed is true (controlled by config)

    Example Usage:
        ```lua
        ITEM.health = 250  -- Weapon can take 250 damage before being destroyed
        ```
]]
ITEM.health = 100

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
        end
    end
end)

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

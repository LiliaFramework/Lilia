ITEM.name = "weaponsName"
ITEM.desc = "weaponsDesc"
ITEM.category = "weapons"
ITEM.model = "models/weapons/w_pistol.mdl"
ITEM.class = "weapon_pistol"
ITEM.width = 2
ITEM.height = 2
ITEM.isWeapon = true
ITEM.weaponCategory = "sidearm"
ITEM.RequiredSkillLevels = {}
ITEM.DropOnDeath = true
function ITEM.postHooks:drop()
    local client = self.player
    if not client or not IsValid(client) then return end
    if client:HasWeapon(self.class) then
        client:notifyLocalized("invalidWeapon")
        client:StripWeapon(self.class)
    end
end

ITEM:hook("drop", function(item)
    local client = item.player
    if not client or not IsValid(client) then return false end
    if IsValid(client:getRagdoll()) then
        client:notifyLocalized("noRagdollAction")
        return false
    end

    if item:getData("equip") then
        item:setData("equip", nil)
        client.carryWeapons = client.carryWeapons or {}
        local weapon = client.carryWeapons[item.weaponCategory]
        if IsValid(weapon) then
            item:setData("ammo", weapon:Clip1())
            client:StripWeapon(item.class)
            client.carryWeapons[item.weaponCategory] = nil
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
        if IsValid(client:getRagdoll()) then
            client:notifyLocalized("noRagdollAction")
            return false
        end

        client.carryWeapons = client.carryWeapons or {}
        local weapon = client.carryWeapons[item.weaponCategory]
        if not weapon or not IsValid(weapon) then weapon = client:GetWeapon(item.class) end
        if weapon and IsValid(weapon) then
            item:setData("ammo", weapon:Clip1())
            client:StripWeapon(item.class)
        else
            lia.error(L("weaponDoesNotExist", item.class))
        end

        client:EmitSound(item.unequipSound or "items/ammo_pickup.wav", 80)
        client.carryWeapons[item.weaponCategory] = nil
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
        if IsValid(client:getRagdoll()) then
            client:notifyLocalized("noRagdollAction")
            return false
        end

        local items = client:getChar():getInv():getItems()
        client.carryWeapons = client.carryWeapons or {}
        for _, v in pairs(items) do
            if v.id ~= item.id and v.isWeapon and client.carryWeapons[item.weaponCategory] and v:getData("equip") then
                client:notifyLocalized("weaponSlotFilled")
                return false
            end
        end

        if client:HasWeapon(item.class) then client:StripWeapon(item.class) end
        local weapon = client:Give(item.class, true)
        if IsValid(weapon) then
            timer.Simple(0, function() client:SelectWeapon(weapon:GetClass()) end)
            client.carryWeapons[item.weaponCategory] = weapon
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
        client.carryWeapons = client.carryWeapons or {}
        local weapon = client:Give(self.class, true)
        if IsValid(weapon) then
            client:RemoveAmmo(weapon:Clip1(), weapon:GetPrimaryAmmoType())
            client.carryWeapons[self.weaponCategory] = weapon
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
# Weapons Item Definition

Weapon items bind inventory entries to SWEP classes. Use them when players should equip, store, drop, and restore weapons through Lilia's item system instead of handling those weapons only as native entities.

## Placement

Use the normal `ITEM` form in item definition files loaded by the item loader, such as `schema/items/[item_id].lua`. If the item should inherit a base, place it under the matching base folder, such as `schema/items/weapons/[item_id].lua` or `modules/[module]/items/weapons/[item_id].lua`. Base item files themselves live under an `items/base` directory, for example `gamemode/items/base/weapons.lua` or `modules/[module]/items/base/weapons.lua`.

Use `lia.item.register` from a shared Lua file when you want to register an item directly from code instead of relying on the item loader's `ITEM` table.

## Reference

| Field | Type | Purpose |
| --- | --- | --- |
| `name` | `string` | Display name shown in the inventory. |
| `desc` | `string` | Description text shown to the player. |
| `category` | `string` | Inventory category used for sorting and grouping. |
| `model` | `string` | World and inventory model used by the item. |
| `class` | `string` | SWEP class granted or restored by the item. |
| `width` | `number` | Inventory width in slots. |
| `height` | `number` | Inventory height in slots. |
| `isWeapon` | `boolean` | Marks the item as a weapon-backed item definition. |
| `RequiredSkillLevels` | `table` | Table of required skill levels. |
| `DropOnDeath` | `boolean` | Controls whether the weapon should be dropped when the player dies. |
| `weaponCategory` | `string` | Optional slot key used to prevent equipping another weapon with the same category. |
| `equipSound` | `string` | Optional sound played when the weapon is equipped. |
| `unequipSound` | `string` | Optional sound played when the weapon is unequipped or dropped while equipped. |

## Callback Fields

| Callback | Purpose |
| --- | --- |
| `postHooks.drop` | Extra drop logic run after the standard item drop flow. |
| `hook("drop", fn)` | Lets the item react when it is dropped. |
| `OnCanBeTransfered(_, newInventory)` | Blocks transfer while the weapon is equipped when the item logic requires it. |
| `onLoadout()` | Restores weapon state when the character loads out. |
| `OnSave()` | Persists any item-side state needed for restoration. |
| `getName()` | Returns a runtime display name, often including ammo or condition state. |

## Normal Item File Example

```lua
ITEM.name = "Pistol"
ITEM.desc = "A standard issue sidearm."
ITEM.category = "weapons"
ITEM.model = "models/weapons/w_pistol.mdl"
ITEM.class = "weapon_pistol"
ITEM.width = 2
ITEM.height = 2
ITEM.isWeapon = true
ITEM.RequiredSkillLevels = {
    guns = 5
}
ITEM.DropOnDeath = true
ITEM.weaponCategory = "sidearm"
ITEM.equipSound = "items/ammo_pickup.wav"
ITEM.unequipSound = "items/ammo_pickup.wav"

ITEM.functions.Equip = {
    name = "equip",
    tip = "equipThisItem",
    icon = "icon16/gun.png",
    onRun = function(item)
        local client = item.player
        if IsValid(client) then
            client:Give(item.class)
        end

        item:setData("equip", true)
        return false
    end
}

function ITEM:onLoadout()
    if self:getData("equip") and IsValid(self.player) then
        self.player:Give(self.class)
    end
end

function ITEM:getName()
    return self.name
end
```

## Direct Registration Example

```lua
local item = lia.item.register("pistol", "base_weapons", false, nil, true)

item.name = "Pistol"
item.desc = "A standard issue sidearm."
item.category = "weapons"
item.model = "models/weapons/w_pistol.mdl"
item.class = "weapon_pistol"
item.width = 2
item.height = 2
item.isWeapon = true
item.RequiredSkillLevels = {
    guns = 5
}
item.DropOnDeath = true
item.weaponCategory = "sidearm"
item.equipSound = "items/ammo_pickup.wav"
item.unequipSound = "items/ammo_pickup.wav"

item.functions.Equip = {
    name = "equip",
    tip = "equipThisItem",
    icon = "icon16/gun.png",
    onRun = function(itemInstance)
        local client = itemInstance.player
        if IsValid(client) then
            client:Give(itemInstance.class)
        end

        itemInstance:setData("equip", true)
        return false
    end
}

function item:onLoadout()
    if self:getData("equip") and IsValid(self.player) then
        self.player:Give(self.class)
    end
end
```

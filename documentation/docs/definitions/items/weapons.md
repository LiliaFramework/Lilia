# Weapons Item Definition

Weapon items bind inventory entries to SWEP classes. Use them when players should equip, store, drop, and restore weapons through Lilia's item system instead of handling those weapons only as native entities.

## Placement

Register weapon items in:

```text
garrysmod/gamemodes/[schema folder]/schema/definitions/sh_items.lua
```

Use `lia.item.registerItem` in that shared file to define the item directly from code.

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

## Example

```lua
lia.item.registerItem("pistol", "base_weapons", {
    name = "Pistol",
    desc = "A standard issue sidearm.",
    category = "weapons",
    model = "models/weapons/w_pistol.mdl",
    class = "weapon_pistol",
    width = 2,
    height = 2,
    isWeapon = true,
    RequiredSkillLevels = {
        guns = 5
    },
    DropOnDeath = true,
    weaponCategory = "sidearm",
    equipSound = "items/ammo_pickup.wav",
    unequipSound = "items/ammo_pickup.wav"
})
```

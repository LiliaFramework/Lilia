# Ammo Item Definition

Ammo items represent stored ammunition inside the inventory. Use them when players should carry ammo as items instead of receiving it only through scripted loadouts or entity pickups.

## Placement

Use the normal `ITEM` form in item definition files loaded by the item loader, such as `schema/items/[item_id].lua`. If the item should inherit a base, place it under the matching base folder, such as `schema/items/ammo/[item_id].lua` or `modules/[module]/items/ammo/[item_id].lua`. Base item files themselves live under an `items/base` directory, for example `gamemode/items/base/ammo.lua` or `modules/[module]/items/base/ammo.lua`.

Use `lia.item.register` from a shared Lua file when you want to register an item directly from code instead of relying on the item loader's `ITEM` table.

## Reference

| Field | Type | Purpose |
| --- | --- | --- |
| `name` | `string` | Display name shown in the inventory. |
| `model` | `string` | World and inventory model used by the item. |
| `width` | `number` | Inventory width in slots. |
| `height` | `number` | Inventory height in slots. |
| `ammo` | `string` | Ammo type granted when the item is used. |
| `category` | `string` | Inventory category used for sorting and grouping. |
| `useSound` | `string` | Optional sound played when ammo is loaded. |

## Normal Item File Example

```lua
ITEM.name = "Pistol Ammo"
ITEM.model = "models/items/boxsrounds.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.ammo = "Pistol"
ITEM.category = "ammo"
ITEM.useSound = "items/ammo_pickup.wav"

ITEM.functions.Use = {
    name = "load",
    tip = "useTip",
    icon = "icon16/box.png",
    onRun = function(item)
        local client = item.player
        if not IsValid(client) then return false end

        client:GiveAmmo(24, item.ammo, true)
        return true
    end
}
```

## Direct Registration Example

```lua
local item = lia.item.register("pistol_ammo", "base_ammo", false, nil, true)

item.name = "Pistol Ammo"
item.model = "models/items/boxsrounds.mdl"
item.width = 1
item.height = 1
item.ammo = "Pistol"
item.category = "ammo"
item.useSound = "items/ammo_pickup.wav"

item.functions.Use = {
    name = "load",
    tip = "useTip",
    icon = "icon16/box.png",
    onRun = function(itemInstance)
        local client = itemInstance.player
        if not IsValid(client) then return false end

        client:GiveAmmo(24, itemInstance.ammo, true)
        return true
    end
}
```

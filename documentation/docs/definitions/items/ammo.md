# Ammo Item Definition

Ammo items represent stored ammunition inside the inventory. Use them when players should carry ammo as items instead of receiving it only through scripted loadouts or entity pickups.

## Placement

Register ammo items in:

```text
garrysmod/gamemodes/[schema folder]/schema/definitions/sh_items.lua
```

Use `lia.item.registerItem` in that shared file to define the item directly from code.

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

## Example

```lua
lia.item.registerItem("pistol_ammo", "base_ammo", {
    name = "Pistol Ammo",
    model = "models/items/boxsrounds.mdl",
    width = 1,
    height = 1,
    ammo = "Pistol",
    category = "ammo",
    useSound = "items/ammo_pickup.wav"
})
```

# Grenade Item Definition

Grenade items wrap throwable weapon classes in inventory form. Use them when a grenade should be carried, dropped, and optionally stripped from the player on death through item state instead of direct weapon-only handling.

## Placement

Register grenade items in:

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
| `class` | `string` | Weapon class granted or represented by the grenade item. |
| `width` | `number` | Inventory width in slots. |
| `height` | `number` | Inventory height in slots. |
| `DropOnDeath` | `boolean` | Controls whether the grenade should be dropped when the player dies. |

## Example

```lua
lia.item.registerItem("frag_grenade", "base_grenade", {
    name = "Fragmentation Grenade",
    desc = "A deadly fragmentation grenade.",
    category = "grenades",
    model = "models/weapons/w_eq_fraggrenade.mdl",
    class = "weapon_frag",
    width = 1,
    height = 1,
    DropOnDeath = true
})
```

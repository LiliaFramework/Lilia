# Stackable Item Definition

Stackable items track quantity inside one inventory entry. Use them for ammo boxes, scrap, food portions, crafting materials, or any other item type that should combine into stacks.

## Placement

Use the normal `ITEM` form in item definition files loaded by the item loader, such as `schema/items/[item_id].lua`. If the item should inherit a base, place it under the matching base folder, such as `schema/items/stackable/[item_id].lua` or `modules/[module]/items/stackable/[item_id].lua`. Base item files themselves live under an `items/base` directory, for example `gamemode/items/base/stackable.lua` or `modules/[module]/items/base/stackable.lua`.

Use `lia.item.register` from a shared Lua file when you want to register an item directly from code instead of relying on the item loader's `ITEM` table.

## Reference

| Field | Type | Purpose |
| --- | --- | --- |
| `name` | `string` | Display name shown in the inventory. |
| `model` | `string` | World and inventory model used by the item. |
| `width` | `number` | Inventory width in slots. |
| `height` | `number` | Inventory height in slots. |
| `isStackable` | `boolean` | Marks the item as using stack quantity logic. |
| `maxQuantity` | `number` | Maximum number of units allowed in one stack. |
| `canSplit` | `boolean` | Controls whether players are allowed to split the stack. |

## Normal Item File Example

```lua
ITEM.name = "Ammo Box"
ITEM.model = "models/props_junk/cardboard_box001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.isStackable = true
ITEM.maxQuantity = 50
ITEM.canSplit = true
```

## Direct Registration Example

```lua
local item = lia.item.register("ammo_box", "base_stackable", false, nil, true)

item.name = "Ammo Box"
item.model = "models/props_junk/cardboard_box001a.mdl"
item.width = 1
item.height = 1
item.isStackable = true
item.maxQuantity = 50
item.canSplit = true
```

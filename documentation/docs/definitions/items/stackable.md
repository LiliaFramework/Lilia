# Stackable Item Definition

Stackable items track quantity inside one inventory entry. Use them for ammo boxes, scrap, food portions, crafting materials, or any other item type that should combine into stacks.

## Placement

Register stackable items in:

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
| `isStackable` | `boolean` | Marks the item as using stack quantity logic. |
| `maxQuantity` | `number` | Maximum number of units allowed in one stack. |
| `canSplit` | `boolean` | Controls whether players are allowed to split the stack. |

## Example

```lua
lia.item.registerItem("ammo_box", "base_stackable", {
    name = "Ammo Box",
    model = "models/props_junk/cardboard_box001a.mdl",
    width = 1,
    height = 1,
    isStackable = true,
    maxQuantity = 50,
    canSplit = true
})
```

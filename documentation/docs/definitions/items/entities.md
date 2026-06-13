# Entity Item Definition

Entity items spawn or represent scripted entities in the world. Use them when an inventory item should place a specific entity, tool object, or deployable prop when used.

## Placement

Register entity items in:

```text
garrysmod/gamemodes/[schema folder]/schema/definitions/sh_items.lua
```

Use `lia.item.registerItem` in that shared file to define the item directly from code.

## Reference

| Field | Type | Purpose |
| --- | --- | --- |
| `name` | `string` | Display name shown in the inventory. |
| `model` | `string` | World and inventory model used by the item. |
| `desc` | `string` | Description text shown to the player. |
| `category` | `string` | Inventory category used for sorting and grouping. |
| `entityid` | `string` | Scripted entity class spawned by the item. |

## Example

```lua
lia.item.registerItem("chair", "base_entities", {
    name = "Chair",
    model = "models/props_c17/FurnitureChair001a.mdl",
    desc = "A placeable chair.",
    category = "entities",
    entityid = "prop_physics"
})
```

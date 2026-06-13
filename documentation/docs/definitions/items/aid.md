# Aid Item Definition

Aid items are consumables that restore health, armor, or another tracked resource when used. Use this pattern for medical kits, bandages, syringes, and similar support items.

## Placement

Register aid items in:

```text
garrysmod/gamemodes/[schema folder]/schema/definitions/sh_items.lua
```

Use `lia.item.registerItem` in that shared file to define the item directly from code.

## Reference

| Field | Type | Purpose |
| --- | --- | --- |
| `name` | `string` | Display name shown in the inventory and item interactions. |
| `desc` | `string` | Description text shown to the player. |
| `model` | `string` | World and inventory model used by the item. |
| `width` | `number` | Inventory width in slots. |
| `height` | `number` | Inventory height in slots. |
| `health` | `number` | Amount of health restored when the item is used. |
| `armor` | `number` | Amount of armor restored when the item is used. |
| `stamina` | `number` | Amount of stamina restored when the item is used. |
| `healTime` | `number` | Optional total duration in seconds for spreading `health` across timed ticks. Leave at `0` for instant healing. |
| `healInterval` | `number` | Optional delay in seconds between healing ticks while `healTime` is active. |

## Example

```lua
lia.item.registerItem("medical_kit", "base_aid", {
    name = "Medical Kit",
    desc = "A medical kit that restores health.",
    model = "models/items/healthkit.mdl",
    width = 1,
    height = 1,
    health = 50,
    healTime = 5,
    healInterval = 1
})
```

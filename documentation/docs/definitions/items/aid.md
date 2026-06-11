# Aid Item Definition

Aid items are consumables that restore health, armor, or another tracked resource when used. Use this pattern for medical kits, bandages, syringes, and similar support items.

## Placement

Use the normal `ITEM` form in item definition files loaded by the item loader, such as `schema/items/[item_id].lua`. If the item should inherit a base, place it under the matching base folder, such as `schema/items/aid/[item_id].lua` or `modules/[module]/items/aid/[item_id].lua`. Base item files themselves live under an `items/base` directory, for example `gamemode/items/base/aid.lua` or `modules/[module]/items/base/aid.lua`.

Use `lia.item.register` from a shared Lua file when you want to register an item directly from code instead of relying on the item loader's `ITEM` table.

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

## Normal Item File Example

```lua
ITEM.name = "Medical Kit"
ITEM.desc = "A medical kit that restores health."
ITEM.model = "models/items/healthkit.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.health = 50
ITEM.healTime = 5
ITEM.healInterval = 1

ITEM.functions.Use = {
    name = "use",
    tip = "useTip",
    icon = "icon16/heart.png",
    onRun = function(item)
        local client = item.player
        if not IsValid(client) then return false end

        client:SetHealth(math.min(client:Health() + 25, client:GetMaxHealth()))
        return true
    end
}
```

## Direct Registration Example

```lua
local item = lia.item.register("medical_kit", "base_aid", false, nil, true)

item.name = "Medical Kit"
item.desc = "A medical kit that restores health."
item.model = "models/items/healthkit.mdl"
item.width = 1
item.height = 1
item.health = 50
item.healTime = 5
item.healInterval = 1

item.functions.Use = {
    name = "use",
    tip = "useTip",
    icon = "icon16/heart.png",
    onRun = function(itemInstance)
        local client = itemInstance.player
        if not IsValid(client) then return false end

        client:SetHealth(math.min(client:Health() + 25, client:GetMaxHealth()))
        return true
    end
}
```

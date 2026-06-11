# Outfit Item Definition

Outfit items change how a character is presented when equipped. Use them for wearable gear, uniforms, armor shells, or model swaps that should participate in outfit conflict rules.

## Placement

Use the normal `ITEM` form in item definition files loaded by the item loader, such as `schema/items/[item_id].lua`. If the item should inherit a base, place it under the matching base folder, such as `schema/items/outfit/[item_id].lua` or `modules/[module]/items/outfit/[item_id].lua`. Base item files themselves live under an `items/base` directory, for example `gamemode/items/base/outfit.lua` or `modules/[module]/items/base/outfit.lua`.

Use `lia.item.register` from a shared Lua file when you want to register an item directly from code instead of relying on the item loader's `ITEM` table.

## Reference

| Field | Type | Purpose |
| --- | --- | --- |
| `name` | `string` | Display name shown in the inventory. |
| `desc` | `string` | Description text shown to the player. |
| `category` | `string` | Inventory category used for sorting and grouping. |
| `model` | `string` | World and inventory model used by the item. |
| `width` | `number` | Inventory width in slots. |
| `height` | `number` | Inventory height in slots. |
| `outfitCategory` | `string` | Outfit grouping used to stop conflicting items from equipping together. |
| `pacData` | `table` | Optional PAC data applied with the outfit. |
| `isOutfit` | `boolean` | Marks the item as an outfit definition. |
| `armor` | `number` | Optional armor added while the outfit is equipped. |
| `newSkin` | `number` | Optional skin index applied while the outfit is equipped. |
| `bodyGroups` | `table` | Optional bodygroup values applied while the outfit is equipped. |
| `attribBoosts` | `table` | Optional attribute boosts applied while the outfit is equipped. |
| `replacement` | `string` | Optional replacement model path applied on equip. |
| `replacements` | `string \| table` | Optional replacement rule or replacement rule list applied on equip. |

## Normal Item File Example

```lua
ITEM.name = "Police Uniform"
ITEM.desc = "A standard police uniform."
ITEM.category = "outfit"
ITEM.model = "models/props_c17/BriefCase001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "uniform"
ITEM.pacData = nil
ITEM.isOutfit = true

ITEM.functions.Equip = {
    name = "wear",
    tip = "equipThisItem",
    icon = "icon16/user_suit.png",
    onRun = function(item)
        item:setData("equip", true)
        return false
    end
}
```

## Direct Registration Example

```lua
local item = lia.item.register("police_uniform", "base_outfit", false, nil, true)

item.name = "Police Uniform"
item.desc = "A standard police uniform."
item.category = "outfit"
item.model = "models/props_c17/BriefCase001a.mdl"
item.width = 1
item.height = 1
item.outfitCategory = "uniform"
item.pacData = nil
item.isOutfit = true

item.functions.Equip = {
    name = "wear",
    tip = "equipThisItem",
    icon = "icon16/user_suit.png",
    onRun = function(itemInstance)
        itemInstance:setData("equip", true)
        return false
    end
}
```

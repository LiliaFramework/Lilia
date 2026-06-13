# Outfit Item Definition

Outfit items change how a character is presented when equipped. Use them for wearable gear, uniforms, armor shells, or model swaps that should participate in outfit conflict rules.

## Placement

Register outfit items in:

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
| `width` | `number` | Inventory width in slots. |
| `height` | `number` | Inventory height in slots. |
| `outfitCategory` | `string` | Outfit grouping used to stop conflicting items from equipping together. |
| `pacData` | `table` | Optional PAC data applied with the outfit. |
| `isOutfit` | `boolean` | Marks the item as an outfit definition. |
| `armor` | `number` | Optional armor added while the outfit is equipped. |
| `skin` | `number` | Optional skin index applied while the outfit is equipped. Also used by inventory/world model presentation. |
| `bodyGroups` | `table` | Optional bodygroup values applied while the outfit is equipped. |
| `bodygroups` | `table` | Alias of `bodyGroups`. Also used by inventory/world model presentation. |
| `attribBoosts` | `table` | Optional attribute boosts applied while the outfit is equipped. |
| `replacement` | `string` | Optional replacement model path applied on equip. When you use this form, set `skin` and `bodygroups` on the item itself. |
| `replacements` | `string \| table` | Optional replacement rule or replacement rule list applied on equip. This also supports a per-model lookup table where each entry can define `replacement`, `skin`, and `bodygroups`. |

## Example

```lua
lia.item.registerItem("police_uniform", "base_outfit", {
    name = "Police Uniform",
    desc = "A standard police uniform.",
    category = "outfit",
    model = "models/props_c17/BriefCase001a.mdl",
    width = 1,
    height = 1,
    outfitCategory = "uniform",
    pacData = nil,
    isOutfit = true
})
```

## Appearance Override Patterns

Use top-level appearance overrides when the outfit has a single direct replacement:

```lua
lia.item.registerItem("uniform_override", "base_outfit", {
    replacement = "models/example/new_uniform.mdl",
    skin = 1,
    bodygroups = {
        [1] = 2,
        helmet = 0
    }
})
```

Use a keyed `replacements` table when different source models need different replacement data:

```lua
lia.item.registerItem("uniform_override", "base_outfit", {
    replacements = {
        ["models/player/group01/male_07.mdl"] = {
            replacement = "models/example/male_uniform.mdl",
            skin = 2,
            bodygroups = {
                [1] = 2,
                helmet = 0
            }
        }
    }
})
```

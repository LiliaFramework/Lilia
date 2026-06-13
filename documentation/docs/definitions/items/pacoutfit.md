# PAC Outfit Item Definition

PAC outfit items apply PAC3 parts through item state. Use them for cosmetics or wearable attachments that should persist through inventory behavior and clean themselves up when dropped, transferred, or removed.

## Placement

Register PAC outfit items in:

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
| `pacData` | `table` | PAC3 part data attached when the item equips. |
| `attribBoosts` | `table` | Optional attribute boosts applied while the item is equipped. |

## Callback Fields

| Callback | Purpose |
| --- | --- |
| `paintOver(item, w, h)` | Draws equipped-state UI over the inventory icon. |
| `removePart(client)` | Removes the PAC3 part from the player. |
| `OnCanBeTransfered(_, newInventory)` | Blocks transfer while the item is equipped. |
| `onLoadout()` | Re-applies the PAC3 part when the item loads out on the player. |
| `onRemoved()` | Cleans up PAC state when the item is removed permanently. |
| `hook("drop", fn)` | Removes the PAC3 part if the equipped item is dropped. |

## Example

```lua
lia.item.registerItem("hat", "base_pacoutfit", {
    name = "Hat",
    desc = "A wearable PAC3 hat.",
    category = "outfit",
    model = "models/props_junk/TrafficCone001a.mdl",
    width = 1,
    height = 1,
    outfitCategory = "head",
    pacData = {}
})
```

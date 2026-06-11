# PAC Outfit Item Definition

PAC outfit items apply PAC3 parts through item state. Use them for cosmetics or wearable attachments that should persist through inventory behavior and clean themselves up when dropped, transferred, or removed.

## Placement

Use the normal `ITEM` form in item definition files loaded by the item loader, such as `schema/items/[item_id].lua`. If the item should inherit a base, place it under the matching base folder, such as `schema/items/pacoutfit/[item_id].lua` or `modules/[module]/items/pacoutfit/[item_id].lua`. Base item files themselves live under an `items/base` directory, for example `gamemode/items/base/pacoutfit.lua` or `modules/[module]/items/base/pacoutfit.lua`.

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

## Normal Item File Example

```lua
if not pac then return end

ITEM.name = "Hat"
ITEM.desc = "A wearable PAC3 hat."
ITEM.category = "outfit"
ITEM.model = "models/props_junk/TrafficCone001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "head"
ITEM.pacData = {}

function ITEM:paintOver(item, w, h)
    if item:getData("equip") then
        surface.SetDrawColor(110, 255, 110, 100)
        surface.DrawRect(w - 14, h - 14, 8, 8)
    end
end

function ITEM:removePart(client)
    if client.removePart then
        client:removePart(self.uniqueID)
    end

    self:setData("equip", nil)
end

ITEM:hook("drop", function(item)
    if item:getData("equip") and IsValid(item.player) then
        item:removePart(item.player)
    end
end)

function ITEM:OnCanBeTransfered(_, newInventory)
    if newInventory and self:getData("equip") then return false end
    return true
end
```

## Direct Registration Example

```lua
if not pac then return end

local item = lia.item.register("hat", "base_pacoutfit", false, nil, true)

item.name = "Hat"
item.desc = "A wearable PAC3 hat."
item.category = "outfit"
item.model = "models/props_junk/TrafficCone001a.mdl"
item.width = 1
item.height = 1
item.outfitCategory = "head"
item.pacData = {}

function item:removePart(client)
    if client.removePart then
        client:removePart(self.uniqueID)
    end

    self:setData("equip", nil)
end
```

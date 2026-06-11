# ArcCW Attachment Item Definition

ArcCW attachment items give, remove, and restore ArcCW attachments through normal item actions. Use this definition when an attachment should live in inventory, persist equip state, and be re-applied on loadout.

## Placement

Use the normal `ITEM` form in item definition files loaded by the item loader, such as `schema/items/[item_id].lua`. If the item should inherit a base, place it under the matching base folder, such as `schema/items/arccw_att/[item_id].lua` or `modules/[module]/items/arccw_att/[item_id].lua`. Base item files themselves live under an `items/base` directory, for example `gamemode/items/base/arccw_att.lua` or `modules/[module]/items/base/arccw_att.lua`.

Use `lia.item.register` from a shared Lua file when you want to register an item directly from code instead of relying on the item loader's `ITEM` table.

## Reference

| Field | Type | Purpose |
| --- | --- | --- |
| `name` | `string` | Display name shown in the inventory. |
| `desc` | `string` | Description text shown to the player. |
| `category` | `string` | Inventory category used for sorting. |
| `model` | `string` | World and inventory model used by the item. |
| `width` | `number` | Inventory width in slots. |
| `height` | `number` | Inventory height in slots. |
| `att` | `string` | ArcCW attachment ID managed by this item. |

## Callback Fields

| Callback | Purpose |
| --- | --- |
| `paintOver(item, w, h)` | Draws equipped-state UI over the inventory icon. |
| `removeAttachment(client)` | Removes the ArcCW attachment from the player and clears equip state. |
| `addAttachment(client)` | Gives the ArcCW attachment to the player. |
| `hook("transfer", fn)` | Removes the attachment if the equipped item is transferred away. |
| `hook("drop", fn)` | Removes the attachment if the equipped item is dropped. |
| `functions.Unequip` | Adds an Unequip inventory action. |
| `functions.Equip` | Adds an Equip inventory action. |
| `OnCanBeTransfered(_, newInventory)` | Blocks transfer while the attachment is equipped. |
| `onLoadout()` | Re-applies the attachment when the item loads out on the player. |
| `onRemoved()` | Cleans up equipped state when the item leaves the inventory permanently. |

## Normal Item File Example

```lua
if not ArcCWInstalled then return end

ITEM.name = "Micro Optic"
ITEM.desc = "A compact ArcCW optic attachment."
ITEM.category = "attachments"
ITEM.model = "models/items/boxsrounds.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.att = "optic_micro"

function ITEM:paintOver(item, w, h)
    if item:getData("equip") then
        surface.SetDrawColor(110, 255, 110, 100)
        surface.DrawRect(w - 14, h - 14, 8, 8)
    end
end

function ITEM:removeAttachment(client)
    if ArcCW:PlayerTakeAtt(client, self.att, 1) then
        self:setData("equip", nil)
        ArcCW:PlayerSendAttInv(client)
        return true
    end

    return false
end

function ITEM:addAttachment(client)
    ArcCW:PlayerGiveAtt(client, self.att, 1)
    ArcCW:PlayerSendAttInv(client)
end

ITEM:hook("transfer", function(item)
    if item:getData("equip") then
        item:removeAttachment(item.player)
    end
end)

ITEM.functions.Equip = {
    name = "equip",
    tip = "equipThisItem",
    icon = "icon16/tick.png",
    onRun = function(item)
        item:setData("equip", true)
        item:addAttachment(item.player)
        return false
    end
}

function ITEM:OnCanBeTransfered(_, newInventory)
    if newInventory and self:getData("equip") then return false end
    return true
end

function ITEM:onLoadout()
    if self:getData("equip") then
        self:addAttachment(self.player)
    end
end
```

## Direct Registration Example

```lua
if not ArcCWInstalled then return end

local item = lia.item.register("optic_micro", "base_arccw_att", false, nil, true)

item.name = "Micro Optic"
item.desc = "A compact ArcCW optic attachment."
item.category = "attachments"
item.model = "models/items/boxsrounds.mdl"
item.width = 1
item.height = 1
item.att = "optic_micro"

function item:paintOver(itemInstance, w, h)
    if itemInstance:getData("equip") then
        surface.SetDrawColor(110, 255, 110, 100)
        surface.DrawRect(w - 14, h - 14, 8, 8)
    end
end

function item:addAttachment(client)
    ArcCW:PlayerGiveAtt(client, self.att, 1)
    ArcCW:PlayerSendAttInv(client)
end
```

# Grenade Item Definition

Grenade items wrap throwable weapon classes in inventory form. Use them when a grenade should be carried, dropped, and optionally stripped from the player on death through item state instead of direct weapon-only handling.

## Placement

Use the normal `ITEM` form in item definition files loaded by the item loader, such as `schema/items/[item_id].lua`. If the item should inherit a base, place it under the matching base folder, such as `schema/items/grenade/[item_id].lua` or `modules/[module]/items/grenade/[item_id].lua`. Base item files themselves live under an `items/base` directory, for example `gamemode/items/base/grenade.lua` or `modules/[module]/items/base/grenade.lua`.

Use `lia.item.register` from a shared Lua file when you want to register an item directly from code instead of relying on the item loader's `ITEM` table.

## Reference

| Field | Type | Purpose |
| --- | --- | --- |
| `name` | `string` | Display name shown in the inventory. |
| `desc` | `string` | Description text shown to the player. |
| `category` | `string` | Inventory category used for sorting and grouping. |
| `model` | `string` | World and inventory model used by the item. |
| `class` | `string` | Weapon class granted or represented by the grenade item. |
| `width` | `number` | Inventory width in slots. |
| `height` | `number` | Inventory height in slots. |
| `DropOnDeath` | `boolean` | Controls whether the grenade should be dropped when the player dies. |

## Normal Item File Example

```lua
ITEM.name = "Fragmentation Grenade"
ITEM.desc = "A deadly fragmentation grenade."
ITEM.category = "grenades"
ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"
ITEM.class = "weapon_frag"
ITEM.width = 1
ITEM.height = 1
ITEM.DropOnDeath = true

ITEM.functions.Throw = {
    name = "equip",
    tip = "equipThisItem",
    icon = "icon16/bomb.png",
    onRun = function(item)
        local client = item.player
        if IsValid(client) then
            client:Give(item.class)
        end

        return false
    end
}
```

## Direct Registration Example

```lua
local item = lia.item.register("frag_grenade", "base_grenade", false, {
    name = "Fragmentation Grenade",
    desc = "A deadly fragmentation grenade.",
    category = "grenades",
    model = "models/weapons/w_eq_fraggrenade.mdl",
    class = "weapon_frag",
    width = 1,
    height = 1,
    DropOnDeath = true,
    functions = {
        Throw = {
            name = "equip",
            tip = "equipThisItem",
            icon = "icon16/bomb.png",
            onRun = function(itemInstance)
                local client = itemInstance.player

                if IsValid(client) then
                    client:Give(itemInstance.class)
                end

                return false
            end
        }
    }
}, true)
```

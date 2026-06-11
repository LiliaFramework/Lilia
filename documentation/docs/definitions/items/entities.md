# Entity Item Definition

Entity items spawn or represent scripted entities in the world. Use them when an inventory item should place a specific entity, tool object, or deployable prop when used.

## Placement

Use the normal `ITEM` form in item definition files loaded by the item loader, such as `schema/items/[item_id].lua`. If the item should inherit a base, place it under the matching base folder, such as `schema/items/entities/[item_id].lua` or `modules/[module]/items/entities/[item_id].lua`. Base item files themselves live under an `items/base` directory, for example `gamemode/items/base/entities.lua` or `modules/[module]/items/base/entities.lua`.

Use `lia.item.register` from a shared Lua file when you want to register an item directly from code instead of relying on the item loader's `ITEM` table.

## Reference

| Field | Type | Purpose |
| --- | --- | --- |
| `name` | `string` | Display name shown in the inventory. |
| `model` | `string` | World and inventory model used by the item. |
| `desc` | `string` | Description text shown to the player. |
| `category` | `string` | Inventory category used for sorting and grouping. |
| `entityid` | `string` | Scripted entity class spawned by the item. |

## Normal Item File Example

```lua
ITEM.name = "Chair"
ITEM.model = "models/props_c17/FurnitureChair001a.mdl"
ITEM.desc = "A placeable chair."
ITEM.category = "entities"
ITEM.entityid = "prop_physics"

ITEM.functions.Place = {
    name = "place",
    tip = "useTip",
    icon = "icon16/brick_add.png",
    onRun = function(item)
        local client = item.player
        if not IsValid(client) then return false end

        local trace = client:GetEyeTraceNoCursor()
        local ent = ents.Create(item.entityid)
        ent:SetModel(item.model)
        ent:SetPos(trace.HitPos + trace.HitNormal * 16)
        ent:Spawn()
        return true
    end
}
```

## Direct Registration Example

```lua
local item = lia.item.register("chair", "base_entities", false, nil, true)

item.name = "Chair"
item.model = "models/props_c17/FurnitureChair001a.mdl"
item.desc = "A placeable chair."
item.category = "entities"
item.entityid = "prop_physics"

item.functions.Place = {
    name = "place",
    tip = "useTip",
    icon = "icon16/brick_add.png",
    onRun = function(itemInstance)
        local client = itemInstance.player
        if not IsValid(client) then return false end

        local trace = client:GetEyeTraceNoCursor()
        local ent = ents.Create(itemInstance.entityid)
        ent:SetModel(itemInstance.model)
        ent:SetPos(trace.HitPos + trace.HitNormal * 16)
        ent:Spawn()
        return true
    end
}
```

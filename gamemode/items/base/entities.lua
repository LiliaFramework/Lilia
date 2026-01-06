--[[
    Folder: Definitions
    File:  entities.md
]]
--[[
    Entities Item Definition

    Entity placement item system for the Lilia framework.
]]
--[[
    Entity items allow players to place down entities in the world.
    They support data restoration and various entity properties.

    PLACEMENT:
    - Place in: ModuleFolder/items/entities/ItemHere.lua (for module-specific items)
    - Place in: SchemaFolder/items/entities/ItemHere.lua (for schema-specific items)

    USAGE:
    - Entity items are placed by using the item
    - They spawn the entity specified in ITEM.entityid
    - Entities are placed at the player's position
    - Items are consumed when placed
    - Entities can be picked up and returned to inventory
]]
--[[
    Purpose:
        Sets the display name shown to players

    Example Usage:
        ```lua
        -- Set the entity item name
        ITEM.name = "Vending Machine"
        ```
]]
ITEM.name = "entitiesName"
--[[
    Purpose:
        Sets the 3D model used for the item

    Example Usage:
        ```lua
        -- Set the item model (empty for entity placement)
        ITEM.model = "models/props_interiors/vendingmachinesoda01a.mdl"
        ```
]]
ITEM.model = ""
--[[
    Purpose:
        Sets the description text shown to players

    Example Usage:
        ```lua
        -- Set the entity description
        ITEM.desc = "A functional vending machine that can be placed in the world"
        ```
]]
ITEM.desc = "entitiesDesc"
--[[
    Purpose:
        Sets the category for inventory sorting

    Example Usage:
        ```lua
        -- Set inventory category
        ITEM.category = "entities"
        ```
]]
ITEM.category = "entities"
--[[
    Purpose:
        Sets the entity class to spawn when the item is placed

    Example Usage:
        ```lua
        -- Set the entity class to spawn
        ITEM.entityid = "lia_vendingmachine"
        ```
]]
ITEM.entityid = ""
ITEM.functions.Place = {
    name = "placeDownEntity",
    onRun = function(item)
        local client = item.player
        local entity = ents.Create(item.entityid)
        local pos = IsValid(item.entity) and item.entity:GetPos() or client:getItemDropPos()
        entity:SetPos(pos)
        entity:Spawn()
        item:remove()
        return true
    end,
}
--[[
Example Item:

```lua
-- Basic item identification
    ITEM.name = "Vending Machine"                 -- Display name shown to players
    ITEM.desc = "A functional vending machine that can be placed in the world"  -- Description text
    ITEM.category = "entities"                    -- Category for inventory sorting
    ITEM.model = "models/props_interiors/vendingmachinesoda01a.mdl"  -- 3D model for the item
    ITEM.width = 2                                -- Inventory width (2 slots)
    ITEM.height = 3                               -- Inventory height (3 slots)
    ITEM.entityid = "lia_vendingmachine"          -- Entity class to spawn when placed
```
]]

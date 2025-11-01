--[[
    Entities Item Definition

    Entity placement item system for the Lilia framework.

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
        Sets the display name of the entity item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.name = "Chair"
        ```
]]
ITEM.name = "entitiesName"
--[[
    Purpose:
        Sets the 3D model for the entity item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.model = "models/props_c17/FurnitureChair001a.mdl"
        ```
]]
ITEM.model = ""
--[[
    Purpose:
        Sets the description of the entity item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.desc = "A comfortable chair for sitting"
        ```
]]
ITEM.desc = "entitiesDesc"
--[[
    Purpose:
        Sets the category for the entity item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.category = "entities"
        ```
]]
ITEM.category = "entities"
--[[
    Purpose:
        Sets the entity class name to spawn

    When Called:
        During item definition (used in Place function)

    Example Usage:
        ```lua
        ITEM.entityid = "prop_physics"
        ```
]]
ITEM.entityid = ""
--[[
Example Item:

```lua
-- Basic item identification
ITEM.name = "Chair"                                          -- Display name shown to players
ITEM.model = "models/props_c17/FurnitureChair001a.mdl"       -- 3D model for the item
ITEM.desc = "A comfortable chair for sitting"                -- Description text
ITEM.category = "entities"                                   -- Category for inventory sorting
ITEM.entityid = "prop_physics"                               -- Entity class to spawn when placed
```
]]

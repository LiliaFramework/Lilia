--[[
    Folder: Items/Base
    File:  entities.lua
]]
--[[
    Entities Item Base

    Base entity placement item implementation for the Lilia framework.

    Entity items allow players to place down entities in the world.
    They support data restoration and various entity properties.
]]
--[[
    Overview:
        Entity items provide the foundation for all placeable objects in Lilia. They enable players to spawn entities from their inventory
        at desired locations, with support for different entity types and properties. The base implementation includes placement mechanics,
        position validation, and proper entity spawning with automatic item consumption.

        The base entity item supports:
        - Entity spawning at player position or item drop location
        - Automatic item removal after placement
        - Support for various entity types through entityid
        - Integration with Lilia's placement system
]]

-- Basic item identification
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
    Purpose:
        Sets the health value for the item when it's dropped as an entity in the world

    When Called:
        During item definition (used when item is spawned as entity)

    Notes:
        - Defaults to 100 if not specified
        - When the item entity takes damage, its health decreases
        - Item is destroyed when health reaches 0
        - Only applies if ITEM.CanBeDestroyed is true (controlled by config)

    Example Usage:
        ```lua
        ITEM.health = 250  -- Item can take 250 damage before being destroyed
        ```
]]
ITEM.health = 100
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

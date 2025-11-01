--[[
    Grenade Item Definition

    Grenade item system for the Lilia framework.

    Grenade items are weapons that can be equipped and used by players.
    They drop on death and prevent duplicate grenades.

    PLACEMENT:
    - Place in: ModuleFolder/items/grenade/ItemHere.lua (for module-specific items)
    - Place in: SchemaFolder/items/grenade/ItemHere.lua (for schema-specific items)

    USAGE:
    - Grenades are used by equipping them
    - They give the weapon specified in ITEM.class
    - Items are consumed when equipped
    - Weapons can be thrown and will explode
    - Grenades drop on death if ITEM.DropOnDeath is true
]]
--[[
    Purpose:
        Sets the display name of the grenade item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.name = "Fragmentation Grenade"
        ```
]]
ITEM.name = "grenadeName"
--[[
    Purpose:
        Sets the description of the grenade item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.desc = "A deadly fragmentation grenade"
        ```
]]
ITEM.desc = "grenadeDesc"
--[[
    Purpose:
        Sets the category for the grenade item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.category = "itemCatGrenades"
        ```
]]
ITEM.category = "itemCatGrenades"
--[[
    Purpose:
        Sets the 3D model for the grenade item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"
        ```
]]
ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"
--[[
    Purpose:
        Sets the weapon class name for the grenade

    When Called:
        During item definition (used in Use function)

    Example Usage:
        ```lua
        ITEM.class = "weapon_frag"
        ```
]]
ITEM.class = "weapon_frag"
--[[
    Purpose:
        Sets the inventory width of the grenade item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.width = 1  -- Takes 1 slot width
        ```
]]
ITEM.width = 1
--[[
    Purpose:
        Sets the inventory height of the grenade item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.height = 1  -- Takes 1 slot height
        ```
]]
ITEM.height = 1
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
--[[
    Purpose:
        Sets whether the grenade drops when player dies

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.DropOnDeath = true  -- Drops on death
        ```
]]
ITEM.DropOnDeath = true
--[[
Example Item:

```lua
-- Basic item identification
    ITEM.name = "Fragmentation Grenade"                    -- Display name shown to players
    ITEM.desc = "A deadly fragmentation grenade"           -- Description text
    ITEM.category = "itemCatGrenades"                      -- Category for inventory sorting
    ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"     -- 3D model for the grenade
    ITEM.class = "weapon_frag"                             -- Weapon class to give when used
    ITEM.width = 1                                         -- Inventory width (1 slot)
    ITEM.height = 1                                        -- Inventory height (1 slot)
    ITEM.health = 100                                      -- Health when dropped (default: 100)
    ITEM.DropOnDeath = true                                -- Drops on death
```
]]

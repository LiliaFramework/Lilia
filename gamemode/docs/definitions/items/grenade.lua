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
--
--[[
    ITEM.name
    Purpose: Sets the display name of the grenade item
    When Called: During item definition
    Example Usage:
        ```lua
        ITEM.name = "Fragmentation Grenade"
        ```
]]
--
ITEM.name = "grenadeName"
--[[
    ITEM.desc
    Purpose: Sets the description of the grenade item
    When Called: During item definition
    Example Usage:
        ```lua
        ITEM.desc = "A deadly fragmentation grenade"
        ```
]]
--
ITEM.desc = "grenadeDesc"
--[[
    ITEM.category
    Purpose: Sets the category for the grenade item
    When Called: During item definition
    Example Usage:
        ```lua
        ITEM.category = "itemCatGrenades"
        ```
]]
--
ITEM.category = "itemCatGrenades"
--[[
    ITEM.model
    Purpose: Sets the 3D model for the grenade item
    When Called: During item definition
    Example Usage:
        ```lua
        ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"
        ```
]]
--
ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"
--[[
    ITEM.class
    Purpose: Sets the weapon class name for the grenade
    When Called: During item definition (used in Use function)
    Example Usage:
        ```lua
        ITEM.class = "weapon_frag"
        ```
]]
--
ITEM.class = "weapon_frag"
--[[
    ITEM.width
    Purpose: Sets the inventory width of the grenade item
    When Called: During item definition
    Example Usage:
        ```lua
        ITEM.width = 1  -- Takes 1 slot width
        ```
]]
--
ITEM.width = 1
--[[
    ITEM.height
    Purpose: Sets the inventory height of the grenade item
    When Called: During item definition
    Example Usage:
        ```lua
        ITEM.height = 1  -- Takes 1 slot height
        ```
]]
--
ITEM.height = 1
--[[
    ITEM.DropOnDeath
    Purpose: Sets whether the grenade drops when player dies
    When Called: During item definition
    Example Usage:
        ```lua
        ITEM.DropOnDeath = true  -- Drops on death
        ```
]]
--
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
```
]]
--

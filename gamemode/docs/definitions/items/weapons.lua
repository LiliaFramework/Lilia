--[[
    Weapons Item Definition
    Weapon item system for the Lilia framework.
    Weapon items are equippable weapons that can be given to players.
    They support ammo tracking, weapon categories, and visual indicators.
    PLACEMENT:
    - Place in: ModuleFolder/items/weapons/ItemHere.lua (for module-specific items)
    - Place in: SchemaFolder/items/weapons/ItemHere.lua (for schema-specific items)
    USAGE:
    - Weapon items are equipped by using them
    - They give the weapon specified in ITEM.class
    - Items remain in inventory when equipped
    - Can be unequipped to remove weapons
    - Weapons drop on death if ITEM.DropOnDeath is true
]]
--
--[[
    ITEM.name
    Purpose: Sets the display name of the weapon item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.name = "Pistol"
    ```
]]
--
ITEM.name = "weaponsName"
--[[
    ITEM.desc
    Purpose: Sets the description of the weapon item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.desc = "A standard issue pistol"
    ```
]]
--
ITEM.desc = "weaponsDesc"
--[[
    ITEM.category
    Purpose: Sets the category for the weapon item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.category = "weapons"
    ```
]]
--
ITEM.category = "weapons"
--[[
    ITEM.model
    Purpose: Sets the 3D model for the weapon item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.model = "models/weapons/w_pistol.mdl"
    ```
]]
--
ITEM.model = "models/weapons/w_pistol.mdl"
--[[
    ITEM.class
    Purpose: Sets the weapon class name
    When Called: During item definition (used in equip/unequip functions)
    Example Usage:
    ```lua
    ITEM.class = "weapon_pistol"
    ```
]]
--
ITEM.class = "weapon_pistol"
--[[
    ITEM.width
    Purpose: Sets the inventory width of the weapon item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.width = 2  -- Takes 2 slot width
    ```
]]
--
ITEM.width = 2
--[[
    ITEM.height
    Purpose: Sets the inventory height of the weapon item
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.height = 2  -- Takes 2 slot height
    ```
]]
--
ITEM.height = 2
--[[
    ITEM.isWeapon
    Purpose: Marks the item as a weapon
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.isWeapon = true
    ```
]]
--
ITEM.isWeapon = true
--[[
    ITEM.RequiredSkillLevels
    Purpose: Sets required skill levels for the weapon
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.RequiredSkillLevels = {}  -- No skill requirements
    ```
]]
--
ITEM.RequiredSkillLevels = {}
--[[
    ITEM.DropOnDeath
    Purpose: Sets whether the weapon drops when player dies
    When Called: During item definition
    Example Usage:
    ```lua
    ITEM.DropOnDeath = true  -- Drops on death
    ```
]]
--
ITEM.DropOnDeath = true
--
--[[
Example Item:
    ```lua
    -- Basic item identification
    ITEM.name = "Pistol"                              -- Display name shown to players
    ITEM.desc = "A standard issue pistol"             -- Description text
    ITEM.category = "weapons"                         -- Category for inventory sorting
    ITEM.model = "models/weapons/w_pistol.mdl"        -- 3D model for the weapon
    ITEM.class = "weapon_pistol"                      -- Weapon class to give when equipped
    ITEM.width = 2                                    -- Inventory width (2 slots)
    ITEM.height = 2                                   -- Inventory height (2 slots)
    ```
]]
--

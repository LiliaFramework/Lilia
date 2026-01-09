--[[
    Folder: Definitions
    File:  grenade.md
]]
--[[
    Grenade Item Definition

    Grenade item system for the Lilia framework.
]]
--[[
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
        Sets the display name shown to players

    Example Usage:
        ```lua
        -- Set the grenade name
        ITEM.name = "Frag Grenade"
        ```
]]
ITEM.name = "grenadeName"
--[[
    Purpose:
        Sets the description text shown to players

    Example Usage:
        ```lua
        -- Set the grenade description
        ITEM.desc = "A high-explosive fragmentation grenade"
        ```
]]
ITEM.desc = "grenadeDesc"
--[[
    Purpose:
        Sets the category for inventory sorting

    Example Usage:
        ```lua
        -- Set inventory category
        ITEM.category = "itemCatGrenades"
        ```
]]
ITEM.category = "itemCatGrenades"
--[[
    Purpose:
        Sets the 3D model used for the item

    Example Usage:
        ```lua
        -- Set the grenade model
        ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"
        ```
]]
ITEM.model = "models/weapons/w_eq_fraggrenade.mdl"
--[[
    Purpose:
        Sets the weapon entity class that gets given to players

    Example Usage:
        ```lua
        -- Set the grenade weapon class
        ITEM.class = "weapon_frag"
        ```
]]
ITEM.class = "weapon_frag"
--[[
    Purpose:
        Sets the inventory width in slots

    Example Usage:
        ```lua
        -- Set inventory width
        ITEM.width = 1
        ```
]]
ITEM.width = 1
--[[
    Purpose:
        Sets the inventory height in slots

    Example Usage:
        ```lua
        -- Set inventory height
        ITEM.height = 1
        ```
]]
ITEM.height = 1
--[[
    Purpose:
        Determines whether grenade drops on player death

    Example Usage:
        ```lua
        -- Make grenade drop on death
        ITEM.DropOnDeath = true
        ```
]]
ITEM.DropOnDeath = true
ITEM.functions.Use = {
    name = "useGrenade",
    icon = "icon16/tick.png",
    onRun = function(item)
        local client = item.player
        if IsValid(client:GetRagdollEntity()) then
            client:notifyErrorLocalized("noRagdollAction")
            return false
        end

        if client:HasWeapon(item.class) then
            client:notifyErrorLocalized("alreadyHaveGrenade")
            return false
        end

        client:Give(item.class)
        return true
    end,
}

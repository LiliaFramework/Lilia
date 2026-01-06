--[[
    Folder: Items/Base
    File:  grenade.lua
]]
--[[
    Grenade Item Base

    Base grenade item implementation for the Lilia framework.

    Grenade items are weapons that can be equipped and used by players.
    They drop on death and prevent duplicate grenades.
]]
--[[
    Overview:
        Grenade items provide the foundation for all throwable explosive weapons in Lilia. They enable players to equip grenades as weapons,
        with built-in safety measures to prevent duplicates and proper death drop mechanics. The base implementation includes weapon
        validation, ragdoll checks, and integration with Lilia's weapon system.

        The base grenade item supports:
        - Weapon class assignment and equipping
        - Duplicate prevention (one grenade per type)
        - Ragdoll action blocking
        - Configurable death dropping
        - Integration with Lilia's weapon management
]]

-- Basic item identification
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

--[[
    Folder: Definitions
    File:  aid.md
]]
--[[
    Aid Item Definition

    Medical aid item system for the Lilia framework.
]]
--[[
    Aid items are consumable medical items that can restore health to players.
    They can be used on the player themselves or on other players through targeting.

    PLACEMENT:
    - Place in: ModuleFolder/items/aid/ItemHere.lua (for module-specific items)
    - Place in: SchemaFolder/items/aid/ItemHere.lua (for schema-specific items)

    USAGE:
    - Aid items are automatically consumed when used
    - They restore health based on the ITEM.health value
    - Can be used on self or other players
    - Health restoration is instant and cannot be interrupted
    - Items are removed from inventory after use
]]
--[[
    Purpose:
        Sets the display name shown to players

    Example Usage:
        ```lua
        -- Set the aid item name
        ITEM.name = "Medical Kit"
        ```
]]
ITEM.name = "aidName"
--[[
    Purpose:
        Sets the description text shown to players

    Example Usage:
        ```lua
        -- Set the aid item description
        ITEM.desc = "A medical kit that restores health"
        ```
]]
ITEM.desc = "aidDesc"
--[[
    Purpose:
        Sets the 3D model used for the item

    Example Usage:
        ```lua
        -- Set the aid item model
        ITEM.model = "models/items/medkit.mdl"
        ```
]]
ITEM.model = "models/weapons/w_package.mdl"
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
        Sets the amount of health restored when used

    Example Usage:
        ```lua
        -- Set health restoration amount
        ITEM.health = 25
        ```
]]
ITEM.health = 0
--[[
    Purpose:
        Sets the amount of armor restored when used

    Example Usage:
        ```lua
        -- Set armor restoration amount
        ITEM.armor = 10
        ```
]]
ITEM.armor = 0
ITEM.functions.use = {
    name = "use",
    sound = "items/medshot4.wav",
    onRun = function(item)
        local client = item.player
        if IsValid(client) then
            local newHealth = math.min(client:Health() + item.health, client:GetMaxHealth())
            client:SetHealth(newHealth)
            if item.armor > 0 then
                local newArmor = math.min(client:Armor() + item.armor, client:GetMaxArmor())
                client:SetArmor(newArmor)
            end
        end
    end
}

ITEM.functions.target = {
    name = "itemUseOnTarget",
    sound = "items/medshot4.wav",
    onRun = function(item)
        local client = item.player
        if IsValid(client) then
            local target = client:getTracedEntity()
            if IsValid(target) and target:IsPlayer() and target:Alive() then
                local newHealth = math.min(target:Health() + item.health, target:GetMaxHealth())
                target:SetHealth(newHealth)
                if item.armor > 0 then
                    local newArmor = math.min(target:Armor() + item.armor, target:GetMaxArmor())
                    target:SetArmor(newArmor)
                end
            else
                client:notifyErrorLocalized("invalidTargetNeedLiving")
            end
        end
    end,
    onCanRun = function(item)
        local client = item.player
        local target = client:getTracedEntity()
        return not IsValid(item.entity) and IsValid(target)
    end
}

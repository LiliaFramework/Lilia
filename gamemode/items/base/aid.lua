--[[
    Folder: Items/Base
    File:  aid.lua
]]
--[[
    Aid Item Base

    Base medical aid item implementation for the Lilia framework.

    Aid items are consumable medical items that can restore health to players.
    They can be used on the player themselves or on other players through targeting.
]]
--[[
    Overview:
        Aid items provide the foundation for all medical items in Lilia. They enable players to restore health through consumable items
        with support for both self-use and targeting other players. The base implementation includes health restoration mechanics,
        sound effects, and proper validation for target selection.

        The base aid item supports:
        - Health restoration for self or targeted players
        - Armor restoration (optional)
        - Sound effects when used
        - Target validation and error messaging
        - Integration with Lilia's item system
]]

-- Basic item identification
--[[
    Purpose:
        Sets the display name of the aid item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.name = "Medical Kit"
        ```
]]
ITEM.name = "aidName"
--[[
    Purpose:
        Sets the description of the aid item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.desc = "A medical kit that restores 25 health points"
        ```
]]
ITEM.desc = "aidDesc"
--[[
    Purpose:
        Sets the 3D model for the aid item

    When Called:
        During item definition

    Example Usage:
        ```lua
        ITEM.model = "models/weapons/w_package.mdl"
        ```
]]
ITEM.model = "models/weapons/w_package.mdl"
--[[
    Purpose:
        Sets the inventory width of the aid item

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
        Sets the inventory height of the aid item

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
        Sets the amount of health restored by the aid item

    When Called:
        During item definition (used in use functions)

    Example Usage:
        ```lua
        ITEM.health = 25  -- Restores 25 health points
        ```
]]
ITEM.health = 0
--[[
    Purpose:
        Sets the amount of armor restored by the aid item

    When Called:
        During item definition (used in use functions)

    Example Usage:
        ```lua
        ITEM.armor = 10  -- Restores 10 armor points
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

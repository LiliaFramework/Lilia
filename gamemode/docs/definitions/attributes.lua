--[[
    Attribute Definitions

    Character attribute definition system for the Lilia framework.

    PLACEMENT INSTRUCTIONS:

    SCHEMA LOCATION:
    - Path: garrysmod/gamemodes/<SchemaName>/schema/attributes/
    - File naming: Use descriptive names like "strength.lua", "intelligence.lua", "agility.lua"
    - Registration: Each file should define an ATTRIBUTE table and register it using lia.attribs.loadFromDir()
    - Example: lia.attribs.loadFromDir("schema/attributes/")

    MODULE LOCATION:
    - Path: garrysmod/gamemodes/<SchemaName>/modules/<ModuleName>/attributes/
    - File naming: Use descriptive names like "magic.lua", "stealth.lua", "charisma.lua"
    - Registration: Each file should define an ATTRIBUTE table and register it using lia.attribs.loadFromDir()
    - Example: lia.attribs.loadFromDir("modules/magicmodule/attributes/")

    FILE STRUCTURE EXAMPLES:
    Schema: garrysmod/gamemodes/myschema/schema/attributes/strength.lua
    Module: garrysmod/gamemodes/myschema/modules/magicmodule/attributes/magic.lua

    NOTE: Attributes represent character statistics that can be modified, boosted, and used in
    gameplay calculations. They can be configured with maximum values, starting limits, and
    whether they appear in character creation.
]]
--[[
    Overview:
    The attribute system provides functionality for defining character attributes within the Lilia framework. Attributes represent character statistics that can be modified, boosted, and used in gameplay calculations. The system includes automatic attribute loading from directories, localization support for attribute names and descriptions, and hooks for custom attribute behavior. Attributes can be configured with maximum values, starting limits, and whether they appear in character creation. The system supports attribute boosts through the character system and validation through callback methods that are automatically invoked during character setup.
]]
--[[
    Purpose:
        Sets the display name of the attribute

    When Called:
        During attribute definition

    Example Usage:
    ```lua
    ATTRIBUTE.name = "Strength"
    ```
]]
ATTRIBUTE.name = ""
--[[
    Purpose:
        Sets the description of the attribute that appears in tooltips and UI

    When Called:
        During attribute definition

    Example Usage:
    ```lua
    ATTRIBUTE.desc = "Physical power and muscle strength. Affects melee damage and carrying capacity."
    ```
]]
ATTRIBUTE.desc = ""
--[[
    Purpose:
        Sets the maximum value this attribute can reach

    When Called:
        During attribute definition (used by GetAttributeMax hook)

    Example Usage:
    ```lua
    ATTRIBUTE.maxValue = 50
    ```
]]
ATTRIBUTE.maxValue = nil
--[[
    Purpose:
        Sets the maximum value this attribute can have during character creation

    When Called:
        During attribute definition (used by GetAttributeStartingMax hook)

    Example Usage:
    ```lua
    ATTRIBUTE.startingMax = 20
    ```
]]
ATTRIBUTE.startingMax = nil
--[[
    Purpose:
        Prevents this attribute from appearing in character creation attribute allocation

    When Called:
        During attribute definition (checked in character creation UI)

    Example Usage:
    ```lua
    ATTRIBUTE.noStartBonus = true
    ```
]]
ATTRIBUTE.noStartBonus = false
--[[
    Purpose:
        Hook function called when setting up attributes for a character

    When Called:
        When a character spawns or when their attributes are initialized

    Parameters:
        - client (Player): The client whose character is being set up
        - value (number): The current attribute value

    Returns:
        None

    Realm:
        Server

    Example Usage:
    ```lua
    function ATTRIBUTE:OnSetup(client, value)
        local char = client:getChar()
        if not char then return end

        -- Set default attribute value if not already set
        if value == 0 then
            char:setAttrib(self.uniqueID, 10)
        end
    end
    ```
]]
function ATTRIBUTE:OnSetup(client, value)
end
--[[
    Example Attribute:

    Below is a comprehensive example showing how to define a complete attribute with all
    available properties and methods. This example creates a "Strength" attribute
    that demonstrates typical usage of the attribute system.

    ```lua
    ATTRIBUTE.name = "Strength"
    ATTRIBUTE.desc = "Physical power and muscle strength. Affects melee damage and carrying capacity."

    -- Configuration
    ATTRIBUTE.maxValue = 30
    ATTRIBUTE.startingMax = 15
    ATTRIBUTE.noStartBonus = false

    -- Callback Methods
    function ATTRIBUTE:OnSetup(client, value)
        local char = client:getChar()
        if not char then return end

        -- Set default strength value if not already set
        if value == 0 then
            char:setAttrib("str", 10)
        end

        -- Apply strength-based effects
        local strength = char:getAttrib("str", 10)
        char:setVar("meleeDamageBonus", math.max(0, strength - 10))
        char:setVar("carryCapacityBonus", math.floor(strength / 2))
    end
    ```
]]
--[[
    Example Attribute: Intelligence

    Below is another example showing how to define an "Intelligence" attribute
    that demonstrates different configuration options and usage patterns.

    ```lua
    ATTRIBUTE.name = "Intelligence"
    ATTRIBUTE.desc = "Mental acuity and reasoning ability. Affects learning speed and technical skills."

    -- Configuration
    ATTRIBUTE.maxValue = 40
    ATTRIBUTE.startingMax = 20
    ATTRIBUTE.noStartBonus = false

    -- Callback Methods
    function ATTRIBUTE:OnSetup(client, value)
        local char = client:getChar()
        if not char then return end

        -- Set default intelligence value if not already set
        if value == 0 then
            char:setAttrib("int", 10)
        end

        -- Apply intelligence-based effects
        local intelligence = char:getAttrib("int", 10)
        char:setVar("learningSpeedBonus", math.max(0, intelligence - 10))
        char:setVar("technicalSkillBonus", math.floor(intelligence / 3))
    end
    ```
]]
--[[
    Example Attribute: Luck (Hidden from Character Creation)

    Below is an example showing how to define a "Luck" attribute that is hidden
    from character creation but can still be modified through gameplay.

    ```lua
    ATTRIBUTE.name = "Luck"
    ATTRIBUTE.desc = "Fortune and chance. Affects random events and critical success rates."

    -- Configuration
    ATTRIBUTE.maxValue = 20
    ATTRIBUTE.startingMax = 5
    ATTRIBUTE.noStartBonus = true  -- Hidden from character creation

    -- Callback Methods
    function ATTRIBUTE:OnSetup(client, value)
        local char = client:getChar()
        if not char then return end

        -- Set default luck value if not already set
        if value == 0 then
            char:setAttrib("luck", 5)
        end

        -- Apply luck-based effects
        local luck = char:getAttrib("luck", 5)
        char:setVar("criticalChanceBonus", math.max(0, luck - 5) * 0.02)
        char:setVar("randomEventBonus", math.floor(luck / 2))
    end
    ```
]]
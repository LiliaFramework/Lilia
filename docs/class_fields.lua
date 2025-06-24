--[[
    This file documents CLASS fields defined within the codebase.

    Generated automatically.
]]
--[[
        name

        Description:
            The displayed name of the class.

        Example Usage:
            CLASS.name = "Engineer"
]]
--[[
        desc

        Description:
            The description or lore of the class.

        Example Usage:
            CLASS.desc = "Technicians who maintain equipment."
]]
--[[
        isDefault

        Description:
            Determines if the class is available by default.

        Example Usage:
            CLASS.isDefault = true
]]
--[[
        isWhitelisted

        Description:
            Indicates if the class requires whitelisting.

        Example Usage:
            CLASS.isWhitelisted = false
]]
--[[
        faction

        Description:
            Links the class to a specific faction.

        Example Usage:
            CLASS.faction = FACTION_CITIZEN
]]
--[[
        color

        Description:
            The color associated with the class.

        Example Usage:
            CLASS.color = Color(255, 0, 0)
]]
--[[
        weapons

        Description:
            Weapons available to class members.

        Example Usage:
            CLASS.weapons = {"weapon_pistol", "weapon_crowbar"}
]]
--[[
        pay

        Description:
            Payment amount for class members.

        Example Usage:
            CLASS.pay = 50
]]
--[[
        payLimit

        Description:
            Maximum accumulated pay for class members.

        Example Usage:
            CLASS.payLimit = 1000
]]
--[[
        payTimer

        Description:
            Interval in seconds for issuing pay.

        Example Usage:
            CLASS.payTimer = 3600
]]
--[[
        limit

        Description:
            Maximum number of players allowed in the class.

        Example Usage:
            CLASS.limit = 10
]]
--[[
        health

        Description:
            Default health for class members.

        Example Usage:
            CLASS.health = 150
]]
--[[
        armor

        Description:
            Default armor for class members.

        Example Usage:
            CLASS.armor = 50
]]
--[[
        scale

        Description:
            Adjusts the player model's size.

        Example Usage:
            CLASS.scale = 1.2
]]
--[[
        runSpeed

        Description:
            Default running speed for class members.

        Example Usage:
            CLASS.runSpeed = 250
]]
--[[
        runSpeedMultiplier

        Description:
            If true, multiplies runSpeed by the base speed; otherwise sets it directly.

        Example Usage:
            CLASS.runSpeedMultiplier = true
]]
--[[
        walkSpeed

        Description:
            Default walking speed for class members.

        Example Usage:
            CLASS.walkSpeed = 200
]]
--[[
        walkSpeedMultiplier

        Description:
            If true, multiplies walkSpeed by the base speed; otherwise sets it directly.

        Example Usage:
            CLASS.walkSpeedMultiplier = false
]]
--[[
        jumpPower

        Description:
            Default jump power for class members.

        Example Usage:
            CLASS.jumpPower = 200
]]
--[[
        jumpPowerMultiplier

        Description:
            If true, multiplies jumpPower by the base jump power; otherwise sets it directly.

        Example Usage:
            CLASS.jumpPowerMultiplier = true
]]
--[[
        bloodcolor

        Description:
            Sets the blood color for class members.

        Example Usage:
            CLASS.bloodcolor = BLOOD_COLOR_RED
]]
--[[
        bodyGroups

        Description:
            Assigns bodygroup values on spawn.

        Example Usage:
            CLASS.bodyGroups = { [1] = 2, [3] = 1 }
]]
--[[
        model

        Description:
            Model or models assigned to the class.

        Example Usage:
            CLASS.model = "models/player/alyx.mdl"
]]
--[[
        index

        Description:
            Unique ID (team index) identifying the class.

        Example Usage:
            CLASS.index = CLASS_ENGINEER
]]

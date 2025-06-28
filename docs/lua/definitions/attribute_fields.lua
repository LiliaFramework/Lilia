--[[
        This file documents ATTRIBUTE fields defined within the codebase.

        Generated automatically.
]]
--[[
        ATTRIBUTE.name

        Description:
            Specifies the display name of the attribute.

        Example Usage:
            ATTRIBUTE.name = "Strength"
]]
--[[
        ATTRIBUTE.desc

        Description:
            Provides a short description of the attribute.

        Example Usage:
            ATTRIBUTE.desc = "Strength Skill."
]]
--[[
        ATTRIBUTE.noStartBonus

        Description:
            Determines whether the attribute can receive a bonus at the start of the game.

        Example Usage:
            ATTRIBUTE.noStartBonus = false
]]
--[[
        ATTRIBUTE.maxValue

        Description:
            Specifies the maximum value the attribute can reach.

        Example Usage:
            ATTRIBUTE.maxValue = 50
]]
--[[
        ATTRIBUTE.startingMax

        Description:
            Defines the maximum value the attribute can start with.

        Example Usage:
            ATTRIBUTE.startingMax = 15
]]
--[[
        ATTRIBUTE:OnSetup(client, value)

        Description:
            Runs custom logic when the attribute is initialized on a player,
            for example after character load or whenever the attribute
            value is modified.

        Example Usage:
            function ATTRIBUTE:OnSetup(client, value)
                if value > 5 then
                    client:ChatPrint("You are very Strong!")
                end
            end
]]
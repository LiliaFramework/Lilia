--[[
    This file documents FACTION fields defined within the codebase.

    Generated automatically.
]]

--[[
        name

        Description:
            Display name shown for members of this faction.

        Example Usage:
            FACTION.name = "Minecrafters"
]]

--[[
        desc

        Description:
            Lore or descriptive text about the faction.

        Example Usage:
            FACTION.desc = "Surviving and crafting in the blocky world."
]]

--[[
        isDefault

        Description:
            Set to true if players may select this faction without a whitelist.

        Example Usage:
            FACTION.isDefault = false
]]

--[[
        color

        Description:
            Color used to represent the faction in UI elements.

        Example Usage:
            FACTION.color = Color(255, 56, 252)
]]

--[[
        models

        Description:
            Table of player models available to faction members.

        Example Usage:
            FACTION.models = {"models/Humans/Group02/male_07.mdl"}
]]

--[[
        uniqueID

        Description:
            String identifier used internally to reference the faction.

        Example Usage:
            FACTION.uniqueID = "staff"
]]

--[[
        weapons

        Description:
            Weapons automatically granted to players in this faction.

        Example Usage:
            FACTION.weapons = {"weapon_physgun", "gmod_tool"}
]]

--[[
        items

        Description:
            Table of item uniqueIDs automatically granted when a character is created.

        Example Usage:
            FACTION.items = {"radio", "handcuffs"}
]]

--[[
        index

        Description:
            Numeric identifier assigned during faction registration.

        Example Usage:
            FACTION_STAFF = FACTION.index
]]
--[[
        pay

        Description:
            Payment amount for members of this faction.

        Example Usage:
            FACTION.pay = 50
]]

--[[
        payLimit

        Description:
            Maximum pay a member can accumulate.

        Example Usage:
            FACTION.payLimit = 1000
]]

--[[
        payTimer

        Description:
            Interval in seconds between salary payouts.

        Example Usage:
            FACTION.payTimer = 3600
]]

--[[
        limit

        Description:
            Maximum number of players allowed in this faction.

        Example Usage:
            FACTION.limit = 20
]]

--[[
        oneCharOnly

        Description:
            If true, players may only create one character in this faction.

        Example Usage:
            FACTION.oneCharOnly = true
]]

--[[
        health

        Description:
            Starting health for faction members.

        Example Usage:
            FACTION.health = 150
]]

--[[
        armor

        Description:
            Starting armor for faction members.

        Example Usage:
            FACTION.armor = 25
]]

--[[
        scale

        Description:
            Player model scale multiplier for this faction.

        Example Usage:
            FACTION.scale = 1.1
]]

--[[
        runSpeed

        Description:
            Base running speed for members of this faction.

        Example Usage:
            FACTION.runSpeed = 250
]]

--[[
        runSpeedMultiplier

        Description:
            If true, runSpeed multiplies the base speed instead of replacing it.

        Example Usage:
            FACTION.runSpeedMultiplier = false
]]

--[[
        walkSpeed

        Description:
            Base walking speed for members of this faction.

        Example Usage:
            FACTION.walkSpeed = 200
]]

--[[
        walkSpeedMultiplier

        Description:
            If true, walkSpeed multiplies the base speed instead of replacing it.

        Example Usage:
            FACTION.walkSpeedMultiplier = true
]]

--[[
        jumpPower

        Description:
            Base jump power for members of this faction.

        Example Usage:
            FACTION.jumpPower = 200
]]

--[[
        jumpPowerMultiplier

        Description:
            If true, jumpPower multiplies the base jump power instead of replacing it.

        Example Usage:
            FACTION.jumpPowerMultiplier = true
]]

--[[
        MemberToMemberAutoRecognition

        Description:
            Whether members automatically recognize each other.

        Example Usage:
            FACTION.MemberToMemberAutoRecognition = true
]]

--[[
        bloodcolor

        Description:
            Blood color enumeration for faction members.

        Example Usage:
            FACTION.bloodcolor = BLOOD_COLOR_RED
]]

--[[
        bodyGroups

        Description:
            Table mapping bodygroup names to the index value each should use.
            These are applied whenever a faction member spawns.

        Example Usage:
            FACTION.bodyGroups = {
                hands = 1,
                torso = 3
            }
]]

--[[
        NPCRelations

        Description:
            Table mapping NPC class names to disposition constants such as
            D_HT (hate) or D_LI (like). Each NPC is updated with these
            relationships when the player spawns or the NPC is created.

        Example Usage:
            FACTION.NPCRelations = {
                ["npc_combine_s"] = D_HT,
                ["npc_citizen"] = D_LI
            }
]]

--[[
        RecognizesGlobally

        Description:
            If true, members of this faction recognize all players globally.

        Example Usage:
            FACTION.RecognizesGlobally = false
]]

--[[
        ScoreboardHidden

        Description:
            If true, members of this faction are hidden from the scoreboard.

        Example Usage:
            FACTION.ScoreboardHidden = false
]]

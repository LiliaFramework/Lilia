--[[
    This file documents ITEM fields defined within the codebase.

]]
--[[
        ITEM.BagSound

        Description:
            Sound played when moving items to/from the bag.

        Base:
            Bag Base

        Example Usage:
            ITEM.BagSound = {"physics/cardboard/cardboard_box_impact_soft2.wav", 50}
]]

--[[
        ITEM.DropOnDeath

        Description:
            Deletes the item upon player death.

        Base:
            Weapons/Grenade Base

        Example Usage:
            ITEM.DropOnDeath = true
]]

--[[
        ITEM.FactionWhitelist

        Description:
            Allowed factions for vendor interaction.

        Base:
            General

        Example Usage:
            ITEM.FactionWhitelist = {FACTION_CITIZEN}
]]

--[[
        ITEM.RequiredSkillLevels

        Description:
            Skill requirements needed to use the item.

        Base:
            General

        Example Usage:
            ITEM.RequiredSkillLevels = {Strength = 5}
]]

--[[
        ITEM.SteamIDWhitelist

        Description:
            Allowed Steam IDs for vendor interaction.

        Base:
            General

        Example Usage:
            ITEM.SteamIDWhitelist = {"STEAM_0:1:123"}
]]

--[[
        ITEM.UsergroupWhitelist

        Description:
            Allowed user groups for vendor interaction.

        Base:
            General

        Example Usage:
            ITEM.UsergroupWhitelist = {"admin"}
]]

--[[
        ITEM.VIPWhitelist

        Description:
            Restricts usage to VIP players.

        Base:
            General

        Example Usage:
            ITEM.VIPWhitelist = true
]]

--[[
        ITEM.VManipDisabled

        Description:
            Disables VManip grabbing for the item.

        Base:
            General

        Example Usage:
            ITEM.VManipDisabled = true
]]

--[[
        ITEM.ammo

        Description:
            Ammo type provided.

        Base:
            Ammo Base

        Example Usage:
            ITEM.ammo = "pistol"
]]

--[[
        ITEM.ammoAmount

        Description:
            Amount of ammo contained.

        Base:
            Ammo Base

        Example Usage:
            ITEM.ammoAmount = 30
]]

--[[
        ITEM.armor

        Description:
            Armor value granted when equipped.

        Base:
            Outfit Base

        Example Usage:
            ITEM.armor = 50
]]

--[[
        ITEM.attribBoosts

        Description:
            Attribute boosts applied on equip.

        Base:
            Outfit Base

        Example Usage:
            ITEM.attribBoosts = {strength = 5}
]]

--[[
        ITEM.base

        Description:
            Base item this item derives from.

        Base:
            General

        Example Usage:
            ITEM.base = "weapon"
]]

--[[
        ITEM.canSplit

        Description:
            Whether the item stack can be divided.

        Base:
            General

        Example Usage:
            ITEM.canSplit = true
]]

--[[
        ITEM.category

        Description:
            Inventory grouping category.

        Base:
            General

        Example Usage:
            ITEM.category = "Storage"
]]

--[[
        ITEM.class

        Description:
            Weapon entity class.

        Base:
            Weapon/Grenade Base

        Example Usage:
            ITEM.class = "weapon_pistol"
]]

--[[
        ITEM.contents

        Description:
            HTML contents of a readable book.

        Base:
            Book Base

        Example Usage:
            ITEM.contents = "<h1>Book</h1>"
]]

--[[
        ITEM.desc

        Description:
            Short description shown to players.

        Base:
            General

        Example Usage:
            ITEM.desc = "An example item"
]]

--[[
        ITEM.entityid

        Description:
            Entity class spawned by the item.

        Base:
            Entities Base

        Example Usage:
            ITEM.entityid = "item_suit"
]]

--[[
        ITEM.equipSound

        Description:
            Sound played when equipping.

        Base:
            Weapon/Outfit

        Example Usage:
            ITEM.equipSound = "items/ammo_pickup.wav"
]]

--[[
        ITEM.flag

        Description:
            Flag required to purchase the item.

        Base:
            General

        Example Usage:
            ITEM.flag = "Y"
]]

--[[
        ITEM.functions

        Description:
            Table of interaction functions.

        Base:
            General

        Example Usage:
            ITEM.functions = {}
]]

--[[
        ITEM.grenadeClass

        Description:
            Class name used when spawning a grenade.

        Base:
            Grenade Base

        Example Usage:
            ITEM.grenadeClass = "weapon_frag"
]]

--[[
        ITEM.health

        Description:
            Amount of health restored when used.

        Base:
            Aid Base

        Example Usage:
            ITEM.health = 50
]]

--[[
        ITEM.height

        Description:
            Height in inventory grid.

        Base:
            General

        Example Usage:
            ITEM.height = 1
]]

--[[
        ITEM.id

        Description:
            Database identifier.

        Base:
            General

        Example Usage:
            print(item.id)
]]

--[[
        ITEM.invHeight

        Description:
            Internal bag inventory height.

        Base:
            Bag Base

        Example Usage:
            ITEM.invHeight = 2
]]

--[[
        ITEM.invWidth

        Description:
            Internal bag inventory width.

        Base:
            Bag Base

        Example Usage:
            ITEM.invWidth = 2
]]

--[[
        ITEM.isBag

        Description:
            Marks the item as a bag providing extra inventory.

        Base:
            Bag Base

        Example Usage:
            ITEM.isBag = true
]]

--[[
        ITEM.isBase

        Description:
            Indicates the table is a base item.

        Base:
            General

        Example Usage:
            ITEM.isBase = true
]]

--[[
        ITEM.isOutfit

        Description:
            Marks the item as an outfit.

        Base:
            Outfit Base

        Example Usage:
            ITEM.isOutfit = true
]]

--[[
        ITEM.isStackable

        Description:
            Allows stacking multiple quantities.

        Base:
            General

        Example Usage:
            ITEM.isStackable = false
]]

--[[
        ITEM.isWeapon

        Description:
            Marks the item as a weapon.

        Base:
            Weapon Base

        Example Usage:
            ITEM.isWeapon = true
]]

--[[
        ITEM.maxQuantity

        Description:
            Maximum stack size.

        Base:
            General

        Example Usage:
            ITEM.maxQuantity = 10
]]

--[[
        ITEM.model

        Description:
            3D model path for the item.

        Base:
            General

        Example Usage:
            ITEM.model = "models/props_c17/oildrum001.mdl"
]]

--[[
        ITEM.name

        Description:
            Displayed name of the item.

        Base:
            General

        Example Usage:
            ITEM.name = "Example Item"
]]

--[[
        ITEM.newSkin

        Description:
            Skin index applied to the player model.

        Base:
            Outfit Base

        Example Usage:
            ITEM.newSkin = 1
]]

--[[
        ITEM.outfitCategory

        Description:
            Slot or category for the outfit.

        Base:
            Outfit/PAC Outfit

        Example Usage:
            ITEM.outfitCategory = "body"
]]

--[[
        ITEM.pacData

        Description:
            PAC3 customization information.

        Base:
            Bag/Outfit/PAC Outfit

        Example Usage:
            ITEM.pacData = {}
]]

--[[
        ITEM.postHooks

        Description:
            Table of post-hook callbacks.

        Base:
            General

        Example Usage:
            ITEM.postHooks = {}
]]

--[[
        ITEM.price

        Description:
            Item cost for trading or selling.

        Base:
            General

        Example Usage:
            ITEM.price = 100
]]

--[[
        ITEM.quantity

        Description:
            Current amount in the item stack.

        Base:
            General

        Example Usage:
            item:getQuantity()
]]

--[[
        ITEM.rarity

        Description:
            Rarity level affecting vendor color.

        Base:
            General

        Example Usage:
            ITEM.rarity = "Legendary"
]]

--[[
        ITEM.replacements

        Description:
            Model replacements when equipped.

        Base:
            Outfit Base

        Example Usage:
            ITEM.replacements = "models/player/combine_soldier.mdl"
]]

--[[
        ITEM.unequipSound

        Description:
            Sound played when unequipping.

        Base:
            Weapon/Outfit

        Example Usage:
            ITEM.unequipSound = "items/ammo_pickup.wav"
]]

--[[
        ITEM.uniqueID

        Description:
            Overrides the automatically generated unique identifier.

        Base:
            General

        Example Usage:
            ITEM.uniqueID = "custom_unique_id"
]]

--[[
        ITEM.url

        Description:
            Web address opened when using the item.

        Base:
            URL Base

        Example Usage:
            ITEM.url = "https://example.com"
]]

--[[
        ITEM.visualData

        Description:
            Table storing outfit visual information.

        Base:
            Outfit Base

        Example Usage:
            ITEM.visualData = {}
]]

--[[
        ITEM.weaponCategory

        Description:
            Slot category for the weapon.

        Base:
            Weapon Base

        Example Usage:
            ITEM.weaponCategory = "sidearm"
]]

--[[
        ITEM.width

        Description:
            Width in inventory grid.

        Base:
            General

        Example Usage:
            ITEM.width = 2
]]

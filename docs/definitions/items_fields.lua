--[[
    This file documents ITEM fields defined within the codebase.

    Generated automatically.
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
            Weapon/Grenade Base

        Example Usage:
            ITEM.DropOnDeath = true
]]

--[[
        ITEM.FactionWhitelist

        Description:
            Factions allowed to interact with vendors.

        Base:
            General

        Example Usage:
            ITEM.FactionWhitelist = {FACTION_CITIZEN}
]]

--[[
        ITEM.RequiredSkillLevels

        Description:
            Minimum skill levels required to use the item.

        Base:
            General

        Example Usage:
            ITEM.RequiredSkillLevels = {Strength = 5}
]]

--[[
        ITEM.SteamIDWhitelist

        Description:
            Steam IDs permitted to interact with vendors.

        Base:
            General

        Example Usage:
            ITEM.SteamIDWhitelist = {"STEAM_0:1:123"}
]]

--[[
        ITEM.UsergroupWhitelist

        Description:
            User groups permitted to interact with vendors.

        Base:
            General

        Example Usage:
            ITEM.UsergroupWhitelist = {"admin"}
]]

--[[
        ITEM.VIPWhitelist

        Description:
            Restricts usage to VIP players only.

        Base:
            General

        Example Usage:
            ITEM.VIPWhitelist = true
]]

--[[
        ITEM.VManipDisabled

        Description:
            Disables VManip grabbing support for this item.

        Base:
            General

        Example Usage:
            ITEM.VManipDisabled = true
]]

--[[
        ITEM.ammo

        Description:
            Type of ammunition provided.

        Base:
            Ammo Base

        Example Usage:
            ITEM.ammo = "pistol"
]]

--[[
        ITEM.ammoAmount

        Description:
            Amount of ammunition contained.

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
            Attribute boosts applied when equipped.

        Base:
            Outfit Base

        Example Usage:
            ITEM.attribBoosts = {strength = 5}
]]

--[[
        ITEM.base

        Description:
            Base item from which this item derives.

        Base:
            General

        Example Usage:
            ITEM.base = "weapon"
]]

--[[
        ITEM.canSplit

        Description:
            Whether the item stack can be divided into smaller stacks.

        Base:
            General

        Example Usage:
            ITEM.canSplit = true
]]

--[[
        ITEM.category

        Description:
            Inventory category used for grouping.

        Base:
            General

        Example Usage:
            ITEM.category = "Storage"
]]

--[[
        ITEM.class

        Description:
            Class name of the weapon entity.

        Base:
            Weapon/Grenade Base

        Example Usage:
            ITEM.class = "weapon_pistol"
]]

--[[
        ITEM.contents

        Description:
            HTML content for a readable book.

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
            Entity class that this item spawns.

        Base:
            Entities Base

        Example Usage:
            ITEM.entityid = "item_suit"
]]

--[[
        ITEM.equipSound

        Description:
            Sound to play when the item is equipped.

        Base:
            Weapon/Outfit

        Example Usage:
            ITEM.equipSound = "items/ammo_pickup.wav"
]]

--[[
        ITEM.flag

        Description:
            Flag required in order to purchase the item.

        Base:
            General

        Example Usage:
            ITEM.flag = "Y"
]]

--[[
        ITEM.functions

        Description:
            Table of item interaction functions.

        Base:
            General

        Example Usage:
            ITEM.functions = {}
]]

--[[
        ITEM.grenadeClass

        Description:
            Class name used when spawning the grenade.

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
            Height of the item in the inventory grid.

        Base:
            General

        Example Usage:
            ITEM.height = 1
]]

--[[
        ITEM.id

        Description:
            Unique database identifier.

        Base:
            General

        Example Usage:
            print(item.id)
]]

--[[
        ITEM.invHeight

        Description:
            Height of the internal bag inventory.

        Base:
            Bag Base

        Example Usage:
            ITEM.invHeight = 2
]]

--[[
        ITEM.invWidth

        Description:
            Width of the internal bag inventory.

        Base:
            Bag Base

        Example Usage:
            ITEM.invWidth = 2
]]

--[[
        ITEM.isBag

        Description:
            Marks the item as a bag that provides extra inventory space.

        Base:
            Bag Base

        Example Usage:
            ITEM.isBag = true
]]

--[[
        ITEM.isBase

        Description:
            Indicates that this table is a base item.

        Base:
            General

        Example Usage:
            ITEM.isBase = true
]]

--[[
        ITEM.isOutfit

        Description:
            Marks the item as an outfit item.

        Base:
            Outfit Base

        Example Usage:
            ITEM.isOutfit = true
]]

--[[
        ITEM.isStackable

        Description:
            Allows stacking multiple copies.

        Base:
            General

        Example Usage:
            ITEM.isStackable = false
]]

--[[
        ITEM.isWeapon

        Description:
            Marks the item as a weapon item.

        Base:
            Weapon Base

        Example Usage:
            ITEM.isWeapon = true
]]

--[[
        ITEM.maxQuantity

        Description:
            Maximum allowed stack size.

        Base:
            General

        Example Usage:
            ITEM.maxQuantity = 10
]]

--[[
        ITEM.model

        Description:
            Path to the item model.

        Base:
            General

        Example Usage:
            ITEM.model = "models/props_c17/oildrum001.mdl"
]]

--[[
        ITEM.name

        Description:
            Display name of the item.

        Base:
            General

        Example Usage:
            ITEM.name = "Example Item"
]]

--[[
        ITEM.newSkin

        Description:
            Skin index applied to the player's model.

        Base:
            Outfit Base

        Example Usage:
            ITEM.newSkin = 1
]]

--[[
        ITEM.outfitCategory

        Description:
            Slot or category assigned to the outfit.

        Base:
            Outfit/PAC Outfit

        Example Usage:
            ITEM.outfitCategory = "body"
]]

--[[
        ITEM.pacData

        Description:
            Saved data from your PAC3 addon used to apply custom outfits when the item is equipped.

        Base:
            Bag/Outfit/PAC Outfit

        Example Usage:
            ITEM.pacData = {
                [1] = {
                    self = {
                        ClassName = "model",
                        Model = "models/Gibs/HGIBS.mdl"
                    }
                }
            }
]]

--[[
        ITEM.postHooks

        Description:
            Callbacks executed after built-in item actions, such as after the item is equipped or used.

        Base:
            General

        Example Usage:
            ITEM.postHooks = {
                drop = function(item)
                    print(item:getName() .. " dropped")
                end
            }
]]

--[[
        ITEM.price

        Description:
            Item cost when trading or selling.

        Base:
            General

        Example Usage:
            ITEM.price = 100
]]

--[[
        ITEM.quantity

        Description:
            Current quantity within the stack.

        Base:
            General

        Example Usage:
            item:getQuantity()
]]

--[[
        ITEM.rarity

        Description:
            Rarity level that affects vendor color.

        Base:
            General

        Example Usage:
            ITEM.rarity = "Legendary"
]]

--[[
        ITEM.replacements

        Description:
            Model replacements applied when equipped.

        Base:
            Outfit Base

        Example Usage:
            ITEM.replacements = "models/player/combine_soldier.mdl"
]]

--[[
        ITEM.unequipSound

        Description:
            Sound to play when the item is unequipped.

        Base:
            Weapon/Outfit

        Example Usage:
            ITEM.unequipSound = "items/ammo_pickup.wav"
]]

--[[
        ITEM.uniqueID

        Description:
            Overrides the automatically generated unique ID.

        Base:
            General

        Example Usage:
            ITEM.uniqueID = "custom_unique_id"
]]

--[[
        ITEM.url

        Description:
            URL opened when the item is used.

        Base:
            URL Base

        Example Usage:
            ITEM.url = "https://example.com"
]]

--[[
        ITEM.visualData

        Description:
            Table storing outfit visual data.

        Base:
            Outfit Base

        Example Usage:
            ITEM.visualData = {}
]]

--[[
        ITEM.weaponCategory

        Description:
            Slot category assigned to the weapon.

        Base:
            Weapon Base

        Example Usage:
            ITEM.weaponCategory = "sidearm"
]]

--[[
        ITEM.width

        Description:
            Width of the item in the inventory grid.

        Base:
            General

        Example Usage:
            ITEM.width = 2
]]

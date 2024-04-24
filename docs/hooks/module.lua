--[[--
General Hooks.

These hooks are regular hooks that can be used in your schema with `SCHEMA:HookName(args)`, in your module with
`MODULE:HookName(args)`, or in your addon with `hook.Add("HookName", function(args) end)`.
They can be used for an assorted of reasons, depending on what you are trying to achieve.
]]
-- @hooks Module

--- Called after a player sends a chat message.
-- @realm server
-- @client client The player entity who sent the message.
-- @string message The message sent by the player.
-- @string chatType The type of chat message (e.g., "ic" for in-character, "ooc" for out-of-character).
-- @bool anonymous Whether the message was sent anonymously (true) or not (false).
function PostPlayerSay(client, message, chatType, anonymous)
end

--- Whether or not a player can trade with a vendor.
-- @realm server
-- @client client Player attempting to trade
-- @entity entity Vendor entity
-- @string uniqueID The uniqueID of the item being traded.
-- @bool isSellingToVendor If the client is selling to the vendor
-- @treturn bool Whether or not to allow the client to trade with the vendor
-- @usage function MODULE:CanPlayerTradeWithVendor(client, entity, uniqueID, isSellingToVendor)
-- 	return false -- Disallow trading with vendors outright.
-- end
function CanPlayerTradeWithVendor(client, entity, uniqueID, isSellingToVendor)
end

--- Whether or not a player can unequip an item.
-- @realm server
-- @client client Player attempting to unequip an item
-- @tab item Item being unequipped
-- @treturn bool Whether or not to allow the player to unequip the item
-- @see CanPlayerEquipItem
-- @usage function MODULE:CanPlayerUnequipItem(client, item)
-- 	return false -- Disallow unequipping items.
-- end
function CanPlayerUnequipItem(client, item)
end

--- Whether or not a player is allowed to drop the given `item`.
-- @realm server
-- @client client Player attempting to drop an item
-- @number item instance ID of the item being dropped
-- @treturn bool Whether or not to allow the player to drop the item
-- @usage function MODULE:CanPlayerDropItem(client, item)
-- 	return false -- Never allow dropping items.
-- end
function CanPlayerDropItem(client, item)
end

--- Whether or not a player is allowed to take an item and put it in their inventory.
-- @realm server
-- @client client Player attempting to take the item
-- @entity item Entity corresponding to the item
-- @treturn bool Whether or not to allow the player to take the item
-- @usage function MODULE:CanPlayerTakeItem(client, item)
-- 	return !(client:GetMoveType() == MOVETYPE_NOCLIP and !client:InVehicle()) -- Disallow players in observer taking items.
-- end
function CanPlayerTakeItem(client, item)
end

--- Whether or not a player can equip the given `item`. This is called for items with `outfit`, `pacoutfit`, or `weapons` as
-- their base. Schemas/modules can utilize this hook for their items.
-- @realm server
-- @client client Player attempting to equip the item
-- @tab item Item being equipped
-- @treturn bool Whether or not to allow the player to equip the item
-- @see CanPlayerUnequipItem
-- @usage function MODULE:CanPlayerEquipItem(client, item)
-- 	return client:IsAdmin() -- Restrict equipping items to admins only.
-- end
function CanPlayerEquipItem(client, item)
end

--- Whether or not a player is allowed to interact with an item via an inventory action (e.g picking up, dropping, transferring
-- inventories, etc). Note that this is for an item *table*, not an item *entity*. This is called after `CanPlayerDropItem`
-- and `CanPlayerTakeItem`.
-- @realm server
-- @client client Player attempting interaction
-- @string action The action being performed
-- @param item Item's instance ID or item table
-- @treturn bool Whether or not to allow the player to interact with the item
-- @usage function MODULE:CanPlayerInteractItem(client, action, item, data)
-- 	return false -- Disallow interacting with any item.
-- end
function CanPlayerInteractItem(client, action, item)
end

--- Displays the context menu for interacting with an item entity.
--- @realm client
--- @entity entity The item entity for which the context menu is displayed.
function ItemShowEntityMenu(entity)
end

--- Called when the third person mode is toggled.
--- @realm client
--- @bool state Indicates whether the third person mode is enabled (`true`) or disabled (`false`).
function thirdPersonToggled(state)
end

--- Called when a character trades with a vendor entity.
-- This function can be used to perform additional actions when a character trades
-- with a vendor entity.
-- @realm shared
-- @client client The player character trading with the vendor
-- @param entity The vendor entity being traded with
-- @param uniqueID The unique identifier of the traded item
-- @param isSellingToVendor Whether the trade involves selling to the vendor
-- @usage function CharacterVendorTraded(client, entity, uniqueID, isSellingToVendor)
--     -- Perform additional actions when a character trades with the vendor
-- end
function CharacterVendorTraded(client, entity, uniqueID, isSellingToVendor)
end

--- Called when a player interacts with a vendor entity.
-- This function adds the player to the vendor's receivers list and notifies the player
-- about accessing the vendor.
-- @param client The player accessing the vendor
-- @param entity The vendor
-- @usage function PlayerAccessVendor(client, entity)
--     -- Add the player to the vendor's receivers list
--     entity.receivers[#entity.receivers + 1] = client
--
--     -- Notify the player about accessing the vendor
--     if entity.messages[VENDOR_WELCOME] then
--         client:notify(entity:getNetVar("name") .. ": " .. entity.messages[VENDOR_WELCOME])
--     end
-- end
--- @realm shared
function PlayerAccessVendor(client, entity)
end

--- Called when a player sells an item to a vendor.
-- @realm shared
-- This function handles the event where a player sells an item to a vendor.
-- @param client The player selling the item
-- @param vendor The vendor entity
-- @param itemType The type of item being sold
-- @param isSellingToVendor Indicates whether the player is selling to the vendor (always false in this context)
-- @param character The character of the player selling the item
-- @param price The price at which the item is sold
function VendorSellEvent(client, vendor, itemType, isSellingToVendor, character, price)
end

--- Called when a player successfully buys an item from a vendor.
-- This function is called when a player successfully completes a purchase from a vendor.
-- @param client The player who made the purchase
-- @param vendor The vendor entity from which the item was bought
-- @param itemType The type of item being bought
-- @param isSellingToVendor Indicates whether the player is selling to the vendor (always false in this context)
-- @param character The character of the player involved in the trade
-- @param price The price of the item being bought
-- @realm shared
function VendorBuyEvent(client, vendor, itemType, isSellingToVendor, character, price)
end

--- Called to determine whether data should be saved before shutting down the server.
-- This function is called to determine whether data should be saved before the server shuts down.
-- @return boolean True if data should be saved, false otherwise
-- @realm shared
function ShouldDataBeSaved()
end

--- Called when a player picks up money.
-- This function is called when a player picks up money from the ground.
-- @client client The player who picked up the money
-- @entity moneyEntity The entity representing the money being picked up
-- @realm shared

function OnPickupMoney(client, moneyEntity)
end
--- Determines whether an item can be transferred between inventories.
-- @realm shared
-- This hook allows custom logic to be implemented to determine if an item can be transferred
-- from one inventory to another. It can be used to impose restrictions on item transfers.
-- @param item The item being transferred
-- @param currentInv The current inventory from which the item is being transferred
-- @param oldInv The old inventory to which the item belonged
-- @return boolean|string Whether the item can be transferred, or false and a reason if not
-- @usage function CanItemBeTransfered(item, currentInv, oldInv)
--     -- Implement custom logic to determine if the item can be transferred
--     -- For example, check if the item is allowed to be transferred based on specific conditions
--     -- If allowed, return true; otherwise, return false and a reason
-- end
function CanItemBeTransfered(item, currentInv, oldInv)
end

--- Saves the server data.
-- @realm server
function SaveData()
end

--- Loads the server data.
-- @realm server
function LoadData()
end

--- Called after data has been loaded.
-- @realm server
function PostLoadData()
end

--- Whether or not a player is allowed to create a new character.
-- @realm server
-- @client client Player attempting to create a new character
-- @treturn bool Whether or not the player is allowed to create the character. This function defaults to `true`, so you
-- should only ever return `false` if you're disallowing creation. Otherwise, don't return anything as you'll prevent any other
-- calls to this hook from running.
-- @treturn string Language phrase to use for the error message
-- @treturn ... Arguments to use for the language phrase
-- @usage function MODULE:CanPlayerCreateCharacter(client)
-- 	if (!client:IsAdmin()) then
-- 		return false, "notNow" -- only allow admins to create a character
-- 	end
-- end
-- -- non-admins will see the message "You are not allowed to do this right now!"
function CanPlayerCreateCharacter(client)
end

--- Called after a character is deleted.
-- @realm server
-- @client client The player entity.
-- @character character The character being deleted.
function PostCharDelete(client, character)
end

--- Called after a player's loadout is applied.
-- @realm server
-- @client client The player entity.
function PostPlayerLoadout(client)
end

--- Called after all of the player's loadout hooks are executed (PlayerLoadout, FactionOnLoadout, ClassOnLoadout).
-- This hook is called after a player's loadout has been fully applied, including faction and class loadouts.
-- @param client The player entity for whom the loadout was applied.
-- @realm server
function PostPlayerLoadout(client)
    -- Your implementation here
end

--- Called after PlayerLoadout is executed.
-- This hook is called after a player's faction loadout has been applied.
-- @param client The player entity for whom the faction loadout was applied.
-- @realm server
function FactionOnLoadout(client)
    -- Your implementation here
end

--- Called after FactionOnLoadout is executed.
-- This hook is called after a player's class loadout has been applied.
-- @param client The player entity for whom the class loadout was applied.
-- @realm server
function ClassOnLoadout(client)
    -- Your implementation here
end

--- Called after PostPlayerLoadout is executed.
-- This hook is called after additional actions related to a player's faction loadout have been performed.
-- @param client The player entity for whom the faction loadout was applied.
-- @realm server
function FactionPostLoadout(client)
    -- Your implementation here
end

--- Called after FactionPostLoadout is executed.
-- This hook is called after additional actions related to a player's class loadout have been performed.
-- @param client The player entity for whom the class loadout was applied.
-- @realm server
function ClassPostLoadout(client)
    -- Your implementation here
end

--- Called after a character is deleted.
-- @realm server
-- @client client The player entity.
-- @character character The character being deleted.
function CharDeleted(client, character)
end

--- Called before a player's character is loaded.
-- @realm server
-- @client client The player entity.
-- @character character The character being loaded.
-- @character currentChar The current character of the player.
function PrePlayerLoadedChar(client, character, currentChar)
end

--- Called when a player's character is loaded.
-- @realm server
-- @client client The player entity.
-- @character character The character being loaded.
-- @character currentChar The current character of the player.
function PlayerLoadedChar(client, character, currentChar)
end

--- Called after a player's character is loaded.
-- @realm server
-- @client client The player entity.
-- @character character The character being loaded.
-- @character currentChar The current character of the player.
function PostPlayerLoadedChar(client, character, currentChar)
end

--- Determines whether a client should drown.
-- @realm server
-- @client client The player entity.
-- @return boolean True if the client should drown, false otherwise.
function ShouldClientDrown(client)
end

--- Called when a player tries to use abilities on the door, such as locking.
-- @realm shared
-- @client client The client trying something on the door.
-- @entity door The door entity itself.
-- @number access The access level used when called.
-- @treturn bool Whether or not to allow the client access.
-- @usage function MODULE:CanPlayerAccessDoor(client, door, access)
--     return true -- Always allow access.
-- end
function CanPlayerAccessDoor(client, door, access)
end

--- Whether or not a plyer is allowed to join a class.
-- @realm shared
-- @client client Player attempting to join
-- @number class ID of the class
-- @tab info The class table
-- @treturn bool Whether or not to allow the player to join the class
-- @usage function MODULE:CanPlayerJoinClass(client, class, info)
-- 	return client:IsAdmin() -- Restrict joining classes to admins only.
-- end
function CanPlayerJoinClass(client, class, info)
end

--- Whether or not a player can earn money at regular intervals. This hook runs only if the player's character faction has
-- a salary set i.e `FACTION.pay` is set to something other than `0` for their faction.
-- @realm server
-- @client client Player to give money to
-- @tab faction Faction of the player's character
-- @tab class Class of the player's character
-- @treturn bool Whether or not to allow the player to earn salary
-- @usage function MODULE:CanPlayerEarnSalary(client, faction)
-- 	return client:IsAdmin() -- Restricts earning salary to admins only.
-- end
function CanPlayerEarnSalary(client, faction, class)
end

--- Whether or not the player is allowed to punch with the hands SWEP.
-- @realm shared
-- @client client Player attempting throw a punch
-- @treturn bool Whether or not to allow the player to punch
-- @usage function MODULE:CanPlayerThrowPunch(client)
-- 	return client:GetCharacter():GetAttribute("str", 0) > 0 -- Only allow players with strength to punch.
-- end
function CanPlayerThrowPunch(client)
end

--- Determines whether a player is allowed to use a specific character.
-- This hook can be used to implement custom checks to determine if a player is
-- allowed to use a particular character.
-- @realm shared
-- @client client The player attempting to use the character
-- @param character The character being considered for use
-- @treturn boolean Whether the player is allowed to use the character
-- @treturn string|nil If disallowed, a reason for the disallowance; otherwise, nil
function CanPlayerUseChar(client, character)
end

--- Determines whether a player is allowed to use a door entity.
-- This hook can be used to implement custom checks to determine if a player is
-- allowed to use a specific door entity.
-- @realm server
-- @client client The player attempting to use the door
-- @param entity The door entity being considered for use
-- @treturn boolean Whether the player is allowed to use the door
function CanPlayerUseDoor(client, entity)
end

--- Determines whether a player is allowed to access a vendor entity.
-- This hook can be used to implement custom checks to determine if a player is
-- allowed to access a specific vendor entity.
-- @realm server
-- @param activator The player attempting to access the vendor
function CanPlayerAccessVendor(activator)
end

--- Called when a character is loaded.
-- This function is called after a character has been successfully loaded.
-- @param character The character that has been loaded
-- @realm shared
function CharacterLoaded(character)
    -- Implementation details omitted for brevity
end

--- Called after a character has been saved.
-- This function is called after a character has been successfully saved.
-- @param character The character that has been saved
-- @realm server
function CharacterPostSave(character)
    -- Implementation details omitted for brevity
end

--- Called before a character is saved.
-- This function is called before a character is about to be saved.
-- @param character The character about to be saved
-- @realm shared
function CharacterPreSave(character)
    -- Implementation details omitted for brevity
end

--- Whether or not the ammo HUD should be drawn.
-- @realm client
-- @entity weapon Weapon the player currently is holding
-- @treturn bool Whether or not to draw the ammo hud
-- @usage function MODULE:ShouldDrawAmmoHUD(weapon)
-- 	if (weapon:GetClass() == "weapon_frag") then
-- 		return false
-- 	end
-- end
function ShouldDrawAmmoHUD(weapon)
end

--- Determines whether a bar should be drawn.
-- @realm client
-- @tab bar The bar object.
-- @return boolean True if the bar should be drawn, false otherwise.
function ShouldBarDraw(bar)
end

--- Determines whether the crosshair should be drawn for a specific client and weapon.
--- @realm client
--- @client client The player entity.
--- @string weapon The weapon entity.
--- @return boolean True if the crosshair should be drawn, false otherwise.
function ShouldDrawCrosshair(client, weapon)
end

--- Determines whether bars should be hidden.
--- @realm client
--- @return boolean True if bars should be hidden, false otherwise.
function ShouldHideBars()
end

--- Called when the screen resolution changes.
-- @realm client
-- @int width number The new width of the screen.
-- @int height number The new height of the screen.
function ScreenResolutionChanged(width, height)
end

--- Determines whether a player should be shown on the scoreboard.
--- @realm client
--- @client client The player entity to be evaluated.
--- @return bool True if the player should be shown on the scoreboard, false otherwise.
function ShouldShowPlayerOnScoreboard(client)
end

--- Called after the player's inventory is drawn.
-- @realm client
-- @panel panel The panel containing the inventory.
function PostDrawInventory(panel)
end

-- This function determines whether certain information can be displayed in the character info panel in the F1 menu.
-- @realm client
-- @table Information to **NOT** display in the UI. This is a table of the names of some panels to avoid displaying. Valid names include:
-- `name` name of the character
-- `desc` description of the character
-- `faction` faction name of the character
-- `money` current money the character has
-- `class` name of the character's class if they're in one
-- Note that schemas/modules can add additional character info panels.
-- @usage function MODULE:CanDisplayCharacterInfo(suppress)
-- 	suppress.faction = true
-- end
function CanDisplayCharacterInfo(suppress)
end

--- Determines whether a player is allowed to view their inventory.
-- @realm client
-- This hook can be used to implement custom checks to determine if a player is
-- allowed to view their inventory.
-- @return boolean Whether the player is allowed to view their inventory
function CanPlayerViewInventory()
end
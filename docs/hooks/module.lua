--[[--
General Hooks.

These hooks are regular hooks that can be used in your schema with `SCHEMA:HookName(args)`, in your module with
`MODULE:HookName(args)`, or in your addon with `hook.Add("HookName", function(args) end)`.
They can be used for an assorted of reasons, depending on what you are trying to achieve.
]]
-- @hooks General

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

--- Called when a player interacts with a vendor entity.
-- This function adds the player to the vendor's receivers list and notifies the player
-- about accessing the vendor.
-- @param activator The player accessing the vendor
-- @usage function PlayerAccessVendor(activator, entity)
--     -- Add the player to the vendor's receivers list
--     entity.receivers[#entity.receivers + 1] = activator
--
--     -- Notify the player about accessing the vendor
--     if entity.messages[VENDOR_WELCOME] then
--         activator:notify(entity:getNetVar("name") .. ": " .. entity.messages[VENDOR_WELCOME])
--     end
-- end
--- @realm shared
function CharacterVendorTraded(client, entity, uniqueID, isSellingToVendor)
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
function PlayerAccessVendor(client, entity)
end

--- Called when a player sells an item to a vendor.
-- This function handles the event where a player sells an item to a vendor.
-- @param player client The player selling the item
-- @param entity vendor The vendor entity
-- @param string itemType The type of item being sold
-- @param any Unknown
-- @param ix.char character The character of the player selling the item
-- @param number price The price at which the item is sold
-- @usage function MODULE:VendorSellEvent(client, vendor, itemType, _, character, price)
--     -- Implement logic to handle the event where a player sells an item to a vendor
--     -- For example, deducting money from the vendor and adding it to the player's character
--     -- Also, remove the sold item from the player's inventory and update vendor's stock
-- end
function VendorSellEvent(client, vendor, itemType, _, character, price)
end

--- Called when a player successfully buys an item from a vendor.
-- This function is called when a player successfully completes a purchase from a vendor.
-- @param Player client The player who made the purchase
-- @param Entity vendor The vendor entity from which the item was bought
-- @param any itemType The type of item being bought
-- @param boolean isSellingToVendor Indicates whether the player is selling to the vendor (always false in this context)
-- @param ix.char character The character of the player involved in the trade
-- @param number price The price of the item being bought
-- @realm shared
-- @usage function MODULE:VendorBuyEvent(client, vendor, itemType, isSellingToVendor, character, price)
--     -- Implement logic to handle a successful purchase from a vendor
--     -- This could involve deducting money, adding the item to the player's inventory, and logging the transaction
-- end
function VendorBuyEvent(client, vendor, itemType, isSellingToVendor, character, price)
end

--- Determines whether an item can be transferred between inventories.
-- This hook allows custom logic to be implemented to determine if an item can be transferred
-- from one inventory to another. It can be used to impose restrictions on item transfers.
-- @param ix.item item The item being transferred
-- @param ix.inventory currentInv The current inventory from which the item is being transferred
-- @param ix.inventory oldInv The old inventory to which the item belonged
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
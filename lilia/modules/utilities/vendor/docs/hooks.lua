--- Hook Documentation for Vendor Module.
-- @hooksmodule Vendor

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

--- Called when a character trades with a vendor entity.
-- This function can be used to perform additional actions when a character trades
-- with a vendor entity.
-- @realm shared
-- @client client The player character trading with the vendor
-- @entity entity The vendor entity being traded with
-- @string uniqueID The unique identifier of the traded item
-- @bool isSellingToVendor Whether the trade involves selling to the vendor
-- @see VendorSellEvent
-- @see VendorBuyEvent
-- @usage function CharacterVendorTraded(client, entity, uniqueID, isSellingToVendor)
--     -- Perform additional actions when a character trades with the vendor
-- end
function CharacterVendorTraded(client, entity, uniqueID, isSellingToVendor)
end

--- Called when a player interacts with a vendor entity.
-- This function adds the player to the vendor's receivers list and notifies the player
-- about accessing the vendor.
-- @client client The player accessing the vendor
-- @entity entity The vendor
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
--- @treturn bool True if the player can access the vendor.
function PlayerAccessVendor(client, entity)
end


--- Determines whether a player is allowed to access a vendor entity.
-- This hook can be used to implement custom checks to determine if a player is
-- allowed to access a specific vendor entity.
-- @realm server
-- @client client The player attempting to access the vendor
function CanPlayerAccessVendor(client)
end

--- Called when a player sells an item to a vendor.
-- @realm shared
-- This function handles the event where a player sells an item to a vendor.
-- @client client The player selling the item
-- @entity vendor The vendor entity
-- @string itemType The uniqueID of item being sold
-- @bool isSellingToVendor Indicates whether the player is selling to the vendor (always false in this context)
-- @character character The character of the player selling the item
-- @int price The price at which the item is sold
-- @see VendorBuyEvent
function VendorSellEvent(client, vendor, itemType, isSellingToVendor, character, price)
end

--- Called when a player successfully buys an item from a vendor.
-- This function is called when a player successfully completes a purchase from a vendor.
-- @client client The player who made the purchase
-- @entity vendor The vendor entity from which the item was bought
-- @string itemType The uniqueID of item being sold
-- @bool isSellingToVendor Indicates whether the player is selling to the vendor (always false in this context)
-- @character character The character of the player involved in the trade
-- @int price The price of the item being bought
-- @realm shared
-- @see VendorSellEvent
function VendorBuyEvent(client, vendor, itemType, isSellingToVendor, character, price)
end

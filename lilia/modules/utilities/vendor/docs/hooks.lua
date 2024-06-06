--- Hook Documentation for Vendor Module.
-- @hooks Vendor

--- Determines whether a player can access a vendor.
-- @realm server
-- @client client The player attempting to access the vendor.
-- @entity entity The vendor entity.
-- @treturn bool Whether the player is allowed to access the vendor.
function CanPlayerAccessVendor(client, entity)
end

--- Called when a player attempts to trade with a vendor.
-- @realm server
-- @client client The player attempting to trade.
-- @entity entity The vendor entity.
-- @string uniqueID The unique ID of the item being traded.
-- @bool isSellingToVendor Indicates if the player is selling to the vendor.
function VendorTradeAttempt(client, entity, uniqueID, isSellingToVendor)
end

--- Called when a vendor entity is edited.
-- @realm client
-- @entity vendor The vendor entity that was edited.
-- @string key The key that was edited.
function VendorEdited(vendor, key)
end

--- Called when a vendor is opened.
-- @realm client
-- @entity vendor The vendor entity that was opened.
function VendorOpened(vendor)
end

--- Called when a vendor's allowed classes are updated.
-- @realm client
-- @entity vendor The vendor entity whose classes were updated.
-- @string id The ID of the class.
-- @bool allowed Whether the class is allowed or not.
function VendorClassUpdated(vendor, id, allowed)
end

--- Called when a vendor's allowed factions are updated.
-- @realm client
-- @entity vendor The vendor entity whose factions were updated.
-- @string id The ID of the faction.
-- @bool allowed Whether the faction is allowed or not.
function VendorFactionUpdated(vendor, id, allowed)
end

--- Called when a vendor's item maximum stock is updated.
-- @realm client
-- @entity vendor The vendor entity.
-- @string itemType The type of the item.
-- @int value The new maximum stock value.
function VendorItemMaxStockUpdated(vendor, itemType, value)
end

--- Called when a vendor's item stock is updated.
-- @realm client
-- @entity vendor The vendor entity.
-- @string itemType The type of the item.
-- @int value The new stock value.
function VendorItemStockUpdated(vendor, itemType, value)
end

--- Called when a vendor's item mode is updated.
-- @realm client
-- @entity vendor The vendor entity.
-- @string itemType The type of the item.
-- @int value The new mode value.
function VendorItemModeUpdated(vendor, itemType, value)
end

--- Called when a vendor's item price is updated.
-- @realm client
-- @entity vendor The vendor entity.
-- @string itemType The type of the item.
-- @int value The new price value.
function VendorItemPriceUpdated(vendor, itemType, value)
end

--- Called when a vendor's money is updated.
-- @realm client
-- @entity vendor The vendor entity.
-- @int money The new money value.
-- @int oldMoney The previous money value.
function VendorMoneyUpdated(vendor, money, oldMoney)
end

--- Called when the vendor menu is opened.
-- @realm client
-- @entity self The vendor entity.
function OnOpenVendorMenu(self)
end

--- Gets the price override for an item.
-- @realm shared
-- @entity self The vendor entity.
-- @string uniqueID The unique ID of the item.
-- @int price The original price of the item.
-- @bool isSellingToVendor Indicates if the player is selling to the vendor.
-- @treturn int The overridden price.
function getPriceOverride(self, uniqueID, price, isSellingToVendor)
end

--- Called when a character trades with a vendor.
-- @realm server
-- @client client The player character trading with the vendor.
-- @entity vendor The vendor entity being traded with.
-- @entity item The item being traded.
-- @bool isSellingToVendor Indicates if the trade involves selling to the vendor.
-- @entity character The character entity of the player.
function OnCharTradeVendor(client, vendor, item, isSellingToVendor, character)
end

--- Called when a player accesses a vendor.
-- @realm server
-- @client activator The player accessing the vendor.
-- @entity self The vendor entity.
function PlayerAccessVendor(activator, self)
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

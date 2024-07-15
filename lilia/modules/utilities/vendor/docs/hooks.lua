--- Hook Documentation for Vendor Module.
-- @hooks Vendor

--- Called when a vendor's allowed classes are updated.
-- @realm client
-- @internal
-- @entity vendor The vendor entity whose classes were updated.
-- @string id The ID of the class.
-- @bool allowed Whether the class is allowed or not.
function VendorClassUpdated(vendor, id, allowed)
end

--- Called when a vendor's allowed factions are updated.
-- @realm client
-- @internal
-- @entity vendor The vendor entity whose factions were updated.
-- @string id The ID of the faction.
-- @bool allowed Whether the faction is allowed or not.
function VendorFactionUpdated(vendor, id, allowed)
end

--- Called when a vendor's item maximum stock is updated.
-- @realm client
-- @internal
-- @entity vendor The vendor entity.
-- @string itemType The type of the item.
-- @int value The new maximum stock value.
function VendorItemMaxStockUpdated(vendor, itemType, value)
end

--- Called when a vendor's item stock is updated.
-- @realm client
-- @internal
-- @entity vendor The vendor entity.
-- @string itemType The type of the item.
-- @int value The new stock value.
function VendorItemStockUpdated(vendor, itemType, value)
end

--- Called when a vendor's item mode is updated.
-- @realm client
-- @internal
-- @entity vendor The vendor entity.
-- @string itemType The type of the item.
-- @int value The new mode value.
function VendorItemModeUpdated(vendor, itemType, value)
end

--- Called when a vendor's item price is updated.
-- @realm client
-- @internal
-- @entity vendor The vendor entity.
-- @string itemType The type of the item.
-- @int value The new price value.
function VendorItemPriceUpdated(vendor, itemType, value)
end

--- Called when a vendor's money is updated.
-- @realm client
-- @internal
-- @entity vendor The vendor entity.
-- @int money The new money value.
-- @int oldMoney The previous money value.
function VendorMoneyUpdated(vendor, money, oldMoney)
end
--- Called after a delay when a vendor's data is edited.
-- @realm client
-- @internal
-- @entity vendor The vendor entity whose data is being edited.
-- @string key The key related to the specific data being edited.
function VendorEdited(vendor, key)
end

--- Called when a player attempts to trade with a vendor.
-- @realm server
-- @internal
-- @client client The player attempting to trade.
-- @entity entity The vendor entity.
-- @string uniqueID The unique ID of the item being traded.
-- @bool isSellingToVendor Indicates if the player is selling to the vendor.
function VendorTradeEvent(client, entity, uniqueID, isSellingToVendor)
end

--- Called when vendor synchronization data is received.
-- @realm client
-- @entity vendor The vendor entity whose data has been synchronized.
function VendorSynchronized(vendor)
end

--- Determines whether a player can access a vendor.
-- @realm server
-- @client client The player attempting to access the vendor.
-- @entity entity The vendor entity.
-- @treturn bool Whether the player is allowed to access the vendor.
function CanPlayerAccessVendor(client, entity)
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

--- Called when a player exits from interacting with a vendor.
-- @realm client
function VendorExited()
end

--- Called when a vendor is opened.
-- @realm client
-- @entity vendor The vendor entity that was opened.
function VendorOpened(vendor)
end

--- Called when the vendor menu is opened.
-- @realm client
-- @entity self The vendor entity.
function OnOpenVendorMenu(self)
end
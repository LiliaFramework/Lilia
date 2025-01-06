--- Hook Documentation for Inventory Module.
-- @hooks Inventory
--- Determines whether a player is allowed to view their inventory.
-- @realm client
-- This hook can be used to implement custom checks to determine if a player is
-- allowed to view their inventory.
-- @treturn bool Whether the player is allowed to view their inventory
function CanPlayerViewInventory()
end

--- Called after the player's inventory is drawn.
-- @realm client
-- @panel panel The panel containing the inventory
function PostDrawInventory(panel)
end

--- Called when a player clicks on an item icon.
-- @realm client
-- @panel self The panel that received the click
-- @panel itemIcon The item icon that was clicked
-- @int keyCode The key code associated with the click
function InterceptClickItemIcon(self, itemIcon, keyCode)
end

--- Called when an item transfer is requested.
-- @realm client
-- @panel self The panel from which the transfer is requested
-- @int itemID The ID of the item being transferred
-- @int inventoryID The ID of the inventory from which the item is being transferred
-- @int x The x-coordinate of the transfer request
-- @int y The y-coordinate of the transfer request
function OnRequestItemTransfer(self, itemID, inventoryID, x, y)
end

--- Called when an item is being painted over.
-- @realm client
-- @panel self The panel being painted
-- @tab itemTable The table representing the item being painted
-- @int w The width of the panel
-- @int h The height of the panel
function ItemPaintOver(self, itemTable, w, h)
end

--- Called when an item interaction menu is being created.
-- @realm client
-- @panel self The panel on which the menu is being created
-- @panel menu The menu being created
-- @tab itemTable The table representing the item for which the menu is being created
function OnCreateItemInteractionMenu(self, menu, itemTable)
end

--- Determines whether a specific action can be run on an item.
-- @realm client
-- @tab itemTable The table representing the item
-- @string action The action of the action being checked
-- @treturn bool Whether the action can be run on the item
function CanRunItemAction(itemTable, action)
end

--- Determines whether an item can be transferred between inventories.
-- @realm shared
-- This hook allows custom logic to be implemented to determine if an em can be transferred
-- from one inventory to another. It can be used to impose restrictionon item transfers.
-- @item item The item being transferred
-- @inventory currentInv The current inventory from which the item is beintransferred
-- @inventory oldInv The old inventory to which the item belonged
-- @treturn bool|string Whether the item can be transferred, or fal and a reason if not
function CanItemBeTransfered(item, currentInv, oldInv)
end

--- Called when an item is dragged out of an inventory.
-- @realm server
-- @client client The client dragging the item
-- @item item The item being dragged
function ItemDraggedOutOfInventory(client, item)
end

--- Called when an item is transferred between inventories.
-- @realm server
-- @tab context The context of the item transfer
function ItemTransfered(context)
end

--- Called when a player drops a stackable item.
-- @realm shared
-- @param itemTypeOrItem The type or instance of the item being lost
function OnPlayerLostStackItem(itemTypeOrItem)
end

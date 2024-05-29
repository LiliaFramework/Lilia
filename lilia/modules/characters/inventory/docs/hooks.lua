--- Hook Documentation for Inventory Module.
-- @hooksmodule Inventory

--- Determines whether a player is allowed to view their inventory.
-- @realm client
-- This hook can be used to implement custom checks to determine if a player is
-- allowed to view their inventory.
-- @treturn boolean Whether the player is allowed to view their inventory
function CanPlayerViewInventory()
end

--- Called after the player's inventory is drawn.
-- @realm client
-- @panel panel The panel containing the inventory
function PostDrawInventory(panel)
end

--[[
   hook.Run("InterceptClickItemIcon", self, itemIcon, keyCode) 
   hook.Run("OnRequestItemTransfer", self, item:getID(), self.inventory:getID(), x, y)
   hook.Run("ItemPaintOver", self, itemTable, w, h)
   hook.Run("OnCreateItemInteractionMenu", self, menu, itemTable)
   hook.Run("CanRunItemAction", itemTable, k)
   hook.Run("CanItemBeTransfered", item, bagInventory, bagInventory, context.client)
   hook.Run("ItemDraggedOutOfInventory", client, item) 
   hook.Run("ItemTransfered", context)
   hook.Run("OnPlayerLostStackItem", itemTypeOrItem) 
]]
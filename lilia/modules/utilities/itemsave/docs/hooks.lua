--- Hook Documentation for Item Save Module.
-- @hooks ItemSave
--- Determines if saved items should be deleted on server restart.
-- This hook is called to check whether saved items should be deleted when the server restarts.
-- @realm server
-- @treturn boolean True if saved items should be deleted, false otherwise.
function ShouldDeleteSavedItems()
end

--- Called when saved items are loaded from the database.
-- This hook is called after the saved items have been successfully loaded from the database.
-- It can be used to perform additional actions with the loaded items.
-- @realm server
-- @param loadedItems A table containing the loaded item entities.
function OnSavedItemLoaded(loadedItems)
end

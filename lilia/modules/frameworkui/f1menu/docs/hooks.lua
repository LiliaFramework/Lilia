--- Hook Documentation for F1 Menu Module.
-- @hooksmodule F1Menu

--- Determines whether a specific character information should be displayed.
-- @realm client
-- @string name The name of the character information being checked.
-- @treturn boolean Whether the character information should be displayed.
function CanDisplayCharInfo(var)
end

--- Called when the player wants to view their inventory.
-- @realm client
-- @treturn boolean Whether the player is allowed to view their inventory.
function CanPlayerViewInventory()
end

--- Called when the help menu is being built.
-- @realm client
-- @tab tabs Table containing the help menu tabs.
function BuildHelpMenu(tabs)
end

--- Called when the menu buttons are being created.
-- @realm client
-- @tab tabs Table containing the menu buttons.
function CreateMenuButtons(tabs)
end

--- Called after the player's inventory is drawn.
-- @realm client
-- @panel panel The panel containing the inventory.
function PostDrawInventory(panel)
end
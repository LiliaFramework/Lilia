--- Hook Documentation for F1 Menu Module.
-- @ahooks F1Menu

-- This function determines whether certain information can be displayed in the character info panel inthe F1 menu.
-- @realm client
-- @table Information to **NOT** display in the UI. This is a table of the names of some panels to avoi displaying. Valid names include:
-- `name` name of the character
-- `desc` description of the character
-- `faction` faction name of the character
-- `money` current money the character has
-- `class` name of the character's class if they're in one
-- Note that schemas/modules can add additional character info panels.
-- @usage function MODULE:CanDisplayCharInfo(suppress)
-- 	suppress.faction = true
-- end
function CanDisplayCharInfo(suppress)
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

--- Creates menu buttons for the F1 menu.
--- @tab tabs A table to store the created buttons.
--- @realm client
function CreateMenuButtons(tabs)
end

--- Called after the player's inventory is drawn.
-- @realm client
-- @panel panel The panel containing the inventory.
function PostDrawInventory(panel)
end
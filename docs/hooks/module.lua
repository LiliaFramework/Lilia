--[[--
Global hooks for general use.

Module hooks are regular hooks that can be used in your schema with `SCHEMA:HookName(args)`, in your module with
`MODULE:HookName(args)`, or in your addon with `hook.Add("HookName", function(args) end)`.
]]
-- @hooks Module

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
function CanPlayerCreateCharacter(client, payload)
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

--- Called after the player's inventory is drawn.
-- @realm client
-- @param panel Panel - The panel containing the inventory.
function PostDrawInventory(panel)
end

--- Called after data has been loaded.
-- @realm server
function PostLoadData()
end

--- Called after a player's loadout is applied.
-- @realm server
-- @client client The player entity.
function PostPlayerLoadout(client)
end

--- Called after a player sends a chat message.
-- @realm server
-- @client client The player entity who sent the message.
-- @string message The message sent by the player.
-- @string chatType The type of chat message (e.g., "ic" for in-character, "ooc" for out-of-character).
-- @bool anonymous Whether the message was sent anonymously (true) or not (false).
function PostPlayerSay(client, message, chatType, anonymous)
end

--- Called after a character is deleted.
-- @realm server
-- @client client The player entity.
-- @char The character being deleted.
function PostCharDelete(client, character)
end

--- Called after a character is deleted.
-- @realm server
-- @param client The player entity.
-- @param character The character being deleted.
function CharDeleted(client, character)
end

--- Called before a player's character is loaded.
-- @realm server
-- @param client The player entity.
-- @param character The character being loaded.
-- @param currentChar The current character of the player.
function PrePlayerLoadedChar(client, character, currentChar)
end

--- Called when a player's character is loaded.
-- @realm server
-- @param client The player entity.
-- @param character The character being loaded.
-- @param currentChar The current character of the player.
function PlayerLoadedChar(client, character, currentChar)
end

--- Called after a player's character is loaded.
-- @realm server
-- @param client The player entity.
-- @param character The character being loaded.
-- @param currentChar The current character of the player.
function PostPlayerLoadedChar(client, character, currentChar)
end

--- Saves the server data.
-- @realm server
function SaveData()
end

--- Called when the screen resolution changes.
-- @realm client
-- @param width number The new width of the screen.
-- @param height number The new height of the screen.
function ScreenResolutionChanged(width, height)
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

--- Determines whether a client should drown.
-- @realm server
-- @client client The player entity.
-- @return boolean True if the client should drown, false otherwise.
function ShouldClientDrown(client)
end

--- Determines whether a player should be shown on the scoreboard.
--- @realm client
--- @client client The player entity to be evaluated.
--- @return bool True if the player should be shown on the scoreboard, false otherwise.
function ShouldShowPlayerOnScoreboard(client)
end

--- Displays the context menu for interacting with an item entity.
--- @realm client
--- @param entity Entity The item entity for which the context menu is displayed.
function ItemShowEntityMenu(entity)
end

--- Called when the third person mode is toggled.
--- @realm client
--- @bool state Indicates whether the third person mode is enabled (`true`) or disabled (`false`).
function thirdPersonToggled(state)
end
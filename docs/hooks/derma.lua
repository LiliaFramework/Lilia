--[[--
Player Derma.

These hooks are meant for derma drawing events. They can be used in your schema with `SCHEMA:HookName(args)`, in your module with
`MODULE:HookName(args)`, or in your addon with `hook.Add("HookName", function(args) end)`.
They can be used for an assorted of reasons, depending on what you are trying to achieve.
]]
-- @hooks Derma

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

--- Called when the screen resolution changes.
-- @realm client
-- @int width number The new width of the screen.
-- @int height number The new height of the screen.
function ScreenResolutionChanged(width, height)
end

--- Determines whether a player should be shown on the scoreboard.
--- @realm client
--- @client client The player entity to be evaluated.
--- @return bool True if the player should be shown on the scoreboard, false otherwise.
function ShouldShowPlayerOnScoreboard(client)
end

--- Called after the player's inventory is drawn.
-- @realm client
-- @panel panel The panel containing the inventory.
function PostDrawInventory(panel)
end

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

--- Determines whether a player is allowed to view their inventory.
-- @realm client
-- This hook can be used to implement custom checks to determine if a player is
-- allowed to view their inventory.
-- @return boolean Whether the player is allowed to view their inventory
-- @usage function CanPlayerViewInventory()
--     -- Implement custom logic to determine if the player can view their inventory
--     if not SomeCustomCondition() then
--         return false
--     end
--
--     -- If allowed, return true
--     return true
-- end
function CanPlayerViewInventory()
end
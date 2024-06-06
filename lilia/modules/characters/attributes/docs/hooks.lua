--- Hook Documentation for Attributes Module.
-- @hooks Attributes

--- Called when a character's attribute is updated.
--- @client client The client associated with the character.
--- @character character The character whose attribute is updated.
--- @string key The key of the attribute being updated.
--- @int value The new value of the attribute.
--- @realm shared
function OnCharAttribBoosted(client, character, key, value)
end

--- Called when a player gains stamina.
--- @client client The player who gained stamina.
--- @realm server
function PlayerStaminaGained(client)
end

--- Called when a player loses stamina.
--- @client client The player who lost stamina.
--- @realm server
function PlayerStaminaLost(client)
end

--- Determines if a player can throw a punch.
--- @client client The player attempting to throw a punch.
--- @treturn True if the player can throw a punch, false otherwise.
--- @realm shared
function CanPlayerThrowPunch(client)
end

--- Adjusts the stamina offset when a player is running.
-- This hook can be used to modify the stamina consumption rate while the player is running.
-- @realm shared
-- @client client The player who is running.
-- @number offset The current stamina offset.
-- @treturn number The modified stamina offset.
function AdjustStaminaOffsetRunning(client, offset)
end

--- Adjusts the stamina regeneration rate.
-- This hook can be used to modify the rate at which a player regenerates stamina.
-- @realm shared
-- @client client The player whose stamina is regenerating.
-- @number offset The current stamina regeneration offset.
-- @treturn number The modified stamina regeneration offset.
function AdjustStaminaRegeneration(client, offset)
end

--- Adjusts the stamina offset otherwise.
-- This hook can be used to apply additional modifications to the stamina offset, whether the player is running or regenerating stamina.
-- @realm shared
-- @client client The player whose stamina is being adjusted.
-- @number offset The current stamina offset.
-- @treturn number The modified stamina offset.
function AdjustStaminaOffset(client, offset)
end

--- Called to calculate the change in a player's stamina.
-- This function determines the change in stamina based on the player's actions, such as running or regenerating stamina.
-- @realm shared
-- @client client The player whose stamina is being calculated.
-- @treturn number The change in stamina, which can be positive (regeneration) or negative (consumption).
function CalcStaminaChange(client)
end

--- Determines if a player can view their attributes.
-- This hook is used to check if a player is allowed to view their attributes.
-- @realm client
-- @client client The player attempting to view attributes.
-- @treturn boolean True if the player can view attributes, false otherwise.
function CanPlayerViewAttributes(client)
end

--- Retrieves the starting attribute points for a player.
-- This hook is used to determine the initial number of attribute points a player starts with.
-- @realm client
-- @client client The player whose starting attribute points are being determined.
-- @tab context The context in which the starting attribute points are being determined.
-- @treturn number The number of starting attribute points.
function GetStartAttribPoints(client, context)
end

--- Determines if a player can pick up an item with his hands.
-- This hook is used to check if a player is allowed to pick up a specific item.
-- @realm shared
-- @client client The player attempting to pick up the item.
-- @item item The item being picked up.
-- @treturn boolean True if the player can pick up the item, false otherwise.
function PlayerCanPickupItem(client, item)
end

--- Determines the maximum stamina for a character.
-- This hook is used to get the maximum stamina value for a character.
-- @realm shared
-- @character character The character whose maximum stamina is being determined.
-- @treturn number The maximum stamina value for the character.
function CharMaxStamina(character)
end
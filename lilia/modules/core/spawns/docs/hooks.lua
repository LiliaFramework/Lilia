--- Hook Documentation for Spawns Module.
-- @hooks Spawns
--- Called after PlayerLoadout is executed.
-- This hook is called after a player's faction loadout has been applied.
-- @client client The player entity for whom the faction loadout was applied.
-- @realm server
function FactionOnLoadout(client)
end

--- Called after FactionOnLoadout is executed.
-- This hook is called after a player's class loadout has been applied.
-- @client client The player entity for whom the class loadout was applied.
-- @realm server
function ClassOnLoadout(client)
end

--- Called after PostPlayerLoadout is executed.
-- This hook is called after additional actions related to a player's faction loadout have been performed.
-- @client client The player entity for whom the faction loadout was applied.
-- @realm server
function FactionPostLoadout(client)
end

--- Called after FactionPostLoadout is executed.
-- This hook is called after additional actions related to a player's class loadout have been performed.
-- @client client The player entity for whom the class loadout was applied.
-- @realm server
function ClassPostLoadout(client)
end

--- Called after all of the player's loadout hooks are executed (PlayerLoadout, FactionOnLoadout, ClassOnLoadout).
-- This hook is called after a player's loadout has been fully applied, including faction and class loadouts.
-- @client client The player entity for whom the loadout was applied.
-- @realm server
function PostPlayerLoadout(client)
end

--- Whether or not a player is allowed to join a class.
-- @realm shared
-- @client client Player attempting to join
-- @int class ID of the class
-- @tab info The class table
-- @treturn bool Whether or not to allow the player to join the class
-- @usage function MODULE:CanPlayerJoinClass(client, class, info)
-- 	return client:isStaff() -- Restrict joining classes to staff only.
-- end
function CanPlayerJoinClass(client, class, info)
end

--- Determines if a character has the given flag(s).
--- @character character The character to check for flags.
--- @string flags The flag(s) to check access for.
--- @treturn bool Whether or not this character has access to the given flag(s).
--- @realm shared
function CharHasFlags(character, flags)
end

--- Determines whether a player is allowed to use a specific character.
-- This hook can be used to implement custom checks to determine if a player is
-- allowed to use a particular character.
-- @realm shared
-- @client client The player attempting to use the character
-- @character character The character being considered for use
-- @treturn bool Whether the player is allowed to use the character
-- @treturn string|nil If disallowed, a reason for the disallowance; otherwise, nil
function CanPlayerUseChar(client, character)
end

--- Whether or not a player is allowed to create a new character.
-- @realm server
-- @client client Player attempting to create a new character
-- @treturn bool Whether or not the player is allowed to create the chacter. This function defaults to `true`, so you
-- should only ever return `false` if you're disallowing creation. Othwise, don't return anything as you'll prevent any other
-- calls to this hook from running.
-- @treturn string Language phrase to use for the error message
-- @treturn ... Arguments to use for the language phrase
-- @usage function MODULE:CanPlayerCreateChar(client)
-- 	if (!client:isStaff()) then
-- 		return false, "notNow" -- only allow staff to create a character
-- 	end
-- end
-- non-admins will see the message "You are not allowed to do this ght now!"
function CanPlayerCreateChar(client)
end

--- Called after a character is deleted.
-- @realm server
-- @client client The player entity.
-- @character character The character being deleted.
function PostCharDelete(client, character)
end

--- Retrieves the maximum number of characters a player can have.
--- @client client The player for whom to retrieve the maximum number of characters.
--- @treturn int The maximum number of characters the player can have.
--- @realm shared
function GetMaxPlayerChar(client)
end

--- Called after a character is deleted.
-- @realm server
-- @client client The player entity.
-- @character character The character being deleted.
function CharDeleted(client, character)
end

--- Called before a player's character is loaded.
-- @realm server
-- @client client The player entity.
-- @character character The character being loaded.
-- @character currentChar The current character of the player.
function PrePlayerLoadedChar(client, character, currentChar)
end

--- Called when a player's character is loaded.
-- @realm server
-- @client client The player entity.
-- @character character The character being loaded.
-- @character currentChar The current character of the player.
function PlayerLoadedChar(client, character, currentChar)
end

--- Called after a player's character is loaded.
-- @realm server
-- @client client The player entity.
-- @character character The character being loaded.
-- @character currentChar The current character of the player.
function PostPlayerLoadedChar(client, character, currentChar)
end

--- Called when a character is loaded.
-- This function is called after a character has been successfully loaded.
-- @character character The character that has been loaded
-- @realm shared
function CharLoaded(character)
end

--- Called after a character has been saved.
-- This function is called after a character has been successfully saved.
-- @character character The character that has been saved
-- @realm server
function CharPostSave(character)
end

--- Called before a character is saved.
-- This function is called before a character is about to be saved.
-- @character character The character about to be saved
-- @realm shared
function CharPreSave(character)
end

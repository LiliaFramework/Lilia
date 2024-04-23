--[[--
Player Hooks.

These hooks are meant for player events. They can be used in your schema with `SCHEMA:HookName(args)`, in your module with
`MODULE:HookName(args)`, or in your addon with `hook.Add("HookName", function(args) end)`.
They can be used for an assorted of reasons, depending on what you are trying to achieve.
]]
-- @hooks Player

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
function CanPlayerCreateCharacter(client)
end

--- Called after a character is deleted.
-- @realm server
-- @client client The player entity.
-- @character character The character being deleted.
function PostCharDelete(client, character)
end

--- Called after a player's loadout is applied.
-- @realm server
-- @client client The player entity.
function PostPlayerLoadout(client)
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

--- Determines whether a client should drown.
-- @realm server
-- @client client The player entity.
-- @return boolean True if the client should drown, false otherwise.
function ShouldClientDrown(client)
end

--- Called when a player tries to use abilities on the door, such as locking.
-- @realm shared
-- @client client The client trying something on the door.
-- @entity door The door entity itself.
-- @number access The access level used when called.
-- @treturn bool Whether or not to allow the client access.
-- @usage function MODULE:CanPlayerAccessDoor(client, door, access)
--     return true -- Always allow access.
-- end
function CanPlayerAccessDoor(client, door, access)
end

--- Whether or not a plyer is allowed to join a class.
-- @realm shared
-- @client client Player attempting to join
-- @number class ID of the class
-- @tab info The class table
-- @treturn bool Whether or not to allow the player to join the class
-- @usage function MODULE:CanPlayerJoinClass(client, class, info)
-- 	return client:IsAdmin() -- Restrict joining classes to admins only.
-- end
function CanPlayerJoinClass(client, class, info)
end

--- Whether or not a player can earn money at regular intervals. This hook runs only if the player's character faction has
-- a salary set i.e `FACTION.pay` is set to something other than `0` for their faction.
-- @realm server
-- @client client Player to give money to
-- @tab faction Faction of the player's character
-- @tab class Class of the player's character
-- @treturn bool Whether or not to allow the player to earn salary
-- @usage function MODULE:CanPlayerEarnSalary(client, faction)
-- 	return client:IsAdmin() -- Restricts earning salary to admins only.
-- end
function CanPlayerEarnSalary(client, faction, class)
end

--- Whether or not the player is allowed to punch with the hands SWEP.
-- @realm shared
-- @client client Player attempting throw a punch
-- @treturn bool Whether or not to allow the player to punch
-- @usage function MODULE:CanPlayerThrowPunch(client)
-- 	return client:GetCharacter():GetAttribute("str", 0) > 0 -- Only allow players with strength to punch.
-- end
function CanPlayerThrowPunch(client)
end

--- Determines whether a player is allowed to use a specific character.
-- This hook can be used to implement custom checks to determine if a player is
-- allowed to use a particular character.
-- @realm shared
-- @client client The player attempting to use the character
-- @param character The character being considered for use
-- @treturn boolean Whether the player is allowed to use the character
-- @treturn string|nil If disallowed, a reason for the disallowance; otherwise, nil
-- @usage function CanPlayerUseChar(client, character)
--     -- Implement custom logic to determine if the player can use the character
--     if not SomeCustomCondition(client, character) then
--         return false, "You are not allowed to use this character."
--     end
--
--     -- If allowed, return true and nil
--     return true, nil
-- end
function CanPlayerUseChar(client, character)
end

--- Determines whether a player is allowed to use a door entity.
-- This hook can be used to implement custom checks to determine if a player is
-- allowed to use a specific door entity.
-- @realm server
-- @client client The player attempting to use the door
-- @param entity The door entity being considered for use
-- @treturn boolean Whether the player is allowed to use the door
-- @usage function CanPlayerUseDoor(client, entity)
--     -- Implement custom logic to determine if the player can use the door
--     if not SomeCustomCondition(client, entity) then
--         return false
--     end
--
--     -- If allowed, return true
--     return true
-- end
function CanPlayerUseDoor(client, entity)
end

--- Determines whether a player is allowed to access a vendor entity.
-- This hook can be used to implement custom checks to determine if a player is
-- allowed to access a specific vendor entity.
-- @realm server
-- @param activator The player attempting to access the vendor
-- @treturn boolean Whether the player is allowed to access the vendor
-- @usage function CanPlayerAccessVendor(activator)
--     -- Implement custom logic to determine if the player can access the vendor
--     if not SomeCustomCondition(activator) then
--         return false
--     end
--
--     -- If allowed, return true
--     return true
-- end
function CanPlayerAccessVendor(activator)
end

--- Called when a character is loaded.
-- This function is called after a character has been successfully loaded.
-- @param character The character that has been loaded
-- @realm shared
-- @usage function CharacterLoaded(character)
--     -- Implement logic to handle character loading
--     -- This could include initializing character data or notifying players
-- end
function CharacterLoaded(character)
    -- Implementation details omitted for brevity
end

--- Called after a character has been saved.
-- This function is called after a character has been successfully saved.
-- @param character The character that has been saved
-- @realm server
-- @usage function CharacterPostSave(character)
--     -- Implement logic to handle post-save operations
--     -- This could include updating associated data or performing cleanup tasks
-- end
function CharacterPostSave(character)
    -- Implementation details omitted for brevity
end

--- Called before a character is saved.
-- This function is called before a character is about to be saved.
-- @param character The character about to be saved
-- @realm shared
-- @usage function CharacterPreSave(character)
--     -- Implement logic to handle pre-save operations
--     -- This could include data validation or preparation tasks
-- end
function CharacterPreSave(character)
    -- Implementation details omitted for brevity
end
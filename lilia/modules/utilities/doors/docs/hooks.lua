--- Hook Documentation for Doors Module.
-- @hooks Doors

--- Called when a player tries to use abilities on the door, such as locking.
-- @realm shared
-- @client client The client trying something on the door.
-- @entity door The door entity itself.
-- @int access The access level used when called.
-- @treturn bool Whether or not to allow the client access.
-- @usage function MODULE:CanPlayerAccessDoor(client, door, access)
--     return true -- Always allow access.
-- end
function CanPlayerAccessDoor(client, door, access)
end

--- Called when a player purchases a door.
--- @client client The player who purchased the door.
--- @entity entity The door entity that was purchased.
--- @bool buying True if the player is buying the door, false if selling.
--- @func CallOnDoorChild A function to call on door children.
--- @realm server
function OnPlayerPurchaseDoor(client, entity, buying, CallOnDoorChild)
end

--- Determines whether a player is allowed to use a door entity.
-- This hook can be used to implement custom checks to determine if a player is
-- allowed to use a specific door entity.
-- @realm server
-- @client client The player attempting to use the door
-- @entity entity The door entity being considered for use
-- @treturn bool Whether the player is allowed to use the door
function CanPlayerUseDoor(client, entity)
end

--- Called when a player attempts to use a door entity.
-- This hook can be used to perform additional actions or checks when a player
-- interacts with a door entity.
-- @realm server
-- @client client The player attempting to use the door.
-- @entity entity The door entity being considered for use.
-- @treturn bool|nil Return false to disallow the use, return true to allow, or return nil to defer to other hooks.
function PlayerUseDoor(client, entity)
end

--- Called when a player attempts to lock a door.
-- This hook is used to handle the locking action on a door entity.
-- @realm server
-- @client owner The player attempting to lock the door.
-- @entity entity The door entity being locked.
-- @float time The time taken to perform the lock action.
function KeyLock(owner, entity, time)
end

--- Called when a player attempts to unlock a door.
-- This hook is used to handle the unlocking action on a door entity.
-- @realm server
-- @client owner The player attempting to unlock the door.
-- @entity entity The door entity being unlocked.
-- @float time The time taken to perform the unlock action.
function KeyUnlock(owner, entity, time)
end

--- Toggles the lock state of a door.
-- This hook is used to change the lock state of a door entity.
-- @realm server
-- @client client The player toggling the lock state.
-- @entity door The door entity being locked or unlocked.
-- @bool state The new lock state, true for locked and false for unlocked.
function ToggleLock(client, door, state)
end

--- Calls a function on all child entities of a door.
-- This hook is used to perform actions on all child entities associated with a door.
-- @realm server
-- @entity entity The parent door entity.
-- @func callback The function to call on each child entity.
function callOnDoorChildren(entity, callback)
end

--- Copies the parent door's properties to a child door.
-- This hook is used to synchronize properties from a parent door to a child door.
-- @realm server
-- @entity child The child door entity.
function copyParentDoor(child)
end

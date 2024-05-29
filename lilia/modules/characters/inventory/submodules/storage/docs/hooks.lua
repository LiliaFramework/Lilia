--- Hook Documentation for Inventory Module.
-- @hooksmodule Storage

--- Whether or not a player is allowed to spawn a container entity.
-- @client client The player attempting to spawn a container.
-- @entity entity The container entity being spawned.
-- @tab data Additional data related to the container being spawned.
-- @treturn bool Whether or not to allow the player to spawn the container.
-- @realm server
-- @usage function MODULE:CanPlayerSpawnStorage(client, entity, data)
--     return client:IsAdmin() -- Restrict spawning containers to admins.
-- end
function CanPlayerSpawnStorage(client, entity, data)
end
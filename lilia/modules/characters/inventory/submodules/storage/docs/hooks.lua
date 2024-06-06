--- Hook Documentation for Inventory Module.
-- @ahooks Storage

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

--- Determines whether an entity is suitable for use as storage.
-- This hook allows customization of conditions for considering an entity as suitable storage.
-- @realm shared
-- @entity entity The entity being checked.
-- @treturn boolean Whether the entity is suitable for use as storage.
function isSuitableForTrunk(entity)
end

--- Called when a storage panel is created.
-- This hook is triggered when a panel for displaying storage inventory is created.
-- @realm client
-- @panel localInvPanel The panel displaying the local inventory.
-- @panel storageInvPanel The panel displaying the storage inventory.
-- @entity storage The storage entity.
function OnCreateStoragePanel(localInvPanel, storageInvPanel, storage)
end

--- Determines whether a player is allowed to spawn a container entity.
-- This hook allows customization of permissions for players to spawn containers.
-- @realm server
-- @client client The player attempting to spawn a container.
-- @entity entity The container entity being spawned.
-- @tab data Additional data related to the container being spawned.
-- @treturn bool Whether the player is allowed to spawn the container.
function CanPlayerSpawnStorage(client, entity, data)
end

--- Determines whether data associated with a storage entity should be saved.
-- This hook allows customization of conditions for saving data associated with a storage entity.
-- @realm server
-- @entity entity The storage entity.
-- @entity inventory The inventory associated with the storage entity.
-- @treturn boolean Whether the data should be saved.
function CanSaveData(entity, inventory)
end

--- Called when a storage entity is restored.
-- This hook is triggered when a storage entity is restored.
-- @realm server
-- @entity storage The storage entity.
-- @entity inventory The inventory associated with the storage entity.
function StorageRestored(storage, inventory)
end

--- Called when a storage is opened.
-- This hook is triggered when a storage is opened, either a car trunk or another storage entity.
-- @realm shared
-- @entity entity The storage entity being opened.
-- @bool isCar Whether the storage entity is a car trunk.
function StorageOpen(entity, isCar)
end

--- Called when a prompt to unlock storage is displayed.
-- This hook is triggered when a prompt to unlock storage is displayed, typically for locked containers.
-- @realm client
-- @entity entity The storage entity.
function StorageUnlockPrompt(entity)
end

--- Determines whether a player is allowed to transfer an item to a storage entity.
-- This hook allows customization of permissions for transferring items to a storage entity.
-- @realm server
-- @client client The player attempting to transfer the item.
-- @entity storage The storage entity.
-- @param item The item being transferred.
-- @treturn boolean Whether the player is allowed to transfer the item.
function StorageCanTransferItem(client, storage, item)
end

--- Called when a storage entity is removed.
-- This hook is triggered when a storage entity is removed from the world.
-- @realm server
-- @entity entity The storage entity being removed.
-- @entity inventory The inventory associated with the storage entity.
function StorageEntityRemoved(entity, inventory)
end

--- Called when the inventory of a storage entity is set.
-- This hook is triggered when the inventory of a storage entity is set, either initially or after modifications.
-- @realm shared
-- @entity entity The storage entity.
-- @entity inventory The inventory associated with the storage entity.
-- @bool isInitial Whether the inventory setting is occurring during initialization.
function StorageInventorySet(entity, inventory, isInitial)
end
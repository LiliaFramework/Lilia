--[[
    Hooks:
        CanPlayerSpawnStorage(client, entity, info)

    Purpose:
        Determines whether a player may convert an entity into storage.

    Category:
        Inventory

    Parameters:
        client (Player)
            The player trying to create the storage entity.

        entity (Entity)
            The target entity being turned into storage.

        info (table)
            The requested storage configuration data.

    Example Usage:
        ```lua
        hook.Add("CanPlayerSpawnStorage", "liaExampleCanPlayerSpawnStorage", function(client, entity, info)
            if IsValid(client) and client:IsAdmin() then
                return true
            end
        end)
        ```

    Returns:
        boolean|nil
            Return false to block storage creation.

    Realm:
        Server
]]
--[[
    Hooks:
        CanSaveData(ent, inventory)

    Purpose:
        Determines whether a storage entity's inventory data should be persisted.

    Category:
        Inventory

    Parameters:
        ent (Entity)
            The storage entity being saved.

        inventory (table)
            The inventory attached to the storage entity.

    Example Usage:
        ```lua
        hook.Add("CanSaveData", "liaExampleCanSaveData", function(ent, inventory)
            return true
        end)
        ```

    Returns:
        boolean|nil
            Return false to skip saving this storage inventory.

    Realm:
        Server
]]
--[[
    Hooks:
        InitializeStorage(entity)

    Purpose:
        Called when the storage system initializes a storage-capable entity.

    Category:
        Inventory

    Parameters:
        entity (Entity)
            The storage entity being initialized.

    Example Usage:
        ```lua
        hook.Add("InitializeStorage", "liaExampleInitializeStorage", function(entity)
            print("[MyModule] handled InitializeStorage")
        end)
        ```

    Returns:
        nil

    Realm:
        Shared
]]
--[[
    Hooks:
        OnCreateStoragePanel(localInvPanel, storageInvPanel, storage)

    Purpose:
        Called after the client creates the paired inventory panels for a storage UI.

    Category:
        Inventory

    Parameters:
        localInvPanel (Panel)
            The local player's inventory panel.

        storageInvPanel (Panel)
            The storage inventory panel.

        storage (Entity)
            The storage entity being viewed.

    Example Usage:
        ```lua
        hook.Add("OnCreateStoragePanel", "liaExampleOnCreateStoragePanel", function(localInvPanel, storageInvPanel, storage)
            print("[MyModule] handled OnCreateStoragePanel")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        StorageCanTransferItem(client, storage, item)

    Purpose:
        Determines whether a player may transfer a specific item through a storage interaction.

    Category:
        Inventory

    Parameters:
        client (Player)
            The player attempting the transfer.

        storage (Entity)
            The storage entity involved in the transfer.

        item (table)
            The item being moved.

    Example Usage:
        ```lua
        hook.Add("StorageCanTransferItem", "liaExampleStorageCanTransferItem", function(client, storage, item)
            if IsValid(client) and client:IsAdmin() then
                return true
            end
        end)
        ```

    Returns:
        boolean|nil
            Return false to block the item transfer.

    Realm:
        Server
]]
--[[
    Hooks:
        StorageEntityRemoved(entity, inventory)

    Purpose:
        Called when a storage entity is removed and its attached inventory is being cleaned up.

    Category:
        Inventory

    Parameters:
        entity (Entity)
            The storage entity being removed.

        inventory (table)
            The inventory attached to the entity.

    Example Usage:
        ```lua
        hook.Add("StorageEntityRemoved", "liaExampleStorageEntityRemoved", function(entity, inventory)
            print("[MyModule] handled StorageEntityRemoved")
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        StorageInventorySet(entity, inventory, isCar)

    Purpose:
        Called after a storage entity is assigned an inventory.

    Category:
        Inventory

    Parameters:
        entity (Entity)
            The storage entity receiving the inventory.

        inventory (table)
            The inventory assigned to the entity.

        isCar (boolean)
            Whether the storage entity is a vehicle trunk.

    Example Usage:
        ```lua
        hook.Add("StorageInventorySet", "liaExampleStorageInventorySet", function(entity, inventory, isCar)
            print("[MyModule] handled StorageInventorySet")
        end)
        ```

    Returns:
        nil

    Realm:
        Shared
]]
--[[
    Hooks:
        StorageRestored(ent, inventory)

    Purpose:
        Called after persisted storage data is restored onto an entity.

    Category:
        Inventory

    Parameters:
        ent (Entity)
            The storage entity that was restored.

        inventory (table)
            The restored inventory.

    Example Usage:
        ```lua
        hook.Add("StorageRestored", "liaExampleStorageRestored", function(ent, inventory)
            print("[MyModule] handled StorageRestored")
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        StorageUnlockPrompt(entity)

    Purpose:
        Called on the client when a storage unlock prompt should be shown.

    Category:
        Inventory

    Parameters:
        entity (Entity)
            The locked storage entity requesting unlock input.

    Example Usage:
        ```lua
        hook.Add("StorageUnlockPrompt", "liaExampleStorageUnlockPrompt", function(entity)
            print("[MyModule] handled StorageUnlockPrompt")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
MODULE.name = "@storage"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@storageSystemDescription"
MODULE.NetworkStrings = {"liaStorageExit", "liaStorageSetPassword", "liaStorageTransfer", "liaStorageUnlock", "liaTrunkInitStorage",}
MODULE.Privileges = {
    ["canSpawnStorage"] = {
        Name = "@canSpawnStorage",
        MinAccess = "superadmin",
        Category = "@spawnPermissions",
    }
}

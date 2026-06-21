--[[
    Hooks:
        CanPlayerSpawnStorage(client, entity, info)

    Purpose:
        Determines whether a player may convert an entity into storage.

    Parameters:
        client (Player)
            The player trying to create the storage entity.

        entity (Entity)
            The target entity being turned into storage.

        info (table)
            The requested storage configuration data.

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

    Parameters:
        ent (Entity)
            The storage entity being saved.

        inventory (table)
            The inventory attached to the storage entity.

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

    Parameters:
        entity (Entity)
            The storage entity being initialized.

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

    Parameters:
        localInvPanel (Panel)
            The local player's inventory panel.

        storageInvPanel (Panel)
            The storage inventory panel.

        storage (Entity)
            The storage entity being viewed.

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

    Parameters:
        client (Player)
            The player attempting the transfer.

        storage (Entity)
            The storage entity involved in the transfer.

        item (table)
            The item being moved.

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

    Parameters:
        entity (Entity)
            The storage entity being removed.

        inventory (table)
            The inventory attached to the entity.

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

    Parameters:
        entity (Entity)
            The storage entity receiving the inventory.

        inventory (table)
            The inventory assigned to the entity.

        isCar (boolean)
            Whether the storage entity is a vehicle trunk.

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

    Parameters:
        ent (Entity)
            The storage entity that was restored.

        inventory (table)
            The restored inventory.

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

    Parameters:
        entity (Entity)
            The locked storage entity requesting unlock input.

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

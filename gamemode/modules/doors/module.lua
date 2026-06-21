--[[
    Hooks:
        CanPlayerLock(client, door)

    Purpose:
        Determines whether a player is allowed to start the key-based door or vehicle locking action.

    Parameters:
        client (Player)
            The player attempting to lock the target entity.

        door (Entity)
            The targeted door, vehicle, or simfphys vehicle.

    Returns:
        boolean|nil
            Return false to block the locking action. Returning nil allows the default permission checks to continue.

    Realm:
        Server
]]
--[[
    Hooks:
        CanPlayerUnlock(client, door)

    Purpose:
        Determines whether a player is allowed to start the key-based door or vehicle unlocking action.

    Parameters:
        client (Player)
            The player attempting to unlock the target entity.

        door (Entity)
            The targeted door, vehicle, or simfphys vehicle.

    Returns:
        boolean|nil
            Return false to block the unlocking action. Returning nil allows the default permission checks to continue.

    Realm:
        Server
]]
--[[
    Hooks:
        CanPlayerUseDoor(client, door)

    Purpose:
        Determines whether a player may use a door before the module applies its default interaction handling.

    Parameters:
        client (Player)
            The player trying to use the door.

        door (Entity)
            The door entity being used.

    Returns:
        boolean|nil
            Return false to deny the use attempt. Returning nil allows the default door-use flow to continue.

    Realm:
        Server
]]
--[[
    Hooks:
        CollectDoorDataFields(fields)

    Purpose:
        Allows plugins or modules to register additional door data fields before default door data is built.

    Parameters:
        fields (table)
            Mutable table that should be populated with custom field definitions. Each key should map to field information such as `default` and, when database-backed, `type`.

    Returns:
        nil

    Realm:
        Shared
]]
--[[
    Hooks:
        DoorLockToggled(client, door, state)

    Purpose:
        Called after a door or supported vehicle has been locked or unlocked through the keys system.

    Parameters:
        client (Player)
            The player who triggered the lock state change.

        door (Entity)
            The entity whose lock state was changed.

        state (boolean)
            The new lock state. True means locked and false means unlocked.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        FilterDoorInfo(entity, doorData, doorInfo)

    Purpose:
        Lets clientside code adjust or filter the assembled door information list before it is rendered.

    Parameters:
        entity (Entity)
            The door entity currently being inspected.

        doorData (table)
            The resolved cached door data for the entity.

        doorInfo (table)
            The mutable list of display entries that will be converted into the door info box text.

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        GetDoorInfo(entity, doorData, doorInfo)

    Purpose:
        Populates the clientside door information list that is shown when looking at a visible door.

    Parameters:
        entity (Entity)
            The door entity currently being inspected.

        doorData (table)
            The resolved cached door data for the entity.

        doorInfo (table)
            The mutable list that should receive formatted door information entries.

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        GetDoorInfoForAdminStick(target, extraInfo)

    Purpose:
        Adds extra clientside admin-stick information lines for a targeted door.

    Parameters:
        target (Entity)
            The door entity currently targeted by the admin stick.

        extraInfo (table)
            The mutable list of additional text lines to append to the admin stick HUD output.

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        KeyLock(client, door, time)

    Purpose:
        Called when the keys weapon requests a lock action for a targeted door or supported vehicle.

    Parameters:
        client (Player)
            The player using the keys weapon.

        door (Entity)
            The targeted door, vehicle, or simfphys vehicle.

        time (number)
            The action duration, in seconds, used for the stared lock interaction.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        KeyUnlock(client, door, time)

    Purpose:
        Called when the keys weapon requests an unlock action for a targeted door or supported vehicle.

    Parameters:
        client (Player)
            The player using the keys weapon.

        door (Entity)
            The targeted door, vehicle, or simfphys vehicle.

        time (number)
            The action duration, in seconds, used for the stared unlock interaction.

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        PlayerUseDoor(client, door)

    Purpose:
        Runs after door-use permission checks succeed, allowing modules to override the final use result.

    Parameters:
        client (Player)
            The player trying to use the door.

        door (Entity)
            The door entity being used.

    Returns:
        boolean|nil
            Return a non-nil value to override the final result of the use attempt. Returning nil leaves the default behavior unchanged.

    Realm:
        Server
]]
--[[
    Hooks:
        PostDoorDataLoad(ent, doorData)

    Purpose:
        Called after persisted or preset door data is assembled, before it is cached on the entity.

    Parameters:
        ent (Entity)
            The door entity receiving the loaded data.

        doorData (table)
            The resolved door data table about to be cached.

    Returns:
        table|nil
            Return a replacement door data table to modify the loaded values, or nil to keep the original table.

    Realm:
        Server
]]
--[[
    Hooks:
        PreDoorDataSave(door, doorData)

    Purpose:
        Called before cached door data is normalized and written back to persistent storage.

    Parameters:
        door (Entity)
            The door entity whose data is about to be saved.

        doorData (table)
            The current resolved door data table that will be serialized.

    Returns:
        table|nil
            Return a replacement door data table to change what gets saved, or nil to keep the current values.

    Realm:
        Server
]]
MODULE.name = "@doorsModuleName"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@doorSystemDescription"
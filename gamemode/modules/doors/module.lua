--[[
    Hooks:
        CanPlayerLock(client, door)

    Purpose:
        Determines whether a player is allowed to start the key-based door or vehicle locking action.

    Category:
        Doors

    Parameters:
        client (Player)
            The player attempting to lock the target entity.

        door (Entity)
            The targeted door, vehicle, or simfphys vehicle.

    Example Usage:
        ```lua
        hook.Add("CanPlayerLock", "liaExampleCanPlayerLock", function(client, door)
            if IsValid(client) and client:IsAdmin() then
                return true
            end
        end)
        ```

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

    Category:
        Doors

    Parameters:
        client (Player)
            The player attempting to unlock the target entity.

        door (Entity)
            The targeted door, vehicle, or simfphys vehicle.

    Example Usage:
        ```lua
        hook.Add("CanPlayerUnlock", "liaExampleCanPlayerUnlock", function(client, door)
            if IsValid(client) and client:IsAdmin() then
                return true
            end
        end)
        ```

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

    Category:
        Doors

    Parameters:
        client (Player)
            The player trying to use the door.

        door (Entity)
            The door entity being used.

    Example Usage:
        ```lua
        hook.Add("CanPlayerUseDoor", "liaExampleCanPlayerUseDoor", function(client, door)
            if IsValid(client) and client:IsAdmin() then
                return true
            end
        end)
        ```

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

    Category:
        Doors

    Parameters:
        fields (table)
            Mutable table that should be populated with custom field definitions. Each key should map to field information such as `default` and, when database-backed, `type`.

    Example Usage:
        ```lua
        hook.Add("CollectDoorDataFields", "liaExampleCollectDoorDataFields", function(fields)
            fields[#fields + 1] = {
                key = "exampleFlag",
                name = "Example Flag"
            }
        end)
        ```

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

    Category:
        Doors

    Parameters:
        client (Player)
            The player who triggered the lock state change.

        door (Entity)
            The entity whose lock state was changed.

        state (boolean)
            The new lock state. True means locked and false means unlocked.

    Example Usage:
        ```lua
        hook.Add("DoorLockToggled", "liaExampleDoorLockToggled", function(client, door, state)
            if not IsValid(client) then return end
            print(string.format("[MyModule] handled DoorLockToggled for %s", client:Name()))
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        KeyLock(client, door, time)

    Purpose:
        Called when the keys weapon requests a lock action for a targeted door or supported vehicle.

    Category:
        Doors

    Parameters:
        client (Player)
            The player using the keys weapon.

        door (Entity)
            The targeted door, vehicle, or simfphys vehicle.

        time (number)
            The action duration, in seconds, used for the stared lock interaction.

    Example Usage:
        ```lua
        hook.Add("KeyLock", "liaExampleKeyLock", function(client, door, time)
            if not IsValid(client) then return end
            print(string.format("[MyModule] handled KeyLock for %s", client:Name()))
        end)
        ```

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

    Category:
        Doors

    Parameters:
        client (Player)
            The player using the keys weapon.

        door (Entity)
            The targeted door, vehicle, or simfphys vehicle.

        time (number)
            The action duration, in seconds, used for the stared unlock interaction.

    Example Usage:
        ```lua
        hook.Add("KeyUnlock", "liaExampleKeyUnlock", function(client, door, time)
            if not IsValid(client) then return end
            print(string.format("[MyModule] handled KeyUnlock for %s", client:Name()))
        end)
        ```

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

    Category:
        Doors

    Parameters:
        client (Player)
            The player trying to use the door.

        door (Entity)
            The door entity being used.

    Example Usage:
        ```lua
        hook.Add("PlayerUseDoor", "liaExamplePlayerUseDoor", function(client, door)
            if IsValid(client) and client:IsAdmin() then
                return true
            end
        end)
        ```

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

    Category:
        Doors

    Parameters:
        ent (Entity)
            The door entity receiving the loaded data.

        doorData (table)
            The resolved door data table about to be cached.

    Example Usage:
        ```lua
        hook.Add("PostDoorDataLoad", "liaExamplePostDoorDataLoad", function(ent, doorData)
            return {
                {name = "Example", value = 1}
            }
        end)
        ```

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

    Category:
        Doors

    Parameters:
        door (Entity)
            The door entity whose data is about to be saved.

        doorData (table)
            The current resolved door data table that will be serialized.

    Example Usage:
        ```lua
        hook.Add("PreDoorDataSave", "liaExamplePreDoorDataSave", function(door, doorData)
            return {
                {name = "Example", value = 1}
            }
        end)
        ```

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

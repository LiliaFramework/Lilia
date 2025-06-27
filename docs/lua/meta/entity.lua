--[[
    isProp()

    Description:
        Returns true if the entity is a physics prop.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – Whether the entity is a physics prop.

    Example Usage:
        local result = ent:isProp()
]]
--[[
    isItem()

    Description:
        Checks if the entity is an item entity.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – True if the entity represents an item.

    Example Usage:
        local result = ent:isItem()
]]
--[[
    isMoney()

    Description:
        Checks if the entity is a money entity.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – True if the entity represents money.

    Example Usage:
        local result = ent:isMoney()
]]
--[[
    isSimfphysCar()

    Description:
        Checks if the entity is a simfphys car.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – True if this is a simfphys vehicle.

    Example Usage:
        local result = ent:isSimfphysCar()
]]
--[[
    isLiliaPersistent()

    Description:
        Determines if the entity is persistent in Lilia.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – Whether the entity should persist.

    Example Usage:
        local result = ent:isLiliaPersistent()
]]
--[[
    checkDoorAccess(client, access)

    Description:
        Checks if a player has the given door access level.

    Parameters:
        client (Player) – The player to check.
        access (number, optional) – Door permission level.

    Realm:
        Shared

    Returns:
        boolean – True if the player has access.

    Example Usage:
        local result = ent:checkDoorAccess(client, access)
]]
--[[
    keysOwn(client)

    Description:
        Assigns the entity to the specified player.

    Parameters:
        client (Player) – Player to set as owner.

    Realm:
        Shared

    Example Usage:
        local result = ent:keysOwn(client)
]]
--[[
    keysLock()

    Description:
        Locks the entity if it is a vehicle.

    Parameters:
        None

    Realm:
        Shared

    Example Usage:
        local result = ent:keysLock()
]]
--[[
    keysUnLock()

    Description:
        Unlocks the entity if it is a vehicle.

    Parameters:
        None

    Realm:
        Shared

    Example Usage:
        local result = ent:keysUnLock()
]]
--[[
    getDoorOwner()

    Description:
        Returns the player that owns this door if available.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        Player|nil – Door owner or nil.

    Example Usage:
        local result = ent:getDoorOwner()
]]
--[[
    isLocked()

    Description:
        Returns the locked state stored in net variables.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – Whether the door is locked.

    Example Usage:
        local result = ent:isLocked()
]]
--[[
    isDoorLocked()

    Description:
        Checks the internal door locked state.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – True if the door is locked.

    Example Usage:
        local result = ent:isDoorLocked()
]]
--[[
    getEntItemDropPos(offset)

    Description:
        Calculates a drop position in front of the entity's eyes.

    Parameters:
        offset (number) – Distance from the player eye position.

    Realm:
        Shared

    Returns:
        Vector – Drop position and angle.

    Example Usage:
        local result = ent:getEntItemDropPos(offset)
]]
--[[
    isNearEntity(radius, otherEntity)

    Description:
        Checks for another entity of the same class nearby.

    Parameters:
        radius (number) – Sphere radius in units.
        otherEntity (Entity, optional) – Specific entity to look for.

    Realm:
        Shared

    Returns:
        boolean – True if another entity is within radius.

    Example Usage:
        local result = ent:isNearEntity(radius, otherEntity)
]]
--[[
    GetCreator()

    Description:
        Returns the entity creator player.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        Player|nil – Creator player if stored.

    Example Usage:
        local result = ent:GetCreator()
]]
--[[
        SetCreator(client)

        Description:
            Stores the creator player on the entity.

        Parameters:
            client (Player) – Creator of the entity.

        Realm:
            Server

    Example Usage:
        local result = ent:SetCreator(client)
    ]]
--[[
        sendNetVar(key, receiver)

        Description:
            Sends a network variable to recipients.

        Parameters:
            key (string) – Identifier of the variable.
            receiver (Player|nil) – Who to send to.

        Realm:
            Server

        Internal:
            Used by the networking system.

    Example Usage:
        local result = ent:sendNetVar(key, receiver)
    ]]
--[[
        clearNetVars(receiver)

        Description:
            Clears all network variables on this entity.

        Parameters:
            receiver (Player|nil) – Receiver to notify.

        Realm:
            Server

    Example Usage:
        local result = ent:clearNetVars(receiver)
    ]]
--[[
        removeDoorAccessData()

        Description:
            Clears all stored door access information.

    Parameters:
        None

        Realm:
            Server

    Example Usage:
        local result = ent:removeDoorAccessData()
    ]]
--[[
        setLocked(state)

        Description:
            Stores the door locked state in network variables.

        Parameters:
            state (boolean) – New locked state.

        Realm:
            Server

    Example Usage:
        local result = ent:setLocked(state)
    ]]
--[[
        isDoor()

        Description:
            Returns true if the entity's class indicates a door.

    Parameters:
        None

        Realm:
            Server

        Returns:
            boolean – Whether the entity is a door.

    Example Usage:
        local result = ent:isDoor()
    ]]
--[[
        getDoorPartner()

        Description:
            Returns the partner door linked with this entity.

    Parameters:
        None

        Realm:
            Server

        Returns:
            Entity|nil – The partnered door.

    Example Usage:
        local result = ent:getDoorPartner()
    ]]
--[[
        setNetVar(key, value, receiver)

        Description:
            Updates a network variable and sends it to recipients.

        Parameters:
            key (string) – Variable name.
            value (any) – Value to store.
            receiver (Player|nil) – Who to send update to.

        Realm:
            Server

    Example Usage:
        local result = ent:setNetVar(key, value, receiver)
    ]]
--[[
        getNetVar(key, default)

        Description:
            Retrieves a stored network variable or a default value.

        Parameters:
            key (string) – Variable name.
            default (any) – Value returned if variable is nil.

        Realm:
            Server
            Client

        Returns:
            any – Stored value or default.

    Example Usage:
        local result = ent:getNetVar(key, default)
    ]]
--[[
        isDoor()

        Description:
            Client-side door check using class name.

    Parameters:
        None

        Realm:
            Client

        Returns:
            boolean – True if entity class contains "door".

    Example Usage:
        local result = ent:isDoor()
    ]]
--[[
        getDoorPartner()

        Description:
            Attempts to find the door partnered with this one.

    Parameters:
        None

        Realm:
            Client

        Returns:
            Entity|nil – The partner door entity.

    Example Usage:
        local result = ent:getDoorPartner()
    ]]
--[[
        getNetVar(key, default)

        Description:
            Retrieves a network variable for this entity on the client.

        Parameters:
            key (string) – Variable name.
            default (any) – Default if not set.

        Realm:
            Client

        Returns:
            any – Stored value or default.

    Example Usage:
        local result = ent:getNetVar(key, default)
    ]]

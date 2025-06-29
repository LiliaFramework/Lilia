# Entity Meta

Entities in Garry's Mod may represent props, items, and interactive objects. This reference describes utility functions added to entity metatables for easier classification and management.

---

## Overview

The entity meta library exposes detection routines, network-safe data helpers, and wrappers for retrieving item information or safe positions. Using these functions ensures consistent behavior when handling game objects across Lilia.

--[[--
Physical object in the game world.

Entities are physical representations of objects in the game world. Helix extends the functionality of entities to interface
between Helix's own classes, and to reduce boilerplate code.

See the [Garry's Mod Wiki](https://wiki.garrysmod.com/page/Category:Entity) for all other methods that the `Player` class has.
]]

---

### `isProp()`

    Description:
        Returns true if the entity is a physics prop.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – Whether the entity is a physics prop.

    Example Usage:
        -- Apply physics damage only if this is a prop
        if ent:isProp() then
            ent:TakeDamage(50)
        end

### `isItem()`

    Description:
        Checks if the entity is an item entity.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – True if the entity represents an item.

    Example Usage:
        -- Attempt to pick up the entity as an item
        if ent:isItem() then
            lia.item.pickup(client, ent)
        end

### `isMoney()`

    Description:
        Checks if the entity is a money entity.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – True if the entity represents money.

    Example Usage:
        -- Collect money dropped on the ground
        if ent:isMoney() then
            char:addMoney(ent:getAmount())
        end

### `isSimfphysCar()`

    Description:
        Checks if the entity is a simfphys car.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – True if this is a simfphys vehicle.

    Example Usage:
        -- Show a custom HUD when entering a simfphys vehicle
        if ent:isSimfphysCar() then
            OpenCarHUD(ent)
        end

### `isLiliaPersistent()`

    Description:
        Determines if the entity is persistent in Lilia.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – Whether the entity should persist.

    Example Usage:
        -- Save this entity across map resets if persistent
        if ent:isLiliaPersistent() then
            lia.persist.saveEntity(ent)
        end

### `checkDoorAccess(client, access)`

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
        -- Block a player from opening the door without access
        if not door:checkDoorAccess(client, DOOR_ACCESS_OPEN) then
            client:notify("The door is locked.")
        end

### `keysOwn(client)`

    Description:
        Assigns the entity to the specified player.

    Parameters:
        client (Player) – Player to set as owner.

    Realm:
        Shared

    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Assign ownership when a player buys the door
        door:keysOwn(buyer)

### `keysLock()`

    Description:
        Locks the entity if it is a vehicle.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Lock the vehicle after the driver exits
        car:keysLock()

### `keysUnLock()`

    Description:
        Unlocks the entity if it is a vehicle.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Unlock the vehicle when the owner presses a key
        car:keysUnLock()

### `getDoorOwner()`

    Description:
        Returns the player that owns this door if available.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        Player|None – Door owner or None.

    Example Usage:
        -- Print the name of the door owner when inspecting
        local owner = door:getDoorOwner()
        if owner then
            print("Owned by", owner:Name())
        end

### `isLocked()`

    Description:
        Returns the locked state stored in net variables.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – Whether the door is locked.

    Example Usage:
        -- Display a lock icon if the door is networked as locked
        if door:isLocked() then
            DrawLockedIcon(door)
        end

### `isDoorLocked()`

    Description:
        Checks the internal door locked state.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – True if the door is locked.

    Example Usage:
        -- Play a sound when trying to open a locked door server-side
        if door:isDoorLocked() then
            door:EmitSound("doors/door_locked2.wav")
        end

### `getEntItemDropPos(offset)`

    Description:
        Calculates a drop position in front of the entity's eyes.

    Parameters:
        offset (number) – Distance from the player eye position.

    Realm:
        Shared

    Returns:
        Vector – Drop position and angle.

    Example Usage:
        -- Spawn an item drop in front of the entity's eyes
        local pos, ang = ent:getEntItemDropPos(16)
        lia.item.spawn("item_water", pos, ang)

### `isNearEntity(radius, otherEntity)`

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
        -- Prevent building too close to another chest
        if ent:isNearEntity(128, otherChest) then
            client:notify("Too close to another chest!")
        end

### `GetCreator()`

    Description:
        Returns the entity creator player.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        Player|None – Creator player if stored.

    Example Usage:
        -- Credit the creator when the entity is removed
        local creator = ent:GetCreator()
        if IsValid(creator) then
            creator:notify("Your prop was removed.")
        end

### `SetCreator(client)`

        Description:
            Stores the creator player on the entity.

        Parameters:
            client (Player) – Creator of the entity.

        Realm:
            Server

        Returns:
            None – This function does not return a value.

        Example Usage:
            -- Record the spawner for cleanup tracking
            ent:SetCreator(client)

### `sendNetVar(key, receiver)`

        Description:
            Sends a network variable to recipients.

        Parameters:
            key (string) – Identifier of the variable.
            receiver (Player|None) – Who to send to.

        Realm:
            Server

        Internal:
            Used by the networking system.

    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Broadcast the "doorState" variable to every connected player
        for _, ply in player.Iterator() do
            ent:sendNetVar("doorState", ply)
        end

### `clearNetVars(receiver)`

        Description:
            Clears all network variables on this entity.

        Parameters:
            receiver (Player|None) – Receiver to notify.

        Realm:
            Server

        Returns:
            None – This function does not return a value.

    Example Usage:
        -- Force reinitialization by clearing all variables for this receiver
        ent:clearNetVars(client)
        ent:sendNetVar("initialized", client)

### `removeDoorAccessData()`

        Description:
            Clears all stored door access information.

    Parameters:
        None

        Realm:
            Server

    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Wipe door permissions during cleanup
        local result = ent:removeDoorAccessData()

### `setLocked(state)`

        Description:
            Stores the door locked state in network variables.

        Parameters:
            state (boolean) – New locked state.

        Realm:
            Server

    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Toggle the door lock and play a latch sound for everyone
        door:setLocked(true)
        door:EmitSound("doors/door_latch3.wav")

### `isDoor()`

        Description:
            Returns true if the entity's class indicates a door.

    Parameters:
        None

        Realm:
            Server

        Returns:
            boolean – Whether the entity is a door.

    Example Usage:
        -- Check if the entity behaves like a door
        local result = ent:isDoor()

### `getDoorPartner()`

        Description:
            Returns the partner door linked with this entity.

    Parameters:
        None

        Realm:
            Server

        Returns:
            Entity|None – The partnered door.

    Example Usage:
        -- Unlock both doors when opening a double-door setup
        local partner = ent:getDoorPartner()
        if IsValid(partner) then
            partner:setLocked(false)
        end

### `setNetVar(key, value, receiver)`

        Description:
            Updates a network variable and sends it to recipients.

        Parameters:
            key (string) – Variable name.
            value (any) – Value to store.
            receiver (Player|None) – Who to send update to.

        Realm:
            Server

    Returns:
        None – This function does not return a value.

    Example Usage:
        -- Store a variable and sync it to players
        local result = ent:setNetVar(key, value, receiver)

### `getNetVar(key, default)`

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
        -- Retrieve the stored variable or fallback to the default
        local result = ent:getNetVar(key, default)

### `isDoor()`

        Description:
            Client-side door check using class name.

    Parameters:
        None

        Realm:
            Client

        Returns:
            boolean – True if entity class contains "door".

    Example Usage:
        -- Determine if this entity's class name contains "door"
        local result = ent:isDoor()

### `getDoorPartner()`

        Description:
            Attempts to find the door partnered with this one.

    Parameters:
        None

        Realm:
            Client

        Returns:
            Entity|None – The partner door entity.

    Example Usage:
        -- Highlight the partner door of the one being looked at
        local partner = ent:getDoorPartner()
        if IsValid(partner) then
            partner:SetColor(Color(0, 255, 0))
        end

### `getNetVar(key, default)`

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
        -- Access a synced variable on the client side
        local result = ent:getNetVar(key, default)


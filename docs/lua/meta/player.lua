--[[
        getChar()

        Description:
            Returns the currently loaded character object for this player.

    Parameters:
        None

        Realm:
            Shared

        Returns:
            Character|nil – The player's active character.

    Example Usage:
        -- Retrieve the character to modify inventory
        local char = player:getChar()
    ]]
--[[
        Name()

        Description:
            Returns either the character's roleplay name or the player's Steam name.

    Parameters:
        None

        Realm:
            Shared

        Returns:
            string – Display name.

    Example Usage:
        -- Print the roleplay name in chat
        chat.AddText(player:Name())
    ]]
--[[
    hasPrivilege(privilegeName)

    Description:
        Wrapper for CAMI privilege checks.

    Parameters:
        privilegeName (string) – Privilege identifier.

    Realm:
        Shared

    Returns:
        boolean – Result from CAMI.PlayerHasAccess.

    Example Usage:
        -- Deny access if the player lacks a privilege
        if not player:hasPrivilege("Manage") then
            return false
        end
]]
--[[
    getCurrentVehicle()

    Description:
        Safely returns the vehicle the player is currently using.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        Entity|nil – Vehicle entity or nil.

    Example Usage:
        -- Attach a camera to the vehicle the player is in
        local veh = player:getCurrentVehicle()
        if IsValid(veh) then
            AttachCamera(veh)
        end
]]
--[[
    hasValidVehicle()

    Description:
        Determines if the player is currently inside a valid vehicle.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – True if a vehicle entity is valid.

    Example Usage:
        -- Allow honking only when in a valid vehicle
        if player:hasValidVehicle() then
            player:GetVehicle():EmitSound("Horn")
        end
]]
--[[
    isNoClipping()

    Description:
        Returns true if the player is in noclip mode and not inside a vehicle.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – Whether the player is noclipping.

    Example Usage:
        -- Disable certain actions while noclipping
        if player:isNoClipping() then return end
]]
--[[
    getItems()

    Description:
        Returns the player's inventory item list if a character is loaded.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        table|nil – Table of items or nil if absent.

    Example Usage:
        -- Iterate player's items to calculate total weight
        for _, it in pairs(player:getItems() or {}) do
            total = total + it.weight
        end
]]
--[[
    getTracedEntity(distance)

    Description:
        Performs a simple trace from the player's shoot position.

    Parameters:
        distance (number) – Trace length in units.

    Realm:
        Shared

    Returns:
        Entity|nil – The entity hit or nil.

    Example Usage:
        -- Grab the entity the player is pointing at
        local entity = player:getTracedEntity(96)
]]
--[[
    getTrace(distance)

    Description:
        Returns a hull trace in front of the player.

    Parameters:
        distance (number) – Hull length in units.

    Realm:
        Shared

    Returns:
        table – Trace result.

    Example Usage:
        -- Use a hull trace for melee attacks
        local tr = player:getTrace(48)
]]
--[[
    getEyeEnt(distance)

    Description:
        Returns the entity the player is looking at within a distance.

    Parameters:
        distance (number) – Maximum distance.

    Realm:
        Shared

    Returns:
        Entity|nil – The entity or nil if too far.

    Example Usage:
        -- Show the name of the object being looked at
        local target = player:getEyeEnt(128)
        if IsValid(target) then
            player:ChatPrint(target:GetClass())
        end
]]
--[[
    notify(message)

    Description:
        Sends a plain notification message to the player.

    Parameters:
        message (string) – Text to display.

    Realm:
        Server
    Returns:
        nil – This function does not return a value.

    Example Usage:
        -- Send a chat notification to the player
        local result = player:notify("Welcome to the server!")
]]
--[[
    notifyLocalized(message, ...)

    Description:
        Sends a localized notification to the player.

    Parameters:
        message (string) – Translation key.
        ... – Additional parameters for localization.

    Realm:
        Server
    Returns:
        nil – This function does not return a value.

    Example Usage:
        -- Send a localized message to the player
        local result = player:notifyLocalized("greeting_key", player:Name())
]]
--[[
    CanEditVendor(vendor)

    Description:
        Determines whether the player can edit the given vendor.

    Parameters:
        vendor (Entity) – Vendor entity to check.

    Realm:
        Server

    Returns:
        boolean – True if allowed to edit.

    Example Usage:
        local result = player:CanEditVendor(vendor)
]]
--[[
    isUser()

    Description:
        Convenience wrapper to check if the player is in the "user" group.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – Whether usergroup is "user".

    Example Usage:
        local result = player:isUser()
]]
--[[
    isStaff()

    Description:
        Returns true if the player belongs to a staff group.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – Result from the privilege check.

    Example Usage:
        local result = player:isStaff()
]]
--[[
    isVIP()

    Description:
        Checks whether the player is in the VIP group.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – Result from privilege check.

    Example Usage:
        local result = player:isVIP()
]]
--[[
    isStaffOnDuty()

    Description:
        Determines if the player is currently in the staff faction.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        boolean – True if staff faction is active.

    Example Usage:
        local result = player:isStaffOnDuty()
]]
--[[
    isFaction(faction)

    Description:
        Checks if the player's character belongs to the given faction.

    Parameters:
        faction (number) – Faction index to compare.

    Realm:
        Shared

    Returns:
        boolean – True if the factions match.

    Example Usage:
        local result = player:isFaction(faction)
]]
--[[
    isClass(class)

    Description:
        Returns true if the player's character is of the given class.

    Parameters:
        class (number) – Class index to compare.

    Realm:
        Shared

    Returns:
        boolean – Whether the character matches the class.

    Example Usage:
        local result = player:isClass(class)
]]
--[[
    hasWhitelist(faction)

    Description:
        Determines if the player has whitelist access for a faction.

    Parameters:
        faction (number) – Faction index.

    Realm:
        Shared

    Returns:
        boolean – True if whitelisted.

    Example Usage:
        local result = player:hasWhitelist(faction)
]]
--[[
    getClass()

    Description:
        Retrieves the class index of the player's character.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        number|nil – Class index or nil.

    Example Usage:
        local result = player:getClass()
]]
--[[
    hasClassWhitelist(class)

    Description:
        Checks if the player's character is whitelisted for a class.

    Parameters:
        class (number) – Class index.

    Realm:
        Shared

    Returns:
        boolean – True if class whitelist exists.

    Example Usage:
        local result = player:hasClassWhitelist(class)
]]
--[[
    getClassData()

    Description:
        Returns the class table of the player's current class.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        table|nil – Class definition table.

    Example Usage:
        local result = player:getClassData()
]]
--[[
    getDarkRPVar(var)

    Description:
        Compatibility helper for retrieving money with DarkRP-style calls.

    Parameters:
        var (string) – Currently only supports "money".

    Realm:
        Shared

    Returns:
        number|nil – Money amount or nil.

    Example Usage:
        local result = player:getDarkRPVar(var)
]]
--[[
    getMoney()

    Description:
        Convenience function to get the character's money amount.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        number – Current funds or 0.

    Example Usage:
        local result = player:getMoney()
]]
--[[
    canAfford(amount)

    Description:
        Checks if the player has enough money for a purchase.

    Parameters:
        amount (number) – Cost to test.

    Realm:
        Shared

    Returns:
        boolean – True if funds are sufficient.

    Example Usage:
        local result = player:canAfford(amount)
]]
--[[
    hasSkillLevel(skill, level)

    Description:
        Verifies the player's character meets an attribute level.

    Parameters:
        skill (string) – Attribute ID.
        level (number) – Required level.

    Realm:
        Shared

    Returns:
        boolean – Whether the character satisfies the requirement.

    Example Usage:
        local result = player:hasSkillLevel(skill, level)
]]
--[[
    meetsRequiredSkills(requiredSkillLevels)

    Description:
        Checks a table of skill requirements against the player.

    Parameters:
        requiredSkillLevels (table) – Mapping of attribute IDs to levels.

    Realm:
        Shared

    Returns:
        boolean – True if all requirements are met.

    Example Usage:
        local result = player:meetsRequiredSkills(requiredSkillLevels)
]]
--[[
    forceSequence(sequenceName, callback, time, noFreeze)

    Description:
        Plays an animation sequence and optionally freezes the player.

    Parameters:
        sequenceName (string) – Sequence to play.
        callback (function|nil) – Called when finished.
        time (number|nil) – Duration override.
        noFreeze (boolean) – Don't freeze movement when true.

    Realm:
        Shared

    Returns:
        number|boolean – Duration or false on failure.

    Example Usage:
        local result = player:forceSequence(sequenceName, callback, time, noFreeze)
]]
--[[
    leaveSequence()

    Description:
        Stops any forced sequence and restores player movement.

    Parameters:
        None

    Realm:
        Shared
    Returns:
        nil – This function does not return a value.

    Example Usage:
        -- Stop the player's forced animation sequence
        local result = player:leaveSequence()
]]
--[[
        restoreStamina(amount)

        Description:
            Increases the player's stamina value.

        Parameters:
            amount (number) – Amount to restore.

        Realm:
            Server
        Returns:
            nil – This function does not return a value.

    Example Usage:
        -- Give the player extra stamina points
        local result = player:restoreStamina(amount)
    ]]
--[[
        consumeStamina(amount)

        Description:
            Reduces the player's stamina value.

        Parameters:
            amount (number) – Amount to subtract.

        Realm:
            Server
        Returns:
            nil – This function does not return a value.

    Example Usage:
        -- Spend stamina as the player performs an action
        local result = player:consumeStamina(amount)
    ]]
--[[
        addMoney(amount)

        Description:
            Adds funds to the player's character, clamping to limits.

        Parameters:
            amount (number) – Money to add.

        Realm:
            Server
    Returns:
        nil – This function does not return a value.

    Example Usage:
        -- Give the player additional money
        local result = player:addMoney(amount)
    ]]
--[[
        takeMoney(amount)

        Description:
            Removes money from the player's character.

        Parameters:
            amount (number) – Amount to subtract.

        Realm:
            Server
    Returns:
        nil – This function does not return a value.

    Example Usage:
        -- Remove money from the player's character
        local result = player:takeMoney(amount)
    ]]

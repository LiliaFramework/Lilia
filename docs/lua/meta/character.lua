--[[
    tostring()

    Description:
        Returns a printable identifier for this character.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        string – Format "character[id]".

    Example Usage:
        local result = char:tostring()
]]
--[[
    eq(other)

    Description:
        Compares two characters by ID for equality.

    Parameters:
        other (Character) – Character to compare.

    Realm:
        Shared

    Returns:
        boolean – True if both share the same ID.

    Example Usage:
        local result = char:eq(other)
]]
--[[
    getID()

    Description:
        Returns the unique database ID for this character.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        number – Character identifier.

    Example Usage:
        local result = char:getID()
]]
--[[
    getPlayer()

    Description:
        Returns the player entity currently controlling this character.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        Player|nil – Owning player or nil.

    Example Usage:
        local result = char:getPlayer()
]]
--[[
    getDisplayedName(client)

    Description:
        Returns the character's name as it should be shown to the given player.

    Parameters:
        client (Player) – Player requesting the name.

    Realm:
        Shared

    Returns:
        string – Localized or recognized character name.

    Example Usage:
        local result = char:getDisplayedName(client)
]]
--[[
    hasMoney(amount)

    Description:
        Checks if the character has at least the given amount of money.

    Parameters:
        amount (number) – Amount to check for.

    Realm:
        Shared

    Returns:
        boolean – True if the character's funds are sufficient.

    Example Usage:
        local result = char:hasMoney(amount)
]]
--[[
    getFlags()

    Description:
        Retrieves the string of permission flags for this character.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        string – Concatenated flag characters.

    Example Usage:
        local result = char:getFlags()
]]
--[[
    hasFlags(flags)

    Description:
        Checks if the character possesses any of the specified flags.

    Parameters:
        flags (string) – String of flag characters to check.

    Realm:
        Shared

    Returns:
        boolean – True if at least one flag is present.

    Example Usage:
        local result = char:hasFlags(flags)
]]
--[[
    getItemWeapon(requireEquip)

    Description:
        Checks the player's active weapon against items in the inventory.

    Parameters:
        requireEquip (boolean) – Only match equipped items if true.

    Realm:
        Shared

    Returns:
        boolean – True if the active weapon corresponds to an item.

    Example Usage:
        local result = char:getItemWeapon(requireEquip)
]]
--[[
    getMaxStamina()

    Description:
        Returns the maximum stamina value for this character.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        number – Maximum stamina points.

    Example Usage:
        local result = char:getMaxStamina()
]]
--[[
    getStamina()

    Description:
        Retrieves the character's current stamina value.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        number – Current stamina.

    Example Usage:
        local result = char:getStamina()
]]
--[[
    hasClassWhitelist(class)

    Description:
        Checks if the character has whitelisted the given class.

    Parameters:
        class (number) – Class index.

    Realm:
        Shared

    Returns:
        boolean – True if the class is whitelisted.

    Example Usage:
        local result = char:hasClassWhitelist(class)
]]
--[[
    isFaction(faction)

    Description:
        Returns true if the character's faction matches.

    Parameters:
        faction (number) – Faction index.

    Realm:
        Shared

    Returns:
        boolean – Whether the faction matches.

    Example Usage:
        local result = char:isFaction(faction)
]]
--[[
    isClass(class)

    Description:
        Returns true if the character's class equals the specified class.

    Parameters:
        class (number) – Class index.

    Realm:
        Shared

    Returns:
        boolean – Whether the classes match.

    Example Usage:
        local result = char:isClass(class)
]]
--[[
    getAttrib(key, default)

    Description:
        Retrieves the value of an attribute including boosts.

    Parameters:
        key (string) – Attribute identifier.
        default (number) – Default value when attribute is missing.

    Realm:
        Shared

    Returns:
        number – Final attribute value.

    Example Usage:
        local result = char:getAttrib(key, default)
]]
--[[
    getBoost(attribID)

    Description:
        Returns the boost table for the given attribute.

    Parameters:
        attribID (string) – Attribute identifier.

    Realm:
        Shared

    Returns:
        table|nil – Table of boosts or nil.

    Example Usage:
        local result = char:getBoost(attribID)
]]
--[[
    getBoosts()

    Description:
        Retrieves all attribute boosts for this character.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        table – Mapping of attribute IDs to boost tables.

    Example Usage:
        local result = char:getBoosts()
]]
--[[
    doesRecognize(id)

    Description:
        Determines if this character recognizes another character.

    Parameters:
        id (number|Character) – Character ID or object to check.

    Realm:
        Shared

    Returns:
        boolean – True if recognized.

    Example Usage:
        local result = char:doesRecognize(id)
]]
--[[
    doesFakeRecognize(id)

    Description:
        Checks if the character has a fake recognition entry for another.

    Parameters:
        id (number|Character) – Character identifier.

    Realm:
        Shared

    Returns:
        boolean – True if fake recognized.

    Example Usage:
        local result = char:doesFakeRecognize(id)
]]

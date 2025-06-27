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
        -- Print a readable identifier when saving debug logs
        print("Active char: " .. char:tostring())
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
        -- Check if the player is controlling the door owner
        if char:eq(door:getNetVar("ownChar")) then
            door:Fire("unlock", "", 0)
        end
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
        -- Store the character ID for later reference
        local id = char:getID()
        session.lastCharID = id
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
        Player|None – Owning player or None.

    Example Usage:
        -- Notify the controlling player that the character loaded
        local ply = char:getPlayer()
        if IsValid(ply) then
            ply:ChatPrint("Character ready")
        end
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
        -- Announce the character's name to a viewer
        client:ChatPrint("You see " .. char:getDisplayedName(client))
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
        -- Verify the character can pay for an item before buying
        if char:hasMoney(item.price) then
            char:takeMoney(item.price)
        end
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
        -- Look for the admin flag on this character
        if char:getFlags():find("A") then
            print("Admin privileges detected")
        end
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
        -- Allow special command if any required flag is present
        if char:hasFlags("abc") then
            performSpecialAction()
        end
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
        -- Determine if the equipped weapon is linked to an item
        local match = char:getItemWeapon(true)
        if match then print("Using weapon item") end
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
        -- Calculate the proportion of stamina remaining
        local pct = char:getStamina() / char:getMaxStamina()
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
        -- Display current stamina in the HUD
        local stamina = char:getStamina()
        drawStaminaBar(stamina)
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
        -- Decide if the player may choose the medic class
        if char:hasClassWhitelist(CLASS_MEDIC) then
            print("You may become a medic")
        end
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
        -- Restrict access to citizens only
        if char:isFaction(FACTION_CITIZEN) then
            door:keysOwn(char:getPlayer())
        end
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
        -- Provide a bonus if the character is currently an engineer
        if char:isClass(CLASS_ENGINEER) then
            char:restoreStamina(10)
        end
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
        -- Calculate damage using the strength attribute
        local strength = char:getAttrib("str", 0)
        dmg = baseDamage + strength * 0.5
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
        table|None – Table of boosts or None.

    Example Usage:
        -- Inspect active boosts on agility
        PrintTable(char:getBoost("agi"))
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
        -- Print all attribute boosts for debugging
        for id, data in pairs(char:getBoosts()) do
            print(id, data)
        end
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
        -- Reveal names in chat only if recognized
        if char:doesRecognize(targetChar) then
            print("Known: " .. targetChar:getName())
        end
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
        -- See if recognition was forced by a disguise item
        if char:doesFakeRecognize(targetChar) then
            print("Recognition is fake")
        end
]]

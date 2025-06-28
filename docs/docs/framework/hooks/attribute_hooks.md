# Attribute Hooks

This document lists hooks related to attribute setup and changes.

---

### `GetMaxStartingAttributePoints(client, context)`


    Description:
    Lets you change how many attribute points a new character receives.
    Retrieves the maximum attribute points available at character creation.

    Parameters:
    client (Player) – Viewing player.
    context (string) – Creation context.

    Realm:
    Client

    Returns:
    number – Maximum starting points

    Example Usage:
    -- Gives every new character 60 starting points.
    hook.Add("GetMaxStartingAttributePoints", "DoublePoints", function(client)
        return 60
    end)

### `GetAttributeStartingMax(client, attribute)`


    Description:
    Sets a limit for a specific attribute at character creation.
    Returns the starting maximum for a specific attribute.

    Parameters:
    client (Player) – Viewing player.
    attribute (string) – Attribute identifier.

    Realm:
    Client

    Returns:
    number – Maximum starting value

    Example Usage:
    -- Limits the Strength attribute to a maximum of 20.
    hook.Add("GetAttributeStartingMax", "CapStrength", function(client, attribute)
        if attribute == "strength" then return 20 end
    end)

### `GetAttributeMax(client, attribute)`


    Description:
    Returns the maximum value allowed for an attribute.

    Parameters:
    client (Player) – Player being queried.
    attribute (string) – Attribute identifier.

    Realm:
    Shared

    Returns:
    number – Maximum attribute value

    Example Usage:
    -- Increase stamina cap for admins.
    hook.Add("GetAttributeMax", "AdminStamina", function(client, attrib)
        if attrib == "stamina" and client:IsAdmin() then
            return 150
        end
    end)

### `OnCharAttribBoosted(client, character, key, boostID, amount)`


    Description:
    Fired when an attribute boost is added or removed.

    Parameters:
    client (Player) – Player owning the character.
    character (Character) – Character affected.
    key (string) – Attribute identifier.
    boostID (string) – Unique boost key.
    amount (number|boolean) – Amount added or true when removed.

    Realm:
    Shared

    Returns:
    None

    Example Usage:
    -- Notify the player when they gain a temporary bonus.
    hook.Add("OnCharAttribBoosted", "BoostNotice", function(client, char, key, id, amount)
        if amount ~= true then client:notify("Boosted " .. key .. " by " .. amount) end
    end)

### `OnCharAttribUpdated(client, character, key, value)`


    Description:
    Fired when a character attribute value is changed.

    Parameters:
    client (Player) – Player owning the character.
    character (Character) – Character updated.
    key (string) – Attribute identifier.
    value (number) – New attribute value.

    Realm:
    Shared

    Returns:
    None

    Example Usage:
    -- Print the changed attribute on the local player's HUD.
    hook.Add("OnCharAttribUpdated", "PrintAttribChange", function(client, char, key, value)
        if client == LocalPlayer() then
            chat.AddText(key .. ": " .. value)
        end
    end)

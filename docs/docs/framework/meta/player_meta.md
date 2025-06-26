## getChar

**Description:**
    Returns the currently loaded character object for this player.

---

### Parameters

---

### Returns

    * Character|nil – The player's active character.

---

**Realm:**
    Shared

---

## Name

**Description:**
    Returns either the character's roleplay name or the player's Steam name.

---

### Parameters

---

### Returns

    * string – Display name.

---

**Realm:**
    Shared

---

## hasPrivilege

**Description:**
    Wrapper for CAMI privilege checks.

---

### Parameters

    * privilegeName (string) – Privilege identifier.

---

### Returns

    * boolean – Result from CAMI.PlayerHasAccess.

---

**Realm:**
    Shared

---

## getCurrentVehicle

**Description:**
    Safely returns the vehicle the player is currently using.

---

### Parameters

---

### Returns

    * Entity|nil – Vehicle entity or nil.

---

**Realm:**
    Shared

---

## hasValidVehicle

**Description:**
    Determines if the player is currently inside a valid vehicle.

---

### Parameters

---

### Returns

    * boolean – True if a vehicle entity is valid.

---

**Realm:**
    Shared

---

## isNoClipping

**Description:**
    Returns true if the player is in noclip mode and not inside a vehicle.

---

### Parameters

---

### Returns

    * boolean – Whether the player is noclipping.

---

**Realm:**
    Shared

---

## getItems

**Description:**
    Returns the player's inventory item list if a character is loaded.

---

### Parameters

---

### Returns

    * table|nil – Table of items or nil if absent.

---

**Realm:**
    Shared

---

## getTracedEntity

**Description:**
    Performs a simple trace from the player's shoot position.

---

### Parameters

    * distance (number) – Trace length in units.

---

### Returns

    * Entity|nil – The entity hit or nil.

---

**Realm:**
    Shared

---

## getTrace

**Description:**
    Returns a hull trace in front of the player.

---

### Parameters

    * distance (number) – Hull length in units.

---

### Returns

    * table – Trace result.

---

**Realm:**
    Shared

---

## getEyeEnt

**Description:**
    Returns the entity the player is looking at within a distance.

---

### Parameters

    * distance (number) – Maximum distance.

---

### Returns

    * Entity|nil – The entity or nil if too far.

---

**Realm:**
    Shared

---

## notify

**Description:**
    Sends a plain notification message to the player.

---

### Parameters

    * message (string) – Text to display.

---

### Returns

---

**Realm:**
    Server

---

## notifyLocalized

**Description:**
    Sends a localized notification to the player.

---

### Parameters

    * message (string) – Translation key.
    * ... – Additional parameters for localization.

---

### Returns

---

**Realm:**
    Server

---

## CanEditVendor

**Description:**
    Determines whether the player can edit the given vendor.

---

### Parameters

    * vendor (Entity) – Vendor entity to check.

---

### Returns

    * boolean – True if allowed to edit.

---

**Realm:**
    Server

---

## isUser

**Description:**
    Convenience wrapper to check if the player is in the "user" group.

---

### Parameters

---

### Returns

    * boolean – Whether usergroup is "user".

---

**Realm:**
    Shared

---

## isStaff

**Description:**
    Returns true if the player belongs to a staff group.

---

### Parameters

---

### Returns

    * boolean – Result from the privilege check.

---

**Realm:**
    Shared

---

## isVIP

**Description:**
    Checks whether the player is in the VIP group.

---

### Parameters

---

### Returns

    * boolean – Result from privilege check.

---

**Realm:**
    Shared

---

## isStaffOnDuty

**Description:**
    Determines if the player is currently in the staff faction.

---

### Parameters

---

### Returns

    * boolean – True if staff faction is active.

---

**Realm:**
    Shared

---

## isFaction

**Description:**
    Checks if the player's character belongs to the given faction.

---

### Parameters

    * faction (number) – Faction index to compare.

---

### Returns

    * boolean – True if the factions match.

---

**Realm:**
    Shared

---

## isClass

**Description:**
    Returns true if the player's character is of the given class.

---

### Parameters

    * class (number) – Class index to compare.

---

### Returns

    * boolean – Whether the character matches the class.

---

**Realm:**
    Shared

---

## hasWhitelist

**Description:**
    Determines if the player has whitelist access for a faction.

---

### Parameters

    * faction (number) – Faction index.

---

### Returns

    * boolean – True if whitelisted.

---

**Realm:**
    Shared

---

## getClass

**Description:**
    Retrieves the class index of the player's character.

---

### Parameters

---

### Returns

    * number|nil – Class index or nil.

---

**Realm:**
    Shared

---

## hasClassWhitelist

**Description:**
    Checks if the player's character is whitelisted for a class.

---

### Parameters

    * class (number) – Class index.

---

### Returns

    * boolean – True if class whitelist exists.

---

**Realm:**
    Shared

---

## getClassData

**Description:**
    Returns the class table of the player's current class.

---

### Parameters

---

### Returns

    * table|nil – Class definition table.

---

**Realm:**
    Shared

---

## getDarkRPVar

**Description:**
    Compatibility helper for retrieving money with DarkRP-style calls.

---

### Parameters

    * var (string) – Currently only supports "money".

---

### Returns

    * number|nil – Money amount or nil.

---

**Realm:**
    Shared

---

## getMoney

**Description:**
    Convenience function to get the character's money amount.

---

### Parameters

---

### Returns

    * number – Current funds or 0.

---

**Realm:**
    Shared

---

## canAfford

**Description:**
    Checks if the player has enough money for a purchase.

---

### Parameters

    * amount (number) – Cost to test.

---

### Returns

    * boolean – True if funds are sufficient.

---

**Realm:**
    Shared

---

## hasSkillLevel

**Description:**
    Verifies the player's character meets an attribute level.

---

### Parameters

    * skill (string) – Attribute ID.
    * level (number) – Required level.

---

### Returns

    * boolean – Whether the character satisfies the requirement.

---

**Realm:**
    Shared

---

## meetsRequiredSkills

**Description:**
    Checks a table of skill requirements against the player.

---

### Parameters

    * requiredSkillLevels (table) – Mapping of attribute IDs to levels.

---

### Returns

    * boolean – True if all requirements are met.

---

**Realm:**
    Shared

---

## forceSequence

**Description:**
    Plays an animation sequence and optionally freezes the player.

---

### Parameters

    * sequenceName (string) – Sequence to play.
    * callback (function|nil) – Called when finished.
    * time (number|nil) – Duration override.
    * noFreeze (boolean) – Don't freeze movement when true.

---

### Returns

    * number|boolean – Duration or false on failure.

---

**Realm:**
    Shared

---

## leaveSequence

**Description:**
    Stops any forced sequence and restores player movement.

---

### Parameters

---

### Returns

---

**Realm:**
    Shared

---

## restoreStamina

**Description:**
    Increases the player's stamina value.

---

### Parameters

    * amount (number) – Amount to restore.

---

### Returns

---

**Realm:**
    Server

---

## consumeStamina

**Description:**
    Reduces the player's stamina value.

---

### Parameters

    * amount (number) – Amount to subtract.

---

### Returns

---

**Realm:**
    Server

---

## addMoney

**Description:**
    Adds funds to the player's character, clamping to limits.

---

### Parameters

    * amount (number) – Money to add.

---

### Returns

---

**Realm:**
    Server

---

## takeMoney

**Description:**
    Removes money from the player's character.

---

### Parameters

    * amount (number) – Amount to subtract.

---

### Returns

---

**Realm:**
    Server

---


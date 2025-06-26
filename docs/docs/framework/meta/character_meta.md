## tostring

**Description:**
    Returns a printable identifier for this character.

---

### Parameters

---

### Returns

    * string – Format "character[id]".

---

**Realm:**
    Shared

---

## eq

**Description:**
    Compares two characters by ID for equality.

---

### Parameters

    * other (Character) – Character to compare.

---

### Returns

    * boolean – True if both share the same ID.

---

**Realm:**
    Shared

---

## getID

**Description:**
    Returns the unique database ID for this character.

---

### Parameters

---

### Returns

    * number – Character identifier.

---

**Realm:**
    Shared

---

## getPlayer

**Description:**
    Returns the player entity currently controlling this character.

---

### Parameters

---

### Returns

    * Player|nil – Owning player or nil.

---

**Realm:**
    Shared

---

## getDisplayedName

**Description:**
    Returns the character's name as it should be shown to the given player.

---

### Parameters

    * client (Player) – Player requesting the name.

---

### Returns

    * string – Localized or recognized character name.

---

**Realm:**
    Shared

---

## hasMoney

**Description:**
    Checks if the character has at least the given amount of money.

---

### Parameters

    * amount (number) – Amount to check for.

---

### Returns

    * boolean – True if the character's funds are sufficient.

---

**Realm:**
    Shared

---

## getFlags

**Description:**
    Retrieves the string of permission flags for this character.

---

### Parameters

---

### Returns

    * string – Concatenated flag characters.

---

**Realm:**
    Shared

---

## hasFlags

**Description:**
    Checks if the character possesses any of the specified flags.

---

### Parameters

    * flags (string) – String of flag characters to check.

---

### Returns

    * boolean – True if at least one flag is present.

---

**Realm:**
    Shared

---

## getItemWeapon

**Description:**
    Checks the player's active weapon against items in the inventory.

---

### Parameters

    * requireEquip (boolean) – Only match equipped items if true.

---

### Returns

    * boolean – True if the active weapon corresponds to an item.

---

**Realm:**
    Shared

---

## getMaxStamina

**Description:**
    Returns the maximum stamina value for this character.

---

### Parameters

---

### Returns

    * number – Maximum stamina points.

---

**Realm:**
    Shared

---

## getStamina

**Description:**
    Retrieves the character's current stamina value.

---

### Parameters

---

### Returns

    * number – Current stamina.

---

**Realm:**
    Shared

---

## hasClassWhitelist

**Description:**
    Checks if the character has whitelisted the given class.

---

### Parameters

    * class (number) – Class index.

---

### Returns

    * boolean – True if the class is whitelisted.

---

**Realm:**
    Shared

---

## isFaction

**Description:**
    Returns true if the character's faction matches.

---

### Parameters

    * faction (number) – Faction index.

---

### Returns

    * boolean – Whether the faction matches.

---

**Realm:**
    Shared

---

## isClass

**Description:**
    Returns true if the character's class equals the specified class.

---

### Parameters

    * class (number) – Class index.

---

### Returns

    * boolean – Whether the classes match.

---

**Realm:**
    Shared

---

## getAttrib

**Description:**
    Retrieves the value of an attribute including boosts.

---

### Parameters

    * key (string) – Attribute identifier.
    * default (number) – Default value when attribute is missing.

---

### Returns

    * number – Final attribute value.

---

**Realm:**
    Shared

---

## getBoost

**Description:**
    Returns the boost table for the given attribute.

---

### Parameters

    * attribID (string) – Attribute identifier.

---

### Returns

    * table|nil – Table of boosts or nil.

---

**Realm:**
    Shared

---

## getBoosts

**Description:**
    Retrieves all attribute boosts for this character.

---

### Parameters

---

### Returns

    * table – Mapping of attribute IDs to boost tables.

---

**Realm:**
    Shared

---

## doesRecognize

**Description:**
    Determines if this character recognizes another character.

---

### Parameters

    * id (number|Character) – Character ID or object to check.

---

### Returns

    * boolean – True if recognized.

---

**Realm:**
    Shared

---

## doesFakeRecognize

**Description:**
    Checks if the character has a fake recognition entry for another.

---

### Parameters

    * id (number|Character) – Character identifier.

---

### Returns

    * boolean – True if fake recognized.

---

**Realm:**
    Shared

---


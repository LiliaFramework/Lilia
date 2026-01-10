# Character Meta

Character management system for the Lilia framework.

---

Overview

The character meta table provides comprehensive functionality for managing character data, attributes, and operations in the Lilia framework. It handles character creation, data persistence, attribute management, recognition systems, and character-specific operations. The meta table operates on both server and client sides, with the server managing character storage and validation while the client provides character data access and display. It includes integration with the database system for character persistence, inventory management for character items, and faction/class systems for character roles. The meta table ensures proper character data synchronization, attribute calculations with boosts, recognition between characters, and comprehensive character lifecycle management from creation to deletion.

---

### getID

#### 📋 Purpose
Returns this character's unique numeric identifier.

#### ⏰ When Called
Use when persisting, comparing, or networking character state.

#### ↩️ Returns
* number
Character ID.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local id = char:getID()

```

---

### getPlayer

#### 📋 Purpose
Retrieves the player entity associated with this character.

#### ⏰ When Called
Use whenever you need the live player controlling this character.

#### ↩️ Returns
* Player|nil
Player that owns the character, or nil if not found.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local ply = char:getPlayer()

```

---

### getDisplayedName

#### 📋 Purpose
Returns the name to show to a viewing client, honoring recognition rules.

#### ⏰ When Called
Use when rendering a character's name to another player.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The viewer whose recognition determines the name. |

#### ↩️ Returns
* string
Display name or a localized "unknown" placeholder.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local name = targetChar:getDisplayedName(viewer)

```

---

### hasMoney

#### 📋 Purpose
Checks if the character has at least the given amount of money.

#### ⏰ When Called
Use before charging a character to ensure they can afford a cost.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `amount` | **number** | The amount to verify. |

#### ↩️ Returns
* boolean
True if the character's balance is equal or higher.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if char:hasMoney(100) then purchase() end

```

---

### hasFlags

#### 📋 Purpose
Determines whether the character possesses any flag in the string.

#### ⏰ When Called
Use when gating actions behind one or more privilege flags.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `flagStr` | **string** | One or more flag characters to test. |

#### ↩️ Returns
* boolean
True if at least one provided flag is present.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if char:hasFlags("ab") then grantAccess() end

```

---

### getAttrib

#### 📋 Purpose
Gets the character's attribute value including any active boosts.

#### ⏰ When Called
Use when calculating rolls or stats that depend on attributes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Attribute identifier. |
| `default` | **number** | Fallback value if the attribute is missing. |

#### ↩️ Returns
* number
Attribute level plus stacked boosts.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local strength = char:getAttrib("str", 0)

```

---

### doesRecognize

#### 📋 Purpose
Determines whether this character recognizes another character.

#### ⏰ When Called
Use when deciding if a viewer should see a real name or remain unknown.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number|table** | Character ID or object implementing getID. |

#### ↩️ Returns
* boolean
True if recognition is allowed by hooks.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if viewerChar:doesRecognize(targetChar) then showName() end

```

---

### doesFakeRecognize

#### 📋 Purpose
Checks if the character recognizes another under a fake name.

#### ⏰ When Called
Use when evaluating disguise or alias recognition logic.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number|table** | Character ID or object implementing getID. |

#### ↩️ Returns
* boolean
True if fake recognition passes custom hooks.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local canFake = char:doesFakeRecognize(otherChar)

```

---

### setData

#### 📋 Purpose
Stores custom data on the character and optionally replicates it.

#### ⏰ When Called
Use when adding persistent or networked character metadata.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `k` | **string|table** | Key to set or table of key/value pairs. |
| `v` | **any** | Value to store when k is a string. |
| `noReplication` | **boolean** | Skip networking when true. |
| `receiver` | **Player|nil** | Specific client to receive the update instead of owner. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    char:setData("lastLogin", os.time())

```

---

### getData

#### 📋 Purpose
Retrieves previously stored custom character data.

#### ⏰ When Called
Use when you need saved custom fields or default fallbacks.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string|nil** | Specific key to fetch or nil for the whole table. |
| `default` | **any** | Value to return if the key is unset. |

#### ↩️ Returns
* any
Stored value, default, or entire data table.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local note = char:getData("note", "")

```

---

### isBanned

#### 📋 Purpose
Reports whether the character is currently banned.

#### ⏰ When Called
Use when validating character selection or spawning.

#### ↩️ Returns
* boolean
True if banned permanently or until a future time.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if char:isBanned() then denyJoin() end

```

---

### recognize

#### 📋 Purpose
Marks another character as recognized, optionally storing a fake name.

#### ⏰ When Called
Invoke when a player learns or is assigned recognition of someone.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `character` | **number|table** | Target character ID or object implementing getID. |
| `name` | **string|nil** | Optional alias to remember instead of real recognition. |

#### ↩️ Returns
* boolean
True after recognition is recorded.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:recognize(otherChar)

```

---

### joinClass

#### 📋 Purpose
Attempts to place the character into the specified class.

#### ⏰ When Called
Use during class selection or forced reassignment.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `class` | **number** | Class ID to join. |
| `isForced` | **boolean** | Skip eligibility checks when true. |

#### ↩️ Returns
* boolean
True if the class change succeeded.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local ok = char:joinClass(newClassID)

```

---

### kickClass

#### 📋 Purpose
Removes the character from its current class, falling back to default.

#### ⏰ When Called
Use when a class is invalid, revoked, or explicitly left.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:kickClass()

```

---

### updateAttrib

#### 📋 Purpose
Increases an attribute by the given amount, respecting maximums.

#### ⏰ When Called
Use when awarding experience toward an attribute.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Attribute identifier. |
| `value` | **number** | Amount to add. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:updateAttrib("stm", 5)

```

---

### setAttrib

#### 📋 Purpose
Directly sets an attribute to a specific value and syncs it.

#### ⏰ When Called
Use when loading characters or forcing an attribute level.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Attribute identifier. |
| `value` | **number** | New attribute level. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:setAttrib("str", 15)

```

---

### addBoost

#### 📋 Purpose
Adds a temporary boost to an attribute and propagates it.

#### ⏰ When Called
Use when buffs or debuffs modify an attribute value.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `boostID` | **string** | Unique identifier for the boost source. |
| `attribID` | **string** | Attribute being boosted. |
| `boostAmount` | **number** | Amount to add (can be negative). |

#### ↩️ Returns
* boolean
Result from setVar update.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:addBoost("stimpack", "end", 2)

```

---

### removeBoost

#### 📋 Purpose
Removes a previously applied attribute boost.

#### ⏰ When Called
Use when a buff expires or is cancelled.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `boostID` | **string** | Identifier of the boost source. |
| `attribID` | **string** | Attribute to adjust. |

#### ↩️ Returns
* boolean
Result from setVar update.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:removeBoost("stimpack", "end")

```

---

### clearAllBoosts

#### 📋 Purpose
Clears all attribute boosts and notifies listeners.

#### ⏰ When Called
Use when resetting a character's temporary modifiers.

#### ↩️ Returns
* boolean
Result from resetting the boost table.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:clearAllBoosts()

```

---

### setFlags

#### 📋 Purpose
Replaces the character's flag string and synchronizes it.

#### ⏰ When Called
Use when setting privileges wholesale (e.g., admin changes).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `flags` | **string** | Complete set of flags to apply. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:setFlags("abc")

```

---

### giveFlags

#### 📋 Purpose
Adds one or more flags to the character if they are missing.

#### ⏰ When Called
Use when granting new permissions or perks.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `flags` | **string** | Concatenated flag characters to grant. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:giveFlags("z")

```

---

### takeFlags

#### 📋 Purpose
Removes specific flags from the character and triggers callbacks.

#### ⏰ When Called
Use when revoking privileges or perks.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `flags` | **string** | Concatenated flag characters to remove. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:takeFlags("z")

```

---

### save

#### 📋 Purpose
Persists the character's current variables to the database.

#### ⏰ When Called
Use during saves, character switches, or shutdown to keep data.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `callback` | **function|nil** | Invoked after the save completes. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:save(function() print("saved") end)

```

---

### sync

#### 📋 Purpose
Sends character data to a specific player or all players.

#### ⏰ When Called
Use after character creation, load, or when vars change.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `receiver` | **Player|nil** | Target player to sync to; nil broadcasts to everyone. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:sync(client)

```

---

### setup

#### 📋 Purpose
Applies the character state to the owning player and optionally syncs.

#### ⏰ When Called
Use right after a character is loaded or swapped in.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `noNetworking` | **boolean** | Skip inventory and char networking when true. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:setup()

```

---

### kick

#### 📋 Purpose
Forces the owning player off this character and cleans up state.

#### ⏰ When Called
Use when removing access, kicking, or swapping characters.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:kick()

```

---

### ban

#### 📋 Purpose
Bans the character for a duration or permanently and kicks them.

#### ⏰ When Called
Use for disciplinary actions like permakill or timed bans.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `time` | **number|nil** | Ban duration in seconds; nil makes it permanent. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:ban(3600)

```

---

### delete

#### 📋 Purpose
Deletes the character from persistent storage.

#### ⏰ When Called
Use when a character is intentionally removed by the player or admin.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:delete()

```

---

### destroy

#### 📋 Purpose
Removes the character from the active cache without DB interaction.

#### ⏰ When Called
Use when unloading a character instance entirely.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:destroy()

```

---

### giveMoney

#### 📋 Purpose
Adds money to the character through the owning player object.

#### ⏰ When Called
Use when rewarding or refunding currency.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `amount` | **number** | Amount to add (can be negative to deduct). |

#### ↩️ Returns
* boolean
False if no valid player exists; otherwise result of addMoney.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:giveMoney(250)

```

---

### takeMoney

#### 📋 Purpose
Deducts money from the character and logs the transaction.

#### ⏰ When Called
Use when charging a player for purchases or penalties.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `amount` | **number** | Amount to remove; the absolute value is used. |

#### ↩️ Returns
* boolean
True after the deduction process runs.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    char:takeMoney(50)

```

---

### isMainCharacter

#### 📋 Purpose
Checks whether this character matches the player's main character ID.

#### ⏰ When Called
Use when showing main character indicators or restrictions.

#### ↩️ Returns
* boolean
True if this character is the player's main selection.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    if char:isMainCharacter() then highlight() end

```

---


# Hooks

Hooks provided by the Loyalism module for managing party tier system.

---

Overview

The Loyalism module adds a loyalty tier system for players, the /partytier command access, permission control through flags, automatic tier progression, and customizable rewards per tier.. It provides comprehensive hook integration for customizing managing party tier system and extending functionality.

---

### PartyTierApplying

#### 📋 Purpose
Called when a party tier is being applied to a player.

#### ⏰ When Called
During party tier update, before the tier is set on the character.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player receiving the tier |
| `tier` | **number** | The tier value being applied |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Loyalism module adds a loyalty tier system for players, the /partytier command access, permission control through flags, automatic tier progression, and customizable rewards per tier.. It provides comprehensive hook integration for customizing managing party tier system and extending functionality.

---

### PartyTierNoCharacter

#### 📋 Purpose
Called when a player has no character during party tier update.

#### ⏰ When Called
When attempting to update party tiers but the player has no character.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player without a character |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Loyalism module adds a loyalty tier system for players, the /partytier command access, permission control through flags, automatic tier progression, and customizable rewards per tier.. It provides comprehensive hook integration for customizing managing party tier system and extending functionality.

---

### PartyTierUpdated

#### 📋 Purpose
Called after a party tier has been updated on a player's character.

#### ⏰ When Called
After the tier value is set on the character.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player whose tier was updated |
| `tier` | **number** | The tier value that was set |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Loyalism module adds a loyalty tier system for players, the /partytier command access, permission control through flags, automatic tier progression, and customizable rewards per tier.. It provides comprehensive hook integration for customizing managing party tier system and extending functionality.

---

### PostUpdatePartyTiers

#### 📋 Purpose
Called after all party tiers have been updated.

#### ⏰ When Called
After all players have been processed in the update cycle.

#### ⚙️ Parameters
None

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Loyalism module adds a loyalty tier system for players, the /partytier command access, permission control through flags, automatic tier progression, and customizable rewards per tier.. It provides comprehensive hook integration for customizing managing party tier system and extending functionality.

---

### PreUpdatePartyTiers

#### 📋 Purpose
Called before party tiers are updated.

#### ⏰ When Called
At the start of the party tier update cycle.

#### ⚙️ Parameters
None

#### ↩️ Returns
nil

#### 🌐 Realm
Server



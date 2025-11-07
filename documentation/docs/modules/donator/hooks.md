# Hooks

Hooks provided by the Donator module for managing donator benefits and rewards.

---

Overview

The Donator module adds libraries to manage donor perks, tracking for donor ranks and perks, configurable perks by tier, and commands to adjust character slots.. It provides comprehensive hook integration for customizing managing donator benefits and rewards and extending functionality.

---

### DonatorAdditionalSlotsGiven

#### 📋 Purpose
Called when additional character slots are given to a player.

#### ⏰ When Called
After the additional slots are added to the player's account.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | **Player** | The player receiving additional slots |
| `addValue` | **number** | The number of additional slots being added |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Donator module adds libraries to manage donor perks, tracking for donor ranks and perks, configurable perks by tier, and commands to adjust character slots.. It provides comprehensive hook integration for customizing managing donator benefits and rewards and extending functionality.

---

### DonatorAdditionalSlotsSet

#### 📋 Purpose
Called when additional character slots are set for a player.

#### ⏰ When Called
After the additional slots value is set on the player.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | **Player** | The player whose slots are being set |
| `value` | **number** | The new total number of additional slots |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Donator module adds libraries to manage donor perks, tracking for donor ranks and perks, configurable perks by tier, and commands to adjust character slots.. It provides comprehensive hook integration for customizing managing donator benefits and rewards and extending functionality.

---

### DonatorFlagsGiven

#### 📋 Purpose
Called when donator flags are given to a player's character.

#### ⏰ When Called
After flags are granted to the character via console command.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | **Player** | The player receiving the flags |
| `flags` | **string** | The flags string being given |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Donator module adds libraries to manage donor perks, tracking for donor ranks and perks, configurable perks by tier, and commands to adjust character slots.. It provides comprehensive hook integration for customizing managing donator benefits and rewards and extending functionality.

---

### DonatorFlagsGranted

#### 📋 Purpose
Called when donator flags are automatically granted based on user group.

#### ⏰ When Called
When a character is loaded and the player's user group matches a donator group.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player receiving the flags |
| `group` | **string** | The donator group name |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Donator module adds libraries to manage donor perks, tracking for donor ranks and perks, configurable perks by tier, and commands to adjust character slots.. It provides comprehensive hook integration for customizing managing donator benefits and rewards and extending functionality.

---

### DonatorItemGiven

#### 📋 Purpose
Called when a donator item is given to a player.

#### ⏰ When Called
After an item is added to the player's inventory via console command.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | **Player** | The player receiving the item |
| `uniqueID` | **string** | The unique ID of the item being given |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Donator module adds libraries to manage donor perks, tracking for donor ranks and perks, configurable perks by tier, and commands to adjust character slots.. It provides comprehensive hook integration for customizing managing donator benefits and rewards and extending functionality.

---

### DonatorMoneyGiven

#### 📋 Purpose
Called when donator money is given to a player.

#### ⏰ When Called
After money is added to the character via console command.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | **Player** | The player receiving the money |
| `amount` | **number** | The amount of money being given |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Donator module adds libraries to manage donor perks, tracking for donor ranks and perks, configurable perks by tier, and commands to adjust character slots.. It provides comprehensive hook integration for customizing managing donator benefits and rewards and extending functionality.

---

### DonatorSlotsAdded

#### 📋 Purpose
Called when override character slots are added to a player.

#### ⏰ When Called
After the override slots count is increased.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | **Player** | The player receiving slots |
| `current` | **number** | The new current total of override slots |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Donator module adds libraries to manage donor perks, tracking for donor ranks and perks, configurable perks by tier, and commands to adjust character slots.. It provides comprehensive hook integration for customizing managing donator benefits and rewards and extending functionality.

---

### DonatorSlotsSet

#### 📋 Purpose
Called when override character slots are set for a player.

#### ⏰ When Called
After the override slots value is set.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | **Player** | The player whose slots are being set |
| `value` | **number** | The new override slots value |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Donator module adds libraries to manage donor perks, tracking for donor ranks and perks, configurable perks by tier, and commands to adjust character slots.. It provides comprehensive hook integration for customizing managing donator benefits and rewards and extending functionality.

---

### DonatorSlotsSubtracted

#### 📋 Purpose
Called when override character slots are subtracted from a player.

#### ⏰ When Called
After the override slots count is decreased.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | **Player** | The player losing slots |
| `current` | **number** | The new current total of override slots |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Donator module adds libraries to manage donor perks, tracking for donor ranks and perks, configurable perks by tier, and commands to adjust character slots.. It provides comprehensive hook integration for customizing managing donator benefits and rewards and extending functionality.

---

### DonatorSpawn

#### 📋 Purpose
Called when a donator player spawns with override character slots.

#### ⏰ When Called
When a player spawns and has override slots configured.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The donator player spawning |
| `currentSlots` | **number** | The current number of override slots |

#### ↩️ Returns
nil

#### 🌐 Realm
Server



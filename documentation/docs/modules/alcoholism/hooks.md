# Hooks

Hooks provided by the Alcoholism module for managing blood alcohol content (BAC) and alcohol consumption effects.

---

Overview

The Alcoholism module implements a comprehensive intoxication system where players can consume alcoholic beverages that progressively increase their Blood Alcohol Content (BAC). As BAC rises, players experience visual impairments like screen blurring, movement slowdown, and other debilitating effects. The system includes BAC thresholds for different intoxication levels, automatic metabolism over time, and extensive hook integration for customizing alcohol effects, consumption mechanics, and sobriety recovery processes.

---

### AlcoholConsumed

#### 📋 Purpose
Called when a player consumes an alcohol item.

#### ⏰ When Called
After a player successfully drinks an alcohol item and their BAC has been increased.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who consumed the alcohol |
| `item` | **Item** | The alcohol item that was consumed |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

---

### BACChanged

#### 📋 Purpose
Called whenever a player's blood alcohol content (BAC) value changes.

#### ⏰ When Called
After the BAC value has been updated on the server, whether it increased or decreased.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose BAC changed |
| `newBac` | **number** | The new BAC value (0-100) |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

---

### BACIncreased

#### 📋 Purpose
Called when a player's BAC value increases.

#### ⏰ When Called
After BAC has been increased but before BACChanged is called.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose BAC increased |
| `oldBac` | **number** | The previous BAC value |
| `newBac` | **number** | The new BAC value |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

---

### BACReset

#### 📋 Purpose
Called when a player's BAC is reset to zero.

#### ⏰ When Called
After BAC has been reset, typically when a character is loaded or respawns.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose BAC was reset |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

---

### BACThresholdReached

#### 📋 Purpose
Called when a player's BAC reaches a specific threshold level.

#### ⏰ When Called
When BAC crosses a defined threshold value (e.g., 30%, 50%, 80%).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who reached the threshold |
| `bac` | **number** | The current BAC value |
| `threshold` | **number** | The threshold that was reached |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

---

### PostBACDecrease

#### 📋 Purpose
Called after a player's BAC has been decreased during the degradation cycle.

#### ⏰ When Called
After BAC degradation has been processed and the new value has been set.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose BAC decreased |
| `newBac` | **number** | The new BAC value after decrease |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

---

### PostBACReset

#### 📋 Purpose
Called after a player's BAC has been reset to zero.

#### ⏰ When Called
After BAC reset has been completed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose BAC was reset |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

---

### PreBACDecrease

#### 📋 Purpose
Called before a player's BAC is decreased during the degradation cycle.

#### ⏰ When Called
Before BAC degradation is processed, allowing modification of the decrease rate.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose BAC will decrease |
| `bac` | **number** | The current BAC value before decrease |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

---

### PreBACIncrease

#### 📋 Purpose
Called before a player's BAC is increased from consuming alcohol.

#### ⏰ When Called
Before BAC increase is processed, allowing modification of the increase amount.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose BAC will increase |
| `item` | **Item** | The alcohol item being consumed |
| `amount` | **number** | The amount of BAC to add |

#### ↩️ Returns
nil  or **number** - Return a modified amount to override the increase

#### 🌐 Realm
Server

---

### PreBACReset

#### 📋 Purpose
Called before a player's BAC is reset to zero.

#### ⏰ When Called
Before BAC reset is processed, allowing cancellation of the reset.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose BAC will be reset |

#### ↩️ Returns
nil  or **boolean** - Return false to prevent reset

#### 🌐 Realm
Server


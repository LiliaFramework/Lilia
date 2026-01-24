# Hooks

Hooks provided by the Slots module for managing slot machine gameplay.

---

Overview

The Slots module adds a slot machine minigame, a workshop model for the machine, handling of payouts to winners, customizable payout odds, and sound and animation effects.. It provides comprehensive hook integration for customizing managing slot machine gameplay and extending functionality.

---

### SlotMachineEnd

#### 📋 Purpose
Called when a slot machine spin ends.

#### ⏰ When Called
After the wheels stop and payout is determined.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `machine` | **Entity** | The slot machine entity |
| `client` | **Player** | The player who used the machine |
| `payout` | **number** | The payout amount (0 if no win) |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Slots module adds a slot machine minigame, a workshop model for the machine, handling of payouts to winners, customizable payout odds, and sound and animation effects.. It provides comprehensive hook integration for customizing managing slot machine gameplay and extending functionality.

---

### SlotMachinePayout

#### 📋 Purpose
Called when a slot machine pays out.

#### ⏰ When Called
When the player wins and receives money.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `machine` | **Entity** | The slot machine entity |
| `client` | **Player** | The player who won |
| `payout` | **number** | The payout amount |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Slots module adds a slot machine minigame, a workshop model for the machine, handling of payouts to winners, customizable payout odds, and sound and animation effects.. It provides comprehensive hook integration for customizing managing slot machine gameplay and extending functionality.

---

### SlotMachineStart

#### 📋 Purpose
Called when a slot machine spin starts.

#### ⏰ When Called
When the wheels begin spinning.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `machine` | **Entity** | The slot machine entity |
| `client` | **Player** | The player who started the spin |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Slots module adds a slot machine minigame, a workshop model for the machine, handling of payouts to winners, customizable payout odds, and sound and animation effects.. It provides comprehensive hook integration for customizing managing slot machine gameplay and extending functionality.

---

### SlotMachineUse

#### 📋 Purpose
Called when a player uses a slot machine.

#### ⏰ When Called
When the use function is called, before checking money.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `machine` | **Entity** | The slot machine entity |
| `client` | **Player** | The player using the machine |

#### ↩️ Returns
nil

#### 🌐 Realm
Server



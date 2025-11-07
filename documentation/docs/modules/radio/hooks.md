# Hooks

Hooks provided by the Radio module for managing radio communication.

---

Overview

The Radio module adds a radio chat channel for players, font configuration via radiofont, workshop models for radios, frequency channels for groups, and handheld radio items.. It provides comprehensive hook integration for customizing managing radio communication and extending functionality.

---

### CanHearRadio

#### 📋 Purpose
Called to determine if a listener can hear a radio transmission.

#### ⏰ When Called
During radio chat range checking.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `listener` | **Player** | The player trying to hear the transmission |
| `speaker` | **Player** | The player transmitting |
| `freq` | **string** | The radio frequency |
| `channel` | **number** | The radio channel |

#### ↩️ Returns
*boolean* - Return false to prevent hearing

#### 🌐 Realm
Shared

---

Overview

The Radio module adds a radio chat channel for players, font configuration via radiofont, workshop models for radios, frequency channels for groups, and handheld radio items.. It provides comprehensive hook integration for customizing managing radio communication and extending functionality.

---

### CanUseRadio

#### 📋 Purpose
Called to determine if a player can use their radio.

#### ⏰ When Called
Before a player starts transmitting on radio.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `speaker` | **Player** | The player attempting to use radio |
| `freq` | **string** | The radio frequency |
| `channel` | **number** | The radio channel |

#### ↩️ Returns
*boolean* - Return false to prevent radio use

#### 🌐 Realm
Shared

---

Overview

The Radio module adds a radio chat channel for players, font configuration via radiofont, workshop models for radios, frequency channels for groups, and handheld radio items.. It provides comprehensive hook integration for customizing managing radio communication and extending functionality.

---

### OnRadioDisabled

#### 📋 Purpose
Called when a radio is disabled/turned off.

#### ⏰ When Called
After the radio's enabled state is set to false.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who disabled the radio |
| `item` | **Item** | The radio item that was disabled |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Radio module adds a radio chat channel for players, font configuration via radiofont, workshop models for radios, frequency channels for groups, and handheld radio items.. It provides comprehensive hook integration for customizing managing radio communication and extending functionality.

---

### OnRadioEnabled

#### 📋 Purpose
Called when a radio is enabled/turned on.

#### ⏰ When Called
After the radio's enabled state is set to true.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who enabled the radio |
| `item` | **Item** | The radio item that was enabled |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Radio module adds a radio chat channel for players, font configuration via radiofont, workshop models for radios, frequency channels for groups, and handheld radio items.. It provides comprehensive hook integration for customizing managing radio communication and extending functionality.

---

### OnRadioFrequencyChanged

#### 📋 Purpose
Called when a radio's frequency is changed.

#### ⏰ When Called
After the frequency is updated on the radio item.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who changed the frequency |
| `item` | **Item** | The radio item |
| `freq` | **string** | The new frequency |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Radio module adds a radio chat channel for players, font configuration via radiofont, workshop models for radios, frequency channels for groups, and handheld radio items.. It provides comprehensive hook integration for customizing managing radio communication and extending functionality.

---

### OnRadioSabotaged

#### 📋 Purpose
Called when a radio is sabotaged/broken.

#### ⏰ When Called
After the radio is broken and removed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who sabotaged the radio |
| `item` | **Item** | The radio item that was sabotaged |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Radio module adds a radio chat channel for players, font configuration via radiofont, workshop models for radios, frequency channels for groups, and handheld radio items.. It provides comprehensive hook integration for customizing managing radio communication and extending functionality.

---

### PlayerFinishRadio

#### 📋 Purpose
Called when a player finishes using radio.

#### ⏰ When Called
After radio transmission ends.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `listener` | **Player** | The player who finished radio use |
| `freq` | **string** | The frequency that was used |
| `channel` | **number** | The channel that was used |

#### ↩️ Returns
nil

#### 🌐 Realm
Shared

---

Overview

The Radio module adds a radio chat channel for players, font configuration via radiofont, workshop models for radios, frequency channels for groups, and handheld radio items.. It provides comprehensive hook integration for customizing managing radio communication and extending functionality.

---

### PlayerStartRadio

#### 📋 Purpose
Called when a player starts using radio.

#### ⏰ When Called
When a player begins transmitting on radio.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `speaker` | **Player** | The player starting radio transmission |
| `freq` | **string** | The frequency being used |
| `channel` | **number** | The channel being used |

#### ↩️ Returns
nil

#### 🌐 Realm
Shared

---

Overview

The Radio module adds a radio chat channel for players, font configuration via radiofont, workshop models for radios, frequency channels for groups, and handheld radio items.. It provides comprehensive hook integration for customizing managing radio communication and extending functionality.

---

### ShouldRadioBeep

#### 📋 Purpose
Called to determine if radio beep sounds should play.

#### ⏰ When Called
When checking if radio end sounds should play.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `listener` | **Player** | The player who would hear the beep |

#### ↩️ Returns
*boolean* - Return false to prevent beep

#### 🌐 Realm
Shared



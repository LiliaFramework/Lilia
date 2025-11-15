# Hooks

Hooks provided by the Bodygrouper module for managing player bodygroups and skins.

---

Overview

The Body Grouper module provides an interactive bodygroup editing system that allows players to customize their character models through a dedicated closet interface. It includes administrative controls for inspecting other players' bodygroups, configurable closet models, and comprehensive hook integration for managing bodygroup changes, validation, and synchronization across the server.

---

### BodygrouperApplyAttempt

#### 📋 Purpose
Called when a player attempts to apply bodygroup and skin changes.

#### ⏰ When Called
When the server receives a bodygroup change request, before validation.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player attempting to apply changes |
| `target` | **Player** | The target player whose bodygroups will be changed |
| `skin` | **number** | The skin index to apply |
| `groups` | **table** | Table of bodygroup indices and values to apply |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### BodygrouperClosetAddUser

#### 📋 Purpose
Called when a player is added to a bodygroup closet entity.

#### ⏰ When Called
When a player enters/uses a bodygroup closet entity.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `closet` | **Entity** | The bodygroup closet entity |
| `user` | **Player** | The player being added to the closet |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### BodygrouperClosetClosed

#### 📋 Purpose
Called when a bodygroup closet is closed (last user removed).

#### ⏰ When Called
When the last user is removed from the closet.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `closet` | **Entity** | The bodygroup closet entity that was closed |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### BodygrouperClosetOpened

#### 📋 Purpose
Called when a bodygroup closet is opened (first user added).

#### ⏰ When Called
When the first user enters the closet.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `closet` | **Entity** | The bodygroup closet entity that was opened |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### BodygrouperClosetRemoveUser

#### 📋 Purpose
Called when a player is removed from a bodygroup closet entity.

#### ⏰ When Called
When a player leaves/ends use of a bodygroup closet entity.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `closet` | **Entity** | The bodygroup closet entity |
| `user` | **Player** | The player being removed from the closet |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### BodygrouperInvalidGroup

#### 📋 Purpose
Called when an invalid bodygroup value is detected during validation.

#### ⏰ When Called
When a bodygroup value exceeds the maximum allowed for that bodygroup.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who attempted the change |
| `target` | **Player** | The target player |
| `bodygroupIndex` | **number** | The invalid bodygroup index |
| `value` | **number** | The invalid value that was attempted |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### BodygrouperInvalidSkin

#### 📋 Purpose
Called when an invalid skin value is detected during validation.

#### ⏰ When Called
When a skin index exceeds the maximum allowed skins for the model.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who attempted the change |
| `target` | **Player** | The target player |
| `skin` | **number** | The invalid skin index |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### BodygrouperMenuClosed

#### 📋 Purpose
Called when the bodygrouper menu is closed on the client.

#### ⏰ When Called
When the menu panel is removed on the client.

#### ⚙️ Parameters
None

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

### BodygrouperMenuClosedServer

#### 📋 Purpose
Called when the bodygrouper menu is closed on the server.

#### ⏰ When Called
When the server receives the menu close network message.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who closed the menu |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### BodygrouperMenuOpened

#### 📋 Purpose
Called when the bodygrouper menu is opened on the client.

#### ⏰ When Called
When the menu panel is created and displayed on the client.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `menu` | **Panel** | The bodygrouper menu panel |
| `target` | **Player** | The target player whose bodygroups are being edited |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

### BodygrouperValidated

#### 📋 Purpose
Called when bodygroup changes have passed validation.

#### ⏰ When Called
After all validation checks pass, before applying changes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player applying changes |
| `target` | **Player** | The target player |
| `skin` | **number** | The validated skin index |
| `groups` | **table** | The validated bodygroup table |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### PostBodygroupApply

#### 📋 Purpose
Called after bodygroup changes have been applied to the character.

#### ⏰ When Called
After the skin and bodygroups are set on both the player and character.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who applied changes |
| `target` | **Player** | The target player |
| `skin` | **number** | The skin that was applied |
| `groups` | **table** | The bodygroups that were applied |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### PreBodygroupApply

#### 📋 Purpose
Called before bodygroup changes are applied to the character.

#### ⏰ When Called
After validation passes, before setting the skin and bodygroups.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player applying changes |
| `target` | **Player** | The target player |
| `skin` | **number** | The skin to be applied |
| `groups` | **table** | The bodygroups to be applied |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### PreBodygrouperMenuOpen

#### 📋 Purpose
Called before the bodygrouper menu is opened.

#### ⏰ When Called
When the viewBodygroups command is executed, before sending the menu to the client.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player opening the menu |
| `target` | **Player** | The target player whose bodygroups will be edited |

#### ↩️ Returns
nil

#### 🌐 Realm
Server


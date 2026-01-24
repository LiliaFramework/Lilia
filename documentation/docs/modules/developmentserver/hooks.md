# Hooks

Hooks provided by the Development Server module for managing development server access.

---

Overview

The Development Server module adds a development server mode for testing, the ability to run special development functions, a toggle via configuration, an environment flag for dev commands, and logging of executed dev actions.. It provides comprehensive hook integration for customizing managing development server access and extending functionality.

---

### DevServerAuthorized

#### 📋 Purpose
Called when a player is authorized to join the development server.

#### ⏰ When Called
During password check when the player's SteamID64 is in the authorized developers list.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `steamid64` | **string** | The SteamID64 of the authorized player |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Development Server module adds a development server mode for testing, the ability to run special development functions, a toggle via configuration, an environment flag for dev commands, and logging of executed dev actions.. It provides comprehensive hook integration for customizing managing development server access and extending functionality.

---

### DevServerModeActivated

#### 📋 Purpose
Called when development server mode is activated.

#### ⏰ When Called
When the module initializes and the DevServer config is set to true.

#### ⚙️ Parameters
None

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Development Server module adds a development server mode for testing, the ability to run special development functions, a toggle via configuration, an environment flag for dev commands, and logging of executed dev actions.. It provides comprehensive hook integration for customizing managing development server access and extending functionality.

---

### DevServerModeDeactivated

#### 📋 Purpose
Called when development server mode is deactivated.

#### ⏰ When Called
When the module initializes and the DevServer config is set to false.

#### ⚙️ Parameters
None

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Development Server module adds a development server mode for testing, the ability to run special development functions, a toggle via configuration, an environment flag for dev commands, and logging of executed dev actions.. It provides comprehensive hook integration for customizing managing development server access and extending functionality.

---

### DevServerUnauthorized

#### 📋 Purpose
Called when a player attempts to join but is not authorized for the development server.

#### ⏰ When Called
During password check when the player's SteamID64 is not in the authorized developers list and DevServer is enabled.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `steamid64` | **string** | The SteamID64 of the unauthorized player |

#### ↩️ Returns
nil

#### 🌐 Realm
Server



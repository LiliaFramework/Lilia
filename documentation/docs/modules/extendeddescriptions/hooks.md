# Hooks

Hooks provided by the Extended Descriptions module for managing detailed character descriptions.

---

Overview

The Extended Descriptions module adds support for long item descriptions, localization for multiple languages, better rp text display, automatic line wrapping, and fallback to short descriptions.. It provides comprehensive hook integration for customizing managing detailed character descriptions and extending functionality.

---

### ExtendedDescriptionClosed

#### 📋 Purpose
Called when the extended description viewing panel is closed.

#### ⏰ When Called
When the description frame is removed on the client.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player whose description was being viewed |
| `descText` | **string** | The description text that was displayed |
| `descURL` | **string** | The description image URL that was displayed |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The Extended Descriptions module adds support for long item descriptions, localization for multiple languages, better rp text display, automatic line wrapping, and fallback to short descriptions.. It provides comprehensive hook integration for customizing managing detailed character descriptions and extending functionality.

---

### ExtendedDescriptionEditClosed

#### 📋 Purpose
Called when the extended description edit panel is closed.

#### ⏰ When Called
When the edit frame is removed on the client.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `steamName` | **string** | The Steam name of the player editing the description |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The Extended Descriptions module adds support for long item descriptions, localization for multiple languages, better rp text display, automatic line wrapping, and fallback to short descriptions.. It provides comprehensive hook integration for customizing managing detailed character descriptions and extending functionality.

---

### ExtendedDescriptionEditOpened

#### 📋 Purpose
Called when the extended description edit panel is opened.

#### ⏰ When Called
When the edit frame is created and displayed on the client.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `frame` | **Panel** | The edit frame panel |
| `steamName` | **string** | The Steam name of the player editing |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The Extended Descriptions module adds support for long item descriptions, localization for multiple languages, better rp text display, automatic line wrapping, and fallback to short descriptions.. It provides comprehensive hook integration for customizing managing detailed character descriptions and extending functionality.

---

### ExtendedDescriptionEditSubmitted

#### 📋 Purpose
Called when an extended description edit is submitted.

#### ⏰ When Called
When the player clicks the submit button to save changes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `steamName` | **string** | The Steam name of the player submitting |
| `url` | **string** | The image URL entered |
| `text` | **string** | The description text entered |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The Extended Descriptions module adds support for long item descriptions, localization for multiple languages, better rp text display, automatic line wrapping, and fallback to short descriptions.. It provides comprehensive hook integration for customizing managing detailed character descriptions and extending functionality.

---

### ExtendedDescriptionOpened

#### 📋 Purpose
Called when the extended description viewing panel is opened.

#### ⏰ When Called
When the description frame is created and displayed on the client.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player whose description is being viewed |
| `frame` | **Panel** | The description frame panel |
| `descText` | **string** | The description text being displayed |
| `descURL` | **string** | The description image URL being displayed |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The Extended Descriptions module adds support for long item descriptions, localization for multiple languages, better rp text display, automatic line wrapping, and fallback to short descriptions.. It provides comprehensive hook integration for customizing managing detailed character descriptions and extending functionality.

---

### ExtendedDescriptionUpdated

#### 📋 Purpose
Called after an extended description has been updated on the server.

#### ⏰ When Called
After the character's description data is saved.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose description was updated |
| `url` | **string** | The new image URL |
| `text` | **string** | The new description text |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Extended Descriptions module adds support for long item descriptions, localization for multiple languages, better rp text display, automatic line wrapping, and fallback to short descriptions.. It provides comprehensive hook integration for customizing managing detailed character descriptions and extending functionality.

---

### PreExtendedDescriptionUpdate

#### 📋 Purpose
Called before an extended description is updated on the server.

#### ⏰ When Called
Before the character's description data is saved.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose description is being updated |
| `url` | **string** | The new image URL to be set |
| `text` | **string** | The new description text to be set |

#### ↩️ Returns
nil

#### 🌐 Realm
Server



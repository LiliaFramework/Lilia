# Hooks

Hooks provided by the Word Filter module for managing word filtering in chat.

---

Overview

The Word Filter module adds chat word filtering, blocking of banned phrases, an easy-to-extend list, and admin commands to modify the list.. It provides comprehensive hook integration for customizing managing word filtering in chat and extending functionality.

---

### FilterCheckFailed

#### 📋 Purpose
Called when a word filter check fails (filtered word found).

#### ⏰ When Called
After a filtered word is detected in the message.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player who used the filtered word |
| `text` | **string** | The message text |
| `bad` | **string** | The filtered word that was found |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Word Filter module adds chat word filtering, blocking of banned phrases, an easy-to-extend list, and admin commands to modify the list.. It provides comprehensive hook integration for customizing managing word filtering in chat and extending functionality.

---

### FilterCheckPassed

#### 📋 Purpose
Called when a word filter check passes (no filtered words found).

#### ⏰ When Called
After all words are checked and none match the filter.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player whose message passed |
| `text` | **string** | The message text |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Word Filter module adds chat word filtering, blocking of banned phrases, an easy-to-extend list, and admin commands to modify the list.. It provides comprehensive hook integration for customizing managing word filtering in chat and extending functionality.

---

### FilteredWordUsed

#### 📋 Purpose
Called when a filtered word is detected in a message.

#### ⏰ When Called
When a word in the blacklist is found in the message.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player who used the filtered word |
| `bad` | **string** | The filtered word that was found |
| `text` | **string** | The message text |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Word Filter module adds chat word filtering, blocking of banned phrases, an easy-to-extend list, and admin commands to modify the list.. It provides comprehensive hook integration for customizing managing word filtering in chat and extending functionality.

---

### PostFilterCheck

#### 📋 Purpose
Called after the filter check completes.

#### ⏰ When Called
After all filtering is done, regardless of result.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player whose message was checked |
| `text` | **string** | The message text |
| `passed` | **boolean** | Whether the check passed (true) or failed (false) |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Word Filter module adds chat word filtering, blocking of banned phrases, an easy-to-extend list, and admin commands to modify the list.. It provides comprehensive hook integration for customizing managing word filtering in chat and extending functionality.

---

### PreFilterCheck

#### 📋 Purpose
Called before the filter check begins.

#### ⏰ When Called
When a player sends a message, before word filtering.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player sending the message |
| `text` | **string** | The message text to be checked |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Word Filter module adds chat word filtering, blocking of banned phrases, an easy-to-extend list, and admin commands to modify the list.. It provides comprehensive hook integration for customizing managing word filtering in chat and extending functionality.

---

### WordAddedToFilter

#### 📋 Purpose
Called when a word is added to the filter blacklist.

#### ⏰ When Called
After a word is added and saved to the blacklist.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `word` | **string** | The word that was added to the filter |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Word Filter module adds chat word filtering, blocking of banned phrases, an easy-to-extend list, and admin commands to modify the list.. It provides comprehensive hook integration for customizing managing word filtering in chat and extending functionality.

---

### WordRemovedFromFilter

#### 📋 Purpose
Called when a word is removed from the filter blacklist.

#### ⏰ When Called
After a word is removed and saved from the blacklist.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `word` | **string** | The word that was removed from the filter |

#### ↩️ Returns
nil

#### 🌐 Realm
Server



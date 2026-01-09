# Logger Library

Comprehensive logging and audit trail system for the Lilia framework.

---

Overview

The logger library provides comprehensive logging functionality for the Lilia framework, enabling detailed tracking and recording of player actions, administrative activities, and system events. It operates on the server side and automatically categorizes log entries into predefined categories such as character management, combat, world interactions, chat communications, item transactions, administrative actions, and security events. The library stores all log entries in a database table with timestamps, player information, and categorized messages. It supports dynamic log type registration and provides hooks for external systems to process log events. The logger ensures accountability and provides administrators with detailed audit trails for server management and moderation.

---

### lia.log.addType

#### 📋 Purpose
Register a new log type with formatter and category.

#### ⏰ When Called
During init to add custom audit events (e.g., quests, crafting).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `logType` | **string** | Unique log key. |
| `func` | **function** | Formatter function (client, ... ) -> string. |
| `category` | **string** | Category label used in console output and DB. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.log.addType("questComplete", function(client, questID, reward)
        return L("logQuestComplete", client:Name(), questID, reward)
    end, L("quests"))

```

---

### lia.log.getString

#### 📋 Purpose
Build a formatted log string and return its category.

#### ⏰ When Called
Internally by lia.log.add before printing/persisting logs.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** |  |
| `logType` | **string** | ... (vararg) |

#### ↩️ Returns
* string|nil, string|nil
logString, category

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local text, category = lia.log.getString(ply, "playerDeath", attackerName)
    if text then print(category, text) end

```

---

### lia.log.add

#### 📋 Purpose
Create and store a log entry (console + database) using a logType.

#### ⏰ When Called
Anywhere you need to audit player/admin/system actions.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** |  |
| `logType` | **string** | ... (vararg) |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.log.add(client, "itemTake", itemName)
    lia.log.add(nil, "frameworkOutdated") -- system log without player

```

---


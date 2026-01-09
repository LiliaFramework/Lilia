# Chatbox Library

Comprehensive chat system management with message routing and formatting for the Lilia framework.

---

Overview

The chatbox library provides comprehensive functionality for managing chat systems in the Lilia framework. It handles registration of different chat types (IC, OOC, whisper, etc.), message parsing and routing, distance-based hearing mechanics, and chat formatting. The library operates on both server and client sides, with the server managing message distribution and validation, while the client handles parsing and display formatting. It includes support for anonymous messaging, custom prefixes, radius-based communication, and integration with the command system for chat-based commands.

---

### lia.chat.timestamp

#### 📋 Purpose
Prepend a timestamp to chat messages based on option settings.

#### ⏰ When Called
During chat display formatting (client) to show the time.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ooc` | **boolean** | Whether the chat is OOC (affects spacing). |

#### ↩️ Returns
* string
Timestamp text or empty string.

#### 🌐 Realm
Shared (used clientside)

#### 💡 Example Usage

```lua
    chat.AddText(lia.chat.timestamp(false), Color(255,255,255), message)

```

---

### lia.chat.register

#### 📋 Purpose
Register a chat class (IC/OOC/whisper/custom) with prefixes and rules.

#### ⏰ When Called
On initialization to add new chat types and bind aliases/commands.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `chatType` | **string** |  |
| `data` | **table** | Fields: prefix, radius/onCanHear, onCanSay, format, color, arguments, etc. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared (prefix commands created clientside)

#### 💡 Example Usage

```lua
    lia.chat.register("yell", {
        prefix = {"/y", "/yell"},
        radius = 600,
        format = "chatYellFormat",
        arguments = {{name = "message", type = "string"}},
        onChatAdd = function(speaker, text) chat.AddText(Color(255,200,120), "[Y] ", speaker:Name(), ": ", text) end
    })

```

---

### lia.chat.parse

#### 📋 Purpose
Parse a raw chat message to determine chat type, strip prefixes, and send.

#### ⏰ When Called
On client (local send) and server (routing) before dispatching chat.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** |  |
| `message` | **string** |  |
| `noSend` | **boolean|nil** | If true, do not forward to recipients (client-side parsing only). |

#### ↩️ Returns
* string, string, boolean
chatType, message, anonymous

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- client
    lia.chat.parse(LocalPlayer(), "/y Hello there!")
    -- server hook
    hook.Add("PlayerSay", "LiliaChatParse", function(ply, txt)
        if lia.chat.parse(ply, txt) then return "" end
    end)

```

---

### lia.chat.send

#### 📋 Purpose
Send a chat message to eligible listeners, honoring canHear/canSay rules.

#### ⏰ When Called
Server-side after parsing chat or programmatic chat generation.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `speaker` | **Player** |  |
| `chatType` | **string** |  |
| `text` | **string** |  |
| `anonymous` | **boolean** |  |
| `receivers` | **table|nil** | Optional explicit receiver list. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.chat.send(ply, "ic", "Hello world", false)

```

---


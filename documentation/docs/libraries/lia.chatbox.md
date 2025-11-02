# Chatbox Library

Comprehensive chat system management with message routing and formatting for the Lilia framework.

---

Overview

The chatbox library provides comprehensive functionality for managing chat systems in the Lilia framework. It handles registration of different chat types (IC, OOC, whisper, etc.), message parsing and routing, distance-based hearing mechanics, and chat formatting. The library operates on both server and client sides, with the server managing message distribution and validation, while the client handles parsing and display formatting. It includes support for anonymous messaging, custom prefixes, radius-based communication, and integration with the command system for chat-based commands.

---

### timestamp

**Purpose**

Generates a formatted timestamp string for chat messages based on current time

**When Called**

Automatically called when displaying chat messages if timestamps are enabled

**Parameters**

* `ooc` (*boolean*): Whether this is an OOC message (affects spacing format)

**Returns**

* string - Formatted timestamp string or empty string if timestamps disabled

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get timestamp for IC message
local timestamp = lia.chat.timestamp(false)
-- Returns: " (14:30) " or "" if timestamps disabled

```

**Medium Complexity:**
```lua
-- Medium: Use timestamp in custom chat format
local function customChatFormat(speaker, text)
    local timeStr = lia.chat.timestamp(false)
    chat.AddText(timeStr, Color(255, 255, 255), speaker:Name() .. ": " .. text)
end

```

**High Complexity:**
```lua
-- High: Dynamic timestamp with custom formatting
local function getFormattedTimestamp(isOOC, customFormat)
    local baseTime = lia.chat.timestamp(isOOC)
    if customFormat and baseTime ~= "" then
        return baseTime:gsub("%((%d+:%d+)%)", "[" .. customFormat .. "]")
    end
    return baseTime
end

```

---

### register

**Purpose**

Registers a new chat type with the chatbox system, defining its behavior and properties

**When Called**

During module initialization to register custom chat types (IC, OOC, whisper, etc.)

**Parameters**

* `chatType` (*string*): Unique identifier for the chat type
* `data` (*table*): Configuration table containing chat type properties

**Returns**

* void

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Register basic IC chat
lia.chat.register("ic", {
    prefix = "/",
    color  = Color(255, 255, 255),
    radius = 200
})

```

**Medium Complexity:**
```lua
-- Medium: Register whisper chat with custom properties
lia.chat.register("whisper", {
    prefix = {"/w", "/whisper"},
    color  = Color(150, 150, 255),
    radius = 50,
    format = "whisperFormat",
    desc   = "Whisper to nearby players"
})

```

**High Complexity:**
```lua
-- High: Register admin chat with complex validation
lia.chat.register("admin", {
    prefix    = "/a",
    color     = Color(255, 100, 100),
    onCanSay  = function(speaker)
        return speaker:IsAdmin()
    end,
    onCanHear = function(speaker, listener)
        return listener:IsAdmin()
    end,
    format    = "adminFormat",
    arguments = {
        {type = "string", name = "message"}
    },
    desc      = "Admin-only communication channel"
})

```

---

### parse

**Purpose**

Parses a chat message to determine its type and extract the actual message content

**When Called**

When a player sends a chat message, either from client input or server processing

**Parameters**

* `client` (*Player*): The player who sent the message
* `message` (*string*): The raw message text to parse
* `noSend` (*boolean, optional*): If true, prevents sending the message to other players

**Returns**

* chatType (string), message (string), anonymous (boolean)

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Parse a basic IC message
local chatType, message, anonymous = lia.chat.parse(LocalPlayer(), "Hello everyone!")
-- Returns: "ic", "Hello everyone!", false

```

**Medium Complexity:**
```lua
-- Medium: Parse message with prefix detection
local function processPlayerMessage(player, rawMessage)
    local chatType, cleanMessage, anonymous = lia.chat.parse(player, rawMessage)
    if chatType == "ooc" then
        print(player:Name() .. " said OOC: " .. cleanMessage)
    end
    return chatType, cleanMessage, anonymous
end

```

**High Complexity:**
```lua
-- High: Advanced message processing with validation
local function advancedMessageParser(player, message, options)
    local chatType, cleanMessage, anonymous = lia.chat.parse(player, message, options.noSend)
    -- Custom validation based on chat type
    if chatType == "admin" and not player:IsAdmin() then
        player:notifyErrorLocalized("noPerm")
        return nil, nil, nil
    end
    -- Log message for moderation
    if options.logMessages then
        lia.log.add("chat", player:Name() .. " [" .. chatType .. "]: " .. cleanMessage)
    end
    return chatType, cleanMessage, anonymous
end

```

---

### send

**Purpose**

Sends a chat message to appropriate recipients based on chat type and hearing rules

**When Called**

Server-side when distributing parsed chat messages to players

**Parameters**

* `speaker` (*Player*): The player who sent the message
* `chatType` (*string*): The type of chat message (ic, ooc, whisper, etc.)
* `text` (*string*): The message content to send
* `anonymous` (*boolean, optional*): Whether to hide the speaker's identity
* `receivers` (*table, optional*): Specific list of players to send to

**Returns**

* void

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Send IC message to all nearby players
lia.chat.send(player, "ic", "Hello everyone!")

```

**Medium Complexity:**
```lua
-- Medium: Send anonymous whisper to specific players
local function sendAnonymousWhisper(speaker, message, targets)
    lia.chat.send(speaker, "whisper", message, true, targets)
end

```

**High Complexity:**
```lua
-- High: Advanced message broadcasting with custom logic
local function broadcastAdminMessage(speaker, message, options)
    local receivers = {}
    -- Collect admin players
    for _, player in pairs(player.GetAll()) do
        if player:IsAdmin() and (not options.excludeSelf or player ~= speaker) then
            table.insert(receivers, player)
        end
    end
    -- Send with custom formatting
    lia.chat.send(speaker, "admin", "[ADMIN] " .. message, false, receivers)
    -- Log the message
    lia.log.add("admin_chat", speaker:Name() .. ": " .. message)
end

```

---


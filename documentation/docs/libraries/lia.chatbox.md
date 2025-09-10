# Chatbox Library

This page documents the functions for working with chat systems and message handling.

---

## Overview

The chatbox library (`lia.chat`) provides a comprehensive chat system for the Lilia framework. It handles different chat types, message parsing, sending, and receiving with support for various chat modes like in-character, out-of-character, and custom chat types.

---

### lia.chat.timestamp

**Purpose**

Generates a timestamp string for chat messages based on configuration.

**Parameters**

* `ooc` (*boolean*): Whether this is an out-of-character message.

**Returns**

* `timestamp` (*string*): The formatted timestamp string.

**Realm**

Client.

**Example Usage**

```lua
-- Get timestamp for regular chat
local timestamp = lia.chat.timestamp(false)
print("Timestamp:", timestamp) -- Output: " (14) " or similar

-- Get timestamp for OOC chat
local oocTimestamp = lia.chat.timestamp(true)
print("OOC Timestamp:", oocTimestamp) -- Output: "(14)" or similar

-- Use in custom chat display
local function displayMessage(text, isOOC)
    local ts = lia.chat.timestamp(isOOC)
    chat.AddText(ts, Color(255, 255, 255), text)
end
```

---

### lia.chat.register

**Purpose**

Registers a new chat type with the chat system.

**Parameters**

* `chatType` (*string*): The unique identifier for the chat type.
* `data` (*table*): The chat type configuration data.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Register a basic chat type
lia.chat.register("whisper", {
    color = Color(150, 150, 150),
    prefix = "/w",
    onCanHear = function(speaker, listener)
        return speaker:GetPos():Distance(listener:GetPos()) <= 100
    end,
    onCanSay = function(speaker)
        return speaker:Alive()
    end
})

-- Register a radio chat type
lia.chat.register("radio", {
    color = Color(0, 255, 0),
    prefix = "/r",
    onCanHear = function(speaker, listener)
        local char = listener:getChar()
        return char and char:hasFlags("r")
    end,
    onCanSay = function(speaker)
        local char = speaker:getChar()
        return char and char:hasFlags("r")
    end
})

-- Register a faction chat type
lia.chat.register("faction", {
    color = Color(255, 255, 0),
    prefix = "/f",
    onCanHear = function(speaker, listener)
        local speakerChar = speaker:getChar()
        local listenerChar = listener:getChar()
        return speakerChar and listenerChar and 
               speakerChar:getFaction() == listenerChar:getFaction()
    end
})

-- Register a global admin chat
lia.chat.register("admin", {
    color = Color(255, 0, 0),
    prefix = "/a",
    onCanHear = function(speaker, listener)
        return listener:hasPrivilege("adminChat")
    end,
    onCanSay = function(speaker)
        return speaker:hasPrivilege("adminChat")
    end
})
```

---

### lia.chat.parse

**Purpose**

Parses a chat message to determine its type and extract the message content.

**Parameters**

* `client` (*Player*): The client who sent the message.
* `message` (*string*): The message to parse.
* `noSend` (*boolean*): Optional parameter to prevent sending the message.

**Returns**

* `chatType` (*string*): The determined chat type.
* `message` (*string*): The parsed message content.
* `anonymous` (*boolean*): Whether the message should be anonymous.

**Realm**

Shared.

**Example Usage**

```lua
-- Parse a chat message
local chatType, message, anonymous = lia.chat.parse(client, "/w Hello there!")
print("Chat type:", chatType) -- "whisper"
print("Message:", message) -- "Hello there!"
print("Anonymous:", anonymous) -- false

-- Parse without sending
local chatType, message = lia.chat.parse(client, "/r Radio message", true)

-- Use in PlayerSay hook
hook.Add("PlayerSay", "CustomChatParse", function(ply, text, teamChat)
    local chatType, message, anonymous = lia.chat.parse(ply, text)
    
    if chatType == "whisper" then
        print(ply:Name() .. " whispered: " .. message)
    elseif chatType == "radio" then
        print(ply:Name() .. " radioed: " .. message)
    end
    
    return false -- Prevent default chat
end)
```

---

### lia.chat.send

**Purpose**

Sends a chat message to appropriate recipients.

**Parameters**

* `speaker` (*Player*): The player who sent the message.
* `chatType` (*string*): The type of chat message.
* `text` (*string*): The message text.
* `anonymous` (*boolean*): Whether the message should be anonymous.
* `receivers` (*table*): Optional table of specific receivers.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Send a regular chat message
lia.chat.send(speaker, "ic", "Hello everyone!")

-- Send an anonymous message
lia.chat.send(speaker, "whisper", "Secret message", true)

-- Send to specific receivers
local receivers = {player1, player2, player3}
lia.chat.send(speaker, "radio", "Radio message", false, receivers)

-- Send OOC message
lia.chat.send(speaker, "ooc", "This is out of character")

-- Use in a command
lia.command.add("announce", {
    arguments = {
        {name = "message", type = "string"}
    },
    onRun = function(client, arguments)
        lia.chat.send(client, "ooc", "[ANNOUNCEMENT] " .. arguments[1])
    end
})
```

---

### lia.chat.add

**Purpose**

Adds a chat message to the client's chat display.

**Parameters**

* `speaker` (*Player*): The player who sent the message.
* `chatType` (*string*): The type of chat message.
* `text` (*string*): The message text.
* `anonymous` (*boolean*): Whether the message should be anonymous.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Add a message to chat
lia.chat.add(speaker, "ic", "Hello there!")

-- Add an anonymous message
lia.chat.add(speaker, "whisper", "Secret message", true)

-- Add OOC message
lia.chat.add(speaker, "ooc", "This is out of character")

-- Use in custom chat display
local function displayCustomMessage(speaker, text, isAnonymous)
    local displayName = isAnonymous and "Someone" or speaker:Name()
    lia.chat.add(speaker, "custom", text, isAnonymous)
end
```
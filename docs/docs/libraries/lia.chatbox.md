# Chatbox Library

This page outlines chatbox related functions and helpers.

---

## Overview
The chatbox library defines chat commands and renders messages. It lets you register chat classes that determine how text such as IC, action, and OOC messages appear and handles radius-based or global visibility.

    
**Description:**
Returns a formatted timestamp if chat timestamps are enabled.
**Parameters:**
* ooc (boolean) – True for out-of-character messages.
**Returns:**
* string – Formatted time string or an empty string.
**Realm:**
* Shared
**Example:**
```lua
-- This snippet demonstrates a common usage of lia.chat.timestamp
local ts = lia.chat.timestamp(false)
```

### lia.chat.register(chatType, data)

    
**Description:**
Registers a new chat class and sets up command aliases.
**Parameters:**
* chatType (string) – Identifier for the chat class.
* data (table) – Table of chat class properties.
**Returns:**
* nil
**Realm:**
* Shared
**Example:**
```lua
-- Register a simple "/me" chat command that prints actions in purple
lia.chat.register("me", {
onChatAdd = function(_, speaker, text)
chat.AddText(Color(200, 100, 255), "* " .. speaker:Name() .. " " .. text)
end,
prefix = {"/me"}
})
```

### lia.chat.parse(client, message, noSend)

    
**Description:**
Parses chat text for the proper chat type and optionally sends it.
**Parameters:**
* client (Player) – Player sending the message.
* message (string) – The chat text.
* noSend (boolean) – Suppress sending when true.
**Returns:**
* chatType (string), text (string), anonymous (boolean)
**Realm:**
* Shared
**Example:**
```lua
-- Parse chat messages and log "/me" actions to the console
hook.Add("PlayerSay", "LogActions", function(ply, text)
local class, parsed = lia.chat.parse(ply, text)
if class == "me" then
print(ply:Name() .. " performs action: " .. parsed)
end
end)
```

### lia.chat.send(speaker, chatType, text, anonymous, receivers)

    
**Description:**
Broadcasts a chat message to all eligible receivers.
**Parameters:**
* speaker (Player) – The message sender.
* chatType (string) – Chat class identifier.
* text (string) – Message text.
* anonymous (boolean) – Whether the sender is anonymous.
* receivers (table) – Optional list of target players.
**Returns:**
* nil
**Realm:**
* Server
**Example:**
```lua
-- This snippet demonstrates a common usage of lia.chat.send
lia.chat.send(client, "ic", "Hello")
```

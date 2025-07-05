# Chatbox Library

This page outlines chatbox related functions and helpers.

---

## Overview

The chatbox library defines chat commands and renders messages. It lets you
register chat classes that determine how text such as IC, action, and OOC
messages appear and handles radius-based or global visibility.

### lia.chat.classes

**Description:**

Table containing all registered chat class definitions indexed by their
identifier.

**Realm:**

* Shared

**Example Usage:**

```lua
local icClass = lia.chat.classes.ic
print(icClass.format)
```

### lia.chat.timestamp

**Description:**

Returns a formatted timestamp if chat timestamps are enabled. When disabled the
function returns an empty string.

**Parameters:**

* `ooc` (`boolean`) – True for out-of-character messages.


**Returns:**

* string – Formatted time string or an empty string.


**Realm:**

* Shared


**Example Usage:**

```lua
    -- Prepend a timestamp to a chat message
    chat.AddText(lia.chat.timestamp(false), Color(255, 255, 255), "Hello!")
```

---

### lia.chat.register

**Description:**

Registers a new chat class and sets up command aliases.

**Parameters:**

* `chatType` (`string`) – Identifier for the chat class.


* `data` (`table`) – Table of chat class properties.
  Common fields include:
  - `syntax` (string) – Argument usage description shown in command help.
  - `desc` (string) – Description of the command shown in menus.
  - `prefix` (string or table) – Command prefixes that trigger this chat type.
    A command alias is created for each prefix.
  - `radius` (number|function) – Hearing range, converted into an `onCanHear`
    check automatically.
  - `onCanHear` (function|number) – Determines if a listener can see the
    message.
  - `onCanSay` (function) – Called before sending to verify the speaker may
    talk.
  - `onChatAdd` (function) – Client-side handler for displaying the text.
  - `onGetColor` (function) – Returns a `Color` for the message.
  - `color` (Color) – Default color used with the fallback `onChatAdd`.
  - `format` (string) – Format string for the fallback `onChatAdd`.
  - `filter` (string) – Chat filter category used by the chat UI.
  - `font` (string) – Font name used when rendering the message.
  - `noSpaceAfter` (boolean) – Allows prefixes without a trailing space.
  - `deadCanChat` (boolean) – Permits dead players to use the chat type.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
-- Register a waving emote command
lia.chat.register("wave", {
    desc = "Wave at those nearby",
    syntax = "",
    format = "* %s waves",
    prefix = {"/wave", "/greet"},
    font = "liaChatFontItalics",
    filter = "actions",
    radius = lia.config.get("ChatRange", 280)
})
```

---

### lia.chat.parse

**Description:**

Parses chat text for the proper chat type and optionally sends it.
Server-side this fires the **PlayerMessageSend** hook before calling
`lia.chat.send` unless `noSend` is true.

**Parameters:**

* `client` (`Player`) – Player sending the message.


* `message` (`string`) – The chat text.


* `noSend` (`boolean`) – Suppress sending when true.


**Realm:**

* Shared


**Returns:**

* `chatType` (`string`), text (string), anonymous (boolean)


**Example Usage:**

```lua
-- Parse chat and modify messages inside PlayerSay
hook.Add("PlayerSay", "ParseChat", function(ply, text)
    local class, parsed = lia.chat.parse(ply, text, true)
    print(ply:Name(), "typed", parsed, "in", class)
    -- optionally re-send with custom formatting
    lia.chat.send(ply, class, string.upper(parsed))
    return ""
end)
```

---

### lia.chat.send

**Description:**

Broadcasts a chat message to all eligible receivers. The text is passed through
the **PlayerMessageSend** hook right before networking, and clients run
**OnChatReceived** when the message arrives.

**Parameters:**

* `speaker` (`Player`) – The message sender.


* `chatType` (`string`) – Chat class identifier.


* `text` (`string`) – Message text.


* `anonymous` (`boolean`) – Whether the sender is anonymous.


* `receivers` (`table`) – Optional list of target players.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
    -- Send a private IC message to a single player
    local target = player.GetByID(1)
    if IsValid(target) then
        lia.chat.send(client, "ic", "Hello", false, {target})
    end
```


# Chatbox Library

This page outlines chatbox related functions and helpers.

---

## Overview

The chatbox library defines chat commands, renders messages, and registers chat classes that control how IC, action, OOC, and other messages appear. It also handles radius-based or global visibility for receivers.

---

### lia.chat.classes

**Purpose**

Table containing all registered chat class definitions indexed by their identifier.

**Realm**

`Shared`

**Example Usage**

```lua
local icClass = lia.chat.classes.ic
print(icClass.format)
```

---

### lia.chat.timestamp(ooc)

**Purpose**

Returns a `"(hour)"` timestamp from `lia.time.GetHour()` when `lia.option.ChatShowTime` is enabled. For OOC messages a leading space is added and no trailing space is used; IC messages get a trailing space. When timestamps are disabled an empty string is returned.

**Parameters**

* `ooc` (*boolean*): True for out-of-character messages.

**Realm**

`Shared`

**Returns**

* *string*: Formatted time string or an empty string.

**Example Usage**

```lua
chat.AddText(lia.chat.timestamp(false), Color(255, 255, 255), "Hello!")
```

---

### lia.chat.register(chatType, data)

**Purpose**

Registers a new chat class and sets up its command aliases.

**Parameters**

* `chatType` (*string*): Identifier for the chat class.

* `data` (*table*): Table of chat class properties.

  * `arguments` (table) – Ordered argument definitions for the associated command. Defaults to an empty table.

  * `desc` (string) – Description of the command shown in menus. Defaults to an empty string.

  * `prefix` (string | table) – Command prefixes that trigger this chat type. Duplicate prefixes are ignored and slashless variants are automatically added.

  * `radius` (number | function) – Hearing range or custom range logic. Used to generate `onCanHear` when that callback is not supplied. If omitted, everyone can hear.

  * `onCanHear` (function | number) – `onCanHear(speaker, listener)` determines if a listener can see the message. Supplying a number is treated as a radius in units.

  * `onCanSay` (function) – `onCanSay(speaker, text)` runs before sending to verify the speaker may talk. The default blocks dead players, calling `speaker:notifyLocalized("noPerm")`, unless `deadCanChat` is `true`.

  * `onChatAdd` (function) – `onChatAdd(speaker, text, anonymous)` runs on the client to display text. The default uses `chat.AddText` with `lia.chat.timestamp(false)`, the chat color, and `L(data.format, anonymous and L("someone") or hook.Run("GetDisplayedName", speaker, chatType) or IsValid(speaker) and speaker:Name() or L("console"), text)`.

  * `color` (Color) – Default colour for the fallback `onChatAdd`. Defaults to `Color(242, 230, 160)`.

  * `format` (string) – Format string used by the fallback `onChatAdd`. Defaults to `"chatFormat"`.

  * `filter` (string) – Chat filter category used by the chat UI. Defaults to `"ic"`.

  * `noSpaceAfter` (boolean) – Allows prefixes without a trailing space. Defaults to `false`.

  * `deadCanChat` (boolean) – Permits dead players to use the chat type. Defaults to `false`.

  * `syntax` (string) – Automatically generated from `arguments` using `lia.command.buildSyntaxFromArguments` and localised with `L`.

On the client, any defined prefixes are registered as command aliases via `lia.command.add` so they can be typed directly into chat.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Register a waving emote command
lia.chat.register("wave", {
    desc = "Wave at those nearby",
    arguments = {{name = "text", type = "string", optional = true}},
    format = "* %s waves",
    prefix = {"/wave", "/greet"},
    filter = "actions",
    radius = lia.config.get("ChatRange", 280)
})
```

---

### lia.chat.parse(client, message, noSend)

**Purpose**

Parses chat text, determines the appropriate chat type, and optionally sends it. The function starts with the default chat type `"ic"` and searches registered prefixes case-insensitively. If the chosen class has `noSpaceAfter` and the remaining message begins with whitespace, that whitespace is trimmed. Results are passed through the `ChatParsed` hook, allowing modification of the chat type, text, or anonymity. When run on the server and `noSend` is `false`, the message is forwarded to `lia.chat.send` with the text filtered through the `PlayerMessageSend` hook.

**Parameters**

* `client` (*Player*): Player sending the message.

* `message` (*string*): Raw chat text.

* `noSend` (*boolean*): Suppress sending when `true`.

**Realm**

`Shared`

**Returns**

* *string*: Chat type identifier.

* *string*: Parsed text.

* *boolean*: Whether the speaker is anonymous.

Returns `nil` if the message contains only whitespace.

**Example Usage**

```lua
hook.Add("PlayerSay", "ParseChat", function(ply, text)
    local class, parsed = lia.chat.parse(ply, text, true)
    print(ply:Name(), "typed", parsed, "in", class)
    lia.chat.send(ply, class, string.upper(parsed))
    return ""
end)
```

---

### lia.chat.send(speaker, chatType, text, anonymous, receivers)

**Purpose**

Broadcasts a chat message to all eligible receivers. It respects the chat class's `onCanSay` and `onCanHear` logic and passes text through the `PlayerMessageSend` hook before networking. If `receivers` is not provided and `onCanHear` exists, a recipient list is built from players with characters that satisfy `onCanHear`. If that list ends up empty, the message is discarded. When a receiver list is provided, it is sent only to those players; otherwise it is broadcast to everyone.

**Parameters**

* `speaker` (*Player*): Message sender.

* `chatType` (*string*): Chat class identifier.

* `text` (*string*): Message text.

* `anonymous` (*boolean*): Whether the sender is anonymous.

* `receivers` (*table*): Optional list of target players.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
local target = player.GetByID(1)
if IsValid(target) then
    lia.chat.send(client, "ic", "Hello", false, {target})
end
```

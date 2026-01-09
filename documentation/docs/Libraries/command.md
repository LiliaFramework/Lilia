# Commands Library

Comprehensive command registration, parsing, and execution system for the Lilia framework.

---

Overview

The commands library provides comprehensive functionality for managing and executing commands in the Lilia framework. It handles command registration, argument parsing, access control, privilege management, and command execution across both server and client sides. The library supports complex argument types including players, booleans, strings, and tables, with automatic syntax generation and validation. It integrates with the administrator system for privilege-based access control and provides user interface elements for command discovery and argument prompting. The library ensures secure command execution with proper permission checks and logging capabilities.

---

### lia.command.buildSyntaxFromArguments

#### 📋 Purpose
Generate a human-readable syntax string from a list of argument definitions.

#### ⏰ When Called
During command registration to populate data.syntax for menus and help text.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `args` | **table** | Array of argument tables {name=, type=, optional=}. |

#### ↩️ Returns
* string
Concatenated syntax tokens describing the command arguments.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local syntax = lia.command.buildSyntaxFromArguments({
        {name = "target", type = "player"},
        {name = "amount", type = "number", optional = true}
    })
    -- "[player target] [string amount optional]"

```

---

### lia.command.add

#### 📋 Purpose
Register a command and normalize its metadata, syntax, privileges, aliases, and callbacks.

#### ⏰ When Called
During schema or module initialization to expose new chat/console commands.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `command` | **string** | Unique command key. |
| `data` | **table** | Command definition (arguments, desc, privilege, superAdminOnly, adminOnly, alias, onRun, onCheckAccess, etc.). |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.command.add("bring", {
        desc = "Bring a player to you.",
        adminOnly = true,
        arguments = {
            {name = "target", type = "player"}
        },
        onRun = function(client, args)
            local target = lia.command.findPlayer(args[1])
            if IsValid(target) then target:SetPos(client:GetPos() + client:GetForward() * 50) end
        end
    })

```

---

### lia.command.hasAccess

#### 📋 Purpose
Determine whether a client may run a command based on privileges, hooks, faction/class access, and custom checks.

#### ⏰ When Called
Before executing a command or showing it in help menus.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player requesting access. |
| `command` | **string** | Command name to check. |
| `data` | **table|nil** | Command definition; looked up from lia.command.list when nil. |

#### ↩️ Returns
* boolean, string
allowed result and privilege name for UI/feedback.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local canUse, priv = lia.command.hasAccess(ply, "bring")
    if not canUse then ply:notifyErrorLocalized("noPerm") end

```

---

### lia.command.extractArgs

#### 📋 Purpose
Split a raw command string into arguments while preserving quoted segments.

#### ⏰ When Called
When parsing chat-entered commands before validation or prompting.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | **string** | Raw command text excluding the leading slash. |

#### ↩️ Returns
* table
Array of parsed arguments.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local args = lia.command.extractArgs("'John Doe' 250")
    -- {"John Doe", "250"}

```

---

### lia.command.run

#### 📋 Purpose
Execute a registered command for a given client with arguments and emit post-run hooks.

#### ⏰ When Called
After parsing chat input or console invocation server-side.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** | Player that issued the command (nil when run from server console). |
| `command` | **string** | Command key to execute. |
| `arguments` | **table|nil** | Parsed command arguments. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.command.run(ply, "bring", {targetSteamID})

```

---

### lia.command.parse

#### 📋 Purpose
Parse chat text into a command invocation, prompt for missing args, and dispatch authorized commands.

#### ⏰ When Called
On the server when a player sends chat starting with '/' or when manually dispatching a command.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player whose chat is being parsed. |
| `text` | **string** | Full chat text. |
| `realCommand` | **string|nil** | Command key when bypassing parsing (used by net/message dispatch). |
| `arguments` | **table|nil** | Pre-parsed arguments; when nil they are derived from text. |
| `Pre` | **unknown** | parsed arguments; when nil they are derived from text. |
| `Pre` | **unknown** | parsed arguments; when nil they are derived from text. |

#### ↩️ Returns
* boolean
true if the text was handled as a command.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    hook.Add("PlayerSay", "liaChatCommands", function(ply, text)
        if lia.command.parse(ply, text) then return "" end
    end)

```

---

### lia.command.openArgumentPrompt

#### 📋 Purpose
Display a clientside UI prompt for missing command arguments and send the completed command back through chat.

#### ⏰ When Called
After the server requests argument completion via the liaCmdArgPrompt net message.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `cmdKey` | **string** | Command key being completed. |
| `missing` | **table** | Names of missing arguments. |
| `prefix` | **table|nil** | Prefilled argument values. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.command.openArgumentPrompt("pm", {"target", "message"}, {"steamid"})

```

---

### lia.command.send

#### 📋 Purpose
Send a command invocation to the server via net as a clientside helper.

#### ⏰ When Called
From UI elements or client logic instead of issuing chat/console commands directly.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `command` | **string** | Command key to invoke. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.command.send("respawn", LocalPlayer():SteamID())

```

---


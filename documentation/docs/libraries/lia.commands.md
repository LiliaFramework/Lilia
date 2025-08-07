# Commands Library

This page documents command registration and execution.

---

## Overview

The commands library registers console and chat commands. It parses arguments, checks permissions, and routes the handlers for execution. Commands can be run via slash chat or the console and may be restricted to specific usergroups through a CAMI-compliant admin mod.

---

### lia.command.add

**Purpose**

Registers a new command with its associated data. See [Command Fields](../definitions/command.md) for available keys in the `data` table.

**Parameters**

* `command` (*string*): Command name.

* `data` (*table*): Table containing command properties.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Register a simple warn command for administrators
lia.command.add("warn", {
    adminOnly = true,
    arguments = {
        {name = "target", type = "player"},
        {name = "reason", type = "string"}
    },
    desc = "Send a warning message to the target player.",
    onRun = function(client, args)
        local target = lia.util.findPlayer(client, args[1])
        if not target then
            return "@targetNotFound"
        end

        local reason = table.concat(args, " ", 2)
        target:ChatPrint("[WARN] " .. reason)
    end
})
```

---

### lia.command.hasAccess

**Purpose**

Determines if a player may run the specified command. Before checking CAMI privileges, the function consults the `CanPlayerUseCommand` hook. If that hook returns `true` or `false`, the result overrides default permission logic. Factions and classes can also whitelist commands by adding them to a `commands` table on their definition.

**Parameters**

* `client` (*Player*): Command caller.

* `command` (*string*): Command name.

* `data` (*table*): Command data table.

**Realm**

`Shared`

**Returns**

* *boolean*: Whether access is granted.

* *string*: Privilege checked.

**Example Usage**

```lua
-- Whitelist `/plytransfer` for the "Staff" faction
FACTION.commands = {
    plytransfer = true
}

-- Globally block a command for non-admins
hook.Add("CanPlayerUseCommand", "BlockReserve", function(client, cmd)
    if cmd == "reserve" and not client:IsAdmin() then
        return false
    end
end)
```

---

### lia.command.extractArgs

**Purpose**

Splits the provided text into arguments, respecting quotes. Sections wrapped in either single (`'`) or double (`"`) quotes are treated as single arguments.

**Parameters**

* `text` (*string*): Raw input text to parse.

**Realm**

`Shared`

**Returns**

* *table*: List of arguments extracted from the text.

**Example Usage**

```lua
local args = lia.command.extractArgs('/mycommand "quoted arg" anotherArg')
-- args = { "quoted arg", "anotherArg" }

local args2 = lia.command.extractArgs("/mycommand 'other arg' another")
-- args2 = { "other arg", "another" }
```

---

### lia.command.run

**Purpose**

Executes a command by its name, passing the provided arguments. If the command returns a string, it notifies the client (if valid).

**Parameters**

* `client` (*Player*): The player or console running the command.

* `command` (*string*): Name of the command to run.

* `arguments` (*table*): List of arguments for the command.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Execute the "boost" command when a player types !boost
hook.Add("PlayerSay", "RunBoostCommand", function(client, text)
    if text == "!boost" then
        local dest = client:GetPos() + Vector(0, 0, 64)
        lia.command.run(client, "boost", { dest, 60 })
        return ""
    end
end)
```

---

### lia.command.parse

**Purpose**

Attempts to parse the input text as a command, optionally using `realCommand` and `arguments` if provided. If parsed successfully, the command is executed.

**Parameters**

* `client` (*Player*): Player or console issuing the command.

* `text` (*string*): Raw text that may contain the command and arguments.

* `realCommand` (*string*): Command name override (optional).

* `arguments` (*table*): Argument list override (optional).

**Realm**

`Server`

**Returns**

* *boolean*: `true` if the text was parsed as a valid command, `false` otherwise.

**Example Usage**

```lua
lia.command.parse(player, "/mycommand arg1 arg2")
```

---

### lia.command.send

**Purpose**

Sends a command (and optional arguments) from the client to the server via the net library. The server then executes the command.

**Parameters**

* `command` (*string*): Command name.

* … (*vararg*): Additional arguments.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.command.send("mycommand", "arg1", "arg2")
```

---

### lia.command.openArgumentPrompt

**Purpose**

Opens a window asking the player to fill in missing arguments for the given command. Arguments marked `optional` may be left blank; all others must be filled before **Submit** is enabled.

**Parameters**

* `cmdKey` (*string*): Command name.

* `missing` (*table*): Array of argument names that still need values.

* `prefix` (*table*): Arguments already supplied (optional).

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.command.openArgumentPrompt("ban", {"target", "duration"})
```

---

### lia.command.findPlayer

**Purpose**

Convenience alias for [lia.util.findPlayer](lia.util.md#liautilfindplayer). Use this when writing command callbacks to locate another player by name or SteamID.

**Parameters**

See [lia.util.findPlayer](lia.util.md#liautilfindplayer).

**Realm**

`Shared`

*Alias*

`lia.util.findPlayer`

**Returns**

* *Player | nil*: The found player, if any.

**Example Usage**

```lua
local target = lia.command.findPlayer(admin, "Sarah")
if target then
    admin:notify("Found " .. target:Name())
end
```

---

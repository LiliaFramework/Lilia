# Commands Library


This page documents command registration and execution.


---


## Overview


The commands library registers console and chat commands. It parses arguments, checks permissions, and routes the handlers for execution. Commands can be run via slash chat or the console and may be restricted to specific usergroups through a CAMI-compliant admin mod.


### lia.command.add(command, data)

**Description:**


Registers a new command with its associated data.


**Parameters:**


* command (string) – Command name.


* data (table) – Table containing command properties.


**Realm:**


* Shared


**Returns:**


* None


**Example Usage:**


```lua
    -- TODO
```


### lia.command.hasAccess(client, command, data)

**Description:**


Determines if a player may run the specified command.


**Parameters:**


* client (Player) – Command caller.


* command (string) – Command name.


* data (table) – Command data table.


**Realm:**


* Shared


**Returns:**


* boolean – Whether access is granted.


* string – Privilege checked.


**Example Usage:**


```lua
    -- TODO
```


### lia.command.extractArgs

**Description:**


Splits the provided text into arguments, respecting quotes.

Quoted sections are treated as single arguments.


**Parameters:**


* text (string) – The raw input text to parse.


**Realm:**


* Shared


**Returns:**


* table – A list of arguments extracted from the text.


**Example Usage:**


```lua
    -- This snippet demonstrates a common usage of lia.command.extractArgs
    local args = lia.command.extractArgs('/mycommand "quoted arg" anotherArg')
    -- args = {"quoted arg", "anotherArg"}
```


---


### lia.command.parseSyntaxFields

**Description:**


Parses a command syntax string into an ordered list of field tables.

Each field contains a name and a type derived from the syntax.


**Parameters:**


* syntax (string) – The syntax string, e.g. "[string Name] [number Time]".


**Realm:**


* Shared


**Returns:**


* table – List of fields in call order.


* boolean – Whether the syntax strictly used the "[type Name]" format.


**Example Usage:**


```lua
    -- Extract field data from a syntax string
    local fields, valid = lia.command.parseSyntaxFields("[string Name] [number Time]")
```


---


### lia.command.run

**Description:**


Executes a command by its name, passing the provided arguments.

If the command returns a string, it notifies the client (if valid).


**Parameters:**


* client (Player) – The player or console running the command.


* command (string) – The name of the command to run.


* arguments (table) – A list of arguments for the command.


**Realm:**


* Server


**Returns:**


* None


**Example Usage:**


```lua
    -- Execute the "boost" command when a player types !boost in chat
    hook.Add("PlayerSay", "RunBoostCommand", function(client, text)
        if text == "!boost" then
            local dest = client:GetPos() + Vector(0, 0, 64)
            lia.command.run(client, "boost", {dest, 60})
            return ""
        end
    end)
```


---


### lia.command.parse

**Description:**


Attempts to parse the input text as a command, optionally using realCommand

and arguments if provided. If parsed successfully, the command is executed.


**Parameters:**


* client (Player) – The player or console issuing the command.


* text (string) – The raw text that may contain the command name and arguments.


* realCommand (string) – If provided, use this as the command name instead of parsing text.


* arguments (table) – If provided, use these as the command arguments instead of parsing text.


**Realm:**


* Server


**Returns:**


* boolean – True if the text was parsed as a valid command, false otherwise.


**Example Usage:**


```lua
    -- This snippet demonstrates a common usage of lia.command.parse
    lia.command.parse(player, "/mycommand arg1 arg2")
```


---


### lia.command.send

**Description:**


Sends a command (and optional arguments) from the client to the server using the

Garry's Mod net library. The server will then execute the command.


**Parameters:**


* command (string) – The name of the command to send.


* ... (vararg) – Any additional arguments to pass to the command.


**Realm:**


* Client


**Returns:**


* None


**Example Usage:**


```lua
    -- This snippet demonstrates a common usage of lia.command.send
    lia.command.send("mycommand", "arg1", "arg2")
```


---


### lia.command.openArgumentPrompt

**Description:**


Opens a window asking the player to fill in arguments for the given command. If only

the command name is supplied, all arguments defined in the command's syntax are

requested. Passing existing arguments causes the prompt to request only the missing

ones.


**Parameters:**


* cmd (string) – The command name.


* args (table|string) – Optional. Either the arguments already provided or a table of


missing fields from the server.

* prefix (table) – Optional prefix when using the legacy field table format.


**Realm:**


* Client


**Returns:**


* None


**Example Usage:**


```lua
    -- TODO
```


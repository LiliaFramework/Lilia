# lia.command

---

Registration, parsing, and handling of commands.

Commands can be run through the chat with slash commands or they can be executed through the console. Commands can be manually restricted to certain user groups using a [CAMI](https://github.com/glua/CAMI)-compliant admin mod.

If you are looking for the command structure, you can find it [here](/framework/definitions/command).

---


### **lia.command.add**

**Description:**  
Creates a new command by registering it with the provided structure. This includes setting up access restrictions, handling aliases, and defining the command's execution behavior.

**Realm:**  
`Shared`

**Parameters:**  
    
- `command` (`string`): Name of the command (recommended in UpperCamelCase).
- `data` (`table`): Data describing the command, adhering to the [`Command Fields`](/framework/definitions/command).

**Example Usage:**
```lua
lia.command.add("Slap", {
    adminOnly = true,
    privilege = "Can Slap",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if target then
            target:TakeDamage(10, client, client)
            client:notify("You slapped " .. target:Nick())
            target:notify(client:Nick() .. " slapped you!")
        end
    end,
    syntax = "<player>"
})
```
---

### **lia.command.hasAccess**

**Description:**  
Checks if a player has access to execute a specific command. This function determines whether a player is authorized to run a given command based on privileges, admin-only or superadmin-only restrictions, and any custom hooks.

**Realm:**  
`Shared`

**Parameters:**  
    
- `client` (`Player`): The player to check access for.
- `command` (`string`): The name of the command to check access for.
- `data` (`table`, optional): The command data. If not provided, the function retrieves the data from `lia.command.list`.

**Returns:**  
    
- `boolean`: Whether the player has access to the command.
- `string`: The privilege associated with the command.

**Example Usage:**
```lua
local canUse, privilege = lia.command.hasAccess(playerInstance, "Ban")
if canUse then
    print("Player can run the command:", privilege)
else
    print("Player does not have access to the command:", privilege)
end
```

---

### **lia.command.extractArgs**

**Description:**  
Returns a table of arguments from a given string. Words separated by spaces are considered individual arguments. To have an argument containing multiple words, they must be enclosed within quotation marks.

**Realm:**  
`Shared`

**Parameters:**  
    
- `text` (`string`): The input string to extract arguments from.

**Returns:**  
    
- `table`: Arguments extracted from the string.

**Example Usage:**
```lua
local args = lia.command.extractArgs('kick "John Doe" 30')
PrintTable(args)
-- Output:
-- 1 = kick
-- 2 = John Doe
-- 3 = 30
```

---

### **lia.util.findPlayer**

**Description:**  
Attempts to find a player by an identifier. If unsuccessful, a notice is displayed to the specified player. The search criteria are derived from `lia.util.findPlayer`.

**Realm:**  
`Server`

**Parameters:**  
    
- `client` (`Player`): The player to notify if the target player cannot be found.
- `name` (`string`): The search query (e.g., player name or SteamID).

**Returns:**  
    
- `Player|nil`: The player that matches the given search query, or `nil` if not found.

**Example Usage:**
```lua
local target = lia.util.findPlayer(adminPlayer, "PlayerName")
if target then
    print("Found player:", target:Nick())
end
```

---

### **lia.command.findFaction**

**Description:**  
Attempts to find a faction by an identifier.

**Realm:**  
`Server`

**Parameters:**  
    
- `client` (`Player`): The player to notify if the faction cannot be found.
- `name` (`string`): The search query (e.g., faction name).

**Returns:**  
    
- `table|nil`: The faction that matches the given search query, or `nil` if not found.

**Example Usage:**
```lua
local faction = lia.command.findFaction(adminPlayer, "Police")
if faction then
    print("Found faction:", faction.name)
end
```

---

### **lia.command.findPlayerSilent**

**Description:**  
Attempts to find a player by an identifier silently. If the player is not found, no notification is sent to the client.

**Realm:**  
`Server`

**Parameters:**  
    
- `client` (`Player`): The player executing the search.
- `name` (`string`): The search query (e.g., player name or SteamID).

**Returns:**  
    
- `Player|nil`: The player that matches the given search query, or `nil` if not found.

**Example Usage:**
```lua
local target = lia.command.findPlayerSilent(adminPlayer, "PlayerName")
if target then
    print("Found player silently:", target:Nick())
end
```

---

### **lia.command.run**

**Description:**  
Forces a player to execute a command by name. This mimics similar functionality to the player typing `/CommandName` in the chatbox.

**Realm:**  
`Server`

**Parameters:**  
    
- `client` (`Player`): The client who is executing the command.
- `command` (`string`): The full name of the command to be executed. This string is case-insensitive.
- `arguments` (`table`): An array of arguments to be passed to the command.

**Example Usage:**
```lua
lia.command.run(adminPlayer, "Roll", {10})
```

---

### **lia.command.parse**

**Description:**  
Parses a command from an input string and executes it.

**Realm:**  
`Server`

**Parameters:**  
    
- `client` (`Player`): The player who is executing the command.
- `text` (`string`): The input string to search for the command format.
- `realCommand` (`string`, optional): Specific command to check for. If specified, it will only try to run this command.
- `arguments` (`table`, optional): An array of arguments to pass to the command. If not specified, it will try to extract them from the text.

**Returns:**  
    
- `boolean`: Whether a command has been found and executed.

**Example Usage:**
```lua
local success = lia.command.parse(adminPlayer, "/roll 10")
if success then
    print("Command executed successfully.")
end
```

---

### **lia.command.send**

**Description:**  
Requests the server to run a command. This mimics similar functionality to the client typing `/CommandName` in the chatbox.

**Realm:**  
`Client`

**Parameters:**  
    
- `command` (`string`): Unique ID of the command.
- `...` (`any`): Arguments to pass to the command.

**Example Usage:**
```lua
lia.command.send("roll", 10)
```

---

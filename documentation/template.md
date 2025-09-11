# Documentation Generation Instructions

When asked to write documentation, always generate it in **Markdown** using the following format.  
Only document functions that belong to the **`lia.*` namespace**. Ignore and refuse requests for any functions outside of this namespace.  

Each documentation file must be generated with the name format:

lia.libraryname.md

Where `libraryname` is the corresponding file/module name.  
For example:  
- Documenting `admin.lua` → `lia.admin.md`  
- Documenting `inventory.lua` → `lia.inventory.md`  
- Documenting `chat.lua` → `lia.chat.md`  

---

# Library Title

A simple, straightforward explanation of what the library does. (1–2 sentences)

---

## Overview

An extended, detailed explanation of the library, including its purpose, scope, and how it fits into the framework/system.

---

### *functionName* (by function name understand either method in Table:Method or * in lia.libraryname.* )

**Purpose**

A one-sentence explanation of what the function does.

**Parameters**

* `paramName` (*type*): Description of the parameter.
* `paramName` (*type*): Description of the parameter.

**Returns**

* `returnName` (*type*): Description of the return value.

**Realm**

State whether the function is **Server**, **Client**, or **Shared**.

**Example Usage**

Provide extensive, practical Lua examples demonstrating usage. Always use clean and production-ready GLua code.

---

## Rules

- Only document functions from the `lia.*` namespace.  
- Always follow the structure exactly as shown.  
- Always write in clear, concise English.  
- Always generate **full Markdown pages** ready to be placed in documentation.  
- Always provide **extensive usage examples** in GLua code fences.  
- Always format code cleanly and consistently.  
- Always save documentation files as `lia.libraryname.md`.  
- Never omit any of the sections (Purpose, Parameters, Returns, Realm, Example Usage).  
- Never include comments in code unless they clarify the example’s intent.  
- Never document hooks, enums, or config variables unless they are explicitly part of the `lia.*` namespace.  

---

## Example Template

_File: `lia.admin.md`_

# Administrator Library

This page documents the functions for working with administrator privileges and user groups.

---

## Overview

The administrator library (`lia.administrator`) provides a comprehensive, hierarchical permission and user group management system for the Lilia framework. It serves as the core authorization system, handling everything from basic tool usage permissions to complex administrative operations.

---

### lia.administrator.hasAccess

**Purpose**

Checks if a player or usergroup has access to a specific privilege.

**Parameters**

* `ply` (*Player|string*): The player entity or usergroup name to check.
* `privilege` (*string*): The privilege to check access for.

**Returns**

* `hasAccess` (*boolean*): True if the player/usergroup has the privilege, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
-- Check if a player has the "manageUsergroups" privilege
if lia.administrator.hasAccess(ply, "manageUsergroups") then
    print(ply:Nick() .. " can manage usergroups!")
end

-- Check if the "admin" group has the "ban" privilege
if lia.administrator.hasAccess("admin", "ban") then
    print("Admins can ban players.")
end

-- Check privilege access in a command function
hook.Add("PlayerSay", "CheckAdminCommand", function(ply, text)
    if string.sub(text, 1, 5) == "!kick" then
        if not lia.administrator.hasAccess(ply, "kick") then
            ply:ChatPrint("You don't have permission to kick players!")
            return false
        end
        -- Process kick command
    end
end)

-- Check tool usage permission
hook.Add("CanTool", "CheckToolPermissions", function(ply, trace, tool)
    local privilege = "tool_" .. tool
    if not lia.administrator.hasAccess(ply, privilege) then
        ply:ChatPrint("You don't have permission to use this tool!")
        return false
    end
end)

-- Conditional feature access
if lia.administrator.hasAccess(LocalPlayer(), "seeAdminChat") then
    drawAdminChat()
end
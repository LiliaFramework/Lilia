# Attribute Hooks

This document lists hooks related to attribute setup and changes.

---

## Overview

Each class can implement lifecycle hooks to control access, initialize settings, and respond to events such as joining, leaving, spawning, or being transferred. All hooks are optional; unspecified hooks will not alter default behavior.

---

#### `OnSetup(client, value)`

**Type:** `function(client, number)`
**Description:** Called when the attribute is initialized on a player (e.g., at character load or creation). Use this hook to run custom logic, send notifications, apply effects, etc.

**Example:**

```lua
function ATTRIBUTE:OnSetup(client, value)
    if value > 5 then
        client:ChatPrint("You are very Strong!")
    end
end
```

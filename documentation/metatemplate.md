# Meta Table Documentation Generation Instructions

When asked to write **meta table documentation**, generate it in **Markdown** using the format below.  
Only document **methods belonging to a single meta type** (e.g., `Player`, `Entity`, `Vehicle`, `Weapon`, `NPC`). Ignore and refuse requests for anything outside the chosen meta type.  

Each documentation file must be generated with the name format:

`<metatype>.md`

Where `<metatype>` is the exact meta type name in lowercase.  
For example:  
- Documenting the `Player` meta table → `player.md`  
- Documenting the `Entity` meta table → `entity.md`  
- Documenting the `Weapon` meta table → `weapon.md`  

---

# Meta Title

A simple, straightforward explanation of what the meta type represents. (1–2 sentences)

---

## Overview

An extended, detailed explanation of the meta table, including its purpose, scope, and how it fits into the framework/system.

---

### MetaType\:FunctionName

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

Provide extensive, practical GLua examples demonstrating usage. Always use clean and production-ready code.

---

## Rules

- Only document **methods of the specified meta type** (e.g., `Player:*`, `Entity:*`).  
- Always follow the structure exactly as shown.  
- Always write in clear, concise English.  
- Always generate **full Markdown pages** ready to be placed in documentation.  
- Always provide **extensive usage examples** in GLua code fences.  
- Always format code cleanly and consistently.  
- File must be saved as **`<metatype>.md`** (lowercase).  
- Never omit any of the sections (Purpose, Parameters, Returns, Realm, Example Usage).  
- Never include comments in code unless they clarify the example's intent.  
- Never document hooks, enums, or config variables—only meta methods for the chosen meta type.  

---

## Example Template

_File: `player.md`_

# Player Meta

This page documents methods available on the `Player` meta table, representing connected human players.

---

## Overview

The `Player` meta table exposes properties and behaviors for player entities, including identity (name, SteamID), permissions, movement, communication, and gameplay interactions. These methods are the foundation for player-centric logic such as permission checks, inventory access, damage handling, UI feedback, and networked state.

---

### Player\:Nick (Get Player Name)

**Purpose**

Returns the player’s current nickname.

**Parameters**

*None.*

**Returns**

* `name` (*string*): The player’s nickname.

**Realm**

Shared.

**Example Usage**

```lua
local function announceJoin(ply)
    local name = ply:Nick()
    for _, v in pairs(player.GetAll()) do
        v:ChatPrint(name .. " joined the server.")
    end
end
hook.Add("PlayerInitialSpawn", "AnnounceJoin", announceJoin)
```

---

### Player\:SteamID64 (Get SteamID64)

**Purpose**

Returns the player’s 64-bit SteamID as a string.

**Parameters**

*None.*

**Returns**

* `steamid64` (*string*): The player’s SteamID64.

**Realm**

Shared.

**Example Usage**

```lua
local function logConnect(ply)
    local sid64 = ply:SteamID64()
    local name = ply:Nick()
    print("[CONNECT] " .. name .. " (" .. sid64 .. ")")
end
hook.Add("PlayerAuthed", "LogConnect", logConnect)
```

---

### Player\:IsAdmin (Check Admin Status)

**Purpose**

Determines whether the player has admin privileges.

**Parameters**

*None.*

**Returns**

* `isAdmin` (*boolean*): True if the player is an admin, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
local function restrictCommand(ply, text)
    if string.sub(text, 1, 6) ~= "!clean" then return end
    if not ply:IsAdmin() then
        ply:ChatPrint("You do not have permission to use this command.")
        return ""
    end
    for _, v in pairs(ents.FindByClass("prop_physics")) do
        if IsValid(v) then v:Remove() end
    end
    ply:ChatPrint("World cleaned.")
    return ""
end
hook.Add("PlayerSay", "RestrictClean", restrictCommand)
```

---

### Player\:ChatPrint (Send Chat Message)

**Purpose**

Sends a plain text message to the player’s chat box.

**Parameters**

* `message` (*string*): The message to send.

**Returns**

* `ok` (*boolean*): True if the message was queued for sending.

**Realm**

Server.

**Example Usage**

```lua
util.AddNetworkString("NotifyScore")

local function notifyHighScore(ply, score)
    ply:ChatPrint("New personal best: " .. tostring(score))
end

net.Receive("NotifyScore", function(_, ply)
    local score = net.ReadUInt(16)
    notifyHighScore(ply, score)
end)
```

---

### Player\:Alive (Is Alive)

**Purpose**

Checks whether the player is alive.

**Parameters**

*None.*

**Returns**

* `alive` (*boolean*): True if alive, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
local function giveMedkit(ply)
    if not IsValid(ply) or not ply:Alive() then return end
    ply:Give("weapon_medkit")
end

concommand.Add("give_medkit", function(ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    for _, v in pairs(player.GetAll()) do
        giveMedkit(v)
    end
end)
```

---

### Player\:Give (Give Weapon)

**Purpose**

Gives the player a weapon by class name.

**Parameters**

* `class` (*string*): Weapon class name.
* `select` (*boolean|nil*): If true, selects the weapon after giving.

**Returns**

* `weapon` (*Weapon|nil*): The weapon entity if successful, otherwise nil.

**Realm**

Server.

**Example Usage**

```lua
local function loadout(ply)
    local weapon = ply:Give("weapon_pistol", true)
    if not IsValid(weapon) then
        ply:ChatPrint("Failed to equip pistol.")
        return
    end
    ply:GiveAmmo(60, weapon:GetPrimaryAmmoType(), true)
end

hook.Add("PlayerSpawn", "DefaultLoadout", loadout)
```

---

### Player\:Kill (Force Death)

**Purpose**

Kills the player, applying standard death handling.

**Parameters**

*None.*

**Returns**

* `ok` (*boolean*): True if the action was applied.

**Realm**

Server.

**Example Usage**

```lua
concommand.Add("punish_afk", function(ply, _, args)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    for _, v in pairs(player.GetAll()) do
        if v:IsFlagSet(FL_ATCONTROLS) then
            v:Kill()
        end
    end
end)
```

---

### Player\:SetRunSpeed (Set Run Speed)

**Purpose**

Sets the player’s run speed.

**Parameters**

* `speed` (*number*): New run speed in Hammer units per second.

**Returns**

* `ok` (*boolean*): True if the speed was set.

**Realm**

Server.

**Example Usage**

```lua
local function applyRankSpeeds(ply)
    local base = 220
    local bonus = ply:IsAdmin() and 80 or 0
    ply:SetRunSpeed(base + bonus)
    ply:SetWalkSpeed(150)
end

hook.Add("PlayerSpawn", "ApplyRankSpeeds", applyRankSpeeds)
```

---

### Player\:GetEyeTrace (Get Eye Trace)

**Purpose**

Returns a trace from the player’s view to what they are looking at.

**Parameters**

* `mask` (*number|nil*): Optional contents mask for the trace.

**Returns**

* `trace` (*table*): Trace result table with hit data.

**Realm**

Shared.

**Example Usage**

```lua
local function pickupClosest(ply)
    local tr = ply:GetEyeTrace()
    if not tr or not IsValid(tr.Entity) then return end
    if tr.Entity:GetMoveType() ~= MOVETYPE_VPHYSICS then return end
    local phys = tr.Entity:GetPhysicsObject()
    if not IsValid(phys) then return end
    ply:PickupObject(tr.Entity)
end

concommand.Add("pickup_look", function(ply)
    if not IsValid(ply) then return end
    pickupClosest(ply)
end)
```

---

### Player\:SetNWString (Set Networked String)

**Purpose**

Sets a networked string value on the player, replicating to clients.

**Parameters**

* `key` (*string*): Networked key.
* `value` (*string*): Value to set.

**Returns**

* `ok` (*boolean*): True if the value was set.

**Realm**

Server.

**Example Usage**

```lua
local function assignTeamLabel(ply, teamName)
    ply:SetNWString("teamLabel", teamName)
end

hook.Add("PlayerSpawn", "AssignTeamLabel", function(ply)
    local wasAdmin = ply:IsAdmin()
    assignTeamLabel(ply, wasAdmin and "Overwatch" or "Citizen")
end)
```

---
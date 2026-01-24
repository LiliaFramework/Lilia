# Configuration

Configuration options for the Load Messages module.

---

Overview

The Load Messages module shows welcome messages to players when they join the server. You can set different colored messages for each faction.

---

### FactionMessages

#### 📋 Description
Welcome messages shown to players based on their faction when they join. Each faction can have its own colored message.

#### ⚙️ Type
Table

#### 💾 Default Value
```lua
{
    [FACTION_STAFF] = {Color(255, 215, 0), "Welcome, staff member. Monitor the server responsibly."}
}
```

#### 📊 Structure
A table mapping faction IDs to arrays containing:
- Color object for the message text color
- String message text to display

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Use faction constants like `FACTION_STAFF`, `FACTION_CITIZEN`, etc.
- Color examples: `Color(255, 215, 0)` for gold, `Color(100, 150, 255)` for blue
- Keep messages short and informative

**Example:**
```lua
MODULE.FactionMessages = {
    [FACTION_STAFF] = {Color(255, 215, 0), "Welcome, staff member."},
    [FACTION_POLICE] = {Color(100, 150, 255), "Welcome to the police force."},
    [FACTION_CITIZEN] = {Color(255, 255, 255), "Welcome to the city."}
}
```


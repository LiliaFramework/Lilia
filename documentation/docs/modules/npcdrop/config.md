# Configuration

Configuration options for the NPC Drop module.

---

Overview

The NPC Drop module lets you set which items NPCs drop when they die. You can set different items for each NPC type with different drop chances.

---

### DropTable

#### 📋 Description
Defines what items each NPC type drops. Higher numbers mean higher drop chance.

#### ⚙️ Type
Table

#### 💾 Default Value
```lua
{
    ["npc_zombie"] = {
        ["soda"] = 25,
        ["cola"] = 10,
        ["water"] = 50,
        ["beer"] = 15
    }
}
```

#### 📊 Structure
A table mapping NPC class names to item drop tables. Each item has a weight number - higher weights drop more often.

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Use NPC class names like `"npc_zombie"`, `"npc_citizen"`, etc.
- Use item unique IDs like `"soda"`, `"water"`, etc.
- Higher numbers = more common drops
- Example: `["water"] = 50` drops more often than `["cola"] = 10`


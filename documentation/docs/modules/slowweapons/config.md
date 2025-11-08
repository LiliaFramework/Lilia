# Configuration

Configuration options for the Slow Weapons module.

---

Overview

The Slow Weapons module makes players move slower when holding heavy weapons. You can set different speed penalties for each weapon.

---

### WeaponsSpeed

#### 📋 Description
Sets movement speed for specific weapons. Lower numbers mean slower movement.

#### ⚙️ Type
Table

#### 💾 Default Value
```lua
{
    ["fo3_fatman"] = 130
}
```

#### 📊 Structure
A table mapping weapon class names to movement speed values.

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Normal movement speed is usually 200-250
- Lower values (100-150) make weapons feel heavy
- Example: `["weapon_rpg"] = 120` makes RPG users move slower


# Configuration

Configuration options for the Hospitals module.

---

Overview

The Hospitals module provides configurable hospital respawn locations for different maps. When players die and respawn, they are randomly placed at one of the configured hospital locations for the current map, providing a more immersive medical recovery experience.

---

### HospitalLocations

#### 📋 Description
Defines hospital spawn locations for different maps. Each map can have multiple hospital locations where players will respawn after death.

#### ⚙️ Type
Table

#### 💾 Default Value
A table containing hospital locations for supported maps (currently rp_nycity and rp_nycity_day).

#### 📊 Structure
Each map entry contains an array of location objects with:
- `pos` (Vector) - The position vector where players will spawn
- `ang` (Angle) - The angle/direction players will face when spawning

#### 🌐 Realm
Server

#### 📝 Example
```lua
HospitalLocations = {
    ["rp_nycity"] = {
        {
            pos = Vector(-6129.52, 8877.73, 16.03),
            ang = Angle(-0.5, -176.99, 0)
        }
    }
}
```

#### 🔧 Customization
To add hospital locations for a new map:
1. Add a new entry to the HospitalLocations table with the map name as the key
2. Create an array of location objects, each containing pos and ang
3. Position and angle values can be obtained using in-game tools or map editors

---

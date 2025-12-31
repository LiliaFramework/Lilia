# Configuration

Configuration options for the Donator module.

---

Overview

The Donator module lets you give special benefits to donators and user groups. You can set character limits, inventory sizes, group assignments, and weapon access.

---

### OverrideCharLimit

#### 📋 Description
Sets how many characters each user group can have.

#### ⚙️ Type
Table

#### 💾 Default Value
```lua
{
    ["founder"] = 10,
    ["superadmin"] = 3,
    ["admin"] = 3,
    ["user"] = 2
}
```

#### 📊 Structure
A table mapping user group names to character limit numbers.

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Add user groups like `["vip"] = 5` to give VIP players 5 characters
- Higher numbers allow more characters per group

---

### DonatorGroups

#### 📋 Description
Links donator groups to benefit groups (like pet access).

#### ⚙️ Type
Table

#### 💾 Default Value
```lua
{
    ["vip"] = "pet"
}
```

#### 📊 Structure
A table mapping donator group names to benefit group names.

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Example: `["vip"] = "pet"` gives VIP players pet access
- Add more entries for different donator tiers

---

### GroupInventorySize

#### 📋 Description
Sets custom inventory sizes for specific user groups.

#### ⚙️ Type
Table

#### 💾 Default Value
```lua
{
    ["superadmin"] = {10, 10}
}
```

#### 📊 Structure
A table mapping user group names to `{width, height}` arrays.

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Format: `{width, height}` - example `{10, 10}` means 10 slots wide and 10 slots tall
- Larger inventories give groups more storage space

---

### DonatorWeapons

#### 📋 Description
Gives specific Steam IDs access to certain weapons.

#### ⚙️ Type
Table

#### 💾 Default Value
```lua
{
    ["76561198312513285"] = {"weapon_smg1", "weapon_shotgun", "weapon_rpg", "weapon_pistol"}
}
```

#### 📊 Structure
A table mapping Steam IDs to arrays of weapon class names.

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Find Steam IDs from player profiles or admin tools
- Add weapon class names like `"weapon_pistol"` to the list
- Each Steam ID gets its own list of allowed weapons


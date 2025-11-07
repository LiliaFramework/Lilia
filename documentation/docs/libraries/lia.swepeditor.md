# SWEP Editor Library

Weapon modification and balancing system for the Lilia framework.

---

Overview

The SWEP Editor library provides comprehensive functionality for modifying and balancing weapons in the Lilia framework. It allows for runtime weapon property adjustments, persistent storage of weapon modifications, and hardcoded weapon overrides. The library supports both server-side database operations for saving weapon configurations and client-side interfaces for weapon editing. It includes functions for adjusting weapon properties using hierarchical key paths, applying overrides to weapon classes, and synchronizing weapon data across players. The library ensures that weapon modifications are applied consistently and can be easily managed through both programmatic overrides and in-game editing tools.

---

### lia.swepeditor.loadData

#### 📋 Purpose
Load saved SWEP editor data from database for a specific weapon class

#### ⏰ When Called
During weapon initialization on server startup, or when syncing weapon data

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `class` | **string** | The weapon class name to load data for (e.g., "weapon_pistol") |

#### ↩️ Returns
* None - Data is loaded asynchronously and applied to the weapon

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Load data for a pistol
    lia.swepeditor.loadData("weapon_pistol")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Load data for multiple weapons in a loop
    local weapons = {"weapon_pistol", "weapon_smg1", "weapon_shotgun"}
    for _, weaponClass in ipairs(weapons) do
        lia.swepeditor.loadData(weaponClass)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Load data with error handling and logging
    local function loadWeaponData(weaponClass)
        lia.db.query(string.format("SELECT * FROM lia_swepeditor WHERE class = '%s'", string.gsub(weaponClass, "'", "''")), function(results)
            if results and results[1] then
                local saveData = util.JSONToTable(results[1].data)
                if saveData then
                    print("[SWEP Editor] Loaded data for " .. weaponClass)
                    for k, v in pairs(saveData) do
                        lia.swepeditor.adjustValue(weaponClass, k, v)
                    end
                    hook.Run("SWEPEditorValueUpdated", weaponClass, saveData)
                else
                    print("[SWEP Editor] Failed to parse data for " .. weaponClass)
                end
            else
                print("[SWEP Editor] No saved data found for " .. weaponClass)
            end
        end)
    end
    loadWeaponData("weapon_pistol")

```

---

### lia.swepeditor.sync

#### 📋 Purpose
Synchronize SWEP editor data with a specific player or all players

#### ⏰ When Called
When a player joins the server, when weapon data is updated, or when syncing data manually

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player, optional** | The player to sync data with. If nil, syncs with all players |

#### ↩️ Returns
* None - Data is sent asynchronously via network messages

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Sync data with a single player
    lia.swepeditor.sync(player.GetByID(1))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Sync data with all players in a faction
    local factionID = 1
    for _, ply in player.Iterator() do
        if ply:getChar() and ply:getChar():getFaction() == factionID then
            lia.swepeditor.sync(ply)
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Sync data with validation and error handling
    local function syncPlayerWeaponData(player)
        if not IsValid(player) then
            print("[SWEP Editor] Invalid player provided to sync")
            return false
        end
        if not player:getChar() then
            print("[SWEP Editor] Player has no character, skipping sync")
            return false
        end
        lia.db.query("SELECT * FROM lia_swepeditor", function(results)
            if results then
                local syncedCount = 0
                for _, row in ipairs(results) do
                    local class = row.class
                    local saveData = util.JSONToTable(row.data)
                    if saveData and lia.swepeditor.NetworkData[class] then
                        net.Start("liaSwepeditorLoad")
                        net.WriteTable(lia.swepeditor.NetworkData[class])
                        net.WriteString(class)
                        net.Send(player)
                        syncedCount = syncedCount + 1
                    end
                end
                print("[SWEP Editor] Synced " .. syncedCount .. " weapons with " .. player:Name())
            else
                print("[SWEP Editor] No weapon data found in database")
            end
        end)
        return true
    end
    syncPlayerWeaponData(player.GetByID(1))

```

---

### lia.swepeditor.adjustValue

#### 📋 Purpose
Adjust a specific value in a weapon's configuration using a hierarchical key path

#### ⏰ When Called
When applying SWEP editor changes or hardcoded overrides to weapon properties

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `weapon` | **string** | The weapon class name to modify |
| `key` | **string** | The hierarchical key path (e.g., "Primary | Damage" or "Primary | RPM") |
| `value` | **any** | The value to set for the specified key |

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Adjust pistol damage
    lia.swepeditor.adjustValue("weapon_pistol", "Primary | Damage", 100)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Adjust multiple properties with validation
    local weaponClass = "weapon_smg1"
    local adjustments = {
        {"Primary | Damage", 25},
        {"Primary | RPM", 800},
        {"Primary | ClipSize", 45}
    }
    for _, adjustment in ipairs(adjustments) do
        local key, value = adjustment[1], adjustment[2]
        lia.swepeditor.adjustValue(weaponClass, key, value)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Adjust weapon properties with nested tables and error handling
    local function adjustWeaponProperties(weaponClass, propertyTable)
        if not weapons.GetStored(weaponClass) then
            print("[SWEP Editor] Weapon " .. weaponClass .. " not found")
            return false
        end
        local adjustedCount = 0
        for keyPath, value in pairs(propertyTable) do
            -- Handle nested table values
            if istable(value) then
                for subKey, subValue in pairs(value) do
                    local fullKey = keyPath .. " | " .. subKey
                    lia.swepeditor.adjustValue(weaponClass, fullKey, subValue)
                    adjustedCount = adjustedCount + 1
                end
            else
                lia.swepeditor.adjustValue(weaponClass, keyPath, value)
                adjustedCount = adjustedCount + 1
            end
        end
        print("[SWEP Editor] Adjusted " .. adjustedCount .. " properties for " .. weaponClass)
        return true
    end
    adjustWeaponProperties("weapon_shotgun", {
        ["Primary | Damage"] = 200,
        ["Primary | NumShots"] = 12,
        ["Secondary"] = {
            ["Damage"] = 50,
            ["ClipSize"] = 8
        }
    })

```

---

### lia.swepeditor.copyTable

#### 📋 Purpose
Create a deep copy of a table, preserving metatables and handling circular references

#### ⏰ When Called
When storing weapon default values or creating override copies to prevent reference issues

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `obj` | **table** | The table to copy |
| `seen` | **table, optional** | Internal parameter for tracking circular references |

#### ↩️ Returns
* table - A deep copy of the original table

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Copy a basic table
    local original = {damage = 25, rpm = 600}
    local copy = lia.swepeditor.copyTable(original)
    copy.damage = 50 -- Original remains unchanged

```

#### 📊 Medium Complexity
```lua
    -- Medium: Copy weapon configuration with nested tables
    local weaponConfig = {
        Primary = {Damage = 25, RPM = 600},
        Secondary = {Damage = 50}
    }
    local configCopy = lia.swepeditor.copyTable(weaponConfig)
    configCopy.Primary.Damage = 100 -- Original Primary.Damage still 25

```

#### ⚙️ High Complexity
```lua
    -- High: Copy complex nested structures with circular references
    local complexWeapon = {
        Primary = {
            Damage = 25,
            SoundData = {volume = 1.0, pitch = 100}
        },
        ViewModel = "models/weapons/v_pistol.mdl"
    }
    -- Add a circular reference
    complexWeapon.Primary.Parent = complexWeapon
    local function safeCopyTable(tbl)
        local copiedTables = {}
        local function copyWithCircularCheck(t, refs)
            if copiedTables[t] then return copiedTables[t] end
            refs = refs or {}
            if refs[t] then
                -- Return a placeholder for circular references
                return "[CIRCULAR REFERENCE]"
            end
            refs[t] = true
            local copy = lia.swepeditor.copyTable(t, refs)
            refs[t] = nil
            copiedTables[t] = copy
            return copy
        end
        return copyWithCircularCheck(tbl)
    end
    local safeCopy = safeCopyTable(complexWeapon)
    print("Copied weapon with circular reference handling")

```

---

### lia.swepeditor.overrideWeapon

#### 📋 Purpose
Apply hardcoded overrides to a weapon, working alongside the ingame editor

#### ⏰ When Called
During weapon initialization or when setting up weapon modifications

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `weaponClass` | **string** | The weapon class name to override (e.g., "weapon_pistol") |
| `overrideTable` | **table** | Table containing the override values in nested structure |

#### ↩️ Returns
* boolean - True if override was applied successfully, false otherwise

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Override pistol with enhanced damage and recoil
    lia.swepeditor.overrideWeapon("weapon_pistol", {
        Primary = {
            Damage = 100,
            Recoil = 0.5,
            NumShots = 1,
            Cone = 0.02,
            Delay = 0.1
        },
        PrintName = "Enhanced Pistol",
        ViewModelFlip = false
    })

```

#### 📊 Medium Complexity
```lua
    -- Medium: Override SMG with complex firing mechanics and custom sounds
    lia.swepeditor.overrideWeapon("weapon_smg1", {
        Primary = {
            Damage = 25,
            RPM = 800,
            ClipSize = 45,
            Automatic = true,
            Spread = 0.08,
            Recoil = 0.3,
            Sound = "weapons/smg1/smg1_fire1.wav",
            Tracer = 1,
            TracerName = "Tracer",
            Force = 5
        },
        Secondary = {
            Damage = 50,
            ClipSize = 2,
            Sound = "weapons/smg1/smg1_fire1.wav"
        },
        Weight = 3,
        Slot = 2,
        SlotPos = 1,
        ViewModel = "models/weapons/v_smg1.mdl",
        WorldModel = "models/weapons/w_smg1.mdl"
    })

```

#### ⚙️ High Complexity
```lua
    -- High: Dynamic weapon balancing system with faction-based overrides
    local FACTION_WEAPON_BALANCE = {
        -- Military faction gets powerful weapons
        [FACTION_MILITARY] = {
            weapon_pistol = {
                Primary = {Damage = 120, RPM = 400, Recoil = 0.2},
                PrintName = "Military Sidearm"
            },
            weapon_smg1 = {
                Primary = {Damage = 35, RPM = 900, ClipSize = 60},
                PrintName = "Military SMG"
            },
            weapon_shotgun = {
                Primary = {Damage = 250, NumShots = 16, RPM = 120},
                PrintName = "Military Shotgun"
            }
        },
        -- Police faction gets balanced weapons
        [FACTION_POLICE] = {
            weapon_pistol = {
                Primary = {Damage = 80, RPM = 300, Recoil = 0.4},
                PrintName = "Police Sidearm"
            },
            weapon_smg1 = {
                Primary = {Damage = 20, RPM = 600, ClipSize = 30},
                PrintName = "Police SMG"
            }
        },
        -- Civilian faction gets weaker weapons
        [FACTION_CIVILIAN] = {
            weapon_pistol = {
                Primary = {Damage = 25, RPM = 200, Recoil = 0.8},
                PrintName = "Civilian Pistol"
            }
        }
    }
    local function applyFactionWeaponOverrides(ply)
        if not ply:getChar() then return end
        local faction = ply:getChar():getFaction()
        local factionOverrides = FACTION_WEAPON_BALANCE[faction]
        if factionOverrides then
            local appliedCount = 0
            for weaponClass, overrideData in pairs(factionOverrides) do
                -- Add faction-specific visual effects
                overrideData.ViewModelFlip = math.random() > 0.5
                overrideData.Weight = overrideData.Weight or 2
                if lia.swepeditor.overrideWeapon(weaponClass, overrideData) then
                    appliedCount = appliedCount + 1
                    ply:ChatPrint("Applied " .. overrideData.PrintName .. " balance")
                end
            end
            print("[Weapon Balance] Applied " .. appliedCount .. " weapon overrides for " .. ply:Name())
        end
    end
    -- Apply to all online players
    for _, ply in player.Iterator() do
        applyFactionWeaponOverrides(ply)
    end
    -- Hook into character loading to apply on join
    hook.Add("PlayerLoadedChar", "ApplyFactionWeaponBalance", function(ply)
        timer.Simple(1, function() -- Delay to ensure weapons are loaded
            if IsValid(ply) then
                applyFactionWeaponOverrides(ply)
            end
        end)
    end)

```

---

### lia.swepeditor.applyOverrides

#### 📋 Purpose
Apply hardcoded overrides to a weapon, working alongside the ingame editor

#### ⏰ When Called
During weapon initialization or when setting up weapon modifications

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `weaponClass` | **string** | The weapon class name to override (e.g., "weapon_pistol") |
| `overrideTable` | **table** | Table containing the override values in nested structure |

#### ↩️ Returns
* boolean - True if override was applied successfully, false otherwise

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Override pistol with enhanced damage and recoil
    lia.swepeditor.overrideWeapon("weapon_pistol", {
        Primary = {
            Damage = 100,
            Recoil = 0.5,
            NumShots = 1,
            Cone = 0.02,
            Delay = 0.1
        },
        PrintName = "Enhanced Pistol",
        ViewModelFlip = false
    })

```

#### 📊 Medium Complexity
```lua
    -- Medium: Override SMG with complex firing mechanics and custom sounds
    lia.swepeditor.overrideWeapon("weapon_smg1", {
        Primary = {
            Damage = 25,
            RPM = 800,
            ClipSize = 45,
            Automatic = true,
            Spread = 0.08,
            Recoil = 0.3,
            Sound = "weapons/smg1/smg1_fire1.wav",
            Tracer = 1,
            TracerName = "Tracer",
            Force = 5
        },
        Secondary = {
            Damage = 50,
            ClipSize = 2,
            Sound = "weapons/smg1/smg1_fire1.wav"
        },
        Weight = 3,
        Slot = 2,
        SlotPos = 1,
        ViewModel = "models/weapons/v_smg1.mdl",
        WorldModel = "models/weapons/w_smg1.mdl"
    })

```

#### ⚙️ High Complexity
```lua
    -- High: Dynamic weapon balancing system with faction-based overrides
    local FACTION_WEAPON_BALANCE = {
        -- Military faction gets powerful weapons
        [FACTION_MILITARY] = {
            weapon_pistol = {
                Primary = {Damage = 120, RPM = 400, Recoil = 0.2},
                PrintName = "Military Sidearm"
            },
            weapon_smg1 = {
                Primary = {Damage = 35, RPM = 900, ClipSize = 60},
                PrintName = "Military SMG"
            },
            weapon_shotgun = {
                Primary = {Damage = 250, NumShots = 16, RPM = 120},
                PrintName = "Military Shotgun"
            }
        },
        -- Police faction gets balanced weapons
        [FACTION_POLICE] = {
            weapon_pistol = {
                Primary = {Damage = 80, RPM = 300, Recoil = 0.4},
                PrintName = "Police Sidearm"
            },
            weapon_smg1 = {
                Primary = {Damage = 20, RPM = 600, ClipSize = 30},
                PrintName = "Police SMG"
            }
        },
        -- Civilian faction gets weaker weapons
        [FACTION_CIVILIAN] = {
            weapon_pistol = {
                Primary = {Damage = 25, RPM = 200, Recoil = 0.8},
                PrintName = "Civilian Pistol"
            }
        }
    }
    local function applyFactionWeaponOverrides(ply)
        if not ply:getChar() then return end
        local faction = ply:getChar():getFaction()
        local factionOverrides = FACTION_WEAPON_BALANCE[faction]
        if factionOverrides then
            local appliedCount = 0
            for weaponClass, overrideData in pairs(factionOverrides) do
                -- Add faction-specific visual effects
                overrideData.ViewModelFlip = math.random() > 0.5
                overrideData.Weight = overrideData.Weight or 2
                if lia.swepeditor.overrideWeapon(weaponClass, overrideData) then
                    appliedCount = appliedCount + 1
                    ply:ChatPrint("Applied " .. overrideData.PrintName .. " balance")
                end
            end
            print("[Weapon Balance] Applied " .. appliedCount .. " weapon overrides for " .. ply:Name())
        end
    end
    -- Apply to all online players
    for _, ply in player.Iterator() do
        applyFactionWeaponOverrides(ply)
    end
    -- Hook into character loading to apply on join
    hook.Add("PlayerLoadedChar", "ApplyFactionWeaponBalance", function(ply)
        timer.Simple(1, function() -- Delay to ensure weapons are loaded
            if IsValid(ply) then
                applyFactionWeaponOverrides(ply)
            end
        end)
    end)

```

---


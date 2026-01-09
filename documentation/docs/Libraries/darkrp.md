# DarkRP Compatibility Library

The DarkRP compatibility library provides essential functions for maintaining compatibility

---

### lia.darkrp.isEmpty

#### 📋 Purpose
Determine whether a position is free of solid contents, players, NPCs, or props.

#### ⏰ When Called
Before spawning DarkRP-style shipments or entities to ensure the destination is clear.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | **Vector** | World position to test. |
| `entitiesToIgnore` | **table|nil** | Optional list of entities that should be excluded from the collision check. |

#### ↩️ Returns
* boolean
true when the spot contains no blocking contents or entities; otherwise false.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local spawnPos = ent:GetPos() + Vector(0, 0, 16)
    if lia.darkrp.isEmpty(spawnPos) then
        lia.darkrp.createEntity("Ammo Crate", {ent = "item_ammo_crate", model = "models/Items/ammocrate_smg1.mdl"})
    end

```

---

### lia.darkrp.findEmptyPos

#### 📋 Purpose
Locate the nearest empty position around a starting point within a search radius.

#### ⏰ When Called
Selecting safe fallback positions for DarkRP-style shipments or NPC spawns.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `startPos` | **Vector** | Origin position to test first. |
| `entitiesToIgnore` | **table|nil** | Optional list of entities to ignore while searching. |
| `maxDistance` | **number** | Maximum distance to search away from the origin. |
| `searchStep` | **number** | Increment used when expanding the search radius. |
| `checkArea` | **Vector** | Additional offset tested to ensure enough clearance (for hull height, etc.). |

#### ↩️ Returns
* Vector
First empty position discovered; if none found, returns startPos.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local spawnPos = lia.darkrp.findEmptyPos(requestPos, nil, 256, 16, Vector(0, 0, 32))
    npc:SetPos(spawnPos)

```

---

### lia.darkrp.notify

#### 📋 Purpose
Provide a DarkRP-compatible wrapper for Lilia's localized notify system.

#### ⏰ When Called
From DarkRP addons or compatibility code that expects DarkRP.notify to exist.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Recipient of the notification. |
| `notifyType` | **number** | Unused legacy parameter kept for API parity. |
| `duration` | **number** | Unused legacy parameter kept for API parity. |
| `message` | **string** | Localization key or message to pass to Lilia's notifier. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.darkrp.notify(ply, NOTIFY_GENERIC, 4, "You received a paycheck.")

```

---

### lia.darkrp.textWrap

#### 📋 Purpose
Wrap long text to a maximum line width based on the active surface font metrics.

#### ⏰ When Called
Preparing DarkRP-compatible messages for HUD or chat rendering without overflow.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | **string** | Message to wrap. |
| `fontName` | **string** | Name of the font to measure. |
| `maxLineWidth` | **number** | Maximum pixel width allowed per line before inserting a newline. |

#### ↩️ Returns
* string
Wrapped text with newline characters inserted.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local wrapped = lia.darkrp.textWrap("A very long notice message...", "DermaDefault", 240)
    chat.AddText(color_white, wrapped)

```

---

### lia.darkrp.formatMoney

#### 📋 Purpose
Format a currency amount using Lilia's currency system while matching DarkRP's API.

#### ⏰ When Called
Anywhere DarkRP.formatMoney is expected by compatibility layers or addons.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `amount` | **number** | Currency amount to format. |

#### ↩️ Returns
* string
Localized and formatted currency string.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local paycheck = DarkRP.formatMoney(500)
    chat.AddText(L("paydayReceived", paycheck))

```

---

### lia.darkrp.createEntity

#### 📋 Purpose
Register a DarkRP entity definition as a Lilia item for compatibility.

#### ⏰ When Called
While converting DarkRP shipments or entities into Lilia items at load time.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Display name for the item. |
| `data` | **table** | Supported fields: cmd, ent, model, desc, price, category. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.darkrp.createEntity("Ammo Crate", {
        ent = "item_ammo_crate",
        model = "models/Items/ammocrate_smg1.mdl",
        price = 750,
        category = "Supplies"
    })

```

---

### lia.darkrp.createCategory

#### 📋 Purpose
Provide an API stub for DarkRP category creation.

#### ⏰ When Called
Invoked by DarkRP.createCategory during addon initialization; intentionally no-op.

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- API parity only; this function performs no actions.
    lia.darkrp.createCategory()

```

---


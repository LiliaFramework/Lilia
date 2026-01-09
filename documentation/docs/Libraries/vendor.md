# Vendor Library

NPC vendor management system with editing and rarity support for the Lilia framework.

---

Overview

The vendor library provides comprehensive functionality for managing NPC vendors in the Lilia framework. It handles vendor configuration, editing, presets, and rarity systems for items sold by vendors. The library operates on both server and client sides, with the server handling vendor data processing and the client managing the editing interface. It includes support for vendor presets, item rarities, stock management, pricing, faction/class restrictions, and visual customization. The library ensures that vendors can be easily configured and managed through both code and in-game editing tools.

---

### lia.vendor.addPreset

#### 📋 Purpose
Register a reusable vendor item preset with validated entries.

#### ⏰ When Called
During initialization to define canned loadouts for vendors (e.g., weapon dealer, medic).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Unique preset name. |
| `items` | **table** | Map of item uniqueIDs to tables with pricing/stock metadata. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Define a preset and apply it dynamically based on map location.
    lia.vendor.addPreset("gunsmith", {
        ar15 = {stock = 3, price = 3500},
        akm = {stock = 2, price = 3200},
        ["9mm"] = {stock = 50, price = 30}
    })
    hook.Add("OnVendorSpawned", "SetupMapVendors", function(vendorEnt)
        if vendorEnt:GetClass() ~= "lia_vendor" then return end
        local zone = lia.zones and lia.zones.getNameAtPos(vendorEnt:GetPos()) or "default"
        if zone == "Armory" then
            vendorEnt:applyPreset("gunsmith")
            vendorEnt:setFactionAllowed(FACTION_POLICE, true)
        end
    end)

```

---

### lia.vendor.getPreset

#### 📋 Purpose
Retrieve a preset definition by name.

#### ⏰ When Called
While applying presets to vendors or inspecting available vendor templates.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Preset identifier (case-insensitive). |

#### ↩️ Returns
* table|nil
Item definition table if present.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Clone and tweak a preset before applying to a specific vendor.
    local preset = table.Copy(lia.vendor.getPreset("gunsmith") or {})
    if preset then
        preset["9mm"].price = 25
        preset["akm"] = nil -- remove AKM for this vendor
        vendor:applyPreset("gunsmith") -- base preset
        for item, data in pairs(preset) do
            vendor:setItemPrice(item, data.price)
            if data.stock then vendor:setMaxStock(item, data.stock) end
        end
    end

```

---

### lia.vendor.getVendorProperty

#### 📋 Purpose
Fetch a vendor property from cache with default fallback.

#### ⏰ When Called
Anywhere vendor state is read (pricing, stock, model, etc.).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | Vendor NPC entity. |
| `property` | **string** | Property key from `lia.vendor.defaults`. |

#### ↩️ Returns
* any
Cached property value or default.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Build a UI row with live vendor state (including defaults).
    local function addVendorRow(list, vendorEnt)
        local name = lia.vendor.getVendorProperty(vendorEnt, "name")
        local cash = lia.vendor.getVendorProperty(vendorEnt, "money") or 0
        local items = lia.vendor.getVendorProperty(vendorEnt, "items")
        list:AddLine(name, cash, table.Count(items or {}))
    end

```

---

### lia.vendor.setVendorProperty

#### 📋 Purpose
Mutate a vendor property, pruning defaults to keep network/state lean.

#### ⏰ When Called
During vendor edits (net messages) or when scripting dynamic vendor behavior.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | Vendor NPC entity. |
| `property` | **string** | Key to update. |
| `value` | **any** | New value to store; default-equivalent values clear the entry. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Dynamically flip vendor inventory for an event and prune defaults.
    hook.Add("EventStarted", "StockEventVendors", function()
        for _, vendorEnt in ipairs(ents.FindByClass("lia_vendor")) do
            lia.vendor.setVendorProperty(vendorEnt, "items", {
                ["event_ticket"] = {stock = 100, price = 0},
                ["rare_crate"] = {stock = 5, price = 7500}
            })
        end
    end)

```

---

### lia.vendor.syncVendorProperty

#### 📋 Purpose
Broadcast a vendor property update to all clients.

#### ⏰ When Called
Server-side after mutating vendor properties to keep clients in sync.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | Vendor NPC entity. |
| `property` | **string** | Key being synchronized. |
| `value` | **any** | New value for the property. |
| `isDefault` | **boolean** | Whether the property should be cleared (uses defaults clientside). |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Force sync after a server-side rebuild of vendor data.
    local function rebuildVendor(vendorEnt)
        lia.vendor.setVendorProperty(vendorEnt, "name", "Quartermaster")
        lia.vendor.setVendorProperty(vendorEnt, "factionSellScales", { [FACTION_POLICE] = 0.8 })
        lia.vendor.syncVendorProperty(vendorEnt, "name", "Quartermaster", false)
        lia.vendor.syncVendorProperty(vendorEnt, "factionSellScales", { [FACTION_POLICE] = 0.8 }, false)
    end

```

---

### lia.vendor.getAllVendorData

#### 📋 Purpose
Build a full vendor state table with defaults applied.

#### ⏰ When Called
Before serializing vendor data for saving or sending to clients.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | Vendor NPC entity. |

#### ↩️ Returns
* table
Key-value table covering every defaulted vendor property.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Serialize full vendor state for a persistence layer.
    net.Receive("RequestVendorSnapshot", function(_, ply)
        local ent = net.ReadEntity()
        local data = lia.vendor.getAllVendorData(ent)
        if not data then return end
        lia.data.set("vendor_" .. ent:EntIndex(), data)
        net.Start("SendVendorSnapshot")
        net.WriteTable(data)
        net.Send(ply)
    end)

```

---


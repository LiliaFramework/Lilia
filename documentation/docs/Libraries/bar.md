# Bars Library

Dynamic progress bar creation and management system for the Lilia framework.

---

Overview

The bars library provides a comprehensive system for creating and managing dynamic progress bars in the Lilia framework. It handles the creation, rendering, and lifecycle management of various types of bars including health, armor, and custom progress indicators. The library operates primarily on the client side, providing smooth animated transitions between bar values and intelligent visibility management based on value changes and user preferences. It includes built-in health and armor bars, custom action progress displays, and a flexible system for adding custom bars with priority-based ordering. The library ensures consistent visual presentation across all bar types while providing hooks for customization and integration with other framework components.

---

### lia.bar.get

#### 📋 Purpose
Retrieve a registered bar definition by its identifier.

#### ⏰ When Called
Before updating/removing an existing bar or inspecting its state.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `identifier` | **string|nil** | Unique bar id supplied when added. |

#### ↩️ Returns
* table|nil
Stored bar data or nil if not found.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local staminaBar = lia.bar.get("stamina")
    if staminaBar then
        print("Current priority:", staminaBar.priority)
    end

```

---

### lia.bar.add

#### 📋 Purpose
Register a new dynamic bar with optional priority and identifier.

#### ⏰ When Called
Client HUD setup or when creating temporary action/status bars.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `getValue` | **function** | Returns current fraction (0-1) when called. |
| `color` | **Color|nil** | Bar color; random bright color if nil. |
| `priority` | **number|nil** | Lower draws earlier; defaults to append order. |
| `identifier` | **string|nil** | Unique id; replaces existing bar with same id. |

#### ↩️ Returns
* number
Priority used for the bar.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- Add a stamina bar that fades after inactivity.
    lia.bar.add(function()
        local client = LocalPlayer()
        local stamina = client:getLocalVar("stm", 100)
        return math.Clamp(stamina / 100, 0, 1)
    end, Color(120, 200, 80), 2, "stamina")

```

---

### lia.bar.remove

#### 📋 Purpose
Remove a bar by its identifier.

#### ⏰ When Called
After a timed action completes or when disabling a HUD element.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `identifier` | **string** | Unique id passed during add. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    timer.Simple(5, function() lia.bar.remove("stamina") end)

```

---

### lia.bar.drawBar

#### 📋 Purpose
Draw a single bar at a position with given fill and color.

#### ⏰ When Called
Internally from drawAll or for custom bars in panels.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pos` | **number** | Current value. |
| `max` | **number** | Maximum value. |
| `color` | **Color** | Fill color. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- Custom panel painting a download progress bar.
    function PANEL:Paint(w, h)
        lia.bar.drawBar(10, h - 24, w - 20, 16, self.progress, 1, Color(120, 180, 255))
    end

```

---

### lia.bar.drawAction

#### 📋 Purpose
Show a centered action bar with text and timed progress.

#### ⏰ When Called
For timed actions like searching, hacking, or channeling abilities.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | **string** | Label to display. |
| `duration` | **number** | Seconds to run before auto-removal. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("OnStartSearch", "ShowSearchBar", function(duration)
        lia.bar.drawAction(L("searchingChar"), duration)
    end)

```

---

### lia.bar.drawAll

#### 📋 Purpose
Render all registered bars with smoothing, lifetimes, and ordering.

#### ⏰ When Called
Each HUDPaintBackground (hooked at bottom of file).

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- Bars are drawn automatically via the HUDPaintBackground hook.
    -- For custom derma panels, you could manually call lia.bar.drawAll().

```

---


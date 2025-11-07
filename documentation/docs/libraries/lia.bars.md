# Bars Library

Dynamic progress bar creation and management system for the Lilia framework.

---

Overview

The bars library provides a comprehensive system for creating and managing dynamic progress bars in the Lilia framework. It handles the creation, rendering, and lifecycle management of various types of bars including health, armor, and custom progress indicators. The library operates primarily on the client side, providing smooth animated transitions between bar values and intelligent visibility management based on value changes and user preferences. It includes built-in health and armor bars, custom action progress displays, and a flexible system for adding custom bars with priority-based ordering. The library ensures consistent visual presentation across all bar types while providing hooks for customization and integration with other framework components.

---

### lia.bar.get

#### 📋 Purpose
Retrieves a bar object by its identifier from the bars list

#### ⏰ When Called
When you need to access or modify an existing bar's properties

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `identifier` | **string** | The unique identifier of the bar to retrieve |

#### ↩️ Returns
* table|nil - The bar object if found, nil otherwise

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get a bar by identifier
    local healthBar = lia.bar.get("health")
    if healthBar then
        print("Health bar found")
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get and modify bar properties
    local customBar = lia.bar.get("custom_stamina")
    if customBar then
        customBar.color = Color(255, 255, 0)
        customBar.priority = 2
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Dynamic bar management with validation
    local barIdentifiers = {"health", "armor", "stamina", "hunger"}
    for _, id in ipairs(barIdentifiers) do
        local bar = lia.bar.get(id)
        if bar then
            bar.lifeTime = CurTime() + 10
            print("Extended lifetime for " .. id .. " bar")
        else
            print("Bar " .. id .. " not found")
        end
    end

```

---

### lia.bar.add

#### 📋 Purpose
Adds a new progress bar to the bars system with specified properties

#### ⏰ When Called
When creating custom bars or adding new progress indicators to the HUD

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `getValue` | **function** | Function that returns the current value (0-1) for the bar |
| `color` | **Color** | Color of the bar fill (optional, defaults to random color) |
| `priority` | **number** | Display priority, lower numbers appear first (optional) |
| `identifier` | **string** | Unique identifier for the bar (optional) |

#### ↩️ Returns
* number - The priority assigned to the bar

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add a basic health bar
    lia.bar.add(function()
        return LocalPlayer():Health() / LocalPlayer():GetMaxHealth()
    end, Color(255, 0, 0), 1, "health")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add a custom stamina bar with validation
    lia.bar.add(function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return 0 end
        return ply:GetNWFloat("stamina", 100) / 100
    end, Color(0, 255, 0), 2, "stamina")

```

#### ⚙️ High Complexity
```lua
    -- High: Dynamic bar creation with multiple conditions
    local function createConditionalBar(condition, getValue, color, priority, id)
        if condition then
            return lia.bar.add(function()
                local ply = LocalPlayer()
                if not IsValid(ply) then return 0 end
                return getValue(ply)
            end, color, priority, id)
        end
        return nil
    end
    createConditionalBar(
        true,
        function(ply) return ply:Armor() / ply:GetMaxArmor() end,
        Color(0, 0, 255),
        3,
        "armor"
    )

```

---

### lia.bar.remove

#### 📋 Purpose
Removes a bar from the bars system by its identifier

#### ⏰ When Called
When you need to remove a specific bar from the HUD or clean up bars

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `identifier` | **string** | The unique identifier of the bar to remove |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Remove a bar by identifier
    lia.bar.remove("health")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Conditionally remove bars
    if not player:HasPermission("see_health") then
        lia.bar.remove("health")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Remove multiple bars with validation
    local barsToRemove = {"stamina", "hunger", "thirst"}
    for _, barId in ipairs(barsToRemove) do
        local bar = lia.bar.get(barId)
        if bar then
            lia.bar.remove(barId)
            print("Removed bar: " .. barId)
        end
    end

```

---

### lia.bar.drawBar

#### 📋 Purpose
Draws a single progress bar at specified coordinates with given properties

#### ⏰ When Called
Internally by the bars system or when manually drawing custom bars

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | **number** | X coordinate for the bar position |
| `y` | **number** | Y coordinate for the bar position |
| `w` | **number** | Width of the bar |
| `h` | **number** | Height of the bar |
| `pos` | **number** | Current progress value (0-max) |
| `max` | **number** | Maximum value for the bar |
| `color` | **Color** | Color of the bar fill |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Draw a basic progress bar
    lia.bar.drawBar(10, 10, 200, 20, 75, 100, Color(255, 0, 0))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Draw a bar with calculated values
    local health = LocalPlayer():Health()
    local maxHealth = LocalPlayer():GetMaxHealth()
    lia.bar.drawBar(10, 10, 200, 20, health, maxHealth, Color(255, 0, 0))

```

#### ⚙️ High Complexity
```lua
    -- High: Dynamic bar drawing with multiple conditions
    local function drawCustomBar(x, y, w, h, value, maxValue, color, condition)
        if condition and value > 0 then
            local normalizedValue = math.min(value, maxValue)
            lia.bar.drawBar(x, y, w, h, normalizedValue, maxValue, color)
        end
    end
    drawCustomBar(10, 10, 200, 20, player:Health(), player:GetMaxHealth(),
        Color(255, 0, 0), player:Alive())

```

---

### lia.bar.drawAction

#### 📋 Purpose
Draws a temporary action progress bar with text overlay for timed actions

#### ⏰ When Called
When displaying progress for actions like reloading, healing, or other timed activities

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | **string** | Text to display above the progress bar |
| `duration` | **number** | Duration in seconds for the action to complete |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Show reload progress
    lia.bar.drawAction("Reloading...", 2.5)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Show healing progress with dynamic text
    local healAmount = 50
    lia.bar.drawAction("Healing for " .. healAmount .. " HP", 3.0)

```

#### ⚙️ High Complexity
```lua
    -- High: Conditional action display with multiple states
    local function showActionProgress(actionType, duration, data)
        local text = ""
        if actionType == "heal" then
            text = "Healing for " .. (data.amount or 25) .. " HP"
        elseif actionType == "repair" then
            text = "Repairing " .. (data.item or "item")
        elseif actionType == "craft" then
            text = "Crafting " .. (data.item or "item")
        end
        if text ~= "" then
            lia.bar.drawAction(text, duration)
        end
    end
    showActionProgress("heal", 2.5, {amount = 75})

```

---

### lia.bar.drawAll

#### 📋 Purpose
Renders all registered bars in priority order with smooth animations and visibility management

#### ⏰ When Called
Automatically called during HUDPaintBackground hook, or manually for custom rendering

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Manually trigger bar rendering
    lia.bar.drawAll()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Custom rendering with conditions
    hook.Add("HUDPaint", "CustomBarRender", function()
        if not hook.Run("ShouldHideBars") then
            lia.bar.drawAll()
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Advanced rendering with custom positioning and filtering
    local function customDrawAll()
        if hook.Run("ShouldHideBars") then return end
        -- Custom positioning logic
        local baseX, baseY = 10, 10
        local barSpacing = 18
        -- Sort bars by priority
        table.sort(lia.bar.list, function(a, b)
            if a.priority == b.priority then
                return (a.order or 0) < (b.order or 0)
            end
            return a.priority < b.priority
        end)
        -- Draw each bar with custom logic
        for i, bar in ipairs(lia.bar.list) do
            if hook.Run("ShouldBarDraw", bar) then
                local y = baseY + (i - 1) * barSpacing
                lia.bar.drawBar(baseX, y, 200, 14, bar.getValue(), 1, bar.color)
            end
        end
    end

```

---


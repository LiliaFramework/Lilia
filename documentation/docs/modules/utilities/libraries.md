# Utilities Library

Utility helpers for colors, time, math, debug printing, and simple entity spawning.

---

Overview

The utilities library provides a comprehensive collection of helper functions for common scripting tasks in the Lilia framework. It includes utilities for color manipulation (HSV interpolation, blending, darkening, lightening), time and date operations (formatting, conversion, difference calculations), vector and angle serialization, debug printing, and server-side entity spawning. The library operates primarily in the shared realm, making functions available on both client and server, with some server-specific functions for entity management. It serves as a central library used by other modules and provides shared constants and utilities for networking data.

---

### lia.utilities.speedTest

#### 📋 Purpose
Run a function repeatedly and measure the elapsed time.

#### ⏰ When Called
When benchmarking a function's performance or measuring execution time.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `func` | **function** | Function to call repeatedly |
| `n` | **number** | Number of iterations to run |

#### ↩️ Returns
* number - Elapsed time in seconds per iteration

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Benchmark a function
    local took = lia.utilities.speedTest(function() end, 1e5)
    print(took)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Compare function performance
    local function testFunc()
        local sum = 0
        for i = 1, 100 do sum = sum + i end
    end
    local avgTime = lia.utilities.speedTest(testFunc, 1000)
    print("Average time: " .. avgTime .. " seconds")

```

#### ⚙️ High Complexity
```lua
    -- High: Benchmark multiple functions with analysis
    local functions = {
        {name = "Function A", func = functionA},
        {name = "Function B", func = functionB}
    }
    for _, data in ipairs(functions) do
        local time = lia.utilities.speedTest(data.func, 1e5)
        print(data.name .. " took " .. time .. " seconds per iteration")
    end

```

---

### lia.utilities.daysBetween

#### 📋 Purpose
Return the number of days between two timestamps or time strings.

#### ⏰ When Called
When comparing dates for cooldowns, reports, or time-based calculations.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `t1` | **string\|number** | First time (timestamp or formatted string) |
| `t2` | **string\|number** | Second time (timestamp or formatted string) |

#### ↩️ Returns
* number - Whole or fractional days between the two times

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Calculate days between timestamps
    local days = lia.utilities.daysBetween(os.time(), os.time() + 172800)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check if cooldown has expired
    local lastUsed = player:GetPData("lastActionTime", "0")
    local daysSince = lia.utilities.daysBetween(lastUsed, os.time())
    if daysSince >= 7 then
        print("Cooldown expired")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Analyze multiple date ranges
    local dates = {
        {start = "2024-01-01", end = "2024-01-15"},
        {start = "2024-02-01", end = "2024-02-20"}
    }
    for _, dateRange in ipairs(dates) do
        local days = lia.utilities.daysBetween(dateRange.start, dateRange.end)
        print("Range spans " .. days .. " days")
    end

```

---

### lia.utilities.lerpHSV

#### 📋 Purpose
Interpolate between two colors in HSV color space.

#### ⏰ When Called
When animating color transitions or creating smooth color gradients.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `c1` | **Color** | Start color |
| `c2` | **Color** | End color |
| `maxVal` | **number** | Maximum range value |
| `curVal` | **number** | Current position in the range |
| `minVal` | **number** | Minimum range value (optional, defaults to 0) |

#### ↩️ Returns
* Color - Interpolated color between c1 and c2

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Interpolate between red and blue
    local c = lia.utilities.lerpHSV(Color(255,0,0), Color(0,0,255), 1, 0.5, 0)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Animate color based on health
    local health = player:Health()
    local maxHealth = player:GetMaxHealth()
    local color = lia.utilities.lerpHSV(
        Color(255, 0, 0),  -- Red (low health)
        Color(0, 255, 0),  -- Green (full health)
        maxHealth,
        health,
        0
    )

```

#### ⚙️ High Complexity
```lua
    -- High: Dynamic color system with multiple states
    local function getStatusColor(status, intensity)
        local colors = {
            good = Color(0, 255, 0),
            warning = Color(255, 255, 0),
            bad = Color(255, 0, 0)
        }
        local baseColor = colors[status] or colors.good
        return lia.utilities.lerpHSV(
            Color(50, 50, 50),  -- Dark base
            baseColor,
            100,
            intensity,
            0
        )
    end

```

---

### lia.utilities.darken

#### 📋 Purpose
Return a darker version of a color by reducing lightness.

#### ⏰ When Called
When you need to create a darker shade of an existing color.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `col` | **Color** | Base color to darken |
| `amt` | **number** | Amount to darken (0-1, where 1 is darkest) |

#### ↩️ Returns
* Color - Darkened color

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Darken a color
    local darkRed = lia.utilities.darken(Color(255, 0, 0), 0.5)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create darker variant for hover states
    local baseColor = Color(100, 150, 200)
    local hoverColor = lia.utilities.darken(baseColor, 0.3)

```

#### ⚙️ High Complexity
```lua
    -- High: Generate color palette with dark variants
    local function createColorPalette(baseColor)
        return {
            light = lia.utilities.lighten(baseColor, 0.3),
            base = baseColor,
            dark = lia.utilities.darken(baseColor, 0.3),
            darker = lia.utilities.darken(baseColor, 0.6)
        }
    end

```

---

### lia.utilities.lerpColor

#### 📋 Purpose
Linear interpolate between two colors in RGB color space.

#### ⏰ When Called
When you need smooth color transitions in RGB space rather than HSV.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `f` | **number** | Fraction between 0 and 1 (0 = from, 1 = to) |
| `from` | **Color** | Start color |
| `to` | **Color** | End color |

#### ↩️ Returns
* Color - Interpolated color

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Lerp between two colors
    local midColor = lia.utilities.lerpColor(0.5, Color(255,0,0), Color(0,0,255))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Animate color over time
    local function getAnimatedColor(t)
        return lia.utilities.lerpColor(
            math.sin(t) * 0.5 + 0.5,
            Color(255, 0, 0),
            Color(0, 255, 0)
        )
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Multi-color gradient system
    local function getGradientColor(colors, progress)
        progress = math.Clamp(progress, 0, 1)
        local segment = 1 / (#colors - 1)
        local index = math.floor(progress / segment) + 1
        index = math.min(index, #colors - 1)
        local localProgress = (progress % segment) / segment
        return lia.utilities.lerpColor(localProgress, colors[index], colors[index + 1])
    end

```

---

### lia.utilities.blend

#### 📋 Purpose
Blend two colors by a specified ratio.

#### ⏰ When Called
When you need to mix two colors together proportionally.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `a` | **Color** | First color |
| `b` | **Color** | Second color |
| `r` | **number** | Blend ratio (0-1, where 0 = a, 1 = b) |

#### ↩️ Returns
* Color - Blended color

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Blend two colors
    local mixed = lia.utilities.blend(Color(255,0,0), Color(0,0,255), 0.5)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Blend based on condition
    local function getConditionalColor(condition)
        local ratio = condition and 1.0 or 0.0
        return lia.utilities.blend(Color(255,0,0), Color(0,255,0), ratio)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Dynamic color blending system
    local function blendMultiple(colors, ratios)
        local result = colors[1]
        for i = 2, #colors do
            result = lia.utilities.blend(result, colors[i], ratios[i] or 0.5)
        end
        return result
    end

```

---

### lia.utilities.rgb

#### 📋 Purpose
Shorthand to create a Color object from RGB values.

#### ⏰ When Called
When you need a quick way to create color objects without typing Color().

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `r` | **number** | Red component (0-255) |
| `g` | **number** | Green component (0-255) |
| `b` | **number** | Blue component (0-255) |

#### ↩️ Returns
* Color - Color object

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Create a color
    local red = lia.utilities.rgb(255, 0, 0)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create color from variables
    local r, g, b = 128, 64, 192
    local color = lia.utilities.rgb(r, g, b)

```

#### ⚙️ High Complexity
```lua
    -- High: Generate color palette
    local function generatePalette(baseR, baseG, baseB, count)
        local palette = {}
        for i = 1, count do
            local factor = i / count
            palette[i] = lia.utilities.rgb(
                baseR * factor,
                baseG * factor,
                baseB * factor
            )
        end
        return palette
    end

```

---

### lia.utilities.rainbow

#### 📋 Purpose
Return a cycling rainbow color over time.

#### ⏰ When Called
When you need animated rainbow colors that cycle continuously.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `freq` | **number** | Speed factor for color cycling |

#### ↩️ Returns
* Color - Current rainbow color

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get rainbow color
    local rainbow = lia.utilities.rainbow(1)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Animate text with rainbow
    hook.Add("HUDPaint", "RainbowText", function()
        local color = lia.utilities.rainbow(0.5)
        draw.SimpleText("Rainbow Text", "DermaDefault", 100, 100, color)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Multiple rainbow elements with different speeds
    local function drawRainbowUI()
        local colors = {
            lia.utilities.rainbow(0.5),
            lia.utilities.rainbow(1.0),
            lia.utilities.rainbow(1.5)
        }
        for i, color in ipairs(colors) do
            draw.RoundedBox(0, 10, 10 + i * 30, 200, 20, color)
        end
    end

```

---

### lia.utilities.colorCycle

#### 📋 Purpose
Cycle between two colors over time.

#### ⏰ When Called
When you need smooth color transitions between two specific colors.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `a` | **Color** | First color |
| `b` | **Color** | Second color |
| `f` | **number** | Frequency/speed of cycling (optional, defaults to 1) |

#### ↩️ Returns
* Color - Current color in the cycle

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Cycle between two colors
    local color = lia.utilities.colorCycle(Color(255,0,0), Color(0,0,255))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Pulsing effect
    hook.Add("HUDPaint", "PulsingBox", function()
        local color = lia.utilities.colorCycle(Color(100,100,100), Color(255,255,255), 2)
        draw.RoundedBox(0, 10, 10, 200, 200, color)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Multi-state color cycling
    local function getStateColor(state)
        local colors = {
            idle = {Color(100,100,100), Color(150,150,150)},
            active = {Color(255,0,0), Color(255,255,0)},
            warning = {Color(255,100,0), Color(255,0,0)}
        }
        local stateColors = colors[state] or colors.idle
        return lia.utilities.colorCycle(stateColors[1], stateColors[2], 1.5)
    end

```

---

### lia.utilities.colorToHex

#### 📋 Purpose
Convert a Color object to a hexadecimal string format.

#### ⏰ When Called
When you need to convert colors to hex format for web or API usage.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `c` | **Color** | Color to convert |

#### ↩️ Returns
* string - Hexadecimal color string (e.g., "0xRRGGBB")

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Convert color to hex
    local hex = lia.utilities.colorToHex(Color(255, 0, 0))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Store color as hex string
    local color = Color(128, 64, 192)
    local hexString = lia.utilities.colorToHex(color)
    player:SetPData("favoriteColor", hexString)

```

#### ⚙️ High Complexity
```lua
    -- High: Export color palette to hex format
    local function exportPaletteToHex(palette)
        local hexPalette = {}
        for name, color in pairs(palette) do
            hexPalette[name] = lia.utilities.colorToHex(color)
        end
        return util.TableToJSON(hexPalette)
    end

```

---

### lia.utilities.lighten

#### 📋 Purpose
Return a lighter version of a color by increasing lightness.

#### ⏰ When Called
When you need to create a lighter shade of an existing color.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `col` | **Color** | Base color to lighten |
| `amt` | **number** | Amount to lighten (0-1, where 1 is lightest) |

#### ↩️ Returns
* Color - Lightened color

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Lighten a color
    local lightBlue = lia.utilities.lighten(Color(0, 0, 255), 0.5)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create lighter variant for UI elements
    local baseColor = Color(50, 50, 50)
    local highlightColor = lia.utilities.lighten(baseColor, 0.4)

```

#### ⚙️ High Complexity
```lua
    -- High: Generate full color scale
    local function createColorScale(baseColor, steps)
        local scale = {}
        for i = 0, steps do
            local amount = i / steps
            scale[i + 1] = lia.utilities.lighten(baseColor, amount)
        end
        return scale
    end

```

---

### lia.utilities.toText

#### 📋 Purpose
Serialize a Color to a human-readable string format.

#### ⏰ When Called
When you need to convert colors to text format for storage or display.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `c` | **Color** | Color to serialize |

#### ↩️ Returns
* string|nil - Color as "r,g,b,a" string, or nil if invalid

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Convert color to text
    local text = lia.utilities.toText(Color(255, 0, 0, 255))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Store color as text
    local color = Color(128, 64, 192, 255)
    local colorText = lia.utilities.toText(color)
    player:SetPData("uiColor", colorText)

```

#### ⚙️ High Complexity
```lua
    -- High: Serialize color palette
    local function serializePalette(palette)
        local serialized = {}
        for name, color in pairs(palette) do
            serialized[name] = lia.utilities.toText(color)
        end
        return util.TableToJSON(serialized)
    end

```

---

### lia.utilities.secondsToDHMS

#### 📋 Purpose
Convert seconds into days, hours, minutes, and seconds.

#### ⏰ When Called
When you need to break down a time duration into its components.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sec` | **number** | Total seconds to convert |

#### ↩️ Returns
* number, number, number, number - Days, hours, minutes, seconds

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Convert seconds to components
    local d, h, m, s = lia.utilities.secondsToDHMS(90061)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Format time remaining
    local function formatTimeRemaining(seconds)
        local d, h, m, s = lia.utilities.secondsToDHMS(seconds)
        local parts = {}
        if d > 0 then table.insert(parts, d .. "d") end
        if h > 0 then table.insert(parts, h .. "h") end
        if m > 0 then table.insert(parts, m .. "m") end
        if s > 0 then table.insert(parts, s .. "s") end
        return table.concat(parts, " ")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Multi-time formatting with localization
    local function formatTimes(times)
        local formatted = {}
        for i, seconds in ipairs(times) do
            local d, h, m, s = lia.utilities.secondsToDHMS(seconds)
            formatted[i] = {
                days = d,
                hours = h,
                minutes = m,
                seconds = s,
                formatted = string.format("%dd %dh %dm %ds", d, h, m, s)
            }
        end
        return formatted
    end

```

---

### lia.utilities.hMSToSeconds

#### 📋 Purpose
Convert hours, minutes, and seconds to total seconds.

#### ⏰ When Called
When you need to convert time components into a single duration value.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `h` | **number** | Hours |
| `m` | **number** | Minutes |
| `s` | **number** | Seconds |

#### ↩️ Returns
* number - Total seconds

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Convert time to seconds
    local seconds = lia.utilities.hMSToSeconds(2, 30, 45)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Calculate total duration
    local function calculateTotalDuration(periods)
        local total = 0
        for _, period in ipairs(periods) do
            total = total + lia.utilities.hMSToSeconds(period.h, period.m, period.s)
        end
        return total
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Schedule system with time conversion
    local function scheduleEvents(events)
        for _, event in ipairs(events) do
            local delay = lia.utilities.hMSToSeconds(event.hours, event.minutes, event.seconds)
            timer.Simple(delay, function()
                hook.Run("ScheduledEvent", event.name)
            end)
        end
    end

```

---

### lia.utilities.formatTimestamp

#### 📋 Purpose
Format a timestamp into a locale-friendly table or string.

#### ⏰ When Called
When you need to display timestamps in a readable format.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ts` | **number** | Unix timestamp |

#### ↩️ Returns
* table|string - Formatted time as table or string

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Format current time
    local formatted = lia.utilities.formatTimestamp(os.time())

```

#### 📊 Medium Complexity
```lua
    -- Medium: Format multiple timestamps
    local function formatTimestamps(timestamps)
        local formatted = {}
        for _, ts in ipairs(timestamps) do
            table.insert(formatted, lia.utilities.formatTimestamp(ts))
        end
        return formatted
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Logging system with formatted timestamps
    local function logEvent(event, data)
        local timestamp = lia.utilities.formatTimestamp(os.time())
        local logEntry = {
            time = timestamp,
            event = event,
            data = data
        }
        table.insert(logSystem.entries, logEntry)
    end

```

---

### lia.utilities.weekdayName

#### 📋 Purpose
Parse a time string and return the weekday name.

#### ⏰ When Called
When you need to determine the day of the week from a formatted time string.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `str` | **string** | Formatted time string (HH:MM:SS - DD/MM/YYYY) |

#### ↩️ Returns
* string - Weekday name (e.g., "Monday")

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get weekday name
    local day = lia.utilities.weekdayName("14:30:00 - 15/01/2024")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check if it's a weekend
    local function isWeekend(timeString)
        local day = lia.utilities.weekdayName(timeString)
        return day == "Saturday" or day == "Sunday"
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Schedule system with weekday filtering
    local function scheduleWeeklyEvents(events)
        for _, event in ipairs(events) do
            local day = lia.utilities.weekdayName(event.time)
            if day == event.weekday then
                timer.Simple(getTimeUntil(event.time), function()
                    hook.Run("WeeklyEvent", event.name)
                end)
            end
        end
    end

```

---

### lia.utilities.timeUntil

#### 📋 Purpose
Calculate time difference until a future time string.

#### ⏰ When Called
When you need to know how long until a specific time.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `str` | **string** | Future time string (HH:MM:SS - DD/MM/YYYY) |

#### ↩️ Returns
* string - Human-readable time difference

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get time until event
    local timeLeft = lia.utilities.timeUntil("15:00:00 - 20/01/2024")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check if event is soon
    local function isEventSoon(eventTime)
        local timeLeft = lia.utilities.timeUntil(eventTime)
        return timeLeft:match("%d+") and tonumber(timeLeft:match("%d+")) < 60
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Event notification system
    local function setupEventNotifications(events)
        for _, event in ipairs(events) do
            timer.Create("event_" .. event.id, 60, 0, function()
                local timeLeft = lia.utilities.timeUntil(event.time)
                if timeLeft then
                    hook.Run("EventTimeUpdate", event.id, timeLeft)
                end
            end)
        end
    end

```

---

### lia.utilities.currentLocalTime

#### 📋 Purpose
Return the current local time as a formatted string.

#### ⏰ When Called
When you need the current time in a formatted string format.

#### ⚙️ Parameters
None

#### ↩️ Returns
* string - Current time formatted as "HH:MM:SS - DD/MM/YYYY"

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get current time
    local time = lia.utilities.currentLocalTime()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Log with timestamp
    local function log(message)
        local timestamp = lia.utilities.currentLocalTime()
        print("[" .. timestamp .. "] " .. message)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Comprehensive logging system
    local function logEvent(eventType, data)
        local timestamp = lia.utilities.currentLocalTime()
        local logEntry = {
            timestamp = timestamp,
            type = eventType,
            data = data,
            player = IsValid(ply) and ply:SteamID() or "SERVER"
        }
        table.insert(logSystem, logEntry)
    end

```

---

### lia.utilities.timeDifference

#### 📋 Purpose
Return a human-friendly difference between now and a time string.

#### ⏰ When Called
When you need to calculate and display time differences.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `str` | **string** | Time string (HH:MM:SS - DD/MM/YYYY) |

#### ↩️ Returns
* number - Days difference

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get days difference
    local days = lia.utilities.timeDifference("14:30:00 - 15/01/2024")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check if within time window
    local function isWithinDays(timeString, maxDays)
        local days = lia.utilities.timeDifference(timeString)
        return math.abs(days) <= maxDays
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Activity tracking system
    local function checkPlayerActivity(steamID)
        local lastSeen = GetPData(steamID, "lastSeen", "")
        if lastSeen == "" then return nil end
        local daysAgo = lia.utilities.timeDifference(lastSeen)
        return {
            steamID = steamID,
            lastSeen = lastSeen,
            daysAgo = daysAgo,
            active = daysAgo <= 30
        }
    end

```

---

### lia.utilities.serializeVector

#### 📋 Purpose
Serialize a Vector object to JSON format.

#### ⏰ When Called
When you need to store or transmit vector data as JSON.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `v` | **Vector** | Vector to serialize |

#### ↩️ Returns
* string - JSON string representation of the vector

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Serialize a vector
    local json = lia.utilities.serializeVector(Vector(100, 200, 300))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Save player position
    local function savePlayerPosition(player)
        local pos = player:GetPos()
        local json = lia.utilities.serializeVector(pos)
        player:SetPData("lastPosition", json)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Save multiple positions
    local function saveCheckpoints(checkpoints)
        local data = {}
        for i, checkpoint in ipairs(checkpoints) do
            data[i] = lia.utilities.serializeVector(checkpoint.pos)
        end
        return util.TableToJSON(data)
    end

```

---

### lia.utilities.deserializeVector

#### 📋 Purpose
Deserialize JSON data into a Vector object.

#### ⏰ When Called
When you need to reconstruct a vector from JSON data.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | **string** | JSON string to deserialize |

#### ↩️ Returns
* Vector - Reconstructed vector

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Deserialize a vector
    local json = "[100,200,300]"
    local vec = lia.utilities.deserializeVector(json)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Load player position
    local function loadPlayerPosition(player)
        local json = player:GetPData("lastPosition", "")
        if json ~= "" then
            local pos = lia.utilities.deserializeVector(json)
            player:SetPos(pos)
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Load checkpoint system
    local function loadCheckpoints(jsonData)
        local data = util.JSONToTable(jsonData)
        local checkpoints = {}
        for i, vecJson in ipairs(data) do
            checkpoints[i] = {
                pos = lia.utilities.deserializeVector(vecJson),
                id = i
            }
        end
        return checkpoints
    end

```

---

### lia.utilities.serializeAngle

#### 📋 Purpose
Serialize an Angle object to JSON format.

#### ⏰ When Called
When you need to store or transmit angle data as JSON.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `a` | **Angle** | Angle to serialize |

#### ↩️ Returns
* string - JSON string representation of the angle

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Serialize an angle
    local json = lia.utilities.serializeAngle(Angle(0, 90, 0))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Save entity angles
    local function saveEntityAngles(entity)
        local ang = entity:GetAngles()
        local json = lia.utilities.serializeAngle(ang)
        entity:SetPData("savedAngles", json)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Save entity transform
    local function saveEntityTransform(entity)
        return {
            pos = lia.utilities.serializeVector(entity:GetPos()),
            ang = lia.utilities.serializeAngle(entity:GetAngles())
        }
    end

```

---

### lia.utilities.deserializeAngle

#### 📋 Purpose
Deserialize JSON data into an Angle object.

#### ⏰ When Called
When you need to reconstruct an angle from JSON data.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | **string** | JSON string to deserialize |

#### ↩️ Returns
* Angle - Reconstructed angle

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Deserialize an angle
    local json = "[0,90,0]"
    local ang = lia.utilities.deserializeAngle(json)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Load entity angles
    local function loadEntityAngles(entity)
        local json = entity:GetPData("savedAngles", "")
        if json ~= "" then
            local ang = lia.utilities.deserializeAngle(json)
            entity:SetAngles(ang)
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Load entity transform
    local function loadEntityTransform(entity, data)
        entity:SetPos(lia.utilities.deserializeVector(data.pos))
        entity:SetAngles(lia.utilities.deserializeAngle(data.ang))
    end

```

---

### lia.utilities.dprint

#### 📋 Purpose
Print a prefixed debug line to console.

#### ⏰ When Called
When you need to output debug information with a consistent prefix.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `...` | **any** | Values to print (variable arguments) |

#### ↩️ Returns
* void

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Debug print
    lia.utilities.dprint("Loaded")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Debug with multiple values
    lia.utilities.dprint("Player", ply:Nick(), "joined at", os.time())

```

#### ⚙️ High Complexity
```lua
    -- High: Conditional debug system
    local function debugLog(condition, ...)
        if condition and GetConVar("developer"):GetInt() > 0 then
            lia.utilities.dprint(...)
        end
    end
    debugLog(true, "Module loaded", moduleName)

```

---

### lia.utilities.spawnProp

#### 📋 Purpose
Spawn a physics prop with optional force, lifetime, angle, and color.

#### ⏰ When Called
When spawning temporary props server-side for effects or gameplay.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `model` | **string** | Model path for the prop |
| `pos` | **Vector** | Position to spawn at |
| `force` | **Vector\|nil** | Optional force to apply |
| `life` | **number\|nil** | Optional auto-remove after seconds |
| `ang` | **Angle\|nil** | Optional spawn angle |
| `col` | **Color\|nil** | Optional collision group override |

#### ↩️ Returns
* Entity - The spawned entity

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Spawn a prop
    local ent = lia.utilities.spawnProp("models/props_c17/oildrum001.mdl", Vector(0,0,64))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Spawn prop with force and lifetime
    local ent = lia.utilities.spawnProp(
        "models/props_junk/wood_crate001a.mdl",
        Vector(0, 0, 100),
        Vector(0, 0, 500),
        10,
        Angle(0, 45, 0)
    )

```

#### ⚙️ High Complexity
```lua
    -- High: Spawn prop system with validation
    local function spawnPropSafe(model, pos, options)
        options = options or {}
        if not util.IsValidModel(model) then
            error("Invalid model: " .. model)
            return nil
        end
        local ent = lia.utilities.spawnProp(
            model,
            pos,
            options.force,
            options.lifetime,
            options.angle,
            options.collisionGroup
        )
        if IsValid(ent) and options.color then
            ent:SetColor(options.color)
        end
        return ent
    end

```

---

### lia.utilities.spawnEntities

#### 📋 Purpose
Spawn multiple entities from a class->properties table.

#### ⏰ When Called
When you need to spawn multiple entities at once from a configuration table.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `tbl` | **table** | Map of entity class to properties (position or full property table) |

#### ↩️ Returns
* void

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Spawn entities
    lia.utilities.spawnEntities({
        ["prop_physics"] = { model = "models/props_junk/wood_crate001a.mdl", pos = Vector(0,0,64) }
    })

```

#### 📊 Medium Complexity
```lua
    -- Medium: Spawn multiple entity types
    lia.utilities.spawnEntities({
        ["prop_physics"] = Vector(0, 0, 64),
        ["prop_dynamic"] = Vector(100, 0, 64),
        ["npc_combine_s"] = Vector(200, 0, 64)
    })

```

#### ⚙️ High Complexity
```lua
    -- High: Spawn system with full configuration
    local function spawnMapEntities(mapData)
        local entities = {}
        for class, config in pairs(mapData.entities) do
            if istable(config) then
                entities[class] = {
                    pos = config.pos or Vector(0,0,0),
                    ang = config.ang or Angle(0,0,0),
                    model = config.model,
                    keyvalues = config.keyvalues or {}
                }
            else
                entities[class] = config
            end
        end
        lia.utilities.spawnEntities(entities)
    end

```

---

# Time Library

This page documents the functions for working with time utilities and time management.

---

## Overview

The time library (`lia.time`) provides a comprehensive system for managing time, date formatting, and time-related utilities in the Lilia framework, serving as the central time management system for all temporal operations and scheduling needs. This library handles sophisticated time management with support for multiple time zones, daylight saving time adjustments, and server-specific time configurations that can be customized for different roleplay scenarios and server themes. The system features advanced time calculations with support for complex date arithmetic, duration formatting, and relative time expressions that provide intuitive time representations for players and administrators. It includes comprehensive date formatting with support for multiple locale-specific formats, cultural date representations, and customizable time display options to accommodate different player preferences and regional settings. The library provides robust time conversion functionality with support for various time units, automatic time zone conversions, and integration with the framework's persistence system for accurate time tracking across server restarts. Additional features include time-based event scheduling, performance monitoring for time-sensitive operations, and integration with other framework systems for creating dynamic and time-aware gameplay experiences that enhance immersion and provide realistic temporal progression.

---

### TimeSince

**Purpose**

Calculates and formats the time since a given timestamp or date string.

**Parameters**

* `strTime` (*number* or *string*): The timestamp (number) or date string to calculate from.

**Returns**

* `formattedTime` (*string*): The formatted time string (e.g., "5 minutes ago", "2 hours ago").

**Realm**

Shared.

**Example Usage**

```lua
-- Calculate time since timestamp
local function timeSince(timestamp)
    return lia.time.TimeSince(timestamp)
end

-- Use in a function
local function checkPlayerLastSeen(client)
    local lastSeen = client:getChar():getLastSeen()
    local timeSince = lia.time.TimeSince(lastSeen)
    print("Player last seen " .. timeSince)
    return timeSince
end

-- Use in a function
local function checkItemAge(item)
    local created = item:getCreatedTime()
    local age = lia.time.TimeSince(created)
    print("Item age: " .. age)
    return age
end

-- Use in a function
local function timeSinceString(dateString)
    local timeSince = lia.time.TimeSince(dateString)
    print("Time since " .. dateString .. ": " .. timeSince)
    return timeSince
end
```

---

### toNumber

**Purpose**

Parses a time string and returns a table with individual time components.

**Parameters**

* `str` (*string*, optional): The time string to parse (format: "YYYY-MM-DD HH:MM:SS"). If not provided, uses current time.

**Returns**

* `timeTable` (*table*): Table containing year, month, day, hour, min, sec components.

**Realm**

Shared.

**Example Usage**

```lua
-- Parse time string to table
local function timeToNumber(timeString)
    return lia.time.toNumber(timeString)
end

-- Use in a function
local function parseTimeString(timeString)
    local timeTable = lia.time.toNumber(timeString)
    if timeTable then
        print("Parsed time:")
        print("  Year: " .. timeTable.year)
        print("  Month: " .. timeTable.month)
        print("  Day: " .. timeTable.day)
        print("  Hour: " .. timeTable.hour)
        print("  Minute: " .. timeTable.min)
        print("  Second: " .. timeTable.sec)
        return timeTable
    else
        print("Failed to parse time string")
        return nil
    end
end

-- Use in a function
local function getCurrentTimeTable()
    local timeTable = lia.time.toNumber()
    print("Current time components:")
    for key, value in pairs(timeTable) do
        print("  " .. key .. ": " .. value)
    end
    return timeTable
end
```

---

### GetDate

**Purpose**

Gets the current date as a formatted string.

**Parameters**

*None*

**Returns**

* `dateString` (*string*): The formatted date string.

**Realm**

Shared.

**Example Usage**

```lua
-- Get current date
local function getCurrentDate()
    return lia.time.GetDate()
end

-- Use in a function
local function showCurrentDate()
    local date = lia.time.GetDate()
    print("Current date: " .. date)
    return date
end

-- Use in a function
local function logWithDate(message)
    local date = lia.time.GetDate()
    print("[" .. date .. "] " .. message)
end
```

---

### formatDHM

**Purpose**

Formats time in days, hours, and minutes.

**Parameters**

* `seconds` (*number*): The time in seconds.

**Returns**

* `formattedTime` (*string*): The formatted time string.

**Realm**

Shared.

**Example Usage**

```lua
-- Format time in DHM
local function formatTime(seconds)
    return lia.time.formatDHM(seconds)
end

-- Use in a function
local function showPlaytime(client)
    local playtime = client:getChar():getPlaytime()
    local formatted = lia.time.formatDHM(playtime)
    client:notify("Playtime: " .. formatted)
end

-- Use in a function
local function showServerUptime()
    local uptime = SysTime()
    local formatted = lia.time.formatDHM(uptime)
    print("Server uptime: " .. formatted)
end
```

---

### GetHour

**Purpose**

Gets the current hour, either as a number or formatted string depending on AmericanTimeStamps configuration.

**Parameters**

*None*

**Returns**

* `hour` (*number* or *string*): The current hour. Returns a number (0-23) if AmericanTimeStamps is false, or a formatted string (e.g., "3PM") if true.

**Realm**

Shared.

**Example Usage**

```lua
-- Get current hour
local function getCurrentHour()
    return lia.time.GetHour()
end

-- Use in a function
local function checkTimeOfDay()
    local hour = lia.time.GetHour()
    if type(hour) == "number" then
        -- Handle as number (0-23)
        if hour >= 6 and hour < 12 then
            print("Good morning!")
        elseif hour >= 12 and hour < 18 then
            print("Good afternoon!")
        elseif hour >= 18 and hour < 22 then
            print("Good evening!")
        else
            print("Good night!")
        end
    else
        -- Handle as formatted string
        print("Current time: " .. hour)
    end
    return hour
end

-- Use in a function
local function isDayTime()
    local hour = lia.time.GetHour()
    if type(hour) == "number" then
        return hour >= 6 and hour < 18
    else
        -- For formatted strings, you'd need to parse it differently
        return true -- Simplified for example
    end
end

-- Use in a function
local function displayCurrentHour()
    local hour = lia.time.GetHour()
    print("Current hour: " .. tostring(hour))
    return hour
end
```
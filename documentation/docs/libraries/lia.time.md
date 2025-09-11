# Time Library

This page documents the functions for working with time utilities and time management.

---

## Overview

The time library (`lia.time`) provides a comprehensive system for managing time, date formatting, and time-related utilities in the Lilia framework, serving as the central time management system for all temporal operations and scheduling needs. This library handles sophisticated time management with support for multiple time zones, daylight saving time adjustments, and server-specific time configurations that can be customized for different roleplay scenarios and server themes. The system features advanced time calculations with support for complex date arithmetic, duration formatting, and relative time expressions that provide intuitive time representations for players and administrators. It includes comprehensive date formatting with support for multiple locale-specific formats, cultural date representations, and customizable time display options to accommodate different player preferences and regional settings. The library provides robust time conversion functionality with support for various time units, automatic time zone conversions, and integration with the framework's persistence system for accurate time tracking across server restarts. Additional features include time-based event scheduling, performance monitoring for time-sensitive operations, and integration with other framework systems for creating dynamic and time-aware gameplay experiences that enhance immersion and provide realistic temporal progression.

---

### lia.time.TimeSince

**Purpose**

Calculates the time since a given timestamp.

**Parameters**

* `timestamp` (*number*): The timestamp to calculate from.

**Returns**

* `timeSince` (*number*): The time since the timestamp in seconds.

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
    print("Player last seen " .. timeSince .. " seconds ago")
    return timeSince
end

-- Use in a function
local function checkItemAge(item)
    local created = item:getCreatedTime()
    local age = lia.time.TimeSince(created)
    print("Item age: " .. age .. " seconds")
    return age
end
```

---

### lia.time.toNumber

**Purpose**

Converts a time string to a number.

**Parameters**

* `timeString` (*string*): The time string to convert.

**Returns**

* `timeNumber` (*number*): The time as a number.

**Realm**

Shared.

**Example Usage**

```lua
-- Convert time string to number
local function timeToNumber(timeString)
    return lia.time.toNumber(timeString)
end

-- Use in a function
local function parseTimeString(timeString)
    local timeNumber = lia.time.toNumber(timeString)
    if timeNumber then
        print("Time parsed: " .. timeNumber)
        return timeNumber
    else
        print("Failed to parse time string")
        return nil
    end
end
```

---

### lia.time.GetDate

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

### lia.time.formatDHM

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

### lia.time.GetHour

**Purpose**

Gets the current hour.

**Parameters**

*None*

**Returns**

* `hour` (*number*): The current hour (0-23).

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
    if hour >= 6 and hour < 12 then
        print("Good morning!")
    elseif hour >= 12 and hour < 18 then
        print("Good afternoon!")
    elseif hour >= 18 and hour < 22 then
        print("Good evening!")
    else
        print("Good night!")
    end
    return hour
end

-- Use in a function
local function isDayTime()
    local hour = lia.time.GetHour()
    return hour >= 6 and hour < 18
end
```
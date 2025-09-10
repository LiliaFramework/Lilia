# Time Library

This page documents the functions for working with time utilities and time management.

---

## Overview

The time library (`lia.time`) provides a comprehensive system for managing time, date formatting, and time-related utilities in the Lilia framework. It includes time calculations, date formatting, and time conversion functionality.

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
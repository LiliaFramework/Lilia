# Time Library

This page lists time- and date-utilities.

---

## Overview

The time library formats dates and converts relative times using Lua's built‑in `os.date` and `os.time` functions. It provides helpers for phrases such as “time since.”

---

### lia.time.TimeSince

**Purpose**

Returns a human-readable string describing how long ago a given time occurred (e.g. “5 minutes ago”).

**Parameters**

* `strTime` (*string | number*): Timestamp to measure from.

  * Strings must use `YYYY-MM-DD` (or `YYYY-MM-DD HH:MM:SS`).

  * Numbers are standard UNIX timestamps.

**Realm**

`Shared`

**Returns**

* *string*: Readable “time since” string.

**Example Usage**

```lua
-- Greet joining players with the time since they last logged in
hook.Add("PlayerInitialSpawn", "welcomeLastSeen", function(ply)
    local key  = "lastLogin_" .. ply:SteamID64()
    local last = lia.data.get(key, nil)

    if last then
        ply:ChatPrint(("Welcome back! You last joined %s."):format(lia.time.TimeSince(last)))
    else
        ply:ChatPrint("Welcome for the first time!")
    end

    lia.data.set(key, os.time(), true)
end)
```

---

### lia.time.toNumber

**Purpose**

Parses a timestamp string (`YYYY-MM-DD HH:MM:SS`) into its numeric components. If no argument is given, returns the current time table.

**Parameters**

* `str` (*string*): Timestamp string. *Optional*.

**Realm**

`Shared`

**Returns**

* *table*: `{ year, month, day, hour, min, sec }`.

**Example Usage**

```lua
-- Schedule an event for 1 April 2025 12:30
local tInfo     = lia.time.toNumber("2025-04-01 12:30:00")
local timestamp = os.time(tInfo)
local delay     = timestamp - os.time()

if delay > 0 then
    timer.Simple(delay, function()
        print("It is now April 1st 2025, 12:30 PM!")
    end)
end
```

---

### lia.time.GetDate

**Purpose**

Returns the full current date/time using the `AmericanTimeStamps` config:

* **Enabled**: `"Weekday, Month DD, YYYY, HH:MM:SSam/pm"`

* **Disabled**: `"Weekday, DD Month YYYY, HH:MM:SS"`

**Parameters**

* *None*

**Realm**

`Shared`

**Returns**

* *string*: Formatted current date/time.

**Example Usage**

```lua
-- Announce the current server date every hour
timer.Create("ServerTimeAnnounce", 3600, 0, function()
    local text = lia.time.GetDate()
    for _, ply in player.Iterator() do
        ply:ChatPrint("Server time: " .. text)
    end
end)
```

---

### lia.time.GetHour

**Purpose**

Returns the current hour formatted by `AmericanTimeStamps`:

* **Enabled** → `"Ham"` / `"Hpm"` (12-hour clock)

* **Disabled** → `H` (0 – 23, 24-hour clock)

**Parameters**

* *None*

**Realm**

`Shared`

**Returns**

* *string | number*: Hour with suffix (am/pm) or 24-hour integer.

**Example Usage**

```lua
-- Toggle an NPC shop by hour
timer.Create("CheckShopHours", 60, 0, function()
    local hour = lia.time.GetHour()      -- could be "3pm" or 15
    local hNum = tonumber(hour) or tonumber(hour:sub(1, -3)) % 12  -- convert if am/pm
    npc:SetNWBool("ShopOpen", hNum >= 9 and hNum < 17)
end)
```

---

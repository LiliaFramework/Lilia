# Time Library

This page lists time and date utilities.

---

## Overview

The time library handles date formatting and relative time conversions. It offers helper functions to compute durations such as "time since" or "time until" and uses a third-party date module to avoid the 1970 epoch limitation.

---

### lia.time.TimeSince

**Purpose**

Returns a human-readable string indicating how long ago a given time occurred (e.g., "5 minutes ago").

**Parameters**

- `strTime` (`string or number`): The time in string or timestamp form.

- Strings should follow `YYYY-MM-DD` while numbers are standard timestamps.


**Realm**

`Shared`


**Returns**

- (string) The time since the given date/time in a readable format.


**Example**

```lua
-- Greet players with the time since they last joined using persistence data
hook.Add("PlayerInitialSpawn", "welcomeLastSeen", function(ply)
    -- Retrieve the time this player last joined from persistent data
    local key = "lastLogin_" .. ply:SteamID64()
    local last = lia.data.get(key, nil, true)

    if last then
        ply:ChatPrint(string.format("Welcome back! You last joined %s.", lia.time.TimeSince(last)))
    else
        ply:ChatPrint("Welcome for the first time!")
    end

    -- Store the current time for the next login
    lia.data.set(key, os.time(), true)
end)
```

---

### lia.time.toNumber

**Purpose**

Converts a string timestamp (YYYY-MM-DD HH:MM:SS) into a table of numeric components: year, month, day, hour, min, and sec. If omitted, it returns the current time.

**Parameters**

- `str` (`string`): The time string to convert (optional).


**Realm**

`Shared`


**Returns**

- (table) A table with numeric year, month, day, hour, min, sec.


**Example**

```lua
    -- Schedule an event at a custom date and time using the parsed table
    local targetInfo = lia.time.toNumber("2025-04-01 12:30:00")
    local targetTimestamp = os.time(targetInfo)
    local delay = targetTimestamp - os.time()
    if delay > 0 then
        timer.Simple(delay, function()
            print("It's now April 1st, 2025, 12:30 PM!")
        end)
    end
```

---

### lia.time.GetDate

**Purpose**

Returns the full current date and time formatted based on the

"AmericanTimeStamps" configuration flag:

• If enabled: "Weekday, Month DD, YYYY, HH:MM:SSam/pm"

• If disabled: "Weekday, DD Month YYYY, HH:MM:SS"

**Parameters**

- None


**Realm**

`Shared`


**Returns**

- (string) Formatted date and time string.


**Example**

```lua
    -- Announce the current server date and time to all players every hour
    timer.Create("ServerTimeAnnounce", 3600, 0, function()
        local dateString = lia.time.GetDate()
        for _, ply in player.GetAll() do
            ply:ChatPrint("Server time: " .. dateString)
        end
    end)
```

---

### lia.time.GetHour

**Purpose**

Returns the current hour formatted based on the

"AmericanTimeStamps" configuration flag:

• If enabled: "Ham" or "Hpm" (12-hour with am/pm)

• If disabled: H (0–23, 24-hour)

**Parameters**

- None


**Realm**

`Shared`


**Returns**

- (string|number) Current hour string with suffix when AmericanTimeStamps is enabled, otherwise numeric hour in 24-hour format.


**Example**

```lua
-- Toggle an NPC's shop based on the in-game hour
timer.Create("CheckShopHours", 60, 0, function()
    local hour = lia.time.GetHour()
    npc:SetNWBool("ShopOpen", hour >= 9 and hour < 17)
end)
```

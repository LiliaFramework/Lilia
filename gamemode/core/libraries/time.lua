--[[
    Folder: Developer - Libraries
    File: lia.time.md
]]
--[[
    Time

    Time and date helpers for localized timestamps, elapsed-time text, and duration formatting.
]]
--[[
    Overview:
        The time library centralizes shared time formatting under `lia.time`. It converts timestamps and formatted date strings into localized readable output, builds current date and hour strings using the configured timestamp style, and formats durations into day, hour, and minute components.
]]
lia.time = lia.time or {}
--[[
    Purpose:
        Returns a localized string describing how much time has passed since a timestamp or parsed date string.

    Parameters:
        strTime (number|string)
            A Unix timestamp, or a date string supported by `lia.time.ParseTime`.

    Returns:
        string
            A localized elapsed-time string, or a localized invalid input or invalid date message.

    Example Usage:
        ```lua
        print(lia.time.timeSince(os.time() - 3600))
        print(lia.time.timeSince("2024-01-01"))
        ```

    Realm:
        Shared
]]
function lia.time.timeSince(strTime)
    local timestamp
    if isnumber(strTime) then
        timestamp = strTime
    elseif isstring(strTime) then
        local year, month, day = lia.time.ParseTime(strTime)
        if not (year and month and day) then return L("invalidDate") end
        timestamp = os.time{
            year = year,
            month = month,
            day = day,
            hour = 0,
            min = 0,
            sec = 0
        }
    else
        return L("invalidInput")
    end

    local diff = os.time() - timestamp
    if diff < 60 then
        return L("secondsAgo", diff)
    elseif diff < 3600 then
        return L("minutesAgo", math.floor(diff / 60))
    elseif diff < 86400 then
        return L("hoursAgo", math.floor(diff / 3600))
    else
        return L("daysAgo", math.floor(diff / 86400))
    end
end

--[[
    Purpose:
        Converts a formatted timestamp string into a table of numeric date and time components.

    Parameters:
        str (string|nil)
            A timestamp string formatted as `YYYY-MM-DD HH:MM:SS`. Defaults to the current local time when nil.

    Returns:
        table
            A table containing `year`, `month`, `day`, `hour`, `min`, and `sec` numeric fields.

    Example Usage:
        ```lua
        local date = lia.time.toNumber("2024-01-31 18:45:10")
        print(date.year, date.month, date.day)
        ```

    Realm:
        Shared
]]
function lia.time.toNumber(str)
    str = str or os.date("%Y-%m-%d %H:%M:%S", os.time())
    return {
        year = tonumber(str:sub(1, 4)),
        month = tonumber(str:sub(6, 7)),
        day = tonumber(str:sub(9, 10)),
        hour = tonumber(str:sub(12, 13)),
        min = tonumber(str:sub(15, 16)),
        sec = tonumber(str:sub(18, 19)),
    }
end

--[[
    Purpose:
        Returns the current localized date and time string using the configured timestamp format.

    Parameters:
        None.

    Returns:
        string
            The current date and time using either the American or default timestamp style.

    Example Usage:
        ```lua
        print(lia.time.getDate())
        ```

    Realm:
        Shared
]]
function lia.time.getDate()
    local ct = os.date("*t")
    local american = lia.config.get("AmericanTimeStamps", false)
    local weekdayKeys = {"weekdaySunday", "weekdayMonday", "weekdayTuesday", "weekdayWednesday", "weekdayThursday", "weekdayFriday", "weekdaySaturday"}
    local monthKeys = {"monthJanuary", "monthFebruary", "monthMarch", "monthApril", "monthMay", "monthJune", "monthJuly", "monthAugust", "monthSeptember", "monthOctober", "monthNovember", "monthDecember"}
    if american then
        local suffix = ct.hour < 12 and L("am") or L("pm")
        local hour12 = ct.hour % 12
        if hour12 == 0 then hour12 = 12 end
        return string.format("%s, %s %02d, %04d, %02d:%02d:%02d%s", L(weekdayKeys[ct.wday]), L(monthKeys[ct.month]), ct.day, ct.year, hour12, ct.min, ct.sec, suffix)
    end
    return string.format("%s, %02d %s %04d, %02d:%02d:%02d", L(weekdayKeys[ct.wday]), ct.day, L(monthKeys[ct.month]), ct.year, ct.hour, ct.min, ct.sec)
end

--[[
    Purpose:
        Formats a duration in seconds as localized days, hours, and minutes.

    Parameters:
        seconds (number|nil)
            The duration in seconds. Nil and negative values are treated as zero.

    Returns:
        string
            A localized duration string containing the calculated days, hours, and minutes.

    Example Usage:
        ```lua
        print(lia.time.formatDHM(93780))
        ```

    Realm:
        Shared
]]
function lia.time.formatDHM(seconds)
    seconds = math.max(seconds or 0, 0)
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    return L("daysHoursMinutes", days, hours, minutes)
end

--[[
    Purpose:
        Returns the current hour using the configured timestamp format.

    Parameters:
        None.

    Returns:
        number|string
            The current 24-hour value when American timestamps are disabled, or a localized 12-hour string with an AM/PM suffix when enabled.

    Example Usage:
        ```lua
        print(lia.time.getHour())
        ```

    Realm:
        Shared
]]
function lia.time.getHour()
    local ct = os.date("*t")
    local american = lia.config.get("AmericanTimeStamps", false)
    if american then
        local suffix = ct.hour < 12 and L("am") or L("pm")
        local hour12 = ct.hour % 12
        if hour12 == 0 then hour12 = 12 end
        return string.format("%d%s", hour12, suffix)
    end
    return ct.hour
end

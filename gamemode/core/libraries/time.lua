--[[
# Time Library

This page documents the functions for working with time and date utilities.

---

## Overview

The time library provides utilities for time and date manipulation within the Lilia framework. It handles time formatting, date parsing, and provides functions for calculating time differences and converting between different time formats. The library supports localized time strings and provides utilities for working with timestamps and date strings.
]]
lia.time = lia.time or {}
--[[
    lia.time.TimeSince

    Purpose:
        Returns a human-readable string representing the time elapsed since the given date or timestamp.
        Accepts either a timestamp (number) or a date string (which will be parsed).
        The output is localized and will be in seconds, minutes, hours, or days ago.

    Parameters:
        strTime (number|string) - The time to compare against the current time. Can be a Unix timestamp or a date string.

    Returns:
        string - Localized string indicating how much time has passed since the input time.

    Realm:
        Shared.

    Example Usage:
        -- Using a timestamp
        print(lia.time.TimeSince(os.time() - 90)) -- "1 minutes ago" (localized)

        -- Using a date string
        print(lia.time.TimeSince("2024-06-01")) -- "X days ago" (localized)
]]
function lia.time.TimeSince(strTime)
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
    lia.time.toNumber

    Purpose:
        Converts a date string in the format "%Y-%m-%d %H:%M:%S" to a table containing its numeric components.
        If no string is provided, uses the current date and time.

    Parameters:
        str (string, optional) - The date string to convert. Defaults to the current date and time.

    Returns:
        table - Table with keys: year, month, day, hour, min, sec (all numbers).

    Realm:
        Shared.

    Example Usage:
        local t = lia.time.toNumber("2024-06-01 15:30:45")
        -- t = { year = 2024, month = 6, day = 1, hour = 15, min = 30, sec = 45 }
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
    lia.time.GetDate

    Purpose:
        Returns the current date and time as a formatted, localized string.
        The format depends on the "AmericanTimeStamps" config setting.
        Includes weekday, month, day, year, and time (with AM/PM if American format).

    Parameters:
        None.

    Returns:
        string - Localized, formatted date and time string.

    Realm:
        Shared.

    Example Usage:
        print(lia.time.GetDate())
        -- "Monday, 01 June 2024, 15:30:45" (or American format if enabled)
]]
function lia.time.GetDate()
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
    lia.time.formatDHM

    Purpose:
        Formats a number of seconds into a localized string showing days, hours, and minutes.
        Useful for displaying durations in a human-readable way.

    Parameters:
        seconds (number) - The number of seconds to format.

    Returns:
        string - Localized string in the format "X days Y hours Z minutes".

    Realm:
        Shared.

    Example Usage:
        print(lia.time.formatDHM(90061))
        -- "1 days 1 hours 1 minutes" (localized)
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
    lia.time.GetHour

    Purpose:
        Returns the current hour, formatted according to the "AmericanTimeStamps" config.
        If American format is enabled, returns hour with AM/PM suffix; otherwise, returns 24-hour format.

    Parameters:
        None.

    Returns:
        string|number - The current hour (with AM/PM if American format, otherwise as a number).

    Realm:
        Shared.

    Example Usage:
        print(lia.time.GetHour())
        -- "3pm" (if American format) or 15 (if not)
]]
function lia.time.GetHour()
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

if SERVER then
    timer.Create("CurTimeSync", 30, -1, function()
        net.Start("CurTimeSync", true)
        net.WriteFloat(CurTime())
        net.Broadcast()
    end)
else
    hook.Add("InitPostEntity", "CurTimeSync", function()
        local SyncTime = 0
        net.Receive("CurTime-Sync", function()
            local ServerCurTime = net.ReadFloat()
            if not ServerCurTime then return end
            SyncTime = OldCurTime() - ServerCurTime
        end)

        OldCurTime = OldCurTime or CurTime
        function CurTime()
            return OldCurTime() - SyncTime
        end
    end)
end
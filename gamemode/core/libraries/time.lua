lia.time = lia.time or {}
--[[
    lia.time.TimeSince
    Description:
       Returns a human-readable string indicating how long ago a given time occurred (e.g., "5 minutes ago").

    Parameters:
       strTime (string or number) — The time in string or timestamp form.

    Returns:
       (string) The time since the given date/time in a readable format.

    Realm:
       Shared

    Example Usage:
       print(lia.time.TimeSince("2025-03-27"))
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

   Description:
      Converts a string timestamp (YYYY-MM-DD HH:MM:SS) to a table with numeric fields:
      year, month, day, hour, min, sec. Defaults to current time if not provided.

   Parameters:
      str (string) — The time string to convert (optional).

   Returns:
      (table) A table with numeric year, month, day, hour, min, sec.

   Realm:
      Shared

   Example Usage:
      local t = lia.time.toNumber("2025-03-27 14:30:00")
      print(t.year, t.month, t.day, t.hour, t.min, t.sec)
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

    Description:
       Returns the full current date and time formatted based on the
       "AmericanTimeStamps" configuration flag:
       • If enabled: "Weekday, Month DD, YYYY, HH:MM:SSam/pm"
       • If disabled: "Weekday, DD Month YYYY, HH:MM:SS"

    Parameters:
       None

    Returns:
       (string) Formatted date and time string.
 ]]
function lia.time.GetDate()
    local ct = os.date("*t")
    local american = lia.config.get("AmericanTimeStamps", false)
    local weekdayKeys = {"weekdaySunday", "weekdayMonday", "weekdayTuesday", "weekdayWednesday", "weekdayThursday", "weekdayFriday", "weekdaySaturday"}
    local monthKeys = {"monthJanuary", "monthFebruary", "monthMarch", "monthApril", "monthMay", "monthJune", "monthJuly", "monthAugust", "monthSeptember", "monthOctober", "monthNovember", "monthDecember"}
    local dayName = L(weekdayKeys[ct.wday])
    local monthName = L(monthKeys[ct.month])
    if american then
        local suffix = ct.hour < 12 and "am" or "pm"
        local hour12 = ct.hour % 12
        if hour12 == 0 then hour12 = 12 end
        return string.format("%s, %s %02d, %04d, %02d:%02d:%02d%s", dayName, monthName, ct.day, ct.year, hour12, ct.min, ct.sec, suffix)
    end
    return string.format("%s, %02d %s %04d, %02d:%02d:%02d", dayName, ct.day, monthName, ct.year, ct.hour, ct.min, ct.sec)
end

--[[
    lia.time.GetHour

    Description:
       Returns the current hour formatted based on the
       "AmericanTimeStamps" configuration flag:
       • If enabled: "Ham" or "Hpm" (12-hour with am/pm)
       • If disabled: H (0–23, 24-hour)

    Parameters:
       None

    Returns:
       (string|number) Current hour string with suffix when AmericanTimeStamps
                      is enabled, otherwise numeric hour in 24-hour format.
 ]]
function lia.time.GetHour()
    local ct = os.date("*t")
    local american = lia.config.get("AmericanTimeStamps", false)
    if american then
        local suffix = ct.hour < 12 and "am" or "pm"
        local hour12 = ct.hour % 12
        if hour12 == 0 then hour12 = 12 end
        return string.format("%d%s", hour12, suffix)
    end
    return ct.hour
end

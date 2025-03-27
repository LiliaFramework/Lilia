lia.time = {}
--[[
   Function: lia.time.GetFormattedDate

   Description:
      Returns a formatted date string based on current system time and provided flags.

   Parameters:
      StartingMessage (string) — The message to prepend (optional).
      includeWeekDay (boolean) — Whether to include the weekday name.
      includeDay (boolean) — Whether to include the day of the month.
      includeMonth (boolean) — Whether to include the month.
      includeYear (boolean) — Whether to include the year.
      includeTime (boolean) — Whether to include the time.

   Returns:
      (string) The formatted date string.

   Realm:
      Shared

   Example Usage:
      lia.time.GetFormattedDate("Today is", true, true, true, true, true)
]]
function lia.time.GetFormattedDate(StartingMessage, includeWeekDay, includeDay, includeMonth, includeYear, includeTime)
    local currentTime = os.date("*t")
    if StartingMessage then
        output = StartingMessage
    else
        output = ""
    end

    if includeWeekDay then
        local daysOfWeek = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
        output = output .. " " .. daysOfWeek[currentTime.wday] .. ", "
    end

    local day, month, year
    if lia.config.get("AmericanDates") then
        month, day, year = currentTime.month, currentTime.day, currentTime.year
    else
        day, month, year = currentTime.day, currentTime.month, currentTime.year
    end

    if includeDay then output = output .. " " .. day end
    if includeMonth then
        local months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
        output = output .. " " .. months[month]
    end

    if includeYear then output = output .. ", " .. year end
    local hourFormat = lia.config.get("AmericanTimeStamp") and 12 or 24
    local ampm = ""
    local hour = currentTime.hour
    if includeTime then
        if hourFormat == 12 then
            if currentTime.hour >= 12 then
                ampm = " PM"
                if currentTime.hour > 12 then hour = currentTime.hour - 12 end
            else
                ampm = " AM"
            end
        end

        output = output .. string.format(" %02d:%02d:%02d%s", hour, currentTime.min, currentTime.sec, ampm)
    end
    return output
end

--[[
   Function: lia.time.GetFormattedDateInGame

   Description:
      Returns a formatted date string for in-game usage, applying schema year if configured.

   Parameters:
      StartingMessage (string) — The message to prepend (optional).
      includeWeekDay (boolean) — Whether to include the weekday name.
      includeDay (boolean) — Whether to include the day of the month.
      includeMonth (boolean) — Whether to include the month.
      includeYear (boolean) — Whether to include the year (or schema year if set).
      includeTime (boolean) — Whether to include the time.

   Returns:
      (string) The formatted date string.

   Realm:
      Shared

   Example Usage:
      lia.time.GetFormattedDateInGame("In-game date:", true, true, true, true, true)
]]
function lia.time.GetFormattedDateInGame(StartingMessage, includeWeekDay, includeDay, includeMonth, includeYear, includeTime)
    local currentTime = os.date("*t")
    if StartingMessage then
        output = StartingMessage
    else
        output = ""
    end

    if includeWeekDay then
        local daysOfWeek = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
        output = output .. " " .. daysOfWeek[currentTime.wday] .. ", "
    end

    local day, month, year
    if lia.config.get("AmericanDates") then
        month, day, year = currentTime.month, currentTime.day, lia.config.get("SchemaYear") or currentTime.year
    else
        day, month, year = currentTime.day, currentTime.month, lia.config.get("SchemaYear") or currentTime.year
    end

    if includeDay then output = output .. " " .. day end
    if includeMonth then
        local months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
        output = output .. " " .. months[month]
    end

    if includeYear then output = output .. ", " .. year end
    local hourFormat = lia.config.get("AmericanTimeStamp") and 12 or 24
    local ampm = ""
    local hour = currentTime.hour
    if includeTime then
        if hourFormat == 12 then
            if currentTime.hour >= 12 then
                ampm = " PM"
                if currentTime.hour > 12 then hour = currentTime.hour - 12 end
            else
                ampm = " AM"
            end
        end

        output = output .. string.format(" %02d:%02d:%02d%s", hour, currentTime.min, currentTime.sec, ampm)
    end
    return output
end

--[[
   Function: lia.time.GetPreFormattedDate

   Description:
      Returns a formatted date string from a given time string, using system or configured date format.

   Parameters:
      StartingMessage (string) — The message to prepend (optional).
      timeToFormat (string) — The time string to format.
      includeWeekDay (boolean) — Whether to include the weekday name.
      includeDay (boolean) — Whether to include the day of the month.
      includeMonth (boolean) — Whether to include the month.
      includeYear (boolean) — Whether to include the year.
      includeTime (boolean) — Whether to include the time.

   Returns:
      (string) The formatted date string.

   Realm:
      Shared

   Example Usage:
      lia.time.GetPreFormattedDate("Date is:", "2025-03-27 14:30:00", true, true, true, true, true)
]]
function lia.time.GetPreFormattedDate(StartingMessage, timeToFormat, includeWeekDay, includeDay, includeMonth, includeYear, includeTime)
    local currentTime = tostring(timeToFormat)
    if StartingMessage then
        output = StartingMessage
    else
        output = ""
    end

    if includeWeekDay then
        local daysOfWeek = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
        output = output .. " " .. daysOfWeek[currentTime.wday] .. ", "
    end

    local day, month, year
    if lia.config.get("AmericanDates") then
        month, day, year = currentTime.month, currentTime.day, currentTime.year
    else
        day, month, year = currentTime.day, currentTime.month, currentTime.year
    end

    if includeDay then output = output .. " " .. day end
    if includeMonth then
        local months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
        output = output .. " " .. months[month]
    end

    if includeYear then output = output .. ", " .. year end
    local hourFormat = lia.config.get("AmericanTimeStamp") and 12 or 24
    local ampm = ""
    local hour = currentTime.hour
    if includeTime then
        if hourFormat == 12 then
            if currentTime.hour >= 12 then
                ampm = " PM"
                if currentTime.hour > 12 then hour = currentTime.hour - 12 end
            else
                ampm = " AM"
            end
        end

        output = output .. string.format(" %02d:%02d:%02d%s", hour, currentTime.min, currentTime.sec, ampm)
    end
    return output
end

--[[
   Function: lia.time.GetPreFormattedDateInGame

   Description:
      Returns a formatted date string for in-game usage from a given time string, applying schema year if configured.

   Parameters:
      StartingMessage (string) — The message to prepend (optional).
      timeToFormat (string) — The time string to format.
      includeWeekDay (boolean) — Whether to include the weekday name.
      includeDay (boolean) — Whether to include the day of the month.
      includeMonth (boolean) — Whether to include the month.
      includeYear (boolean) — Whether to include the year (or schema year if set).
      includeTime (boolean) — Whether to include the time.

   Returns:
      (string) The formatted date string.

   Realm:
      Shared

   Example Usage:
      lia.time.GetPreFormattedDateInGame("In-game date is:", "2025-03-27 14:30:00", true, true, true, true, true)
]]
function lia.time.GetPreFormattedDateInGame(StartingMessage, timeToFormat, includeWeekDay, includeDay, includeMonth, includeYear, includeTime)
    local currentTime = tostring(timeToFormat)
    if StartingMessage then
        output = StartingMessage
    else
        output = ""
    end

    if includeWeekDay then
        local daysOfWeek = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
        output = output .. " " .. daysOfWeek[currentTime.wday] .. ", "
    end

    local day, month, year
    if lia.config.get("AmericanDates") then
        month, day, year = currentTime.month, currentTime.day, lia.config.get("SchemaYear") or currentTime.year
    else
        day, month, year = currentTime.day, currentTime.month, lia.config.get("SchemaYear") or currentTime.year
    end

    if includeDay then output = output .. " " .. day end
    if includeMonth then
        local months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
        output = output .. " " .. months[month]
    end

    if includeYear then output = output .. ", " .. year end
    local hourFormat = lia.config.get("AmericanTimeStamp") and 12 or 24
    local ampm = ""
    local hour = currentTime.hour
    if includeTime then
        if hourFormat == 12 then
            if currentTime.hour >= 12 then
                ampm = " PM"
                if currentTime.hour > 12 then hour = currentTime.hour - 12 end
            else
                ampm = " AM"
            end
        end

        output = output .. string.format(" %02d:%02d:%02d%s", hour, currentTime.min, currentTime.sec, ampm)
    end
    return output
end

--[[
   Function: lia.time.toNumber

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
   Function: lia.time.TimeSince

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
        if not (year and month and day) then return "Invalid date" end
        timestamp = os.time({
            year = year,
            month = month,
            day = day,
            hour = 0,
            min = 0,
            sec = 0
        })
    else
        return "Invalid input"
    end

    local diff = os.time() - timestamp
    if diff < 60 then
        return diff .. " seconds ago"
    elseif diff < 3600 then
        return math.floor(diff / 60) .. " minutes ago"
    elseif diff < 86400 then
        return math.floor(diff / 3600) .. " hours ago"
    else
        return math.floor(diff / 86400) .. " days ago"
    end
end

--[[
   Function: lia.time.TimeUntil

   Description:
      Returns the time remaining until a specified future date/time, in a readable format.

   Parameters:
      strTime (string) — The time string in the format "HH:MM:SS - DD/MM/YYYY".

   Returns:
      (string) A human-readable duration until the specified time, or an error message if invalid.

   Realm:
      Shared

   Example Usage:
      print(lia.time.TimeUntil("14:30:00 - 28/03/2025"))
]]
function lia.time.TimeUntil(strTime)
    local pattern = "(%d+):(%d+):(%d+)%s*%-%s*(%d+)/(%d+)/(%d+)"
    local hour, minute, second, day, month, year = strTime:match(pattern)
    if not (hour and minute and second and day and month and year) then return "Invalid time format. Expected 'HH:MM:SS - DD/MM/YYYY'." end
    hour, minute, second, day, month, year = tonumber(hour), tonumber(minute), tonumber(second), tonumber(day), tonumber(month), tonumber(year)
    if hour < 0 or hour > 23 or minute < 0 or minute > 59 or second < 0 or second > 59 or day < 1 or day > 31 or month < 1 or month > 12 or year < 1970 then return "Invalid time values." end
    local inputTimestamp = os.time({
        year = year,
        month = month,
        day = day,
        hour = hour,
        min = minute,
        sec = second
    })

    local currentTimestamp = os.time()
    if inputTimestamp <= currentTimestamp then return "The specified time is in the past." end
    local diffSeconds = inputTimestamp - currentTimestamp
    local years = math.floor(diffSeconds / (365.25 * 24 * 3600))
    diffSeconds = diffSeconds % (365.25 * 24 * 3600)
    local months = math.floor(diffSeconds / (30.44 * 24 * 3600))
    diffSeconds = diffSeconds % (30.44 * 24 * 3600)
    local days = math.floor(diffSeconds / (24 * 3600))
    diffSeconds = diffSeconds % (24 * 3600)
    local hours = math.floor(diffSeconds / 3600)
    diffSeconds = diffSeconds % 3600
    local minutes = math.floor(diffSeconds / 60)
    local seconds = diffSeconds % 60
    return string.format("%d years, %d months, %d days, %d hours, %d minutes, %d seconds", years, months, days, hours, minutes, seconds)
end

--[[
   Function: lia.time.CurrentLocalTime

   Description:
      Returns the current local system time as a formatted string "HH:MM:SS - DD/MM/YYYY".

   Parameters:
      None

   Returns:
      (string) The formatted current local time.

   Realm:
      Shared

   Example Usage:
      print(lia.time.CurrentLocalTime())
]]
function lia.time.CurrentLocalTime()
    local now = os.time()
    local t = os.date("*t", now)
    return string.format("%02d:%02d:%02d - %02d/%02d/%04d", t.hour, t.min, t.sec, t.day, t.month, t.year)
end

--[[
   Function: lia.time.SecondsToDHMS

   Description:
      Converts a total number of seconds into days, hours, minutes, and seconds.

   Parameters:
      seconds (number) — The total number of seconds.

   Returns:
      (number, number, number, number) days, hours, minutes, and seconds.

   Realm:
      Shared

   Example Usage:
      local d, h, m, s = lia.time.SecondsToDHMS(98765)
      print(d, "days,", h, "hours,", m, "minutes,", s, "seconds")
]]
function lia.time.SecondsToDHMS(seconds)
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    return days, hours, minutes, secs
end

--[[
   Function: lia.time.HMSToSeconds

   Description:
      Converts hours, minutes, and seconds to total seconds.

   Parameters:
      hour (number) — The hour component.
      minute (number) — The minute component.
      second (number) — The second component.

   Returns:
      (number) The total number of seconds.

   Realm:
      Shared

   Example Usage:
      local totalSeconds = lia.time.HMSToSeconds(2, 30, 15)
      print(totalSeconds) -- 9015
]]
function lia.time.HMSToSeconds(hour, minute, second)
    return hour * 3600 + minute * 60 + second
end

--[[
   Function: lia.time.FormatTimestamp

   Description:
      Formats an epoch timestamp into "HH:MM:SS - DD/MM/YYYY".

   Parameters:
      timestamp (number) — The epoch timestamp to format.

   Returns:
      (string) A formatted date/time string.

   Realm:
      Shared

   Example Usage:
      print(lia.time.FormatTimestamp(os.time()))
]]
function lia.time.FormatTimestamp(timestamp)
    local t = os.date("*t", timestamp)
    return string.format("%02d:%02d:%02d - %02d/%02d/%04d", t.hour, t.min, t.sec, t.day, t.month, t.year)
end

--[[
   Function: lia.time.DaysBetween

   Description:
      Calculates the number of days between two date/time strings, each in "HH:MM:SS - DD/MM/YYYY" format.

   Parameters:
      strTime1 (string) — The first date/time string.
      strTime2 (string) — The second date/time string.

   Returns:
      (number or string) The number of days between the two dates, or "Invalid dates" on error.

   Realm:
      Shared

   Example Usage:
      print(lia.time.DaysBetween("00:00:00 - 01/01/2025", "00:00:00 - 10/01/2025"))
]]
function lia.time.DaysBetween(strTime1, strTime2)
    local y1, mo1, d1 = lia.time.ParseTime(strTime1)
    local y2, mo2, d2 = lia.time.ParseTime(strTime2)
    if not (y1 and y2) then return "Invalid dates" end
    local t1 = os.time({
        year = y1,
        month = mo1,
        day = d1,
        hour = 0,
        min = 0,
        sec = 0
    })

    local t2 = os.time({
        year = y2,
        month = mo2,
        day = d2,
        hour = 0,
        min = 0,
        sec = 0
    })

    local diff = os.difftime(t2, t1)
    return math.floor(diff / 86400)
end

--[[
   Function: lia.time.WeekdayName

   Description:
      Returns the weekday name for a given date/time string in "HH:MM:SS - DD/MM/YYYY" format.

   Parameters:
      strTime (string) — The date/time string.

   Returns:
      (string) The weekday name, or "Invalid date" on error.

   Realm:
      Shared

   Example Usage:
      print(lia.time.WeekdayName("14:30:00 - 27/03/2025"))
]]
function lia.time.WeekdayName(strTime)
    local y, mo, d, h, mi, s = lia.time.ParseTime(strTime)
    if not y then return "Invalid date" end
    local t = os.time({
        year = y,
        month = mo,
        day = d,
        hour = h,
        min = mi,
        sec = s
    })
    return os.date("%A", t)
end

--[[
   Function: lia.time.TimeDifference

   Description:
      Calculates the difference in days between a specified target date/time (in "HH:MM:SS - DD/MM/YYYY" format) and the current date/time.

   Parameters:
      strTime (string) — The target date/time string.

   Returns:
      (number) The day difference as an integer, or nil if invalid.

   Realm:
      Shared

   Example Usage:
      print(lia.time.TimeDifference("14:30:00 - 30/03/2025"))
]]
function lia.time.TimeDifference(strTime)
    local pattern = "(%d+):(%d+):(%d+)%s*-%s*(%d+)/(%d+)/(%d+)"
    local hour, minute, second, day, month, year = strTime:match(pattern)
    if not (hour and minute and second and day and month and year) then return nil end
    hour, minute, second, day, month, year = tonumber(hour), tonumber(minute), tonumber(second), tonumber(day), tonumber(month), tonumber(year)
    local targetDate = os.time({
        year = year,
        month = month,
        day = day,
        hour = hour,
        min = minute,
        sec = second
    })

    local currentDate = os.time()
    local differenceInDays = math.floor(os.difftime(targetDate, currentDate) / (24 * 60 * 60))
    return differenceInDays
end

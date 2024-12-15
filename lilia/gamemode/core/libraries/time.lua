--- Various useful helper functions.
-- @library lia.time
lia.time = {}
--- Generates a formatted date string based on the current system time.
-- @realm shared
-- @string[opt] StartingMessage A message to prepend to the formatted date.
-- @bool[opt] includeWeekDay Whether to include the day of the week in the formatted date.
-- @bool[opt] includeDay Whether to include the day of the month in the formatted date.
-- @bool[opt] includeMonth Whether to include the month in the formatted date.
-- @bool[opt] includeYear Whether to include the year in the formatted date.
-- @bool[opt] includeTime Whether to include the time in the formatted date.
-- @return string The formatted date string.
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
    if lia.config.AmericanDates then
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
    local hourFormat = lia.config.AmericanTimeStamp and 12 or 24
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

--- Generates a formatted date string based on the current system time for in-game usage.
-- @realm shared
-- @string[opt] StartingMessage A message to prepend to the formatted date.
-- @bool[opt] includeWeekDay Whether to include the day of the week in the formatted date.
-- @bool[opt] includeDay Whether to include the day of the month in the formatted date.
-- @bool[opt] includeMonth Whether to include the month in the formatted date.
-- @bool[opt] includeYear Whether to include the year in the formatted date.
-- @bool[opt] includeTime Whether to include the time in the formatted date.
-- @return string The formatted date string.
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
    if lia.config.AmericanDates then
        month, day, year = currentTime.month, currentTime.day, lia.config.SchemaYear or currentTime.year
    else
        day, month, year = currentTime.day, currentTime.month, lia.config.SchemaYear or currentTime.year
    end

    if includeDay then output = output .. " " .. day end
    if includeMonth then
        local months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
        output = output .. " " .. months[month]
    end

    if includeYear then output = output .. ", " .. year end
    local hourFormat = lia.config.AmericanTimeStamp and 12 or 24
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

--- Generates a pre-formatted date string based on the provided time.
-- @realm shared
-- @string[opt] StartingMessage A message to prepend to the formatted date.
-- @tab timeToFormat The time to format.
-- @bool[opt] includeWeekDay Whether to include the day of the week in the formatted date.
-- @bool[opt] includeDay Whether to include the day of the month in the formatted date.
-- @bool[opt] includeMonth Whether to include the month in the formatted date.
-- @bool[opt] includeYear Whether to include the year in the formatted date.
-- @bool[opt] includeTime Whether to include the time in the formatted date.
-- @return string The formatted date string.
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
    if lia.config.AmericanDates then
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
    local hourFormat = lia.config.AmericanTimeStamp and 12 or 24
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

--- Generates a pre-formatted date string based on the provided time for in-game usage.
-- @realm shared
-- @string[opt] StartingMessage A message to prepend to the formatted date.
-- @tab timeToFormat The time to format.
-- @bool[opt] includeWeekDay Whether to include the day of the week in the formatted date.
-- @bool[opt] includeDay Whether to include the day of the month in the formatted date.
-- @bool[opt] includeMonth Whether to include the month in the formatted date.
-- @bool[opt] includeYear Whether to include the year in the formatted date.
-- @bool[opt] includeTime Whether to include the time in the formatted date.
-- @return string The formatted date string.
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
    if lia.config.AmericanDates then
        month, day, year = currentTime.month, currentTime.day, lia.config.SchemaYear or currentTime.year
    else
        day, month, year = currentTime.day, currentTime.month, lia.config.SchemaYear or currentTime.year
    end

    if includeDay then output = output .. " " .. day end
    if includeMonth then
        local months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
        output = output .. " " .. months[month]
    end

    if includeYear then output = output .. ", " .. year end
    local hourFormat = lia.config.AmericanTimeStamp and 12 or 24
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

--- Converts a date string to a table containing date and time components.
-- @string str The date string in the format "YYYY-MM-DD HH:MM:SS"
-- @treturn table Table containing date and time components
-- @realm shared
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

--- Returns the amount of time passed since the given time.
-- Expected format of `strTime`: "HH:MM:SS - DD/MM/YYYY"
-- @string strTime A time string in the specified format.
-- @treturn string A human-readable string indicating years, months, days, hours, minutes, and seconds passed.
-- @realm shared
function lia.time.TimeSince(strTime)
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
    if inputTimestamp >= currentTimestamp then return "The specified time is in the future." end
    local diffSeconds = currentTimestamp - inputTimestamp
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

--- Returns the amount of time until the given time.
-- Expected format of `strTime`: "HH:MM:SS - DD/MM/YYYY"
-- @string strTime A time string in the specified format.
-- @treturn string A human-readable string indicating years, months, days, hours, minutes, and seconds remaining.
-- @realm shared
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

--- Returns the current local time in "HH:MM:SS - DD/MM/YYYY" format.
-- @treturn string The current local time string.
-- @realm shared
function lia.time.CurrentLocalTime()
    local now = os.time()
    local t = os.date("*t", now)
    return string.format("%02d:%02d:%02d - %02d/%02d/%04d", t.hour, t.min, t.sec, t.day, t.month, t.year)
end

--- Converts a number of seconds into days, hours, minutes, and seconds.
-- @int seconds The total number of seconds.
-- @treturn number Days
-- @treturn number Hours
-- @treturn number Minutes
-- @treturn number Seconds
-- @realm shared
function lia.time.SecondsToDHMS(seconds)
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    return days, hours, minutes, secs
end

--- Converts hours, minutes, and seconds into a total number of seconds.
-- @int hour The hour component.
-- @int minute The minute component.
-- @int second The second component.
-- @treturn number The total number of seconds.
-- @realm shared
function lia.time.HMSToSeconds(hour, minute, second)
    return hour * 3600 + minute * 60 + second
end

--- Formats a UNIX timestamp into "HH:MM:SS - DD/MM/YYYY".
-- @int timestamp A UNIX timestamp.
-- @treturn string The formatted time string.
-- @realm shared
function lia.time.FormatTimestamp(timestamp)
    local t = os.date("*t", timestamp)
    return string.format("%02d:%02d:%02d - %02d/%02d/%04d", t.hour, t.min, t.sec, t.day, t.month, t.year)
end

--- Parses a time string ("HH:MM:SS - DD/MM/YYYY") into numeric components.
-- @string strTime The time string.
-- @treturn[1] number year The parsed year
-- @treturn[1] number month The parsed month
-- @treturn[1] number day The parsed day
-- @treturn[1] number hour The parsed hour
-- @treturn[1] number minute The parsed minute
-- @treturn[1] number second The parsed second
-- @treturn[2] nil If parsing fails
-- @realm shared
function lia.time.ParseTime(strTime)
    local pattern = "(%d+):(%d+):(%d+)%s*%-%s*(%d+)/(%d+)/(%d+)"
    local hour, minute, second, d, m, y = strTime:match(pattern)
    if not (hour and minute and second and d and m and y) then return nil end
    hour, minute, second, d, m, y = tonumber(hour), tonumber(minute), tonumber(second), tonumber(d), tonumber(m), tonumber(y)
    if hour < 0 or hour > 23 then return nil end
    if minute < 0 or minute > 59 then return nil end
    if second < 0 or second > 59 then return nil end
    if m < 1 or m > 12 then return nil end
    local maxDay = lia.time.DaysInMonth(m, y)
    if not maxDay or d < 1 or d > maxDay then return nil end
    if y < 1970 then return nil end
    return y, m, d, hour, minute, second
end

--- Calculates the number of days between two dates (ignoring time of day).
-- @string strTime1 A time string "HH:MM:SS - DD/MM/YYYY"
-- @string strTime2 A time string "HH:MM:SS - DD/MM/YYYY"
-- @treturn number|nil The number of days between the two dates, or a string error message.
-- @realm shared
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

--- Returns the name of the weekday for the given date/time.
-- @string strTime A time string "HH:MM:SS - DD/MM/YYYY"
-- @treturn string The weekday name, or "Invalid date" if invalid.
-- @realm shared
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

--- Calculates the time difference in days between the given date and the current date.
-- @string strTime A time string in the format "HH:MM:SS - DD/MM/YYYY".
-- @treturn number|nil The difference in days between the given date and the current date, or nil if the input is invalid.
-- @realm shared
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
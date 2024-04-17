
--[[--
Date and time handling.

All of Lua's time functions are dependent on the Unix epoch, which means we can't have dates that go further than 1970. This
library remedies this problem. Time/date is represented by a `date` object that is queried, instead of relying on the seconds
since the epoch.
]]
-- @module lia.date

lia.date = lia.date or {}

--- Generates a formatted date string based on the current system time.
-- @realm shared
-- @param StartingMessage (optional) A message to prepend to the formatted date.
-- @param includeWeekDay (optional) Whether to include the day of the week in the formatted date.
-- @param includeDay (optional) Whether to include the day of the month in the formatted date.
-- @param includeMonth (optional) Whether to include the month in the formatted date.
-- @param includeYear (optional) Whether to include the year in the formatted date.
-- @param includeTime (optional) Whether to include the time in the formatted date.
-- @return The formatted date string.
function lia.date.GetFormattedDate(StartingMessage, includeWeekDay, includeDay, includeMonth, includeYear, includeTime)
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
-- @param StartingMessage (optional) A message to prepend to the formatted date.
-- @param includeWeekDay (optional) Whether to include the day of the week in the formatted date.
-- @param includeDay (optional) Whether to include the day of the month in the formatted date.
-- @param includeMonth (optional) Whether to include the month in the formatted date.
-- @param includeYear (optional) Whether to include the year in the formatted date.
-- @param includeTime (optional) Whether to include the time in the formatted date.
-- @return The formatted date string.
function lia.date.GetFormattedDateInGame(StartingMessage, includeWeekDay, includeDay, includeMonth, includeYear, includeTime)
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
-- @param StartingMessage (optional) A message to prepend to the formatted date.
-- @param timeToFormat The time to format.
-- @param includeWeekDay (optional) Whether to include the day of the week in the formatted date.
-- @param includeDay (optional) Whether to include the day of the month in the formatted date.
-- @param includeMonth (optional) Whether to include the month in the formatted date.
-- @param includeYear (optional) Whether to include the year in the formatted date.
-- @param includeTime (optional) Whether to include the time in the formatted date.
-- @return The formatted date string.
function lia.date.GetPreFormattedDate(StartingMessage, timeToFormat, includeWeekDay, includeDay, includeMonth, includeYear, includeTime)
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
-- @param StartingMessage (optional) A message to prepend to the formatted date.
-- @param timeToFormat The time to format.
-- @param includeWeekDay (optional) Whether to include the day of the week in the formatted date.
-- @param includeDay (optional) Whether to include the day of the month in the formatted date.
-- @param includeMonth (optional) Whether to include the month in the formatted date.
-- @param includeYear (optional) Whether to include the year in the formatted date.
-- @param includeTime (optional) Whether to include the time in the formatted date.
-- @return The formatted date string.

function lia.date.GetPreFormattedDateInGame(StartingMessage, timeToFormat, includeWeekDay, includeDay, includeMonth, includeYear, includeTime)
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

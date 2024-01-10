lia.date = lia.date or {}
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

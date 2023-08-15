--------------------------------------------------------------------------------------------------------
lia.date = lia.date or {}
--------------------------------------------------------------------------------------------------------
function lia.date.GetFormattedDate(includeWeek, includeDay, includeMonth, includeYear, includeTime)
    local currentTime = os.date("*t") -- Get the current date and time as a table
    local output = "Current Date:"
    if includeWeek then
        local daysOfWeek = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
        output = output .. " " .. daysOfWeek[currentTime.wday]
    end

    if includeDay then output = output .. " " .. currentTime.day end
    if includeMonth then
        local months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
        output = output .. " " .. months[currentTime.month]
    end

    if includeYear then output = output .. " " .. currentTime.year end
    if includeTime then output = output .. string.format(" %02d:%02d:%02d", currentTime.hour, currentTime.min, currentTime.sec) end
    return output
end
--------------------------------------------------------------------------------------------------------
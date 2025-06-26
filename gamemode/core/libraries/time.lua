lia.time = lia.time or {}
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

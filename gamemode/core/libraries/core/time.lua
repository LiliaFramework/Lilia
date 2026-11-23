lia.time = lia.time or {}
function lia.time.timeSince(strTime)
    local timestamp
    if isnumber(strTime) then
        timestamp = strTime
    elseif isstring(strTime) then
        local year, month, day = lia.time.ParseTime(strTime)
        if not (year and month and day) then return "Invalid date" end
        timestamp = os.time{
            year = year,
            month = month,
            day = day,
            hour = 0,
            min = 0,
            sec = 0
        }
    else
        return "Invalid input"
    end

    local diff = os.time() - timestamp
    if diff < 60 then
        return string.format("%s seconds ago", diff)
    elseif diff < 3600 then
        return string.format("%s minutes ago", math.floor(diff / 60))
    elseif diff < 86400 then
        return string.format("%s hours ago", math.floor(diff / 3600))
    else
        return string.format("%s days ago", math.floor(diff / 86400))
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

function lia.time.getDate()
    local ct = os.date("*t")
    local american = lia.config.get("AmericanTimeStamps", false)
    if american then
        local suffix = ct.hour < 12 and "am" or "pm"
        local hour12 = ct.hour % 12
        if hour12 == 0 then hour12 = 12 end
        return string.format("%s, %s %02d, %04d, %02d:%02d:%02d%s", ({"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"})[ct.wday], ({"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"})[ct.month], ct.day, ct.year, hour12, ct.min, ct.sec, suffix)
    end
    return string.format("%s, %02d %s %04d, %02d:%02d:%02d", ({"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"})[ct.wday], ct.day, ({"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"})[ct.month], ct.year, ct.hour, ct.min, ct.sec)
end

function lia.time.formatDHM(seconds)
    seconds = math.max(seconds or 0, 0)
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    return string.format("%sd %sh %sm", days, hours, minutes)
end

function lia.time.getHour()
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

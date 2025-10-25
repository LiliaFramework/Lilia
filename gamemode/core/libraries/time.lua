﻿--[[
    Time Library
    Time manipulation, formatting, and calculation system for the Lilia framework.
]]
--[[
    Overview:
    The time library provides comprehensive functionality for time manipulation, formatting, and calculation within the Lilia framework. It handles time parsing, formatting, relative time calculations, and date/time display with support for both 24-hour and 12-hour (American) time formats. The library operates on both server and client sides, providing consistent time handling across the gamemode. It includes functions for calculating time differences, formatting durations, parsing date strings, and generating localized time displays. The library ensures proper time zone handling and supports configurable time format preferences.
]]
lia.time = lia.time or {}
--[[
    Purpose: Calculate and return a human-readable string representing how long ago a given time was
    When Called: When displaying relative timestamps, such as "last seen" times, message timestamps, or activity logs
    Parameters: strTime (string|number) - Either a timestamp number or a date string in "YYYY-MM-DD" format
    Returns: string - Localized string indicating time elapsed (e.g., "5 minutes ago", "2 hours ago", "3 days ago")
    Realm: Shared (works on both client and server)
    Example Usage:

    Low Complexity:
    ```lua
        -- Simple: Get time since a timestamp
        local lastSeen = lia.time.timeSince(1640995200) -- Returns "2 hours ago"
    ```
    Medium Complexity:
    ```lua
        -- Medium: Get time since a date string with validation
        local playerData = {lastLogin = "2024-01-01"}
        if playerData.lastLogin then
            local timeAgo = lia.time.timeSince(playerData.lastLogin)
            print("Player last seen: " .. timeAgo)
        end
    ```
    High Complexity:
    ```lua
        -- High: Batch process multiple timestamps with error handling
        local timestamps = {1640995200, "2024-01-01", 1641081600}
        for i, timestamp in ipairs(timestamps) do
            local result = lia.time.timeSince(timestamp)
            if result ~= L("invalidDate") and result ~= L("invalidInput") then
                print("Item " .. i .. " was created " .. result)
            end
        end
    ```
]]
--
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
    Purpose: Parse a date/time string and convert it into a structured table with individual time components
    When Called: When converting date strings to structured data for further processing or validation
    Parameters: str (string, optional) - Date string in "YYYY-MM-DD HH:MM:SS" format, defaults to current time if nil
    Returns: table - Table containing year, month, day, hour, min, sec as numbers
    Realm: Shared (works on both client and server)
    Example Usage:

    Low Complexity:
    ```lua
        -- Simple: Parse current time
        local timeData = lia.time.toNumber() -- Returns current time components
        print(timeData.year) -- Prints current year
    ```
    Medium Complexity:
    ```lua
        -- Medium: Parse specific date with validation
        local dateStr = "2024-01-15 14:30:45"
        local timeData = lia.time.toNumber(dateStr)
        if timeData.year and timeData.month then
            print("Year: " .. timeData.year .. ", Month: " .. timeData.month)
        end
    ```
    High Complexity:
    ```lua
        -- High: Batch parse multiple dates and validate ranges
        local dates = {"2024-01-01 00:00:00", "2024-12-31 23:59:59", "2023-06-15 12:30:00"}
        for i, dateStr in ipairs(dates) do
            local timeData = lia.time.toNumber(dateStr)
            if timeData.year >= 2024 and timeData.month <= 12 then
                print("Valid date " .. i .. ": " .. timeData.day .. "/" .. timeData.month .. "/" .. timeData.year)
            end
        end
    ```
]]
--
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
    Purpose: Get a formatted, localized string representation of the current date and time
    When Called: When displaying current date/time in UI elements, logs, or status displays
    Parameters: None
    Returns: string - Formatted date string with localized weekday and month names
    Realm: Shared (works on both client and server)
    Example Usage:

    Low Complexity:
    ```lua
        -- Simple: Display current date
        local currentDate = lia.time.getDate()
        print("Current time: " .. currentDate)
    ```
    Medium Complexity:
    ```lua
        -- Medium: Use in UI with conditional formatting
        local dateStr = lia.time.getDate()
        local isAmerican = lia.config.get("AmericanTimeStamps", false)
        local displayText = isAmerican and "US Time: " .. dateStr or "Time: " .. dateStr
    ```
    High Complexity:
    ```lua
        -- High: Log system with date formatting and multiple outputs
        local function logWithTimestamp(message)
            local timestamp = lia.time.getDate()
            local logEntry = "[" .. timestamp .. "] " .. message
            -- Log to console
            print(logEntry)
            -- Log to file (if file logging exists)
            if file.Exists("logs/server.log", "DATA") then
                file.Append("logs/server.log", logEntry .. "\n")
            end
            -- Send to admin chat
            for _, admin in ipairs(player.GetAll()) do
                if admin:IsAdmin() then
                    admin:ChatPrint(logEntry)
                end
            end
        end
    ```
]]
--
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
    Purpose: Format a duration in seconds into a human-readable string showing days, hours, and minutes
    When Called: When displaying durations, cooldowns, or time remaining in UI elements
    Parameters: seconds (number, optional) - Duration in seconds to format, defaults to 0 if nil
    Returns: string - Localized string showing days, hours, and minutes (e.g., "2 days, 5 hours, 30 minutes")
    Realm: Shared (works on both client and server)
    Example Usage:

    Low Complexity:
    ```lua
        -- Simple: Format a duration
        local duration = lia.time.formatDHM(90000) -- Returns "1 day, 1 hour, 0 minutes"
        print("Time remaining: " .. duration)
    ```
    Medium Complexity:
    ```lua
        -- Medium: Format cooldown with validation
        local cooldownTime = player:GetNWInt("cooldown", 0)
        if cooldownTime > 0 then
            local formatted = lia.time.formatDHM(cooldownTime)
            player:ChatPrint("Cooldown remaining: " .. formatted)
        end
    ```
    High Complexity:
    ```lua
        -- High: Multiple duration formatting with conditional display
        local function formatMultipleDurations(durations)
            local results = {}
            for name, seconds in pairs(durations) do
                if seconds and seconds > 0 then
                    local formatted = lia.time.formatDHM(seconds)
                    table.insert(results, name .. ": " .. formatted)
                end
            end
            return table.concat(results, ", ")
        end
        local durations = {
            cooldown = 3600,
            banTime = 86400,
            muteTime = 1800
        }
        print(formatMultipleDurations(durations))
    ```
]]
--
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
    Purpose: Get the current hour in either 12-hour (AM/PM) or 24-hour format based on configuration
    When Called: When displaying current hour in UI elements, time-based events, or hour-specific functionality
    Parameters: None
    Returns: string|number - Current hour as string with AM/PM suffix (American format) or number (24-hour format)
    Realm: Shared (works on both client and server)
    Example Usage:

    Low Complexity:
    ```lua
        -- Simple: Get current hour
        local currentHour = lia.time.getHour()
        print("Current hour: " .. tostring(currentHour))
    ```
    Medium Complexity:
    ```lua
        -- Medium: Time-based greeting system
        local hour = lia.time.getHour()
        local greeting = ""
        if lia.config.get("AmericanTimeStamps", false) then
            -- American format returns string like "2pm"
            local hourNum = tonumber(hour:match("%d+"))
            if hourNum >= 6 and hourNum < 12 then
                greeting = "Good morning!"
            elseif hourNum >= 12 and hourNum < 18 then
                greeting = "Good afternoon!"
            else
                greeting = "Good evening!"
            end
        else
            -- 24-hour format returns number
            if hour >= 6 and hour < 12 then
                greeting = "Good morning!"
            elseif hour >= 12 and hour < 18 then
                greeting = "Good afternoon!"
            else
                greeting = "Good evening!"
            end
        end
    ```
    High Complexity:
    ```lua
        -- High: Dynamic server events based on time with multiple time zones
        local function getServerEvents()
            local hour = lia.time.getHour()
            local events = {}
            -- Parse hour for both formats
            local hourNum
            if type(hour) == "string" then
                hourNum = tonumber(hour:match("%d+"))
                local isPM = hour:find("pm")
                if isPM and hourNum ~= 12 then
                    hourNum = hourNum + 12
                elseif not isPM and hourNum == 12 then
                    hourNum = 0
                end
            else
                hourNum = hour
            end
            -- Schedule events based on hour
            if hourNum >= 0 and hourNum < 6 then
                table.insert(events, "Night shift bonus active")
            elseif hourNum >= 6 and hourNum < 12 then
                table.insert(events, "Morning rush hour")
            elseif hourNum >= 12 and hourNum < 18 then
                table.insert(events, "Afternoon activities")
            else
                table.insert(events, "Evening events")
            end
            return events
        end
    ```
]]
--
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

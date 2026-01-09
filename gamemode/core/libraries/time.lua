--[[
    Folder: Libraries
    File: time.md
]]
--[[
    Time Library

    Time manipulation, formatting, and calculation system for the Lilia framework.
]]
--[[
    Overview:
        The time library provides comprehensive functionality for time manipulation, formatting, and calculation within the Lilia framework. It handles time parsing, formatting, relative time calculations, and date/time display with support for both 24-hour and 12-hour (American) time formats. The library operates on both server and client sides, providing consistent time handling across the gamemode. It includes functions for calculating time differences, formatting durations, parsing date strings, and generating localized time displays. The library ensures proper time zone handling and supports configurable time format preferences.
]]
lia.time = lia.time or {}
--[[
    Purpose:
        Produce a localized "time since" string from a date stamp or Unix time.

    When Called:
        Anywhere UI or logs need relative time (e.g., last seen, ban info).

    Parameters:
        strTime (string|number)
            "YYYY-MM-DD" style date or Unix timestamp (seconds).

    Returns:
        string
            Localized human-friendly delta (seconds/minutes/hours/days ago).

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Build a rich status string for a ban record and a last-seen stamp.
            local function formatBanStatus(ply)
                local lastSeen = lia.time.timeSince(ply:getNetVar("lastSeenAt"))
                local banStarted = lia.time.timeSince(ply:getNetVar("banStart"))
                local banEnds = lia.time.formatDHM(ply:getNetVar("banEnd") - os.time())
                return string.format("%s • banned %s • expires in %s", lastSeen, banStarted, banEnds)
            end

            hook.Add("ScoreboardShow", "ShowBanTiming", function()
                for _, ply in ipairs(player.GetAll()) do
                    local status = formatBanStatus(ply)
                    chat.AddText(Color(200, 200, 50), ply:Name(), Color(180, 180, 180), " - ", status)
                end
            end)
        ```
]]
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
    Purpose:
        Parse a date/time string in "YYYY-MM-DD HH:MM:SS" format into a numeric date table.

    When Called:
        When converting date strings to components for calculations or storage.

    Parameters:
        str (string)
            Date/time string in "YYYY-MM-DD HH:MM:SS" format. Defaults to current date/time if omitted.

    Returns:
        table
            Table containing numeric date components: {year, month, day, hour, min, sec}.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Normalize a date string into a timestamp for storage.
            local function normalizeDate(inputStr)
                local parts = lia.time.toNumber(inputStr)
                if not parts.year then return nil end
                return os.time(parts)
            end

            net.Receive("liaSubmitEvent", function(_, ply)
                local eventDateStr = net.ReadString()
                local ts = normalizeDate(eventDateStr)
                if not ts then
                    ply:notifyLocalized("invalidDate")
                    return
                end
                lia.log.add(ply, "eventScheduled", os.date("%c", ts))
            end)
        ```
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
    Purpose:
        Return the current date/time as a localized formatted string.

    When Called:
        For HUD clocks, chat timestamps, or admin panels showing server time.

    Parameters:
        None

    Returns:
        string
            Localized date/time in 24h or American 12h format based on config.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Display server time in a HUD corner, honoring American/24h format.
            hook.Add("HUDPaint", "DrawServerClock", function()
                local text = lia.time.getDate()
                surface.SetFont("liaSmallFont")
                local w, h = surface.GetTextSize(text)
                draw.RoundedBox(4, ScrW() - w - 20, 16, w + 12, h + 8, Color(0, 0, 0, 170))
                draw.SimpleText(text, "liaSmallFont", ScrW() - 14, 20, color_white, TEXT_ALIGN_RIGHT)
            end)
        ```
]]
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
    Purpose:
        Format a duration into days, hours, and minutes.

    When Called:
        Cooldowns, jail timers, rental durations, or any long-running countdown.

    Parameters:
        seconds (number)
            Duration in seconds.

    Returns:
        string
            Localized `X days Y hours Z minutes`.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Show detention duration and remaining parole time in an admin panel.
            local function buildDetentionRow(char)
                local remainingSeconds = math.max(char:getDetainTime() - os.time(), 0)
                local formatted = lia.time.formatDHM(remainingSeconds)
                return string.format("%s (%s)", char:getName(), formatted)
            end

            hook.Add("OnAdminPanelOpened", "PopulateDetentions", function(panel)
                for _, char in ipairs(lia.char.loaded) do
                    if char:isDetained() then
                        panel:AddLine(buildDetentionRow(char))
                    end
                end
            end)
        ```
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
    Purpose:
        Get the current hour string honoring 12h/24h configuration.

    When Called:
        HUD clocks or schedule checks that need the current hour formatted.

    Parameters:
        None

    Returns:
        string|number
            "12am/pm" string in American mode; numeric 0-23 otherwise.

    Realm:
        Shared

    Example Usage:
        ```lua
            -- Trigger different ambiance based on configured hour format and time.
            local function applyAmbientByHour()
                local hour = lia.time.getHour()
                local numericHour = tonumber(hour) or (tostring(hour):find("pm") and (tonumber(hour:match("%d+")) % 12) + 12 or tonumber(hour:match("%d+")) % 12)
                if numericHour >= 20 or numericHour < 6 then
                    RunConsoleCommand("stopsound")
                    surface.PlaySound("ambient/atmosphere/city_silent.wav")
                else
                    surface.PlaySound("ambient/atmosphere/underground_hall.wav")
                end
            end

            hook.Add("InitPostEntity", "ApplyAmbientHourly", applyAmbientByHour)
        ```
]]
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

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
        -- Greet players with the time since they last joined using persistence data
        hook.Add("PlayerInitialSpawn", "welcomeLastSeen", function(ply)
            -- Retrieve the time this player last joined from persistent data
            local key = "lastLogin_" .. ply:SteamID64()
            local last = lia.data.get(key, nil, true)

            if last then
                ply:ChatPrint("Welcome back! You last joined " .. lia.time.TimeSince(last) .. ".")
            else
                ply:ChatPrint("Welcome for the first time!")
            end

            -- Store the current time for the next login
            lia.data.set(key, os.time(), true)
        end)
 ]]
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
        -- Schedule an event at a custom date and time using the parsed table
        local targetInfo = lia.time.toNumber("2025-04-01 12:30:00")
        local delay = os.time(targetInfo) - os.time()
        if delay > 0 then
            timer.Simple(delay, function()
                print("It's now April 1st, 2025, 12:30 PM!")
            end)
        end
]]
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

    Realm:
       Shared

    Example Usage:
        -- Announce the current server date and time to all players every hour
        timer.Create("ServerTimeAnnounce", 3600, 0, function()
            local dateString = lia.time.GetDate()
            for _, ply in player.Iterator() do
                ply:ChatPrint("Server time: " .. dateString)
            end
        end)
 ]]
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

    Realm:
       Shared

    Example Usage:
        -- Toggle an NPC's shop based on the in-game hour
        local hour = lia.time.GetHour()
        if hour >= 9 and hour < 17 then
            npc:SetNWBool("ShopOpen", true)
        else
            npc:SetNWBool("ShopOpen", false)
        end
 ]]
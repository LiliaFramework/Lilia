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
        -- This snippet demonstrates a common usage of print
       print(lia.time.TimeSince("2025-03-27"))
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
        -- This snippet demonstrates a common usage of lia.time.toNumber
      local t = lia.time.toNumber("2025-03-27 14:30:00")
      print(t.year, t.month, t.day, t.hour, t.min, t.sec)
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
 ]]

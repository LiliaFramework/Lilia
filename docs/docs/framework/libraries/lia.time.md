# lia.time

---

The `lia.time` library provides a suite of utility functions for managing and formatting time-related data within the Lilia Framework. These functions facilitate tasks such as generating formatted date strings, calculating time differences, converting between different time formats, and parsing time strings. By utilizing these utilities, developers can efficiently handle time manipulations, ensuring consistent and accurate time representations across their schemas and plugins.

---

## Functions

### **lia.time.GetFormattedDate**

**Description:**  
Generates a formatted date string based on the current system time. This function allows customization of the date format by including or excluding specific components such as the weekday, day, month, year, and time.

**Realm:**  
`Shared`

**Parameters:**  

- `StartingMessage` (`string`, optional):  
  A message to prepend to the formatted date.

- `includeWeekDay` (`bool`, optional):  
  Whether to include the day of the week in the formatted date.

- `includeDay` (`bool`, optional):  
  Whether to include the day of the month in the formatted date.

- `includeMonth` (`bool`, optional):  
  Whether to include the month in the formatted date.

- `includeYear` (`bool`, optional):  
  Whether to include the year in the formatted date.

- `includeTime` (`bool`, optional):  
  Whether to include the time in the formatted date.

**Returns:**  
`string` - The formatted date string.

**Example Usage:**
```lua
-- Generate a formatted date with all components
local formattedDate = lia.time.GetFormattedDate("Current Date:", true, true, true, true, true)
print(formattedDate)
-- Output: "Current Date: Tuesday, 15 March, 2025 14:30:45 PM"

-- Generate a formatted date without the weekday and time
local simpleDate = lia.time.GetFormattedDate(nil, false, true, true, true, false)
print(simpleDate)
-- Output: " 15 March, 2025"
```

---
  
### **lia.time.GetFormattedDateInGame**

**Description:**  
Generates a formatted date string based on the current system time for in-game usage. This function is similar to `GetFormattedDate` but allows for schema-specific year configurations.

**Realm:**  
`Shared`

**Parameters:**  

- `StartingMessage` (`string`, optional):  
  A message to prepend to the formatted date.

- `includeWeekDay` (`bool`, optional):  
  Whether to include the day of the week in the formatted date.

- `includeDay` (`bool`, optional):  
  Whether to include the day of the month in the formatted date.

- `includeMonth` (`bool`, optional):  
  Whether to include the month in the formatted date.

- `includeYear` (`bool`, optional):  
  Whether to include the year in the formatted date.

- `includeTime` (`bool`, optional):  
  Whether to include the time in the formatted date.

**Returns:**  
`string` - The formatted date string tailored for in-game usage.

**Example Usage:**
```lua
-- Generate an in-game formatted date with custom schema year
local inGameDate = lia.time.GetFormattedDateInGame("Game Date:", true, true, true, true, true)
print(inGameDate)
-- Output: "Game Date: Wednesday, 15 March, 2025 14:30:45 PM"

-- Generate an in-game formatted date without the year
local inGameSimpleDate = lia.time.GetFormattedDateInGame(nil, true, true, true, false, true)
print(inGameSimpleDate)
-- Output: " Tuesday, 15 March 14:30:45 PM"
```

---

### **lia.time.GetPreFormattedDate**

**Description:**  
Generates a pre-formatted date string based on the provided time. This function allows customization of the date format by including or excluding specific components such as the weekday, day, month, year, and time.

**Realm:**  
`Shared`

**Parameters:**  

- `StartingMessage` (`string`, optional):  
  A message to prepend to the formatted date.

- `timeToFormat` (`table`):  
  The time to format, typically obtained from `os.date("*t")`.

- `includeWeekDay` (`bool`, optional):  
  Whether to include the day of the week in the formatted date.

- `includeDay` (`bool`, optional):  
  Whether to include the day of the month in the formatted date.

- `includeMonth` (`bool`, optional):  
  Whether to include the month in the formatted date.

- `includeYear` (`bool`, optional):  
  Whether to include the year in the formatted date.

- `includeTime` (`bool`, optional):  
  Whether to include the time in the formatted date.

**Returns:**  
`string` - The formatted date string.

**Example Usage:**
```lua
-- Define a specific time to format
local specificTime = {
    year = 2025,
    month = 12,
    day = 25,
    hour = 18,
    min = 45,
    sec = 30,
    wday = 6 -- Saturday
}

-- Generate a pre-formatted date with all components
local preFormattedDate = lia.time.GetPreFormattedDate("Event Date:", specificTime, true, true, true, true, true)
print(preFormattedDate)
-- Output: " Event Date: Saturday, 25 December, 2025 06:45:30 PM"

-- Generate a pre-formatted date without the time
local preFormattedSimpleDate = lia.time.GetPreFormattedDate(nil, specificTime, false, true, true, true, false)
print(preFormattedSimpleDate)
-- Output: " 25 December, 2025"
```

---

### **lia.time.GetPreFormattedDateInGame**

**Description:**  
Generates a pre-formatted date string based on the provided time for in-game usage. This function is similar to `GetPreFormattedDate` but allows for schema-specific year configurations.

**Realm:**  
`Shared`

**Parameters:**  

- `StartingMessage` (`string`, optional):  
  A message to prepend to the formatted date.

- `timeToFormat` (`table`):  
  The time to format, typically obtained from `os.date("*t")`.

- `includeWeekDay` (`bool`, optional):  
  Whether to include the day of the week in the formatted date.

- `includeDay` (`bool`, optional):  
  Whether to include the day of the month in the formatted date.

- `includeMonth` (`bool`, optional):  
  Whether to include the month in the formatted date.

- `includeYear` (`bool`, optional):  
  Whether to include the year in the formatted date.

- `includeTime` (`bool`, optional):  
  Whether to include the time in the formatted date.

**Returns:**  
`string` - The formatted date string tailored for in-game usage.

**Example Usage:**
```lua
-- Define a specific time to format
local specificTime = {
    year = 2025,
    month = 7,
    day = 4,
    hour = 12,
    min = 0,
    sec = 0,
    wday = 7 -- Sunday
}

-- Generate a pre-formatted in-game date with custom schema year
local preFormattedInGameDate = lia.time.GetPreFormattedDateInGame("Holiday:", specificTime, true, true, true, true, true)
print(preFormattedInGameDate)
-- Output: " Holiday: Sunday, 04 July, 2025 12:00:00 PM"

-- Generate a pre-formatted in-game date without the weekday
local preFormattedInGameSimpleDate = lia.time.GetPreFormattedDateInGame(nil, specificTime, false, true, true, true, true)
print(preFormattedInGameSimpleDate)
-- Output: " 04 July, 2025 12:00:00 PM"
```

---

### **lia.time.toNumber**

**Description:**  
Converts a date string in the format "YYYY-MM-DD HH:MM:SS" into a table containing individual date and time components. This function parses the string and extracts numerical values for the year, month, day, hour, minute, and second.

**Realm:**  
`Shared`

**Parameters:**  

- `str` (`string`, optional):  
  The date string to convert. Defaults to the current date and time if not provided.

**Returns:**  
`table` - A table containing the following keys:
- `year` (`number`)
- `month` (`number`)
- `day` (`number`)
- `hour` (`number`)
- `min` (`number`)
- `sec` (`number`)

**Example Usage:**
```lua
-- Convert a specific date string to a table
local dateTable = lia.time.toNumber("2025-12-25 18:45:30")
print(dateTable.year)  -- Output: 2025
print(dateTable.month) -- Output: 12
print(dateTable.day)   -- Output: 25
print(dateTable.hour)  -- Output: 18
print(dateTable.min)   -- Output: 45
print(dateTable.sec)   -- Output: 30

-- Convert the current date and time to a table
local currentDateTable = lia.time.toNumber()
print(currentDateTable.year)  -- Output: Current year
print(currentDateTable.month) -- Output: Current month
-- and so on...
```

---

### **lia.time.TimeSince**

**Description:**  
Returns the amount of time passed since the given time. The input can be a UNIX timestamp or a date string in the format "HH:MM:SS - DD/MM/YYYY". The function returns a human-readable string indicating the time elapsed in seconds, minutes, hours, or days.

**Realm:**  
`Shared`

**Parameters:**  

- `strTime` (`string|number`):  
  A time string in the format "HH:MM:SS - DD/MM/YYYY" or a UNIX timestamp.

**Returns:**  
`string` - A human-readable string indicating the time passed since the given time, such as "10 seconds ago", "5 minutes ago", "3 hours ago", or "2 days ago". Returns "Invalid date" or "Invalid input" if the input is not in the expected format.

**Example Usage:**
```lua
-- Calculate time since a specific date string
local timePassed = lia.time.TimeSince("14:30:00 - 01/01/2025")
print(timePassed)
-- Output: "X days ago"

-- Calculate time since a UNIX timestamp
local pastTimestamp = os.time() - 5000 -- 5000 seconds ago
local timeSinceTimestamp = lia.time.TimeSince(pastTimestamp)
print(timeSinceTimestamp)
-- Output: "1 hour ago"
```

---

### **lia.time.TimeUntil**

**Description:**  
Returns the amount of time remaining until the given time. The input must be a date string in the format "HH:MM:SS - DD/MM/YYYY". The function returns a human-readable string indicating the time remaining in years, months, days, hours, minutes, and seconds. If the specified time is in the past, it returns an appropriate message.

**Realm:**  
`Shared`

**Parameters:**  

- `strTime` (`string`):  
  A time string in the format "HH:MM:SS - DD/MM/YYYY".

**Returns:**  
`string` - A human-readable string indicating the time remaining until the given time, such as "2 years, 3 months, 5 days, 4 hours, 30 minutes, 15 seconds". Returns an error message if the input is invalid or the time is in the past.

**Example Usage:**
```lua
-- Calculate time until a specific date string
local timeRemaining = lia.time.TimeUntil("18:45:30 - 25/12/2025")
print(timeRemaining)
-- Output: "X years, Y months, Z days, A hours, B minutes, C seconds"
```

---

### **lia.time.CurrentLocalTime**

**Description:**  
Returns the current local time in the format "HH:MM:SS - DD/MM/YYYY". This function provides a standardized string representation of the current system time, suitable for display purposes.

**Realm:**  
`Shared`

**Returns:**  
`string` - The current local time string in the format "HH:MM:SS - DD/MM/YYYY".

**Example Usage:**
```lua
-- Get the current local time
local localTime = lia.time.CurrentLocalTime()
print(localTime)
-- Output: "14:30:45 - 15/03/2025"
```

---

### **lia.time.SecondsToDHMS**

**Description:**  
Converts a number of seconds into days, hours, minutes, and seconds. This function is useful for breaking down a total duration into its constituent time units.

**Realm:**  
`Shared`

**Parameters:**  

- `seconds` (`number`):  
  The total number of seconds to convert.

**Returns:**  
- `days` (`number`)
- `hours` (`number`)
- `minutes` (`number`)
- `secs` (`number`)

**Example Usage:**
```lua
-- Convert 100000 seconds to days, hours, minutes, and seconds
local days, hours, minutes, seconds = lia.time.SecondsToDHMS(100000)
print(days, hours, minutes, seconds)
-- Output: "1 3 46 40"
```

---

### **lia.time.HMSToSeconds**

**Description:**  
Converts hours, minutes, and seconds into a total number of seconds. This function is useful for aggregating time components into a single duration value.

**Realm:**  
`Shared`

**Parameters:**  

- `hour` (`number`):  
  The hour component.

- `minute` (`number`):  
  The minute component.

- `second` (`number`):  
  The second component.

**Returns:**  
`number` - The total number of seconds.

**Example Usage:**
```lua
-- Convert 2 hours, 30 minutes, and 45 seconds to total seconds
local totalSeconds = lia.time.HMSToSeconds(2, 30, 45)
print(totalSeconds)
-- Output: 9045
```

---

### **lia.time.FormatTimestamp**

**Description:**  
Formats a UNIX timestamp into a string with the format "HH:MM:SS - DD/MM/YYYY". This function provides a standardized way to represent UNIX timestamps as readable date and time strings.

**Realm:**  
`Shared`

**Parameters:**  

- `timestamp` (`number`):  
  A UNIX timestamp to format.

**Returns:**  
`string` - The formatted time string.

**Example Usage:**
```lua
-- Format the current UNIX timestamp
local currentTimestamp = os.time()
local formattedTime = lia.time.FormatTimestamp(currentTimestamp)
print(formattedTime)
-- Output: "14:30:45 - 15/03/2025"
```

---

### **lia.time.ParseTime**

**Description:**  
Parses a time string in the format "HH:MM:SS - DD/MM/YYYY" into its individual numeric components. This function extracts the year, month, day, hour, minute, and second from the input string.

**Realm:**  
`Shared`

**Parameters:**  

- `strTime` (`string`):  
  The time string to parse, formatted as "HH:MM:SS - DD/MM/YYYY".

**Returns:**  
- `year` (`number`)  
- `month` (`number`)  
- `day` (`number`)  
- `hour` (`number`)  
- `minute` (`number`)  
- `second` (`number`)  
- `nil` if parsing fails.

**Example Usage:**
```lua
-- Parse a specific time string
local year, month, day, hour, minute, second = lia.time.ParseTime("14:30:45 - 15/03/2025")
print(year, month, day, hour, minute, second)
-- Output: "2025 3 15 14 30 45"

-- Attempt to parse an invalid time string
local result = lia.time.ParseTime("Invalid Time String")
print(result)
-- Output: "nil"
```

---

### **lia.time.TimeDifference**

**Description:**  
Calculates the difference in days between a specified date and the current date. The input must be a date string in the format "HH:MM:SS - DD/MM/YYYY". The function returns the number of days remaining until the specified date or `nil` if the input is invalid.

**Realm:**  
`Shared`

**Parameters:**  

- `strTime` (`string`):  
  A time string in the format "HH:MM:SS - DD/MM/YYYY".

**Returns:**  
`number|nil` - The difference in days between the given date and the current date, or `nil` if the input is invalid.

**Example Usage:**
```lua
-- Calculate the time difference until a specific date
local daysLeft = lia.time.TimeDifference("18:45:30 - 25/12/2025")
print(daysLeft)
-- Output: "X days"

-- Attempt to calculate time difference with an invalid input
local invalidDifference = lia.time.TimeDifference("Invalid Date")
print(invalidDifference)
-- Output: "nil"
```

---

### **lia.time.TimeSince**

**Description:**  
Returns the amount of time passed since the given time. The input can be a UNIX timestamp or a date string in the format "HH:MM:SS - DD/MM/YYYY". The function returns a human-readable string indicating the time elapsed in seconds, minutes, hours, or days.

**Realm:**  
`Shared`

**Parameters:**  

- `strTime` (`string|number`):  
  A time string in the format "HH:MM:SS - DD/MM/YYYY" or a UNIX timestamp.

**Returns:**  
`string` - A human-readable string indicating the time passed since the given time, such as "10 seconds ago", "5 minutes ago", "3 hours ago", or "2 days ago". Returns "Invalid date" or "Invalid input" if the input is not in the expected format.

**Example Usage:**
```lua
-- Calculate time since a specific date string
local timePassed = lia.time.TimeSince("14:30:00 - 01/01/2025")
print(timePassed)
-- Output: "X days ago"

-- Calculate time since a UNIX timestamp
local pastTimestamp = os.time() - 5000 -- 5000 seconds ago
local timeSinceTimestamp = lia.time.TimeSince(pastTimestamp)
print(timeSinceTimestamp)
-- Output: "1 hour ago"
```

---

### **lia.time.TimeUntil**

**Description:**  
Returns the amount of time remaining until the given time. The input must be a date string in the format "HH:MM:SS - DD/MM/YYYY". The function returns a human-readable string indicating the time remaining in years, months, days, hours, minutes, and seconds. If the specified time is in the past, it returns an appropriate message.

**Realm:**  
`Shared`

**Parameters:**  

- `strTime` (`string`):  
  A time string in the format "HH:MM:SS - DD/MM/YYYY".

**Returns:**  
`string` - A human-readable string indicating the time remaining until the given time, such as "2 years, 3 months, 5 days, 4 hours, 30 minutes, 15 seconds". Returns an error message if the input is invalid or the time is in the past.

**Example Usage:**
```lua
-- Calculate time until a specific date string
local timeRemaining = lia.time.TimeUntil("18:45:30 - 25/12/2025")
print(timeRemaining)
-- Output: "X years, Y months, Z days, A hours, B minutes, C seconds"
```

---

### **lia.time.CurrentLocalTime**

**Description:**  
Returns the current local time in the format "HH:MM:SS - DD/MM/YYYY". This function provides a standardized string representation of the current system time, suitable for display purposes.

**Realm:**  
`Shared`

**Returns:**  
`string` - The current local time string in the format "HH:MM:SS - DD/MM/YYYY".

**Example Usage:**
```lua
-- Get the current local time
local localTime = lia.time.CurrentLocalTime()
print(localTime)
-- Output: "14:30:45 - 15/03/2025"
```

---

### **lia.time.SecondsToDHMS**

**Description:**  
Converts a number of seconds into days, hours, minutes, and seconds. This function is useful for breaking down a total duration into its constituent time units.

**Realm:**  
`Shared`

**Parameters:**  

- `seconds` (`number`):  
  The total number of seconds to convert.

**Returns:**  
- `days` (`number`)
- `hours` (`number`)
- `minutes` (`number`)
- `secs` (`number`)

**Example Usage:**
```lua
-- Convert 100000 seconds to days, hours, minutes, and seconds
local days, hours, minutes, seconds = lia.time.SecondsToDHMS(100000)
print(days, hours, minutes, seconds)
-- Output: "1 3 46 40"
```

---

### **lia.time.HMSToSeconds**

**Description:**  
Converts hours, minutes, and seconds into a total number of seconds. This function is useful for aggregating time components into a single duration value.

**Realm:**  
`Shared`

**Parameters:**  

- `hour` (`number`):  
  The hour component.

- `minute` (`number`):  
  The minute component.

- `second` (`number`):  
  The second component.

**Returns:**  
`number` - The total number of seconds.

**Example Usage:**
```lua
-- Convert 2 hours, 30 minutes, and 45 seconds to total seconds
local totalSeconds = lia.time.HMSToSeconds(2, 30, 45)
print(totalSeconds)
-- Output: 9045
```

---

### **lia.time.FormatTimestamp**

**Description:**  
Formats a UNIX timestamp into a string with the format "HH:MM:SS - DD/MM/YYYY". This function provides a standardized way to represent UNIX timestamps as readable date and time strings.

**Realm:**  
`Shared`

**Parameters:**  

- `timestamp` (`number`):  
  A UNIX timestamp to format.

**Returns:**  
`string` - The formatted time string.

**Example Usage:**
```lua
-- Format the current UNIX timestamp
local currentTimestamp = os.time()
local formattedTime = lia.time.FormatTimestamp(currentTimestamp)
print(formattedTime)
-- Output: "14:30:45 - 15/03/2025"
```

---

### **lia.time.ParseTime**

**Description:**  
Parses a time string in the format "HH:MM:SS - DD/MM/YYYY" into its individual numeric components. This function extracts the year, month, day, hour, minute, and second from the input string.

**Realm:**  
`Shared`

**Parameters:**  

- `strTime` (`string`):  
  The time string to parse, formatted as "HH:MM:SS - DD/MM/YYYY".

**Returns:**  
- `year` (`number`)  
- `month` (`number`)  
- `day` (`number`)  
- `hour` (`number`)  
- `minute` (`number`)  
- `second` (`number`)  
- `nil` if parsing fails.

**Example Usage:**
```lua
-- Parse a specific time string
local year, month, day, hour, minute, second = lia.time.ParseTime("14:30:45 - 15/03/2025")
print(year, month, day, hour, minute, second)
-- Output: "2025 3 15 14 30 45"

-- Attempt to parse an invalid time string
local result = lia.time.ParseTime("Invalid Time String")
print(result)
-- Output: "nil"
```

---

### **lia.time.DaysBetween**

**Description:**  
Calculates the number of days between two dates, ignoring the time of day. The dates must be provided as strings in the format "HH:MM:SS - DD/MM/YYYY". This function returns the absolute number of days separating the two dates or an error message if the inputs are invalid.

**Realm:**  
`Shared`

**Parameters:**  

- `strTime1` (`string`):  
  The first time string in the format "HH:MM:SS - DD/MM/YYYY".

- `strTime2` (`string`):  
  The second time string in the format "HH:MM:SS - DD/MM/YYYY".

**Returns:**  
`number|string` - The number of days between the two dates or "Invalid dates" if the inputs are not correctly formatted.

**Example Usage:**
```lua
-- Calculate days between two dates
local daysBetween = lia.time.DaysBetween("00:00:00 - 01/01/2025", "00:00:00 - 31/12/2025")
print(daysBetween)
-- Output: "364"

-- Attempt to calculate days between invalid dates
local invalidDays = lia.time.DaysBetween("Invalid Date", "00:00:00 - 31/12/2025")
print(invalidDays)
-- Output: "Invalid dates"
```

---

### **lia.time.WeekdayName**

**Description:**  
Returns the name of the weekday for the given date and time. The input must be a string in the format "HH:MM:SS - DD/MM/YYYY". This function leverages Lua's `os.date` to determine the weekday name.

**Realm:**  
`Shared`

**Parameters:**  

- `strTime` (`string`):  
  A time string in the format "HH:MM:SS - DD/MM/YYYY".

**Returns:**  
`string` - The name of the weekday (e.g., "Monday") or "Invalid date" if the input is not correctly formatted.

**Example Usage:**
```lua
-- Get the weekday name for a specific date
local weekday = lia.time.WeekdayName("14:30:45 - 15/03/2025")
print(weekday)
-- Output: "Saturday"

-- Attempt to get weekday name with an invalid date
local invalidWeekday = lia.time.WeekdayName("Invalid Date")
print(invalidWeekday)
-- Output: "Invalid date"
```

---

### **lia.time.TimeDifference**

**Description:**  
Calculates the difference in days between a specified date and the current date. The input must be a date string in the format "HH:MM:SS - DD/MM/YYYY". The function returns the number of days remaining until the specified date or `nil` if the input is invalid.

**Realm:**  
`Shared`

**Parameters:**  

- `strTime` (`string`):  
  A time string in the format "HH:MM:SS - DD/MM/YYYY".

**Returns:**  
`number|nil` - The difference in days between the given date and the current date, or `nil` if the input is invalid.

**Example Usage:**
```lua
-- Calculate the time difference until a specific date
local daysLeft = lia.time.TimeDifference("18:45:30 - 25/12/2025")
print(daysLeft)
-- Output: "X days"

-- Attempt to calculate time difference with an invalid input
local invalidDifference = lia.time.TimeDifference("Invalid Date")
print(invalidDifference)
-- Output: "nil"
```

---
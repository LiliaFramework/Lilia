# Utilities Module Libraries

This document describes the library functions available in the Utilities module for common scripting tasks and helper functions.

---

## lia.utilities.Blend

**Purpose**

Blends two colors together using a ratio.

**Parameters**

* `colorA` (*Color*): The first color to blend.
* `colorB` (*Color*): The second color to blend.
* `ratio` (*number*): The blend ratio (0-1, where 0 is colorA and 1 is colorB).

**Returns**

* `blendedColor` (*Color*): The blended color result.

**Realm**

Shared.

**Example Usage**

```lua
-- Blend red and blue colors
local red = Color(255, 0, 0)
local blue = Color(0, 0, 255)
local purple = lia.utilities.Blend(red, blue, 0.5) -- 50% blend

-- Create gradient effect
local startColor = Color(255, 0, 0)
local endColor = Color(0, 255, 0)
for i = 0, 10 do
    local ratio = i / 10
    local gradientColor = lia.utilities.Blend(startColor, endColor, ratio)
    print("Gradient step " .. i .. ": " .. tostring(gradientColor))
end

-- Animate color transition
local currentColor = Color(255, 0, 0)
local targetColor = Color(0, 0, 255)
local transitionSpeed = 0.1

hook.Add("Think", "ColorTransition", function()
    local ratio = math.min(1, (CurTime() - startTime) * transitionSpeed)
    local animatedColor = lia.utilities.Blend(currentColor, targetColor, ratio)
    -- Use animatedColor for rendering
end)
```

---

## lia.utilities.ColorCycle

**Purpose**

Creates a cycling color effect between two colors.

**Parameters**

* `colorA` (*Color*): The first color in the cycle.
* `colorB` (*Color*): The second color in the cycle.
* `frequency` (*number*): The cycling frequency (optional, defaults to 1).

**Returns**

* `cycledColor` (*Color*): The current color in the cycle.

**Realm**

Shared.

**Example Usage**

```lua
-- Create rainbow effect
local red = Color(255, 0, 0)
local blue = Color(0, 0, 255)
local rainbowColor = lia.utilities.ColorCycle(red, blue, 2) -- 2x frequency

-- Create pulsing effect
local baseColor = Color(100, 100, 100)
local pulseColor = Color(255, 255, 255)
local pulseEffect = lia.utilities.ColorCycle(baseColor, pulseColor, 1.5)

-- Use in rendering
hook.Add("HUDPaint", "ColorCycleEffect", function()
    local cycleColor = lia.utilities.ColorCycle(Color(255, 0, 0), Color(0, 255, 0), 1)
    surface.SetDrawColor(cycleColor)
    surface.DrawRect(10, 10, 100, 100)
end)
```

---

## lia.utilities.ColorToHex

**Purpose**

Converts a color to hexadecimal format.

**Parameters**

* `color` (*Color*): The color to convert.

**Returns**

* `hexString` (*string*): The hexadecimal color string.

**Realm**

Shared.

**Example Usage**

```lua
-- Convert color to hex
local red = Color(255, 0, 0)
local hexRed = lia.utilities.ColorToHex(red) -- "0xFF0000"

-- Use in HTML/CSS
local htmlColor = "<div style='color: " .. hexRed .. "'>Red text</div>"

-- Store color data
local colorData = {
    name = "Primary Red",
    hex = lia.utilities.ColorToHex(Color(255, 0, 0)),
    rgb = {255, 0, 0}
}

-- Convert multiple colors
local colors = {
    Color(255, 0, 0),   -- Red
    Color(0, 255, 0),   -- Green
    Color(0, 0, 255)    -- Blue
}

for i, color in ipairs(colors) do
    print("Color " .. i .. ": " .. lia.utilities.ColorToHex(color))
end
```

---

## lia.utilities.CurrentLocalTime

**Purpose**

Gets the current local time in formatted string.

**Parameters**

None.

**Returns**

* `timeString` (*string*): The formatted time string (HH:MM:SS - DD/MM/YYYY).

**Realm**

Shared.

**Example Usage**

```lua
-- Get current time
local currentTime = lia.utilities.CurrentLocalTime()
print("Current time: " .. currentTime)

-- Use in logging
local logEntry = "[" .. lia.utilities.CurrentLocalTime() .. "] Player joined: " .. player:Name()

-- Display time in UI
hook.Add("HUDPaint", "DisplayTime", function()
    local timeText = lia.utilities.CurrentLocalTime()
    draw.SimpleText(timeText, "DermaDefault", 10, 10, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end)

-- Save timestamp
local saveData = {
    timestamp = lia.utilities.CurrentLocalTime(),
    player = player:Name(),
    action = "login"
}
```

---

## lia.utilities.Darken

**Purpose**

Darkens a color by a specified amount.

**Parameters**

* `color` (*Color*): The color to darken.
* `amount` (*number*): The amount to darken (0-1).

**Returns**

* `darkenedColor` (*Color*): The darkened color.

**Realm**

Shared.

**Example Usage**

```lua
-- Darken a color
local brightRed = Color(255, 0, 0)
local darkRed = lia.utilities.Darken(brightRed, 0.5) -- 50% darker

-- Create shadow effect
local baseColor = Color(100, 150, 200)
local shadowColor = lia.utilities.Darken(baseColor, 0.3)

-- Use in UI theming
local theme = {
    primary = Color(100, 150, 200),
    primaryDark = lia.utilities.Darken(Color(100, 150, 200), 0.2),
    primaryDarker = lia.utilities.Darken(Color(100, 150, 200), 0.4)
}

-- Animate darkening
local originalColor = Color(255, 255, 255)
local darkenAmount = math.sin(CurTime()) * 0.5 + 0.5
local animatedColor = lia.utilities.Darken(originalColor, darkenAmount)
```

---

## lia.utilities.DaysBetween

**Purpose**

Calculates the number of days between two dates.

**Parameters**

* `date1` (*string*): The first date string.
* `date2` (*string*): The second date string.

**Returns**

* `days` (*number*): The number of days between the dates.

**Realm**

Shared.

**Example Usage**

```lua
-- Calculate days between dates
local startDate = "2023-01-01"
local endDate = "2023-12-31"
local days = lia.utilities.DaysBetween(startDate, endDate)
print("Days between: " .. days)

-- Check if date is recent
local lastLogin = "2023-01-01"
local today = os.date("%Y-%m-%d")
local daysSinceLogin = lia.utilities.DaysBetween(lastLogin, today)

if daysSinceLogin > 30 then
    print("Last login was over 30 days ago!")
end

-- Calculate age
local birthDate = "1990-01-01"
local currentDate = os.date("%Y-%m-%d")
local ageInDays = lia.utilities.DaysBetween(birthDate, currentDate)
local ageInYears = math.floor(ageInDays / 365)
print("Age: " .. ageInYears .. " years")
```

---

## lia.utilities.DeserializeAngle

**Purpose**

Deserializes an angle from JSON data.

**Parameters**

* `data` (*string*): The JSON string containing the angle data.

**Returns**

* `angle` (*Angle*): The deserialized angle.

**Realm**

Shared.

**Example Usage**

```lua
-- Deserialize angle from JSON
local angleData = '{"p":90,"y":180,"r":0}'
local angle = lia.utilities.DeserializeAngle(angleData)

-- Load angle from database
local savedAngle = player:getData("saved_angle", '{"p":0,"y":0,"r":0}')
local loadedAngle = lia.utilities.DeserializeAngle(savedAngle)
player:SetEyeAngles(loadedAngle)

-- Restore entity angles
local entityData = {
    pos = '{"x":100,"y":200,"z":300}',
    ang = '{"p":0,"y":90,"r":0}'
}
local position = lia.utilities.DeserializeVector(entityData.pos)
local angles = lia.utilities.DeserializeAngle(entityData.ang)
entity:SetPos(position)
entity:SetAngles(angles)
```

---

## lia.utilities.DeserializeVector

**Purpose**

Deserializes a vector from JSON data.

**Parameters**

* `data` (*string*): The JSON string containing the vector data.

**Returns**

* `vector` (*Vector*): The deserialized vector.

**Realm**

Shared.

**Example Usage**

```lua
-- Deserialize vector from JSON
local vectorData = '{"x":100,"y":200,"z":300}'
local vector = lia.utilities.DeserializeVector(vectorData)

-- Load position from database
local savedPos = player:getData("saved_position", '{"x":0,"y":0,"z":0}')
local loadedPos = lia.utilities.DeserializeVector(savedPos)
player:SetPos(loadedPos)

-- Restore entity position
local entityData = {
    pos = '{"x":100,"y":200,"z":300}',
    ang = '{"p":0,"y":90,"r":0}'
}
local position = lia.utilities.DeserializeVector(entityData.pos)
local angles = lia.utilities.DeserializeAngle(entityData.ang)
entity:SetPos(position)
entity:SetAngles(angles)
```

---

## lia.utilities.dprint

**Purpose**

Prints debug information with a prefix.

**Parameters**

* `...` (*any*): The values to print.

**Returns**

None.

**Realm**

Shared.

**Example Usage**

```lua
-- Debug print with prefix
lia.utilities.dprint("Player joined:", player:Name())
lia.utilities.dprint("Health:", player:Health())
lia.utilities.dprint("Position:", player:GetPos())

-- Debug function execution
function MyFunction(param1, param2)
    lia.utilities.dprint("MyFunction called with:", param1, param2)
    -- Function logic here
    lia.utilities.dprint("MyFunction completed")
end

-- Debug table contents
local data = {name = "John", age = 25, city = "New York"}
lia.utilities.dprint("Data table:", data)

-- Conditional debug printing
if DEBUG_MODE then
    lia.utilities.dprint("Debug mode enabled")
    lia.utilities.dprint("Current time:", CurTime())
end
```

---

## lia.utilities.FormatTimestamp

**Purpose**

Formats a timestamp into a readable string.

**Parameters**

* `timestamp` (*number*): The timestamp to format.

**Returns**

* `formattedString` (*string*): The formatted timestamp string.

**Realm**

Shared.

**Example Usage**

```lua
-- Format current timestamp
local currentTime = os.time()
local formatted = lia.utilities.FormatTimestamp(currentTime)
print("Current time: " .. formatted)

-- Format saved timestamp
local savedTime = player:getData("last_login", 0)
local lastLogin = lia.utilities.FormatTimestamp(savedTime)
print("Last login: " .. lastLogin)

-- Use in logging
local logEntry = "[" .. lia.utilities.FormatTimestamp(os.time()) .. "] " .. message

-- Display in UI
hook.Add("HUDPaint", "DisplayTimestamp", function()
    local timestamp = lia.utilities.FormatTimestamp(os.time())
    draw.SimpleText(timestamp, "DermaDefault", 10, 10, Color(255, 255, 255))
end)
```

---

## lia.utilities.HMSToSeconds

**Purpose**

Converts hours, minutes, and seconds to total seconds.

**Parameters**

* `hours` (*number*): The number of hours.
* `minutes` (*number*): The number of minutes.
* `seconds` (*number*): The number of seconds.

**Returns**

* `totalSeconds` (*number*): The total number of seconds.

**Realm**

Shared.

**Example Usage**

```lua
-- Convert time to seconds
local totalSeconds = lia.utilities.HMSToSeconds(1, 30, 45) -- 1 hour, 30 minutes, 45 seconds
print("Total seconds: " .. totalSeconds) -- 5445

-- Calculate duration
local startTime = CurTime()
local duration = lia.utilities.HMSToSeconds(0, 5, 0) -- 5 minutes
timer.Simple(duration, function()
    print("5 minutes have passed!")
end)

-- Use in timers
local cooldownTime = lia.utilities.HMSToSeconds(0, 0, 30) -- 30 seconds
player:setData("cooldown_end", CurTime() + cooldownTime)
```

---

## lia.utilities.LerpColor

**Purpose**

Lerps between two colors.

**Parameters**

* `fraction` (*number*): The lerp fraction (0-1).
* `from` (*Color*): The starting color.
* `to` (*Color*): The ending color.

**Returns**

* `lerpedColor` (*Color*): The lerped color.

**Realm**

Shared.

**Example Usage**

```lua
-- Lerp between colors
local red = Color(255, 0, 0)
local blue = Color(0, 0, 255)
local purple = lia.utilities.LerpColor(0.5, red, blue)

-- Animate color transition
local startColor = Color(255, 0, 0)
local endColor = Color(0, 255, 0)
local transitionTime = 2
local startTime = CurTime()

hook.Add("Think", "ColorLerp", function()
    local elapsed = CurTime() - startTime
    local fraction = math.min(1, elapsed / transitionTime)
    local currentColor = lia.utilities.LerpColor(fraction, startColor, endColor)
    -- Use currentColor for rendering
end)

-- Create smooth color gradient
local colors = {Color(255, 0, 0), Color(0, 255, 0), Color(0, 0, 255)}
for i = 0, 10 do
    local fraction = i / 10
    local gradientColor = lia.utilities.LerpColor(fraction, colors[1], colors[2])
    print("Gradient step " .. i .. ": " .. tostring(gradientColor))
end
```

---

## lia.utilities.LerpHSV

**Purpose**

Lerps between two colors in HSV space.

**Parameters**

* `color1` (*Color*): The first color.
* `color2` (*Color*): The second color.
* `maxVal` (*number*): The maximum value for normalization.
* `curVal` (*number*): The current value for normalization.
* `minVal` (*number*): The minimum value for normalization (optional, defaults to 0).

**Returns**

* `lerpedColor` (*Color*): The lerped color in HSV space.

**Realm**

Shared.

**Example Usage**

```lua
-- Lerp between colors in HSV space
local red = Color(255, 0, 0)
local blue = Color(0, 0, 255)
local lerpedColor = lia.utilities.LerpHSV(red, blue, 100, 50) -- 50% between red and blue

-- Create health bar color
local maxHealth = 100
local currentHealth = 75
local healthColor = lia.utilities.LerpHSV(Color(255, 0, 0), Color(0, 255, 0), maxHealth, currentHealth)

-- Create temperature indicator
local minTemp = 0
local maxTemp = 100
local currentTemp = 75
local tempColor = lia.utilities.LerpHSV(Color(0, 0, 255), Color(255, 0, 0), maxTemp, currentTemp, minTemp)
```

---

## lia.utilities.Lighten

**Purpose**

Lightens a color by a specified amount.

**Parameters**

* `color` (*Color*): The color to lighten.
* `amount` (*number*): The amount to lighten (0-1).

**Returns**

* `lightenedColor` (*Color*): The lightened color.

**Realm**

Shared.

**Example Usage**

```lua
-- Lighten a color
local darkBlue = Color(0, 0, 100)
local lightBlue = lia.utilities.Lighten(darkBlue, 0.5) -- 50% lighter

-- Create highlight effect
local baseColor = Color(100, 150, 200)
local highlightColor = lia.utilities.Lighten(baseColor, 0.3)

-- Use in UI theming
local theme = {
    primary = Color(100, 150, 200),
    primaryLight = lia.utilities.Lighten(Color(100, 150, 200), 0.2),
    primaryLighter = lia.utilities.Lighten(Color(100, 150, 200), 0.4)
}

-- Animate lightening
local originalColor = Color(0, 0, 0)
local lightenAmount = math.sin(CurTime()) * 0.5 + 0.5
local animatedColor = lia.utilities.Lighten(originalColor, lightenAmount)
```

---

## lia.utilities.Rainbow

**Purpose**

Generates a rainbow color based on time and frequency.

**Parameters**

* `frequency` (*number*): The frequency of the rainbow cycle.

**Returns**

* `rainbowColor` (*Color*): The current rainbow color.

**Realm**

Shared.

**Example Usage**

```lua
-- Create rainbow effect
local rainbowColor = lia.utilities.Rainbow(1) -- 1x frequency

-- Use in rendering
hook.Add("HUDPaint", "RainbowEffect", function()
    local rainbow = lia.utilities.Rainbow(2) -- 2x frequency
    surface.SetDrawColor(rainbow)
    surface.DrawRect(10, 10, 100, 100)
end)

-- Create rainbow text
hook.Add("HUDPaint", "RainbowText", function()
    local rainbow = lia.utilities.Rainbow(1.5)
    draw.SimpleText("Rainbow Text", "DermaDefault", 10, 10, rainbow)
end)

-- Animate rainbow on entity
hook.Add("Think", "RainbowEntity", function()
    local rainbow = lia.utilities.Rainbow(0.5) -- Slow rainbow
    entity:SetColor(rainbow)
end)
```

---

## lia.utilities.rgb

**Purpose**

Creates a color from RGB values.

**Parameters**

* `r` (*number*): The red component (0-255).
* `g` (*number*): The green component (0-255).
* `b` (*number*): The blue component (0-255).

**Returns**

* `color` (*Color*): The created color.

**Realm**

Shared.

**Example Usage**

```lua
-- Create colors
local red = lia.utilities.rgb(255, 0, 0)
local green = lia.utilities.rgb(0, 255, 0)
local blue = lia.utilities.rgb(0, 0, 255)

-- Create color from variables
local r, g, b = 100, 150, 200
local customColor = lia.utilities.rgb(r, g, b)

-- Use in UI
local buttonColor = lia.utilities.rgb(50, 100, 150)
button:SetColor(buttonColor)

-- Create color palette
local palette = {
    primary = lia.utilities.rgb(100, 150, 200),
    secondary = lia.utilities.rgb(200, 100, 150),
    accent = lia.utilities.rgb(150, 200, 100)
}
```

---

## lia.utilities.SecondsToDHMS

**Purpose**

Converts seconds to days, hours, minutes, and seconds.

**Parameters**

* `seconds` (*number*): The number of seconds to convert.

**Returns**

* `days` (*number*): The number of days.
* `hours` (*number*): The number of hours.
* `minutes` (*number*): The number of minutes.
* `seconds` (*number*): The remaining seconds.

**Realm**

Shared.

**Example Usage**

```lua
-- Convert seconds to DHMS
local totalSeconds = 90061 -- 1 day, 1 hour, 1 minute, 1 second
local days, hours, minutes, seconds = lia.utilities.SecondsToDHMS(totalSeconds)
print("Days:", days, "Hours:", hours, "Minutes:", minutes, "Seconds:", seconds)

-- Format time display
local timeLeft = 3661 -- 1 hour, 1 minute, 1 second
local d, h, m, s = lia.utilities.SecondsToDHMS(timeLeft)
local timeString = string.format("%02d:%02d:%02d", h, m, s)
print("Time left: " .. timeString)

-- Use in countdown timer
local countdown = 86400 -- 24 hours
local days, hours, minutes, seconds = lia.utilities.SecondsToDHMS(countdown)
if days > 0 then
    print("Countdown: " .. days .. " days, " .. hours .. " hours")
else
    print("Countdown: " .. hours .. " hours, " .. minutes .. " minutes")
end
```

---

## lia.utilities.SerializeAngle

**Purpose**

Serializes an angle to JSON format.

**Parameters**

* `angle` (*Angle*): The angle to serialize.

**Returns**

* `jsonString` (*string*): The JSON string containing the angle data.

**Realm**

Shared.

**Example Usage**

```lua
-- Serialize angle to JSON
local angle = Angle(90, 180, 0)
local angleData = lia.utilities.SerializeAngle(angle)
print("Angle data: " .. angleData) -- {"p":90,"y":180,"r":0}

-- Save angle to database
local playerAngle = player:GetEyeAngles()
local savedAngle = lia.utilities.SerializeAngle(playerAngle)
player:setData("saved_angle", savedAngle)

-- Store entity angles
local entityAngles = entity:GetAngles()
local angleData = lia.utilities.SerializeAngle(entityAngles)
-- Store angleData in database or file
```

---

## lia.utilities.SerializeVector

**Purpose**

Serializes a vector to JSON format.

**Parameters**

* `vector` (*Vector*): The vector to serialize.

**Returns**

* `jsonString` (*string*): The JSON string containing the vector data.

**Realm**

Shared.

**Example Usage**

```lua
-- Serialize vector to JSON
local vector = Vector(100, 200, 300)
local vectorData = lia.utilities.SerializeVector(vector)
print("Vector data: " .. vectorData) -- {"x":100,"y":200,"z":300}

-- Save position to database
local playerPos = player:GetPos()
local savedPos = lia.utilities.SerializeVector(playerPos)
player:setData("saved_position", savedPos)

-- Store entity position
local entityPos = entity:GetPos()
local posData = lia.utilities.SerializeVector(entityPos)
-- Store posData in database or file
```

---

## lia.utilities.spawnEntities

**Purpose**

Spawns multiple entities at specified positions.

**Parameters**

* `entityTable` (*table*): A table mapping entity classes to positions.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
-- Spawn multiple entities
local entitiesToSpawn = {
    ["prop_physics"] = Vector(100, 200, 300),
    ["npc_citizen"] = Vector(150, 250, 350),
    ["weapon_pistol"] = Vector(200, 300, 400)
}
lia.utilities.spawnEntities(entitiesToSpawn)

-- Spawn from configuration
local spawnConfig = {
    ["prop_physics"] = Vector(0, 0, 0),
    ["prop_physics"] = Vector(100, 0, 0),
    ["prop_physics"] = Vector(200, 0, 0)
}
lia.utilities.spawnEntities(spawnConfig)

-- Spawn entities in a pattern
local pattern = {}
for i = 1, 10 do
    pattern["prop_physics"] = Vector(i * 100, 0, 0)
end
lia.utilities.spawnEntities(pattern)
```

---

## lia.utilities.spawnProp

**Purpose**

Spawns a prop entity with optional physics and lifetime.

**Parameters**

* `model` (*string*): The model path of the prop.
* `position` (*Vector* or *Player*): The position to spawn at, or a player to get drop position.
* `force` (*Vector*): Optional force to apply to the prop.
* `lifetime` (*number*): Optional lifetime in seconds before removal.
* `angles` (*Angle*): Optional angles for the prop.
* `collisionGroup` (*number*): Optional collision group.

**Returns**

* `prop` (*Entity*): The spawned prop entity.

**Realm**

Server.

**Example Usage**

```lua
-- Spawn a simple prop
local prop = lia.utilities.spawnProp("models/props_c17/chair_stool01a.mdl", Vector(100, 200, 300))

-- Spawn prop with physics
local prop = lia.utilities.spawnProp("models/props_c17/chair_stool01a.mdl", Vector(100, 200, 300), Vector(0, 0, 100))

-- Spawn prop with lifetime
local prop = lia.utilities.spawnProp("models/props_c17/chair_stool01a.mdl", Vector(100, 200, 300), nil, 60) -- 60 second lifetime

-- Spawn prop at player drop position
local prop = lia.utilities.spawnProp("models/props_c17/chair_stool01a.mdl", player)

-- Spawn prop with custom angles
local prop = lia.utilities.spawnProp("models/props_c17/chair_stool01a.mdl", Vector(100, 200, 300), nil, nil, Angle(0, 90, 0))
```

---

## lia.utilities.SpeedTest

**Purpose**

Tests the execution speed of a function.

**Parameters**

* `function` (*function*): The function to test.
* `iterations` (*number*): The number of iterations to run.

**Returns**

* `averageTime` (*number*): The average execution time per iteration.

**Realm**

Shared.

**Example Usage**

```lua
-- Test function speed
local function MyFunction()
    local result = 0
    for i = 1, 1000 do
        result = result + i
    end
    return result
end

local averageTime = lia.utilities.SpeedTest(MyFunction, 1000)
print("Average execution time: " .. averageTime .. " seconds")

-- Compare two functions
local function FunctionA()
    return math.random(1, 100)
end

local function FunctionB()
    return math.random(1, 100) * 2
end

local timeA = lia.utilities.SpeedTest(FunctionA, 10000)
local timeB = lia.utilities.SpeedTest(FunctionB, 10000)
print("Function A: " .. timeA .. " seconds")
print("Function B: " .. timeB .. " seconds")
```

---

## lia.utilities.TimeDifference

**Purpose**

Calculates the time difference between a timestamp and now.

**Parameters**

* `timestampString` (*string*): The timestamp string to compare.

**Returns**

* `daysDifference` (*number*): The difference in days.

**Realm**

Shared.

**Example Usage**

```lua
-- Calculate time difference
local timestamp = "2023-01-01 12:00:00"
local daysDiff = lia.utilities.TimeDifference(timestamp)
print("Days since: " .. daysDiff)

-- Check if date is recent
local lastLogin = "2023-01-01 12:00:00"
local daysSinceLogin = lia.utilities.TimeDifference(lastLogin)
if daysSinceLogin > 30 then
    print("Last login was over 30 days ago!")
end

-- Calculate age
local birthDate = "1990-01-01 00:00:00"
local ageInDays = lia.utilities.TimeDifference(birthDate)
local ageInYears = math.floor(ageInDays / 365)
print("Age: " .. ageInYears .. " years")
```

---

## lia.utilities.TimeUntil

**Purpose**

Calculates the time until a specific timestamp.

**Parameters**

* `timestampString` (*string*): The timestamp string to calculate until.

**Returns**

* `timeString` (*string*): The formatted time until string.

**Realm**

Shared.

**Example Usage**

```lua
-- Calculate time until event
local eventTime = "2023-12-31 23:59:59"
local timeUntil = lia.utilities.TimeUntil(eventTime)
print("Time until event: " .. timeUntil)

-- Countdown to specific time
local targetTime = "2023-12-25 00:00:00"
local countdown = lia.utilities.TimeUntil(targetTime)
print("Time until Christmas: " .. countdown)

-- Check if time is in the past
local pastTime = "2020-01-01 00:00:00"
local timeUntil = lia.utilities.TimeUntil(pastTime)
if timeUntil == "Time is in the past" then
    print("This time has already passed!")
end
```

---

## lia.utilities.toText

**Purpose**

Converts a color to a text string.

**Parameters**

* `color` (*Color*): The color to convert.

**Returns**

* `textString` (*string*): The color as text string.

**Realm**

Shared.

**Example Usage**

```lua
-- Convert color to text
local red = Color(255, 0, 0)
local colorText = lia.utilities.toText(red)
print("Color text: " .. colorText) -- "255,0,0,255"

-- Store color as text
local playerColor = Color(100, 150, 200)
local colorString = lia.utilities.toText(playerColor)
player:setData("favorite_color", colorString)

-- Load color from text
local savedColor = player:getData("favorite_color", "255,255,255,255")
local colorValues = string.Explode(",", savedColor)
local loadedColor = Color(tonumber(colorValues[1]), tonumber(colorValues[2]), tonumber(colorValues[3]), tonumber(colorValues[4]))
```

---

## lia.utilities.WeekdayName

**Purpose**

Gets the weekday name from a timestamp string.

**Parameters**

* `timestampString` (*string*): The timestamp string to parse.

**Returns**

* `weekdayName` (*string*): The name of the weekday.

**Realm**

Shared.

**Example Usage**

```lua
-- Get weekday name
local timestamp = "2023-01-01 12:00:00"
local weekday = lia.utilities.WeekdayName(timestamp)
print("Weekday: " .. weekday) -- "Sunday"

-- Check if it's a weekend
local timestamp = "2023-01-01 12:00:00"
local weekday = lia.utilities.WeekdayName(timestamp)
if weekday == "Saturday" or weekday == "Sunday" then
    print("It's a weekend!")
end

-- Get weekday for multiple dates
local dates = {
    "2023-01-01 12:00:00",
    "2023-01-02 12:00:00",
    "2023-01-03 12:00:00"
}

for i, date in ipairs(dates) do
    local weekday = lia.utilities.WeekdayName(date)
    print("Date " .. i .. ": " .. weekday)
end
```

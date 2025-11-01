# lia.utilities Library

---

## Overview

Utility helpers for colors, time, math, debug printing, and simple entity spawning.

---

### speedTest

**Purpose**

Run a function repeatedly and measure the elapsed time.

**When Called**

This function is used when:
- Benchmarking a function's performance

**Parameters**

* `func` (function): Function to call.
* `n` (number): Number of iterations.

**Returns**

* `seconds` (number): Elapsed time in seconds.

**Realm**

Shared.

**Example Usage**

```lua
local took = lia.utilities.speedTest(function() end, 1e5)
print(took)
```

---

### daysBetween

**Purpose**

Return the number of days between two timestamps/strings.

**When Called**

This function is used when:
- Comparing dates for cooldowns or reports

**Parameters**

* `t1` (string|number): First time.
* `t2` (string|number): Second time.

**Returns**

* `days` (number): Whole or fractional days between.

**Realm**

Shared.

**Example Usage**

```lua
local days = lia.utilities.daysBetween(os.time(), os.time() + 172800)
```

---

### lerpHSV

**Purpose**

Interpolate between two colors in HSV space.

**When Called**

This function is used when:
- Animating color transitions

**Parameters**

* `c1` (Color): Start color.
* `c2` (Color): End color.
* `maxVal` (number): Max range value.
* `curVal` (number): Current position.
* `minVal` (number): Min range value.

**Returns**

* `color` (Color): Interpolated color.

**Realm**

Shared.

**Example Usage**

```lua
local c = lia.utilities.lerpHSV(Color(255,0,0), Color(0,0,255), 1, 0.5, 0)
```

---

### darken

**Purpose**

Return a darker version of a color.

**Parameters**

* `col` (Color): Base color.
* `amt` (number): Amount 0-1.

**Returns**

* `color` (Color)

**Realm**

Shared.

---

### lerpColor

**Purpose**

Linear interpolate between two colors in RGB space.

**Parameters**

* `f` (number): Fraction 0-1.
* `from` (Color): Start.
* `to` (Color): End.

**Returns**

* `color` (Color)

**Realm**

Shared.

---

### blend

**Purpose**

Blend two colors by ratio.

**Parameters**

* `a` (Color)
* `b` (Color)
* `r` (number): Ratio 0-1.

**Returns**

* `color` (Color)

**Realm**

Shared.

---

### rgb

**Purpose**

Shorthand to create a Color.

**Parameters**

* `r` (number)
* `g` (number)
* `b` (number)

**Returns**

* `color` (Color)

**Realm**

Shared.

---

### rainbow

**Purpose**

Return a cycling rainbow color over time.

**Parameters**

* `freq` (number): Speed factor.

**Returns**

* `color` (Color)

**Realm**

Client.

---

### colorCycle

**Purpose**

Cycle between two colors over time.

**Parameters**

* `a` (Color)
* `b` (Color)
* `f` (number): Frequency.

**Returns**

* `color` (Color)

**Realm**

Client.

---

### colorToHex

**Purpose**

Convert a Color to a `0xRRGGBB` hex string.

**Parameters**

* `c` (Color)

**Returns**

* `hex` (string)

**Realm**

Shared.

---

### lighten

**Purpose**

Return a lighter version of a color.

**Parameters**

* `col` (Color)
* `amt` (number): 0-1.

**Returns**

* `color` (Color)

**Realm**

Shared.

---

### toText

**Purpose**

Serialize a Color to a human readable string.

**Parameters**

* `c` (Color)

**Returns**

* `text` (string|nil)

**Realm**

Shared.

---

### secondsToDHMS

**Purpose**

Convert seconds into days, hours, minutes, seconds.

**Parameters**

* `sec` (number)

**Returns**

* `d` (number), `h` (number), `m` (number), `s` (number)

**Realm**

Shared.

---

### hMSToSeconds

**Purpose**

Convert hours/minutes/seconds to seconds.

**Parameters**

* `h` (number)
* `m` (number)
* `s` (number)

**Returns**

* `seconds` (number)

**Realm**

Shared.

---

### formatTimestamp

**Purpose**

Format a timestamp into a locale-friendly table/string.

**Parameters**

* `ts` (number)

**Returns**

* `t` (table|string): Formatted time.

**Realm**

Shared.

---

### weekdayName

**Purpose**

Parse a time string and return weekday name.

**Parameters**

* `str` (string)

**Returns**

* `name` (string)

**Realm**

Shared.

---

### timeUntil

**Purpose**

Time difference until a future time string.

**Parameters**

* `str` (string)

**Returns**

* `seconds` (number)

**Realm**

Shared.

---

### currentLocalTime

**Purpose**

Return the current local time table.

**Parameters**

None.

**Returns**

* `t` (table)

**Realm**

Shared.

---

### timeDifference

**Purpose**

Return a human-friendly difference between now and a time string.

**Parameters**

* `str` (string)

**Returns**

* `text` (string)

**Realm**

Shared.

---

### serializeVector

**Purpose**

Serialize a `Vector` to JSON.

**Parameters**

* `v` (Vector)

**Returns**

* `json` (string)

**Realm**

Shared.

---

### deserializeVector

**Purpose**

Deserialize JSON into a `Vector`.

**Parameters**

* `data` (string)

**Returns**

* `v` (Vector)

**Realm**

Shared.

---

### serializeAngle

**Purpose**

Serialize an `Angle` to JSON.

**Parameters**

* `a` (Angle)

**Returns**

* `json` (string)

**Realm**

Shared.

---

### deserializeAngle

**Purpose**

Deserialize JSON into an `Angle`.

**Parameters**

* `data` (string)

**Returns**

* `a` (Angle)

**Realm**

Shared.

---

### dprint

**Purpose**

Print a prefixed debug line to console.

**Parameters**

* `...` (any): Values to print.

**Returns**

None.

**Realm**

Shared.

**Example Usage**

```lua
lia.utilities.dprint("Loaded")
```

---

### spawnProp

**Purpose**

Spawn a physics prop with optional force, lifetime, angle, and color.

**When Called**

This function is used when:
- Spawning temporary props server-side

**Parameters**

* `model` (string)
* `pos` (Vector)
* `force` (Vector|nil)
* `life` (number|nil): Auto-remove after seconds.
* `ang` (Angle|nil)
* `col` (Color|nil)

**Returns**

* `ent` (Entity): The spawned entity.

**Realm**

Server.

**Example Usage**

```lua
local ent = lia.utilities.spawnProp("models/props_c17/oildrum001.mdl", Vector(0,0,64))
```

---

### spawnEntities

**Purpose**

Spawn multiple entities from a class->properties table.

**Parameters**

* `tbl` (table): Map of class to properties.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
lia.utilities.spawnEntities({
  ["prop_physics"] = { model = "models/props_junk/wood_crate001a.mdl", pos = Vector(0,0,64) }
})
```



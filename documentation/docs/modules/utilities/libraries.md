# Libraries

This page documents the helper functions defined in **`lia.utilities`** and the small core-Lua extensions shipped alongside them.

---

## Overview

The utilities library bundles a variety of quality-of-life helpers that are useful across many schemas:

* **Benchmarking** – quick micro-benchmarks.

* **Date & time** – parsing, formatting, arithmetic.

* **Colour helpers** – RGB/HSV/HSL manipulation.

* **Serialisation** – vectors, angles, colours.

* **Debugging** – simple tagged printing.

* **Entity helpers** – convenience spawners.

In addition, several frequently-used helpers are added directly to the global **`math`**, **`string`**, and **`table`** libraries (see *Core-Lua extensions* at the end).

All functions are available in the shared realm unless explicitly marked **Server**.

---

### lia.utilities.SpeedTest

**Purpose**

Measures the average execution time (seconds) of a function over *n* runs.

| Name   | Type     | Description                     |

| ------ | -------- | ------------------------------- |

| `func` | function | The callback to benchmark.      |

| `n`    | number   | Number of times to call `func`. |

**Returns**

* *number* – Average seconds per call.

**Example**

```lua
print(lia.utilities.SpeedTest(function() return math.sqrt(2) end, 1e4))
```

---

### lia.utilities.DaysBetween

**Purpose**

Returns the whole-day difference between two date/time strings.

| Name       | Type   | Description                |

| ---------- | ------ | -------------------------- |

| `strTime1` | string | `"HH:MM:SS - DD/MM/YYYY"`. |

| `strTime2` | string | Same format.               |

**Returns**

* *number* – Days between the dates.

* *string* – Localised error on bad input.

**Example**

```lua
print(lia.utilities.DaysBetween("00:00:00 - 01/01/2025",
                                "00:00:00 - 10/01/2025")) -- 9
```

---

### lia.utilities.LerpHSV

**Purpose**

Interpolates between two colours in HSV space based on the position of `currentValue` inside `[minValue,maxValue]`.

| Name           | Type   | Description                           |

| -------------- | ------ | ------------------------------------- |

| `start_color`  | Color  | Colour at `minValue` (default green). |

| `end_color`    | Color  | Colour at `maxValue` (default red).   |

| `maxValue`     | number | Upper bound.                          |

| `currentValue` | number | Value to evaluate.                    |

| `minValue`     | number | Lower bound (default 0).              |

**Returns**

* *Color* – Interpolated RGB colour.

**Example**

```lua
local col = lia.utilities.LerpHSV(nil, nil, 100, 50)
```

---

### lia.utilities.Darken

**Purpose**

Darkens a colour by reducing its HSL lightness.

| Name     | Type   | Description                |

| -------- | ------ | -------------------------- |

| `color`  | Color  | Base colour.               |

| `amount` | number | Lightness decrement `0‒1`. |

**Returns**

* *Color* – Darkened colour.

---

### lia.utilities.Lighten

**Purpose**

Lightens a colour by increasing its HSL lightness.

| Name     | Type   | Description                |

| -------- | ------ | -------------------------- |

| `color`  | Color  | Base colour.               |

| `amount` | number | Lightness increment `0‒1`. |

**Returns**

* *Color* – Lightened colour.

---

### lia.utilities.LerpColor

**Purpose**

Linear RGBA interpolation between two colours.

| Name   | Type   | Description                 |

| ------ | ------ | --------------------------- |

| `frac` | number | Interpolation factor `0‒1`. |

| `from` | Color  | Start colour.               |

| `to`   | Color  | End colour.                 |

**Returns**

* *Color*

---

### lia.utilities.Blend

**Purpose**

Blends two colours by ratio in RGB space.

| Name     | Type   | Description                               |

| -------- | ------ | ----------------------------------------- |

| `color1` | Color  | First colour.                             |

| `color2` | Color  | Second colour.                            |

| `ratio`  | number | `0` → pure `color1`, `1` → pure `color2`. |

**Returns**

* *Color*

---

### lia.utilities.rgb

**Purpose**

Creates a `Color` from 0-255 integer components.

| Name | Type   |

| ---- | ------ |

| `r`  | number |

| `g`  | number |

| `b`  | number |

**Returns**

* *Color*

---

### lia.utilities.Rainbow

**Purpose**

Returns a continuously cycling rainbow colour.

| Name        | Type   | Description         |

| ----------- | ------ | ------------------- |

| `frequency` | number | Hue rotation speed. |

**Returns**

* *Color*

---

### lia.utilities.ColorCycle

**Purpose**

Cycles smoothly between two colours using a sine wave.

| Name   | Type   |

| ------ | ------ |

| `col1` | Color  |

| `col2` | Color  |

| `freq` | number |

**Returns**

* *Color*

---

### lia.utilities.ColorToHex

**Purpose**

Converts a `Color` to a hexadecimal string.

| Name    | Type  |

| ------- | ----- |

| `color` | Color |

**Returns**

* *string* – e.g. `"0xFFA07A"`.

---

### lia.utilities.toText

**Purpose**

Serialises a `Color` as `"r,g,b,a"`.

| Name    | Type  |

| ------- | ----- |

| `color` | Color |

**Returns**

* *string*

---

### lia.utilities.SerializeVector

**Purpose**

Serialises a `Vector` to a JSON array string.

| Name     | Type   |

| -------- | ------ |

| `vector` | Vector |

**Realm**

Server

**Returns**

* *string* – e.g. `"[1,2,3]"`.

---

### lia.utilities.DeserializeVector

**Purpose**

Parses a JSON array into a `Vector`.

| Name   | Type   |

| ------ | ------ |

| `data` | string |

**Realm**

Server

**Returns**

* *Vector*

---

### lia.utilities.SerializeAngle

**Purpose**

Serialises an `Angle` to a JSON array string.

| Name  | Type  |

| ----- | ----- |

| `ang` | Angle |

**Realm**

Server

**Returns**

* *string* – e.g. `"[90,0,0]"`.

---

### lia.utilities.DeserializeAngle

**Purpose**

Parses a JSON array into an `Angle`.

| Name   | Type   |

| ------ | ------ |

| `data` | string |

**Realm**

Server

**Returns**

* *Angle*

---

### lia.utilities.dprint

**Purpose**

Tagged debug printing (`[DEBUG] ...`).

| Name  | Type | Description      |

| ----- | ---- | ---------------- |

| `...` | any  | Values to print. |

**Returns**

* *nil*

---

### lia.utilities.TimeUntil

**Purpose**

Returns a human-readable breakdown of the time remaining until a future date-time.

| Name      | Type   | Description                |

| --------- | ------ | -------------------------- |

| `strTime` | string | `"HH:MM:SS - DD/MM/YYYY"`. |

**Returns**

* *string* – `"Y years, M months, D days, H hours, M minutes, S seconds"`.

---

### lia.utilities.CurrentLocalTime

**Purpose**

Returns the current local time in the library’s standard format.

**Returns**

* *string* – `"HH:MM:SS - DD/MM/YYYY"`.

---

### lia.utilities.SecondsToDHMS

**Purpose**

Breaks a total second count down into days, hours, minutes, seconds.

| Name      | Type   |

| --------- | ------ |

| `seconds` | number |

**Returns**

* *number, number, number, number* – `days, hours, minutes, seconds`.

---

### lia.utilities.HMSToSeconds

**Purpose**

Converts hours, minutes, seconds into total seconds.

| Name     | Type   |

| -------- | ------ |

| `hour`   | number |

| `minute` | number |

| `second` | number |

**Returns**

* *number*

---

### lia.utilities.FormatTimestamp

**Purpose**

Formats a Unix timestamp using library conventions.

| Name        | Type   |

| ----------- | ------ |

| `timestamp` | number |

**Returns**

* *string* – `"HH:MM:SS - DD/MM/YYYY"`.

---

### lia.utilities.WeekdayName

**Purpose**

Returns the weekday name for a formatted date-time.

| Name      | Type   |

| --------- | ------ |

| `strTime` | string |

**Returns**

* *string* – `"Monday"`, `"Tuesday"`, … or a localised error.

---

### lia.utilities.TimeDifference

**Purpose**

Day difference between a date-time and now (negative if in the past).

| Name      | Type   |

| --------- | ------ |

| `strTime` | string |

**Returns**

* *number* – Whole-day difference, or `nil` on error.

---

### lia.utilities.spawnProp

**Purpose**

Convenience helper to spawn a physics prop with optional force, lifetime, etc.

| Name        | Type             | Description                                                      |

| ----------- | ---------------- | ---------------------------------------------------------------- |

| `model`     | string           | Model path.                                                      |

| `position`  | Vector or Player | Spawn position **or** player (uses `GetItemDropPos`).            |

| `force`     | Vector           | *(Optional)* Force to apply to physics object.                   |

| `lifetime`  | number           | *(Optional)* Seconds before auto-remove.                         |

| `angles`    | Angle            | *(Optional)* Initial angles.                                     |

| `collision` | number           | *(Optional)* Collision group (default `COLLISION_GROUP_WEAPON`). |

**Realm**

Server

**Returns**

* *Entity* – The spawned prop.

---

### lia.utilities.spawnEntities

**Purpose**

Batch-spawns entities from a class→position table.

| Name          | Type  | Description                                      |

| ------------- | ----- | ------------------------------------------------ |

| `entityTable` | table | Keys = class names, values = `Vector` positions. |

**Realm**

Server

**Returns**

* *nil*

---

## Core-Lua extensions

The file also extends the base libraries with lightweight helpers:

| Library      | Function(s)                                                                                                                                                                             | Notes                                                      |

| ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |

| **`math`**   | `chance`, `UnitsToInches`, `UnitsToCentimeters`, `UnitsToMeters`, `Bias`, `Gain`, `ApproachSpeed`, `ApproachVectorSpeed`, `ApproachAngleSpeed`, `InRange`, `ClampAngle`, `ClampedRemap` | Extra random/curve and unit-conversion tools.              |

| **`string`** | `generateRandom`, `quote`, `FirstToUpper`, `CommaNumber`, `Clean`, `Gibberish`, `DigitToString`                                                                                         | Random IDs, safe quoting, formatting, and playful helpers. |

| **`table`**  | `Sum`, `Lookupify` (alias `MakeAssociative`), `Unique`, `FullCopy`, `Filter`, `FilterCopy`                                                                                              | Recursion-safe clones, easy look-ups, functional filters.  |

These helpers behave exactly like their standard-library counterparts and require no special includes.

---


# Time Library

Time manipulation, formatting, and calculation system for the Lilia framework.

---

## Overview

The time library provides comprehensive functionality for time manipulation, formatting,

and calculation within the Lilia framework. It handles time parsing, formatting,

relative time calculations, and date/time display with support for both 24-hour

and 12-hour (American) time formats. The library operates on both server and client

sides, providing consistent time handling across the gamemode. It includes functions

for calculating time differences, formatting durations, parsing date strings, and

generating localized time displays. The library ensures proper time zone handling

and supports configurable time format preferences.

---

### timeSince

**Purpose**

Calculate and return a human-readable string representing how long ago a given time was

**When Called**

When displaying relative timestamps, such as "last seen" times, message timestamps, or activity logs

---

### toNumber

**Purpose**

Parse a date/time string and convert it into a structured table with individual time components

**When Called**

When converting date strings to structured data for further processing or validation

**Parameters**

* `print(timeData.year)` (*unknown*): - Prints current year

---

### getDate

**Purpose**

Get a formatted, localized string representation of the current date and time

**When Called**

When displaying current date/time in UI elements, logs, or status displays

---

### formatDHM

**Purpose**

Format a duration in seconds into a human-readable string showing days, hours, and minutes

**When Called**

When displaying durations, cooldowns, or time remaining in UI elements

---

### getHour

**Purpose**

Get the current hour in either 12-hour (AM/PM) or 24-hour format based on configuration

**When Called**

When displaying current hour in UI elements, time-based events, or hour-specific functionality

---


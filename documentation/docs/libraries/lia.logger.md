# Logger Library

Comprehensive logging and audit trail system for the Lilia framework.

---

## Overview

The logger library provides comprehensive logging functionality for the Lilia framework,

enabling detailed tracking and recording of player actions, administrative activities,

and system events. It operates on the server side and automatically categorizes log

entries into predefined categories such as character management, combat, world interactions,

chat communications, item transactions, administrative actions, and security events.

The library stores all log entries in a database table with timestamps, player information,

and categorized messages. It supports dynamic log type registration and provides hooks

for external systems to process log events. The logger ensures accountability and

provides administrators with detailed audit trails for server management and moderation.

---

### addType

**Purpose**

Registers a new log type with a custom formatting function and category

**When Called**

When modules or external systems need to add custom log types

**Parameters**

* `logType` (*string*): Unique identifier for the log type
* `func` (*function*): Function that formats the log message, receives client and additional parameters
* `category` (*string*): Category name for organizing log entries

---

### getString

**Purpose**

Generates a formatted log string from a log type and parameters

**When Called**

Internally by lia.log.add() or when manually retrieving log messages

**Parameters**

* `client` (*Player*): The player who triggered the log event (can be nil for system events)
* `logType` (*string*): The log type identifier to format
* `result` (*string*): The formatted log message, or nil if log type doesn't exist or function fails
* `category` (*string*): The category of the log type, or nil if log type doesn't exist

---

### add

**Purpose**

Adds a log entry to the database and displays it in the server console

**When Called**

When any significant player action or system event occurs that needs logging

**Parameters**

* `client` (*Player*): The player who triggered the log event (can be nil for system events)
* `logType` (*string*): The log type identifier to use for formatting

---


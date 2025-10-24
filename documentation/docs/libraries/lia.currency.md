# Currency Library

In-game currency formatting, display, and management system for the Lilia framework.

---

## Overview

The currency library provides comprehensive functionality for managing in-game currency

within the Lilia framework. It handles currency formatting, display, and physical money

entity spawning. The library operates on both server and client sides, with the server

handling money entity creation and spawning, while the client handles currency display

formatting. It includes localization support for currency names and symbols, ensuring

proper pluralization and formatting based on amount values. The library integrates

with the configuration system to allow customizable currency symbols and names.

---

### get

**Purpose**

Formats a currency amount with proper symbol, singular/plural form, and localization

**When Called**

When displaying currency amounts in UI, chat messages, or any text output

**Parameters**

* `print(formatted)` (*unknown*): - "$100 dollars" (example output)

---

### spawn

**Purpose**

Creates and spawns a physical money entity at the specified position with the given amount

**When Called**

When spawning money drops, creating money rewards, or placing currency in the world

**Parameters**

* `money:SetVelocity(Vector(math.random(` (*unknown*): 50, 50), math.random(-50, 50), 100))

---


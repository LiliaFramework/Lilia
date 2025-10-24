# Notice Library

Player notification and messaging system for the Lilia framework.

---

## Overview

The notice library provides comprehensive functionality for displaying notifications

and messages to players in the Lilia framework. It handles both server-side and

client-side notification systems, supporting both direct text messages and localized

messages with parameter substitution. The library operates across server and client

realms, with the server sending notification data to clients via network messages,

while the client handles the visual display of notifications using VGUI panels.

It includes automatic organization of multiple notifications, sound effects, and

console output for debugging purposes. The library also provides compatibility

with Garry's Mod's legacy notification system.

---

### notify

**Purpose**

Sends a notification message to a specific client or all clients

**When Called**

When server needs to display a notification to player(s)

**Parameters**

* `client` (*Player|nil*): Target player to send notification to, or nil for all players
* `message` (*string*): The notification message text to display
* `notifType` (*string|nil*): Type of notification ("default", "error", "success", "info", etc.)

---

### notifyLocalized

**Purpose**

Sends a localized notification message to a specific client or all clients

**When Called**

When server needs to display a localized notification with parameter substitution

**Parameters**

* `client` (*Player|nil*): Target player to send notification to, or nil for all players
* `key` (*string*): Localization key for the message
* `notifType` (*string|nil*): Type of notification ("default", "error", "success", "info", etc.)

---

### lia.originalReceiveNotify

**Purpose**

Receives and displays notification messages from the server

**When Called**

Automatically called when server sends notification data via network

---

### receiveNotify

**Purpose**

Receives and displays notification messages from the server

**When Called**

Automatically called when server sends notification data via network

---

### lia.originalReceiveNotifyL

**Purpose**

Receives and displays localized notification messages from the server

**When Called**

Automatically called when server sends localized notification data via network

---

### receiveNotifyL

**Purpose**

Receives and displays localized notification messages from the server

**When Called**

Automatically called when server sends localized notification data via network

---

### notify

**Purpose**

Creates and displays a notification message directly on the client

**When Called**

When client needs to display a notification without server communication

**Parameters**

* `_` (*any*): Ignored parameter (for compatibility with server version)
* `message` (*string*): The notification message text to display
* `notifType` (*string|nil*): Type of notification ("default", "error", "success", "info", etc.)

---

### notifyLocalized

**Purpose**

Creates and displays a localized notification message directly on the client

**When Called**

When client needs to display a localized notification without server communication

**Parameters**

* `client` (*any*): Ignored parameter (for compatibility with server version)
* `key` (*string*): Localization key for the message
* `notifType` (*string|nil*): Type of notification ("default", "error", "success", "info", etc.)

---

### lia.originalAddLegacy

**Purpose**

Provides compatibility with Garry's Mod's legacy notification system

**When Called**

When legacy notification functions are used (e.g., notification.AddLegacy)

**Parameters**

* `text` (*string*): The notification message text to display
* `typeId` (*number*): Legacy notification type ID (0=info, 1=error, 2=success)

---

### lia.notification.AddLegacy

**Purpose**

Provides compatibility with Garry's Mod's legacy notification system

**When Called**

When legacy notification functions are used (e.g., notification.AddLegacy)

**Parameters**

* `text` (*string*): The notification message text to display
* `typeId` (*number*): Legacy notification type ID (0=info, 1=error, 2=success)

---

### lia.OrganizeNotices

**Purpose**

Organizes and positions notification panels on the screen

**When Called**

Automatically called when new notifications are created

**Parameters**

* `OrganizeNotices()` (*unknown*): - Ensure proper positioning

---


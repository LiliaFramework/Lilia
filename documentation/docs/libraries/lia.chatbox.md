# Chatbox Library

Comprehensive chat system management with message routing and formatting for the Lilia framework.

---

## Overview

The chatbox library provides comprehensive functionality for managing chat systems in the Lilia framework.

It handles registration of different chat types (IC, OOC, whisper, etc.), message parsing and routing,

distance-based hearing mechanics, and chat formatting. The library operates on both server and client

sides, with the server managing message distribution and validation, while the client handles parsing

and display formatting. It includes support for anonymous messaging, custom prefixes, radius-based

communication, and integration with the command system for chat-based commands.

---

### timestamp

**Purpose**

Generates a formatted timestamp string for chat messages based on current time

**When Called**

Automatically called when displaying chat messages if timestamps are enabled

---

### register

**Purpose**

Registers a new chat type with the chatbox system, defining its behavior and properties

**When Called**

During module initialization to register custom chat types (IC, OOC, whisper, etc.)

---

### parse

**Purpose**

Parses a chat message to determine its type and extract the actual message content

**When Called**

When a player sends a chat message, either from client input or server processing

---

### send

**Purpose**

Sends a chat message to appropriate recipients based on chat type and hearing rules

**When Called**

Server-side when distributing parsed chat messages to players

---


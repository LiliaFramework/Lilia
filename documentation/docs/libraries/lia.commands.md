# Commands Library

Comprehensive command registration, parsing, and execution system for the Lilia framework.

---

## Overview

The commands library provides comprehensive functionality for managing and executing commands

in the Lilia framework. It handles command registration, argument parsing, access control,

privilege management, and command execution across both server and client sides. The library

supports complex argument types including players, booleans, strings, and tables, with

automatic syntax generation and validation. It integrates with the administrator system

for privilege-based access control and provides user interface elements for command

discovery and argument prompting. The library ensures secure command execution with

proper permission checks and logging capabilities.

---

### buildSyntaxFromArguments

**Purpose**

Generates a human-readable syntax string from command argument definitions

**When Called**

Automatically called by lia.command.add when registering commands

---

### add

**Purpose**

Registers a new command with the command system, handling privileges, aliases, and access control

**When Called**

When registering commands during gamemode initialization or module loading

---

### hasAccess

**Purpose**

Checks if a client has access to execute a specific command based on privileges, faction, and class permissions

**When Called**

Before command execution to verify player permissions

**Parameters**

* `client:notify("Privilege` (*unknown*): based access granted!")

---

### extractArgs

**Purpose**

Parses command text and extracts individual arguments, handling quoted strings and spaces

**When Called**

When parsing command input to separate arguments for command execution

---

### run

**Purpose**

Executes a registered command for a client with proper error handling and result processing

**When Called**

When a command needs to be executed after parsing and access validation

---

### parse

**Purpose**

Parses command text input, validates arguments, and executes commands with proper error handling

**When Called**

When processing player chat input or console commands that start with "/"

---

### openArgumentPrompt

**Purpose**

Creates a GUI prompt for users to input missing command arguments with validation

**When Called**

When a command is executed with missing required arguments

---

### lia.ctrl:OnValueChange

**Purpose**

Creates a GUI prompt for users to input missing command arguments with validation

**When Called**

When a command is executed with missing required arguments

---

### lia.ctrl:OnTextChanged

**Purpose**

Creates a GUI prompt for users to input missing command arguments with validation

**When Called**

When a command is executed with missing required arguments

---

### lia.ctrl:OnChange

**Purpose**

Creates a GUI prompt for users to input missing command arguments with validation

**When Called**

When a command is executed with missing required arguments

---

### lia.ctrl:OnSelect

**Purpose**

Creates a GUI prompt for users to input missing command arguments with validation

**When Called**

When a command is executed with missing required arguments

---

### send

**Purpose**

Sends a command execution request from client to server via network

**When Called**

When client needs to execute a command on the server

---


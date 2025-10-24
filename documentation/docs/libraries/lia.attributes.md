# Attributes Library

Character attribute management system for the Lilia framework.

---

## Overview

The attributes library provides functionality for managing character attributes

in the Lilia framework. It handles loading attribute definitions from files,

registering attributes in the system, and setting up attributes for characters

during spawn. The library operates on both server and client sides, with the

server managing attribute setup during character spawning and the client

handling attribute-related UI elements. It includes automatic attribute

loading from directories, localization support for attribute names and

descriptions, and hooks for custom attribute behavior.

---

### loadFromDir

**Purpose**

Loads attribute definitions from a specified directory and registers them in the attributes system

**When Called**

During gamemode initialization or when loading attribute modules

---

### setup

**Purpose**

Sets up attributes for a client's character by calling OnSetup hooks for each registered attribute

**When Called**

When a client spawns or when their character is created

---


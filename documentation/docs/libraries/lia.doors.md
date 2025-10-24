# Doors Library Server

Server-side door management and configuration system for the Lilia framework.

---

## Overview

The doors library server component provides comprehensive door management functionality including

preset configuration, database schema verification, and data cleanup operations. It handles

door data persistence, loading door configurations from presets, and maintaining database

integrity. The library manages door ownership, access permissions, faction and class restrictions,

and provides utilities for door data validation and corruption cleanup. It operates primarily

on the server side and integrates with the database system to persist door configurations

across server restarts. The library also handles door locking/unlocking mechanics and

provides hooks for custom door behavior integration.

---

### addPreset

**Purpose**

Adds a door preset configuration for a specific map

**When Called**

When setting up predefined door configurations for maps

---

### getPreset

**Purpose**

Retrieves a door preset configuration for a specific map

**When Called**

When loading door data or checking for existing presets

---

### lia.customSchemaCheck

**Purpose**

Verifies the database schema for the doors table matches expected structure

**When Called**

During server initialization or when checking database integrity

---

### verifyDatabaseSchema

**Purpose**

Verifies the database schema for the doors table matches expected structure

**When Called**

During server initialization or when checking database integrity

---

### lia.advancedDoorCleanup

**Purpose**

Cleans up corrupted door data in the database by removing invalid faction/class data

**When Called**

During server initialization or when data corruption is detected

---

### cleanupCorruptedData

**Purpose**

Cleans up corrupted door data in the database by removing invalid faction/class data

**When Called**

During server initialization or when data corruption is detected

---

### lia.MODULE:InitPostEntity

**Purpose**

Cleans up corrupted door data in the database by removing invalid faction/class data

**When Called**

During server initialization or when data corruption is detected

---

### lia.MODULE:PlayerUse

**Purpose**

Cleans up corrupted door data in the database by removing invalid faction/class data

**When Called**

During server initialization or when data corruption is detected

---

### lia.MODULE:CanPlayerUseDoor

**Purpose**

Cleans up corrupted door data in the database by removing invalid faction/class data

**When Called**

During server initialization or when data corruption is detected

---

### lia.MODULE:CanPlayerAccessDoor

**Purpose**

Cleans up corrupted door data in the database by removing invalid faction/class data

**When Called**

During server initialization or when data corruption is detected

---

### lia.MODULE:PostPlayerLoadout

**Purpose**

Cleans up corrupted door data in the database by removing invalid faction/class data

**When Called**

During server initialization or when data corruption is detected

---

### lia.MODULE:ShowTeam

**Purpose**

Cleans up corrupted door data in the database by removing invalid faction/class data

**When Called**

During server initialization or when data corruption is detected

---

### lia.MODULE:PlayerDisconnected

**Purpose**

Cleans up corrupted door data in the database by removing invalid faction/class data

**When Called**

During server initialization or when data corruption is detected

---

### lia.MODULE:KeyLock

**Purpose**

Cleans up corrupted door data in the database by removing invalid faction/class data

**When Called**

During server initialization or when data corruption is detected

---

### lia.MODULE:KeyUnlock

**Purpose**

Cleans up corrupted door data in the database by removing invalid faction/class data

**When Called**

During server initialization or when data corruption is detected

---

### lia.MODULE:ToggleLock

**Purpose**

Cleans up corrupted door data in the database by removing invalid faction/class data

**When Called**

During server initialization or when data corruption is detected

---


# Data Library

Data persistence, serialization, and management system for the Lilia framework.

---

## Overview

The data library provides comprehensive functionality for data persistence, serialization,

and management within the Lilia framework. It handles encoding and decoding of complex

data types including vectors, angles, colors, and nested tables for database storage.

The library manages both general data storage with gamemode and map-specific scoping,

as well as entity persistence for maintaining spawned entities across server restarts.

It includes automatic serialization/deserialization, database integration, and caching

mechanisms to ensure efficient data access and storage operations.

---

### encodetable

**Purpose**

Converts complex data types (vectors, angles, colors, tables) into database-storable formats

**When Called**

Automatically called during data serialization before database storage

---

### decode

**Purpose**

Converts encoded data back to original complex data types (vectors, angles, colors)

**When Called**

Automatically called during data deserialization after database retrieval

---

### serialize

**Purpose**

Converts any data structure into a JSON string suitable for database storage

**When Called**

Called before storing data in the database to ensure proper serialization

---

### deserialize

**Purpose**

Converts serialized data (JSON strings or tables) back to original data structures

**When Called**

Called after retrieving data from database to restore original data types

---

### decodeVector

**Purpose**

Specifically decodes vector data from various formats (JSON, strings, tables)

**When Called**

Called when specifically needing to decode vector data from database or serialized format

---

### decodeAngle

**Purpose**

Specifically decodes angle data from various formats (JSON, strings, tables)

**When Called**

Called when specifically needing to decode angle data from database or serialized format

---

### set

**Purpose**

Stores data in the database with gamemode and map-specific scoping

**When Called**

Called when storing persistent data that should survive server restarts

---

### delete

**Purpose**

Removes data from the database with gamemode and map-specific scoping

**When Called**

Called when removing persistent data that should no longer be stored

---

### loadTables

**Purpose**

Loads all stored data from database into memory with hierarchical scoping

**When Called**

Called during server startup to restore all persistent data

---

### loadPersistence

**Purpose**

Ensures persistence table has required columns for entity storage

**When Called**

Called during server startup to prepare database schema for entity persistence

---

### savePersistence

**Purpose**

Saves entity data to database for persistence across server restarts

**When Called**

Called during server shutdown or periodic saves to persist entity states

---

### loadPersistenceData

**Purpose**

Loads persisted entity data from database and optionally executes callback

**When Called**

Called during server startup to restore persisted entities

---

### get

**Purpose**

Retrieves stored data from memory cache with automatic deserialization

**When Called**

Called when accessing stored persistent data

---

### getPersistence

**Purpose**

Retrieves cached entity persistence data from memory

**When Called**

Called when accessing loaded entity persistence data

---


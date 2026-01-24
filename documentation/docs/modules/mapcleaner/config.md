# Configuration

Configuration options for the Map Cleaner module.

---

Overview

The Map Cleaner module provides configurable settings for automatic entity cleanup including entity types to remove and cleanup intervals.

---

### MapCleanerEntitiesToRemove

#### 📋 Description
A list of entity class names that will be automatically cleaned up by the map cleaner.

#### ⚙️ Type
Table

#### 💾 Default Value
{"lia_item", "prop_physics"}

#### 🌐 Realm
Server

---

### MapCleanerEnabled

#### 📋 Description
Enables or disables the map cleaner system.

#### ⚙️ Type
Boolean

#### 💾 Default Value
true

#### 🌐 Realm
Server

---

### ItemCleanupTime

#### 📋 Description
Sets the time in seconds before items are cleaned up.

#### ⚙️ Type
Int

#### 💾 Default Value
7200

#### 📊 Range
Minimum: 60
Maximum: 86400

#### 🌐 Realm
Server

---

### MapCleanupTime

#### 📋 Description
Sets the time in seconds before map entities are cleaned up.

#### ⚙️ Type
Int

#### 💾 Default Value
21600

#### 📊 Range
Minimum: 3600
Maximum: 86400

#### 🌐 Realm
Server


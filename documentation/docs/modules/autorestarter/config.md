# Configuration

Configuration options for the Auto Restarter module.

---

Overview

The Auto Restarter module provides configurable settings for automatic server restarts. These settings control the restart interval, countdown display, and font used for restart notifications.

---

### RestartInterval

#### 📋 Description
Sets the interval in seconds between automatic server restarts.

#### ⚙️ Type
Int

#### 💾 Default Value
3600

#### 📊 Range
Minimum: 60
Maximum: 604800

#### 🌐 Realm
Server

---

### RestartCountdownFont

#### 📋 Description
Sets the font used for displaying the restart countdown timer.

#### ⚙️ Type
Table

#### 💾 Default Value
"Montserrat Medium"

#### 📊 Options
Available fonts from the framework font system.

#### 🌐 Realm
Client


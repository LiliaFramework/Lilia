# Configuration

Configuration options for the Freelook module.

---

Overview

The Freelook module provides client-side options for freelook functionality including enable/disable toggle, angle limits, smoothness, and ADS blocking.

---

### freelookEnabled

#### 📋 Description
Enables or disables the freelook functionality.

#### ⚙️ Type
Boolean

#### 💾 Default Value
false

#### 🌐 Realm
Client

---

### freelookLimitVertical

#### 📋 Description
Sets the maximum freelook angle vertically in degrees.

#### ⚙️ Type
Int

#### 💾 Default Value
65

#### 📊 Range
Minimum: 30
Maximum: 90

#### 🌐 Realm
Client

---

### freelookLimitHorizontal

#### 📋 Description
Sets the maximum freelook angle horizontally in degrees.

#### ⚙️ Type
Int

#### 💾 Default Value
90

#### 📊 Range
Minimum: 60
Maximum: 120

#### 🌐 Realm
Client

---

### freelookSmoothness

#### 📋 Description
Sets the smoothness of the freelook movement.

#### ⚙️ Type
Float

#### 💾 Default Value
1

#### 📊 Range
Minimum: 0.1
Maximum: 2

#### 🌐 Realm
Client

---

### freelookBlockADS

#### 📋 Description
Prevents freelook while aiming down sights.

#### ⚙️ Type
Boolean

#### 💾 Default Value
true

#### 🌐 Realm
Client


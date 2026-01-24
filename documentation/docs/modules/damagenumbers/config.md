# Configuration

Configuration options for the Damage Numbers module.

---

Overview

The Damage Numbers module provides configurable settings for floating damage number displays, including font selection and client-side options for duration and alpha transparency.

---

### DamageFont

#### 📋 Description
Sets the font used for displaying floating damage numbers.

#### ⚙️ Type
Table

#### 💾 Default Value
"Montserrat Medium"

#### 📊 Options
Available fonts from the framework font system.

#### 🌐 Realm
Client

---

### damageNumberTime

#### 📋 Description
Sets how long (in seconds) floating damage numbers stay on screen.

#### ⚙️ Type
Float

#### 💾 Default Value
2

#### 📊 Range
Minimum: 0.5
Maximum: 5

#### 🌐 Realm
Client

---

### damageNumberAlpha

#### 📋 Description
Sets the base alpha (transparency) value for floating damage numbers.

#### ⚙️ Type
Int

#### 💾 Default Value
125

#### 📊 Range
Minimum: 0
Maximum: 255

#### 🌐 Realm
Client


# Configuration

Configuration options for the Alcoholism module.

---

Overview

The Alcoholism module provides configurable alcohol items and intoxication system settings. These settings control the types of alcohol available, their properties, intoxication effects, degradation rates, and visual effects such as screen blur and motion blur. The module allows customization of alcohol items with varying alcohol by volume (ABV), pricing, and physical properties.

---

### AlcoholItems

#### 📋 Description
Defines the available alcohol items in the game. Each item has properties including name, model, alcohol by volume (ABV), weight, price, category, and inventory dimensions.

#### ⚙️ Type
Table

#### 💾 Default Value
A table containing multiple alcohol items including vodka, whiskey, wine, beer, rum, gin, tequila, cider, mead, moonshine, absinthe, sake, and soju.

#### 📊 Structure
Each alcohol item contains:
- `name` (string) - Display name of the alcohol
- `model` (string) - Model path for the item
- `abv` (number) - Alcohol by volume percentage
- `weight` (number) - Weight of the item
- `price` (number) - Purchase price
- `category` (string) - Item category
- `width` (number) - Inventory width
- `height` (number) - Inventory height

#### 🌐 Realm
Server

---

### AlcoholTickTime

#### 📋 Description
Sets the time in seconds between alcohol effect ticks that process intoxication levels.

#### ⚙️ Type
Int

#### 💾 Default Value
30

#### 📊 Range
Minimum: 1
Maximum: 300

#### 🌐 Realm
Server

---

### AlcoholDegradeRate

#### 📋 Description
Sets the rate at which blood alcohol content (BAC) decreases over time.

#### ⚙️ Type
Int

#### 💾 Default Value
5

#### 📊 Range
Minimum: 1
Maximum: 100

#### 🌐 Realm
Server

---

### AlcoholAddAlpha

#### 📋 Description
Controls the alpha (transparency) effect applied to the screen when intoxicated.

#### ⚙️ Type
Float

#### 💾 Default Value
0.03

#### 📊 Range
Minimum: 0.01
Maximum: 1

#### 🌐 Realm
Client

---

### AlcoholEffectDelay

#### 📋 Description
Sets the delay between alcohol visual effects being applied.

#### ⚙️ Type
Float

#### 💾 Default Value
0.03

#### 📊 Range
Minimum: 0.01
Maximum: 1

#### 🌐 Realm
Client

---

### DrunkNotifyThreshold

#### 📋 Description
Sets the BAC threshold at which players receive a notification about their intoxication level.

#### ⚙️ Type
Int

#### 💾 Default Value
50

#### 📊 Range
Minimum: 1
Maximum: 100

#### 🌐 Realm
Server

---

### AlcoholMotionBlurAlpha

#### 📋 Description
Controls the alpha (transparency) of the motion blur effect when intoxicated.

#### ⚙️ Type
Float

#### 💾 Default Value
0.03

#### 📊 Range
Minimum: 0.01
Maximum: 1

#### 🌐 Realm
Client

---

### AlcoholMotionBlurDelay

#### 📋 Description
Sets the delay between motion blur effects being applied.

#### ⚙️ Type
Float

#### 💾 Default Value
0.03

#### 📊 Range
Minimum: 0.01
Maximum: 1

#### 🌐 Realm
Client

---

### AlcoholIntenseMultiplier

#### 📋 Description
Multiplier applied to alcohol effects during intense intoxication periods.

#### ⚙️ Type
Float

#### 💾 Default Value
2

#### 📊 Range
Minimum: 1
Maximum: 5

#### 🌐 Realm
Server

---

### AlcoholRagdollThreshold

#### 📋 Description
Sets the BAC threshold at which players may ragdoll due to intoxication.

#### ⚙️ Type
Int

#### 💾 Default Value
80

#### 📊 Range
Minimum: 1
Maximum: 100

#### 🌐 Realm
Server

---

### AlcoholRagdollMin

#### 📋 Description
Minimum duration in seconds for ragdoll effects when intoxicated.

#### ⚙️ Type
Int

#### 💾 Default Value
10

#### 📊 Range
Minimum: 1
Maximum: 600

#### 🌐 Realm
Server

---

### AlcoholRagdollMax

#### 📋 Description
Maximum duration in seconds for ragdoll effects when intoxicated.

#### ⚙️ Type
Int

#### 💾 Default Value
15

#### 📊 Range
Minimum: 1
Maximum: 600

#### 🌐 Realm
Server

---

### AlcoholRagdollChance

#### 📋 Description
Percentage chance that a player will ragdoll when reaching the ragdoll threshold.

#### ⚙️ Type
Int

#### 💾 Default Value
5

#### 📊 Range
Minimum: 1
Maximum: 100

#### 🌐 Realm
Server

---

### AlcoholRagdollDuration

#### 📋 Description
Duration in seconds that ragdoll effects last when triggered.

#### ⚙️ Type
Int

#### 💾 Default Value
5

#### 📊 Range
Minimum: 1
Maximum: 60

#### 🌐 Realm
Server

---

### AlcoholIntenseTime

#### 📋 Description
Duration in seconds for intense alcohol effect periods.

#### ⚙️ Type
Int

#### 💾 Default Value
5

#### 📊 Range
Minimum: 1
Maximum: 60

#### 🌐 Realm
Server


# Hooks

Hooks provided by the VManip module for managing viewmodel manipulation animations.

---

Overview

The VManip module adds vmanip animation support, hand gestures for items, functionality within lilia, api for custom gesture triggers, and fallback animations when vmanip is missing.. It provides comprehensive hook integration for customizing managing viewmodel manipulation animations and extending functionality.

---

### PreVManipPickup

#### 📋 Purpose
Called before a VManip pickup animation is triggered.

#### ⏰ When Called
When a player picks up an item, before the animation plays.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player picking up the item |
| `item` | **Item** | The item being picked up |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The VManip module adds vmanip animation support, hand gestures for items, functionality within lilia, api for custom gesture triggers, and fallback animations when vmanip is missing.. It provides comprehensive hook integration for customizing managing viewmodel manipulation animations and extending functionality.

---

### VManipAnimationPlayed

#### 📋 Purpose
Called when a VManip animation is played.

#### ⏰ When Called
After the animation starts playing on the client.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemID` | **string** | The unique ID of the item that triggered the animation |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The VManip module adds vmanip animation support, hand gestures for items, functionality within lilia, api for custom gesture triggers, and fallback animations when vmanip is missing.. It provides comprehensive hook integration for customizing managing viewmodel manipulation animations and extending functionality.

---

### VManipChooseAnim

#### 📋 Purpose
Called to choose which VManip animation to play.

#### ⏰ When Called
When determining which animation to use for an item pickup.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemID` | **string** | The unique ID of the item |

#### ↩️ Returns
*string* - Return animation name to use, nil for default

#### 🌐 Realm
Client

---

Overview

The VManip module adds vmanip animation support, hand gestures for items, functionality within lilia, api for custom gesture triggers, and fallback animations when vmanip is missing.. It provides comprehensive hook integration for customizing managing viewmodel manipulation animations and extending functionality.

---

### VManipPickup

#### 📋 Purpose
Called when a VManip pickup is performed.

#### ⏰ When Called
After the pickup animation is sent to the client.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player picking up the item |
| `item` | **Item** | The item being picked up |

#### ↩️ Returns
nil

#### 🌐 Realm
Server



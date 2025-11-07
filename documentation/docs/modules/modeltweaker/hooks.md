# Hooks

Hooks provided by the Model Tweaker module for managing wardrobe model changes.

---

Overview

The Model Tweaker module adds an entity to tweak prop models, adjustments for scale and rotation, easy ui controls, saving of tweaked props between restarts, and undo support for recent tweaks.. It provides comprehensive hook integration for customizing managing wardrobe model changes and extending functionality.

---

### PostWardrobeModelChange

#### 📋 Purpose
Called after a wardrobe model change has been applied.

#### ⏰ When Called
After the model is set on both the player and character.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose model was changed |
| `newModel` | **string** | The model path that was set |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Model Tweaker module adds an entity to tweak prop models, adjustments for scale and rotation, easy ui controls, saving of tweaked props between restarts, and undo support for recent tweaks.. It provides comprehensive hook integration for customizing managing wardrobe model changes and extending functionality.

---

### PreWardrobeModelChange

#### 📋 Purpose
Called before a wardrobe model change is applied.

#### ⏰ When Called
After validation passes, before the model is set.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose model will be changed |
| `newModel` | **string** | The model path that will be set |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Model Tweaker module adds an entity to tweak prop models, adjustments for scale and rotation, easy ui controls, saving of tweaked props between restarts, and undo support for recent tweaks.. It provides comprehensive hook integration for customizing managing wardrobe model changes and extending functionality.

---

### WardrobeModelChanged

#### 📋 Purpose
Called when a wardrobe model has been successfully changed.

#### ⏰ When Called
After the model change is complete and saved.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose model was changed |
| `newModel` | **string** | The model path that was set |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Model Tweaker module adds an entity to tweak prop models, adjustments for scale and rotation, easy ui controls, saving of tweaked props between restarts, and undo support for recent tweaks.. It provides comprehensive hook integration for customizing managing wardrobe model changes and extending functionality.

---

### WardrobeModelChangeRequested

#### 📋 Purpose
Called when a wardrobe model change is requested.

#### ⏰ When Called
When the server receives a model change request.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player requesting the change |
| `newModel` | **string** | The model path being requested |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Model Tweaker module adds an entity to tweak prop models, adjustments for scale and rotation, easy ui controls, saving of tweaked props between restarts, and undo support for recent tweaks.. It provides comprehensive hook integration for customizing managing wardrobe model changes and extending functionality.

---

### WardrobeModelInvalid

#### 📋 Purpose
Called when an invalid model is requested for wardrobe change.

#### ⏰ When Called
When the requested model fails validation.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who requested the invalid model |
| `newModel` | **string** | The invalid model path |

#### ↩️ Returns
nil

#### 🌐 Realm
Server



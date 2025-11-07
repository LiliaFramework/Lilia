# Hooks

Hooks provided by the Model Pay module for managing salary payments based on player models.

---

Overview

The Model Pay module adds payment to characters based on model, custom wage definitions, integration into the economy, config to exclude certain models, and logs of wages issued.. It provides comprehensive hook integration for customizing managing salary payments based on player models and extending functionality.

---

### CreateSalaryTimer

#### 📋 Purpose
Called when a salary timer should be created for a player with an eligible model.

#### ⏰ When Called
When a player's model changes to an eligible model.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose salary timer should be created |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Model Pay module adds payment to characters based on model, custom wage definitions, integration into the economy, config to exclude certain models, and logs of wages issued.. It provides comprehensive hook integration for customizing managing salary payments based on player models and extending functionality.

---

### ModelPayModelChecked

#### 📋 Purpose
Called when a player's model is checked for salary eligibility.

#### ⏰ When Called
During salary amount calculation, before model matching.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose model is being checked |
| `playerModel` | **string** | The lowercase model path |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Model Pay module adds payment to characters based on model, custom wage definitions, integration into the economy, config to exclude certain models, and logs of wages issued.. It provides comprehensive hook integration for customizing managing salary payments based on player models and extending functionality.

---

### ModelPayModelEligible

#### 📋 Purpose
Called when a player's model matches an eligible model for salary.

#### ⏰ When Called
When a player's model changes to a model that has salary configured.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player with the eligible model |
| `newModel` | **string** | The model path that is eligible |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Model Pay module adds payment to characters based on model, custom wage definitions, integration into the economy, config to exclude certain models, and logs of wages issued.. It provides comprehensive hook integration for customizing managing salary payments based on player models and extending functionality.

---

### ModelPayModelIneligible

#### 📋 Purpose
Called when a player's model does not match any eligible models.

#### ⏰ When Called
When a player's model changes to a model that has no salary configured.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player with the ineligible model |
| `newModel` | **string** | The model path that is ineligible |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Model Pay module adds payment to characters based on model, custom wage definitions, integration into the economy, config to exclude certain models, and logs of wages issued.. It provides comprehensive hook integration for customizing managing salary payments based on player models and extending functionality.

---

### ModelPayModelMatched

#### 📋 Purpose
Called when a player's model matches a salary model.

#### ⏰ When Called
During salary calculation when a model match is found.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose model matched |
| `model` | **string** | The model that matched |
| `pay` | **number** | The salary amount for this model |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Model Pay module adds payment to characters based on model, custom wage definitions, integration into the economy, config to exclude certain models, and logs of wages issued.. It provides comprehensive hook integration for customizing managing salary payments based on player models and extending functionality.

---

### ModelPayModelNotMatched

#### 📋 Purpose
Called when a player's model does not match any salary models.

#### ⏰ When Called
During salary calculation when no model match is found.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose model did not match |
| `playerModel` | **string** | The model path that was checked |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Model Pay module adds payment to characters based on model, custom wage definitions, integration into the economy, config to exclude certain models, and logs of wages issued.. It provides comprehensive hook integration for customizing managing salary payments based on player models and extending functionality.

---

### ModelPaySalaryDetermined

#### 📋 Purpose
Called when a player's salary amount has been determined.

#### ⏰ When Called
After salary calculation completes, whether a match was found or not.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose salary was calculated |
| `pay` | **number** | The determined salary amount (0 if no match) |

#### ↩️ Returns
nil

#### 🌐 Realm
Server



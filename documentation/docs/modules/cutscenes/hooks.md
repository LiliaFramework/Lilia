# Hooks

Hooks provided by the Cutscenes module for managing cutscene playback and display.

---

Overview

The Cutscenes module provides a flexible framework for creating and playing scripted cinematic sequences with synchronized camera movement across all clients. It supports table-defined scenes, player skip controls, administrative commands for cutscene management, and comprehensive hook integration for customizing cutscene behavior and extending cinematic functionality.

---

### CutsceneEnded

#### 📋 Purpose
Called when a cutscene has completely finished playing.

#### ⏰ When Called
After the fade-out animation completes and all cutscene elements are removed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **string** | The identifier of the cutscene that ended |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

### CutsceneSceneEnded

#### 📋 Purpose
Called when a specific scene within a cutscene ends.

#### ⏰ When Called
After a scene's duration expires and before the next scene starts (or cutscene ends).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **string** | The identifier of the cutscene |
| `scene` | **table** | The scene data that just ended |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

### CutsceneSceneStarted

#### 📋 Purpose
Called when a specific scene within a cutscene starts.

#### ⏰ When Called
When a new scene begins playing within the cutscene sequence.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **string** | The identifier of the cutscene |
| `scene` | **table** | The scene data that just started |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

### CutsceneStarted

#### 📋 Purpose
Called when a cutscene begins playing.

#### ⏰ When Called
When the cutscene playback is initiated, before any scenes are displayed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **string** | The identifier of the cutscene that started |
| `ply` | **Player, optional** | The player who started the cutscene (server-side only) |

#### ↩️ Returns
nil

#### 🌐 Realm
Client (id only) or Server (ply, id)

---

### CutsceneSubtitleStarted

#### 📋 Purpose
Called when a subtitle within a cutscene scene starts displaying.

#### ⏰ When Called
When a subtitle begins showing, including sound playback if configured.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **string** | The identifier of the cutscene |
| `subtitle` | **table** | The subtitle data containing text, color, font, and sound |

#### ↩️ Returns
nil

#### 🌐 Realm
Client


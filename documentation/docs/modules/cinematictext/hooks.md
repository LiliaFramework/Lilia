# Hooks

Hooks provided by the Cinematic Text module for displaying cinematic splash text and effects.

---

Overview

The Cinematic Text module creates immersive cinematic experiences with splash text overlays, screen darkening effects, and letterbox bars for dramatic storytelling. It supports scripted scenes with timed fades, customizable fonts and positioning, and administrative controls for cinematic playback. The module provides comprehensive hook integration for synchronizing cinematic events across players and extending cinematic functionality with custom effects.

---

### CinematicDisplayEnded

#### 📋 Purpose
Called when a cinematic display has finished and is being removed.

#### ⏰ When Called
After the fade-out animation completes and the cinematic panel is removed.

#### ⚙️ Parameters
None

#### ↩️ Returns
nil 

#### 🌐 Realm
Client

---

### CinematicDisplayStart

#### 📋 Purpose
Called when a cinematic display starts showing.

#### ⏰ When Called
After the cinematic data is received but before the display is rendered.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | **string** | The main text to display (can be nil) |
| `bigText` | **string** | The large text to display (can be nil) |
| `duration` | **number** | The duration in seconds for the display |
| `blackbars` | **boolean** | Whether to show cinematic black bars |
| `music` | **boolean** | Whether to play background music |
| `color` | **Color** | The color of the text |

#### ↩️ Returns
nil 

#### 🌐 Realm
Client

---

### CinematicMenuOpened

#### 📋 Purpose
Called when the cinematic text menu is opened.

#### ⏰ When Called
When a player with the appropriate privilege opens the cinematic text menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who opened the menu |

#### ↩️ Returns
nil 

#### 🌐 Realm
Client

---

### CinematicPanelCreated

#### 📋 Purpose
Called when the cinematic splash text panel is created.

#### ⏰ When Called
After the cinematic panel VGUI element is created but before it's displayed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `panel` | **Panel** | The CinematicSplashText panel that was created |

#### ↩️ Returns
nil 

#### 🌐 Realm
Client

---

### CinematicTriggered

#### 📋 Purpose
Called when a cinematic display is triggered from the server.

#### ⏰ When Called
When the server receives a request to trigger a cinematic display.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who triggered the cinematic |
| `text` | **string** | The main text to display |
| `bigText` | **string** | The large text to display |
| `duration` | **number** | The duration in seconds |
| `blackBars` | **boolean** | Whether to show black bars |
| `music` | **boolean** | Whether to play music |
| `color` | **Color** | The text color |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server


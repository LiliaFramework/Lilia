# Hooks

Hooks provided by the Development HUD module for customizing development information display.

---

Overview

The Development HUD module adds a staff-only development hud, font customization via devhudfont, a requirement for the cami privilege, real-time server performance metrics, and a toggle command to show or hide the hud.. It provides comprehensive hook integration for customizing customizing development information display and extending functionality.

---

### DevelopmentHUDPaint

#### 📋 Purpose
Called after the development HUD has been painted, allowing additional custom drawing.

#### ⏰ When Called
After all standard development HUD elements have been drawn.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The local player viewing the HUD |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The Development HUD module adds a staff-only development hud, font customization via devhudfont, a requirement for the cami privilege, real-time server performance metrics, and a toggle command to show or hide the hud.. It provides comprehensive hook integration for customizing customizing development information display and extending functionality.

---

### DevelopmentHUDPrePaint

#### 📋 Purpose
Called before the development HUD is painted, allowing modification of display settings.

#### ⏰ When Called
Before any development HUD elements are drawn.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The local player viewing the HUD |

#### ↩️ Returns
nil

#### 🌐 Realm
Client



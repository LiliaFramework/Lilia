# Hooks

Hooks provided by the Cursor module for custom cursor rendering and interaction.

---

Overview

The Cursor module provides a toggleable custom cursor system for improved UI navigation and interaction. It offers client-side cursor rendering with hotkey controls, enhanced menu compatibility, and smooth cursor transitions. The module includes comprehensive hook integration for customizing cursor behavior, rendering, and interaction events.

---

### CursorThink

#### 📋 Purpose
Called every frame when the cursor is active and a panel is being hovered.

#### ⏰ When Called
During the Think hook when a custom cursor material is set and a valid panel is hovered.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `hoverPanel` | **Panel** | The VGUI panel currently being hovered by the cursor |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

### PostRenderCursor

#### 📋 Purpose
Called after the custom cursor has been rendered.

#### ⏰ When Called
After the cursor drawing operation completes in PostRenderVGUI.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `cursorMaterial` | **string** | The material path of the cursor being rendered |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

### PreCursorThink

#### 📋 Purpose
Called before the cursor Think logic processes the hovered panel.

#### ⏰ When Called
During the Think hook, before setting the panel cursor to blank.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `hoverPanel` | **Panel** | The VGUI panel currently being hovered by the cursor |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

### PreRenderCursor

#### 📋 Purpose
Called before the custom cursor is rendered.

#### ⏰ When Called
Before the cursor drawing operation begins in PostRenderVGUI.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `cursorMaterial` | **string** | The material path of the cursor to be rendered |

#### ↩️ Returns
nil

#### 🌐 Realm
Client


# Hooks

Hooks provided by the HUD Extras module for managing additional HUD elements.

---

Overview

The HUD Extras module adds extra hud elements like an fps counter, fonts configurable with fpshudfont, hooks so other modules can extend, performance stats display, and toggles for individual hud elements.. It provides comprehensive hook integration for customizing managing additional hud elements and extending functionality.

---

### AdjustBlurAmount

#### 📋 Purpose
Called to adjust the blur amount before it's applied.

#### ⏰ When Called
During blur calculation, before the blur value is set.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `blurGoal` | **number** | The current blur goal value |

#### ↩️ Returns
*number* - Additional blur amount to add (or subtract if negative)

#### 🌐 Realm
Client

---

Overview

The HUD Extras module adds extra hud elements like an fps counter, fonts configurable with fpshudfont, hooks so other modules can extend, performance stats display, and toggles for individual hud elements.. It provides comprehensive hook integration for customizing managing additional hud elements and extending functionality.

---

### HUDExtrasPostDrawBlur

#### 📋 Purpose
Called after the blur effect has been drawn.

#### ⏰ When Called
After the blur is rendered on screen.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `blurValue` | **number** | The blur value that was applied |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The HUD Extras module adds extra hud elements like an fps counter, fonts configurable with fpshudfont, hooks so other modules can extend, performance stats display, and toggles for individual hud elements.. It provides comprehensive hook integration for customizing managing additional hud elements and extending functionality.

---

### HUDExtrasPostDrawFPS

#### 📋 Purpose
Called after the FPS display has been drawn.

#### ⏰ When Called
After the FPS counter is rendered.

#### ⚙️ Parameters
None

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The HUD Extras module adds extra hud elements like an fps counter, fonts configurable with fpshudfont, hooks so other modules can extend, performance stats display, and toggles for individual hud elements.. It provides comprehensive hook integration for customizing managing additional hud elements and extending functionality.

---

### HUDExtrasPostDrawVignette

#### 📋 Purpose
Called after the vignette effect has been drawn.

#### ⏰ When Called
After the vignette is rendered.

#### ⚙️ Parameters
None

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The HUD Extras module adds extra hud elements like an fps counter, fonts configurable with fpshudfont, hooks so other modules can extend, performance stats display, and toggles for individual hud elements.. It provides comprehensive hook integration for customizing managing additional hud elements and extending functionality.

---

### HUDExtrasPostDrawWatermark

#### 📋 Purpose
Called after the watermark has been drawn.

#### ⏰ When Called
After the watermark is rendered.

#### ⚙️ Parameters
None

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The HUD Extras module adds extra hud elements like an fps counter, fonts configurable with fpshudfont, hooks so other modules can extend, performance stats display, and toggles for individual hud elements.. It provides comprehensive hook integration for customizing managing additional hud elements and extending functionality.

---

### HUDExtrasPreDrawBlur

#### 📋 Purpose
Called before the blur effect is drawn.

#### ⏰ When Called
Before blur calculation and rendering.

#### ⚙️ Parameters
None

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The HUD Extras module adds extra hud elements like an fps counter, fonts configurable with fpshudfont, hooks so other modules can extend, performance stats display, and toggles for individual hud elements.. It provides comprehensive hook integration for customizing managing additional hud elements and extending functionality.

---

### HUDExtrasPreDrawFPS

#### 📋 Purpose
Called before the FPS display is drawn.

#### ⏰ When Called
Before the FPS counter is rendered.

#### ⚙️ Parameters
None

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The HUD Extras module adds extra hud elements like an fps counter, fonts configurable with fpshudfont, hooks so other modules can extend, performance stats display, and toggles for individual hud elements.. It provides comprehensive hook integration for customizing managing additional hud elements and extending functionality.

---

### HUDExtrasPreDrawVignette

#### 📋 Purpose
Called before the vignette effect is drawn.

#### ⏰ When Called
Before the vignette is rendered.

#### ⚙️ Parameters
None

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The HUD Extras module adds extra hud elements like an fps counter, fonts configurable with fpshudfont, hooks so other modules can extend, performance stats display, and toggles for individual hud elements.. It provides comprehensive hook integration for customizing managing additional hud elements and extending functionality.

---

### HUDExtrasPreDrawWatermark

#### 📋 Purpose
Called before the watermark is drawn.

#### ⏰ When Called
Before the watermark is rendered.

#### ⚙️ Parameters
None

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The HUD Extras module adds extra hud elements like an fps counter, fonts configurable with fpshudfont, hooks so other modules can extend, performance stats display, and toggles for individual hud elements.. It provides comprehensive hook integration for customizing managing additional hud elements and extending functionality.

---

### ShouldDrawBlur

#### 📋 Purpose
Called to determine if blur should be drawn.

#### ⏰ When Called
During blur drawing check.

#### ⚙️ Parameters
None

#### ↩️ Returns
*boolean* - Return true to force draw, false to prevent, nil for default

#### 🌐 Realm
Client

---

Overview

The HUD Extras module adds extra hud elements like an fps counter, fonts configurable with fpshudfont, hooks so other modules can extend, performance stats display, and toggles for individual hud elements.. It provides comprehensive hook integration for customizing managing additional hud elements and extending functionality.

---

### ShouldDrawWatermark

#### 📋 Purpose
Called to determine if the watermark should be drawn.

#### ⏰ When Called
During watermark drawing check.

#### ⚙️ Parameters
None

#### ↩️ Returns
*boolean* - Return true to force draw, false to prevent, nil for default

#### 🌐 Realm
Client



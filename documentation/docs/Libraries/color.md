# Color Library

Comprehensive color and theme management system for the Lilia framework.

---

Overview

The color library provides comprehensive functionality for managing colors and themes in the Lilia framework. It handles color registration, theme management, color manipulation, and smooth theme transitions. The library operates primarily on the client side, with theme registration available on both server and client. It includes predefined color names, theme switching capabilities, color adjustment functions, and smooth animated transitions between themes. The library ensures consistent color usage across the entire gamemode interface and provides tools for creating custom themes and color schemes.

---

### lia.color.register

#### 📋 Purpose
Register a named color so string-based Color() calls can resolve it.

#### ⏰ When Called
During client initialization or when adding palette entries at runtime.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Identifier stored in lowercase. |
| `color` | **table|Color** | Table or Color with r, g, b, a fields. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.color.register("warning", Color(255, 140, 0))
    local c = Color("warning")

```

---

### lia.color.adjust

#### 📋 Purpose
Apply additive offsets to a color to quickly tint or shade it.

#### ⏰ When Called
While building UI states (hover/pressed) or computing theme variants.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `color` | **Color** | Base color. |
| `aOffset` | **number|nil** | Optional alpha offset; defaults to 0. |

#### ↩️ Returns
* Color
Adjusted color.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local base = lia.color.getMainColor()
    button:SetTextColor(lia.color.adjust(base, -40, -20, -60))

```

---

### lia.color.darken

#### 📋 Purpose
Darken a color by a fractional factor.

#### ⏰ When Called
Deriving hover/pressed backgrounds from a base accent color.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `color` | **Color** | Base color to darken. |
| `factor` | **number|nil** | Amount between 0-1; defaults to 0.1 and is clamped. |

#### ↩️ Returns
* Color
Darkened color.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local accent = lia.color.getMainColor()
    local pressed = lia.color.darken(accent, 0.2)

```

---

### lia.color.getCurrentTheme

#### 📋 Purpose
Get the active theme id from config in lowercase.

#### ⏰ When Called
Before looking up theme tables or theme-specific assets.

#### ↩️ Returns
* string
Lowercased theme id (default "teal").

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    if lia.color.getCurrentTheme() == "dark" then
        panel:SetDarkMode(true)
    end

```

---

### lia.color.getCurrentThemeName

#### 📋 Purpose
Get the display name of the currently selected theme.

#### ⏰ When Called
Showing UI labels or logs about the active theme.

#### ↩️ Returns
* string
Theme name from config with original casing.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    chat.AddText(Color(180, 220, 255), "Theme: ", lia.color.getCurrentThemeName())

```

---

### lia.color.getMainColor

#### 📋 Purpose
Fetch the main color from the current theme with sensible fallbacks.

#### ⏰ When Called
Setting accent colors for buttons, bars, and highlights.

#### ↩️ Returns
* Color
Main theme color, falling back to the default theme or teal.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local accent = lia.color.getMainColor()
    button:SetTextColor(accent)

```

---

### lia.color.applyTheme

#### 📋 Purpose
Apply a theme immediately or begin a smooth transition toward it, falling back to Teal/default palettes and firing OnThemeChanged after updates.

#### ⏰ When Called
On config changes, theme selection menus, or client startup.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `themeName` | **string|nil** | Target theme id; defaults to the current config value. |
| `useTransition` | **boolean|nil** | If true, blends colors over time instead of swapping instantly. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    concommand.Add("lia_theme_preview", function(_, _, args)
        lia.color.applyTheme(args[1] or "Teal", true)
    end)

```

---

### lia.color.isTransitionActive

#### 📋 Purpose
Check whether a theme transition is currently blending.

#### ⏰ When Called
To avoid overlapping transitions or to gate UI animations.

#### ↩️ Returns
* boolean
True if a transition is active, otherwise false.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    if lia.color.isTransitionActive() then return end
    lia.color.applyTheme("Dark", true)

```

---

### lia.color.testThemeTransition

#### 📋 Purpose
Convenience wrapper to start a theme transition immediately.

#### ⏰ When Called
From theme preview buttons to animate a swap.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `themeName` | **string** | Target theme id. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    vgui.Create("DButton").DoClick = function()
        lia.color.testThemeTransition("Red")
    end

```

---

### lia.color.startThemeTransition

#### 📋 Purpose
Begin blending from the current palette toward a target theme, falling back to Teal when missing and finishing by firing OnThemeChanged once applied.

#### ⏰ When Called
Inside applyTheme when transitions are enabled or via previews.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Theme id to blend toward. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.color.transition.speed = 1.5
    lia.color.startThemeTransition("Ice")

```

---

### lia.color.isColor

#### 📋 Purpose
Determine whether a value resembles a Color table.

#### ⏰ When Called
While blending themes to decide how to lerp entries.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `v` | **any** | Value to test. |

#### ↩️ Returns
* boolean
True when v has numeric r, g, b, a fields.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    if lia.color.isColor(entry) then
        panel:SetTextColor(entry)
    end

```

---

### lia.color.calculateNegativeColor

#### 📋 Purpose
Build a readable contrasting color (alpha 255) based on a main color.

#### ⏰ When Called
Choosing text or negative colors for overlays and highlights.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mainColor` | **Color|nil** | Defaults to the current theme main color when nil. |

#### ↩️ Returns
* Color
Contrasting color tuned for readability.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local negative = lia.color.calculateNegativeColor()
    frame:SetTextColor(negative)

```

---

### lia.color.returnMainAdjustedColors

#### 📋 Purpose
Derive a suite of adjusted colors from the main theme color, including brightness-aware text and a calculated negative color.

#### ⏰ When Called
Building consistent palettes for backgrounds, accents, and text.

#### ↩️ Returns
* table
Contains background, sidebar, accent, text, hover, border, highlight, negative.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local palette = lia.color.returnMainAdjustedColors()
    panel:SetBGColor(palette.background)
    panel:SetTextColor(palette.text)

```

---

### lia.color.lerp

#### 📋 Purpose
FrameTime-scaled color lerp helper.

#### ⏰ When Called
Theme transitions or animated highlights needing smooth color changes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `frac` | **number** | Multiplier applied to FrameTime for lerp speed. |
| `col1` | **Color** | Source color; defaults to white when nil. |
| `col2` | **Color** | Target color; defaults to white when nil. |

#### ↩️ Returns
* Color
Interpolated color.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local blink = lia.color.lerp(6, Color(255, 0, 0), Color(255, 255, 255))
    panel:SetBorderColor(blink)

```

---

### lia.color.registerTheme

#### 📋 Purpose
Register a theme table by name for later selection.

#### ⏰ When Called
During initialization to expose custom palettes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Theme name/id; stored in lowercase. |
| `themeData` | **table** | Map of color keys to Color values or arrays. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.color.registerTheme("MyStudio", {
        maincolor = Color(120, 200, 255),
        background = Color(20, 24, 32),
        text = Color(230, 240, 255)
    })

```

---

### lia.color.getAllThemes

#### 📋 Purpose
Return a sorted list of available theme ids.

#### ⏰ When Called
To populate config dropdowns or theme selection menus.

#### ↩️ Returns
* table
Sorted array of theme ids.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local options = {}
    for _, id in ipairs(lia.color.getAllThemes()) do
        options[#options + 1] = id
    end

```

---


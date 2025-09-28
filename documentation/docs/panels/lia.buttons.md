# Button Panels Library

A comprehensive collection of styled button components for consistent UI design across the Lilia framework.

---

## Overview

The button panel library provides various button components with different sizes, styling options, and selection states. All button panels extend Garry's Mod's native `DButton` with enhanced visual effects, including underline animations on hover and persistent selection indicators. These panels integrate seamlessly with Lilia's theming system to provide consistent styling throughout the interface.

---

### liaHugeButton

**Purpose**

Large button styled with `liaHugeFont` and an underline effect on hover. Supports selection state with persistent underline when `SetSelected(true)` is called.

**When Called**

This button is called when:
- Creating large, prominent action buttons in interfaces
- Building main navigation elements in menus
- Displaying primary call-to-action buttons
- Implementing large-scale UI controls

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetSelected(state)` – sets the button's selected state, showing persistent underline when true.
- `IsSelected()` – returns whether the button is currently selected.

**Example Usage**

```lua
-- Create a huge button
local button = vgui.Create("liaHugeButton")
button:SetText("Primary Action")
button:SetSize(200, 50)
button.DoClick = function()
    print("Primary action clicked!")
end

-- Set as selected to show persistent underline
button:SetSelected(true)
```

---

### liaBigButton

**Purpose**

Big-font button with the same underline hover animation and selection state support.

**When Called**

This button is called when:
- Creating medium-large action buttons
- Building secondary navigation elements
- Displaying prominent UI controls
- Implementing standard-sized call-to-action buttons

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetSelected(state)` – sets the button's selected state, showing persistent underline when true.
- `IsSelected()` – returns whether the button is currently selected.

**Example Usage**

```lua
-- Create a big button
local button = vgui.Create("liaBigButton")
button:SetText("Secondary Action")
button:SetSize(150, 40)
button.DoClick = function()
    print("Secondary action clicked!")
end

-- Set as selected to show persistent underline
button:SetSelected(true)
```

---

### liaMediumButton

**Purpose**

Medium-size button using `liaMediumFont` with underline hover animation and selection state support.

**When Called**

This button is called when:
- Creating standard-sized action buttons
- Building regular UI controls
- Displaying default button elements
- Implementing medium-scale interface components

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetSelected(state)` – sets the button's selected state, showing persistent underline when true.
- `IsSelected()` – returns whether the button is currently selected.

**Example Usage**

```lua
-- Create a medium button
local button = vgui.Create("liaMediumButton")
button:SetText("Standard Action")
button:SetSize(120, 35)
button.DoClick = function()
    print("Standard action clicked!")
end

-- Set as selected to show persistent underline
button:SetSelected(true)
```

---

### liaSmallButton

**Purpose**

Small button sized for compact layouts with underline hover animation and selection state support.

**When Called**

This button is called when:
- Creating compact UI elements
- Building dense interface layouts
- Displaying secondary controls
- Implementing space-efficient button designs

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetSelected(state)` – sets the button's selected state, showing persistent underline when true.
- `IsSelected()` – returns whether the button is currently selected.

**Example Usage**

```lua
-- Create a small button
local button = vgui.Create("liaSmallButton")
button:SetText("Compact")
button:SetSize(80, 25)
button.DoClick = function()
    print("Compact action clicked!")
end

-- Set as selected to show persistent underline
button:SetSelected(true)
```

---

### liaMiniButton

**Purpose**

Tiny button using `liaMiniFont` for dense interfaces with underline hover animation and selection state support.

**When Called**

This button is called when:
- Creating very compact UI elements
- Building high-density interfaces
- Displaying minimal control buttons
- Implementing space-critical button layouts

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetSelected(state)` – sets the button's selected state, showing persistent underline when true.
- `IsSelected()` – returns whether the button is currently selected.

**Example Usage**

```lua
-- Create a mini button
local button = vgui.Create("liaMiniButton")
button:SetText("Mini")
button:SetSize(60, 20)
button.DoClick = function()
    print("Mini action clicked!")
end

-- Set as selected to show persistent underline
button:SetSelected(true)
```

---

### liaNoBGButton

**Purpose**

Text-only button with no background that still shows the underline animation and supports selection state.

**When Called**

This button is called when:
- Creating text-only interface elements
- Building subtle navigation controls
- Displaying minimalistic button designs
- Implementing background-free UI elements

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetSelected(state)` – sets the button's selected state, showing persistent underline when true.
- `IsSelected()` – returns whether the button is currently selected.

**Example Usage**

```lua
-- Create a no-background button
local button = vgui.Create("liaNoBGButton")
button:SetText("Text Only")
button:SetSize(100, 30)
button.DoClick = function()
    print("Text-only action clicked!")
end

-- Set as selected to show persistent underline
button:SetSelected(true)
```

---

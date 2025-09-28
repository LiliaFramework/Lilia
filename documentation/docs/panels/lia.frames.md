# Frame and Base Panels Library

A collection of base panel types and frame components for creating consistent interface layouts within the Lilia framework.

---

## Overview

The frame and base panel library provides foundational panel components that serve as building blocks for more complex interfaces. These panels offer specialized backgrounds, transparency effects, and base functionality that can be extended or used directly to create consistent visual experiences throughout the Lilia framework.

---

### BlurredDFrame

**Purpose**

Frame that draws a screen blur behind its contents. Useful for overlay menus that shouldn't fully obscure the game.

**When Called**

This panel is called when:
- Creating overlay menus with blurred backgrounds
- Displaying modal dialogs
- Building interface elements that require background visibility
- Creating semi-transparent overlay interfaces

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a blurred frame
local frame = vgui.Create("BlurredDFrame")
frame:SetSize(400, 300)
frame:Center()
frame:MakePopup()

-- Use as modal dialog
frame:SetTitle("Blurred Dialog")
frame:SetupBlurEffect()
```

---

### SemiTransparentDFrame

**Purpose**

Simplified frame with a semi-transparent background, ideal for pop-up windows where the game should remain partially visible.

**When Called**

This panel is called when:
- Creating pop-up dialogs with transparency
- Displaying overlay information
- Building semi-transparent interface elements
- Creating see-through modal windows

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a semi-transparent frame
local frame = vgui.Create("SemiTransparentDFrame")
frame:SetSize(500, 400)
frame:Center()
frame:MakePopup()

-- Set transparency level
frame:SetTransparency(0.8) -- 80% opaque
frame:SetupTransparency()
```

---

### SemiTransparentDPanel

**Purpose**

Basic panel that paints itself with partial transparency. Often used inside `SemiTransparentDFrame` as an inner container.

**When Called**

This panel is called when:
- Creating transparent panel backgrounds
- Building semi-transparent UI elements
- Adding transparency to existing panels
- Creating layered interface components

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a semi-transparent panel
local panel = vgui.Create("SemiTransparentDPanel")
panel:SetSize(200, 100)
panel:SetPos(10, 10)

-- Set transparency level
panel:SetTransparency(0.6) -- 60% opaque
panel:SetupTransparency()
```

---

### liaFrame

**Purpose**

Base frame component with Lilia-specific styling, theming integration, and enhanced functionality for creating consistent dialog windows.

**When Called**

This panel is called when:
- Creating custom dialog windows
- Building modal interfaces
- Managing themed frame components
- Providing consistent dialog styling

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a custom frame
local frame = vgui.Create("liaFrame")
frame:SetSize(500, 400)
frame:Center()
frame:MakePopup()

-- Set frame properties
frame:SetTitle("Custom Dialog")
frame:SetupCloseButton()
frame:SetupDragRegion()

-- Add custom content
local content = vgui.Create("DPanel", frame)
content:Dock(FILL)
content:SetBackgroundColor(Color(240, 240, 240))
```

---

# Model Display Panels Library

A collection of panels for displaying 3D models with various camera controls and lighting options within the Lilia framework.

---

## Overview

The model display panel library provides specialized components for rendering 3D models with enhanced visual controls. These panels offer different camera modes, lighting systems, and interaction methods, making them ideal for character previews, item displays, and model showcase interfaces throughout the Lilia framework.

---

### liaModelPanel

**Purpose**

Displays a model with custom lighting and mouse controls for rotation and zoom. Useful for previewing items or player characters.

**When Called**

This panel is called when:
- Previewing player models during character creation
- Displaying item models in inventories or shops
- Showing 3D assets in interface elements
- Creating model viewers for various framework features

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a model panel
local panel = vgui.Create("liaModelPanel")
panel:SetSize(400, 300)
panel:Center()
panel:MakePopup()

-- Set a model to display
panel:SetModel("models/player/group01/male_01.mdl")

-- Customize the camera
panel:SetCamPos(Vector(50, 50, 50))
panel:SetLookAt(Vector(0, 0, 40))

-- Create in a frame with controls
local frame = vgui.Create("DFrame")
frame:SetTitle("Model Viewer")
frame:SetSize(500, 400)
frame:Center()
frame:MakePopup()

local modelViewer = vgui.Create("liaModelPanel", frame)
modelViewer:Dock(FILL)
modelViewer:SetModel("models/weapons/w_pistol.mdl")
```

---

### FacingModelPanel

**Purpose**

Variant of `liaModelPanel` that locks the camera to the model's head bone, ideal for mugshots or scoreboard avatars.

**When Called**

This panel is called when:
- Creating character mugshots or avatars
- Displaying player faces on scoreboards
- Generating identification displays
- Showing character portraits in interfaces

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a facing model panel
local panel = vgui.Create("FacingModelPanel")
panel:SetSize(400, 300)
panel:Center()
panel:MakePopup()

-- Set the model - camera will automatically focus on head
panel:SetModel("models/player/group01/male_01.mdl")

-- Use for scoreboard avatar
local scoreboardAvatar = vgui.Create("FacingModelPanel")
scoreboardAvatar:SetSize(64, 64)
scoreboardAvatar:SetModel(player:GetModel())

-- Create in a frame for character display
local frame = vgui.Create("DFrame")
frame:SetTitle("Character Portrait")
frame:SetSize(300, 350)
frame:Center()
frame:MakePopup()

local portrait = vgui.Create("FacingModelPanel", frame)
portrait:Dock(FILL)
portrait:SetModel(LocalPlayer():GetModel())
```

---

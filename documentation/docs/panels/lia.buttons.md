# Button Panel Library

This page documents the button panel components for creating interactive UI elements in the Lilia framework.

---

## Overview

The button panel library provides a comprehensive set of customizable button components with modern styling, animations, and interactive features. These panels are designed to create consistent, responsive user interfaces with visual feedback, hover effects, and ripple animations.

---

### liaFrame

**Purpose**

Creates a draggable window frame with customizable appearance, background blur, and interactive features.

**When Called**

This panel is called when:
- Creating modal dialogs or popup windows
- Building main application windows
- Developing settings or configuration panels
- Creating floating UI elements that require dragging

**Parameters**

* `title` (*string*): The title text displayed in the window header.
* `centerTitle` (*string*): Optional center-aligned title text.
* `iconPath` (*string|IMaterial*): Icon material or path for the window icon.
* `isAlpha` (*boolean*): Whether to enable background transparency.
* `isSizable` (*boolean*): Whether the window can be resized.
* `isDraggable` (*boolean*): Whether the window can be dragged.

**Returns**

* `panel` (*Panel*): The created frame panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic draggable window
local frame = vgui.Create("liaFrame")
frame:SetSize(400, 300)
frame:SetTitle("My Application")
frame:Center()

-- Create a settings window with transparency
local settingsFrame = vgui.Create("liaFrame")
settingsFrame:SetSize(500, 400)
settingsFrame:SetTitle("Settings")
settingsFrame:SetAlphaBackground(true)
settingsFrame:Center()

-- Create a modal dialog
local dialog = vgui.Create("liaFrame")
dialog:SetSize(300, 150)
dialog:SetTitle("Confirm Action")
dialog:SetScreenLock(true)
dialog:Center()
```

---

### liaButton

**Purpose**

Creates a modern styled button with hover effects, ripple animations, and customizable appearance.

**When Called**

This panel is called when:
- Creating interactive UI buttons
- Building form controls and actions
- Developing navigation elements
- Creating custom UI components

**Parameters**

* `text` (*string*): The button text to display.
* `icon` (*string|IMaterial*): Optional icon material or path.
* `iconSize` (*number*): Size of the icon in pixels.
* `radius` (*number*): Corner radius for button styling.
* `color` (*Color*): Base button color.
* `hoverColor` (*Color*): Color when hovered.
* `enableRipple` (*boolean*): Whether to show ripple effect on click.

**Returns**

* `panel` (*Panel*): The created button panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic button
local button = vgui.Create("liaButton")
button:SetText("Click Me!")
button:SetSize(120, 40)
button.DoClick = function()
    print("Button clicked!")
end

-- Create a button with icon
local iconButton = vgui.Create("liaButton")
iconButton:SetText("Save")
iconButton:SetIcon("icon16/disk.png")
iconButton:SetSize(100, 35)

-- Create a button without ripple effect
local simpleButton = vgui.Create("liaButton")
simpleButton:SetText("Simple Button")
simpleButton:SetRipple(false)
```

---

### liaEntry

**Purpose**

Creates a modern text entry field with placeholder text, focus effects, and customizable styling.

**When Called**

This panel is called when:
- Creating form input fields
- Building search boxes
- Developing text input interfaces
- Creating configuration panels

**Parameters**

* `placeholder` (*string*): Placeholder text shown when field is empty.
* `title` (*string*): Optional title label above the input.
* `defaultValue` (*string*): Initial text value.
* `numeric` (*boolean*): Whether to restrict input to numbers only.
* `multiline` (*boolean*): Whether to allow multiple lines of text.

**Returns**

* `panel` (*Panel*): The created entry panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic text input
local textEntry = vgui.Create("liaEntry")
textEntry:SetPlaceholder("Enter your name...")
textEntry:SetSize(200, 30)
textEntry.OnValueChange = function(value)
    print("Text changed to: " .. value)
end

-- Create a titled input field
local nameEntry = vgui.Create("liaEntry")
nameEntry:SetTitle("Player Name")
nameEntry:SetPlaceholder("Enter player name...")
nameEntry.OnEnter = function(value)
    print("Entered name: " .. value)
end

-- Create a numeric input
local numberEntry = vgui.Create("liaEntry")
numberEntry:SetPlaceholder("Enter number...")
numberEntry:SetNumeric(true)
```

---

### liaCheckbox

**Purpose**

Creates a toggleable checkbox with smooth animations and customizable styling.

**When Called**

This panel is called when:
- Creating boolean settings or options
- Building configuration interfaces
- Developing form controls
- Creating toggle switches

**Parameters**

* `text` (*string*): Text label for the checkbox.
* `defaultValue` (*boolean*): Initial checked state.
* `convar` (*string*): Console variable to bind to.
* `description` (*string*): Tooltip text for the checkbox.

**Returns**

* `panel` (*Panel*): The created checkbox panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create a basic checkbox
local checkbox = vgui.Create("liaCheckbox")
checkbox:SetText("Enable feature")
checkbox:SetChecked(true)
checkbox.OnChange = function(checked)
    print("Checkbox state: " .. tostring(checked))
end

-- Create a checkbox bound to a convar
local settingCheckbox = vgui.Create("liaCheckbox")
settingCheckbox:SetText("Show notifications")
settingCheckbox:SetConvar("lia_show_notifications")
settingCheckbox:SetDescription("Toggle notification display")

-- Create a simple checkbox without text
local simpleCheckbox = vgui.Create("liaSimpleCheckbox")
simpleCheckbox:SetSize(24, 24)
simpleCheckbox.OnChange = function(checked)
    print("Simple checkbox: " .. tostring(checked))
end

---

### liaSimpleCheckbox

**Purpose**

Simplified checkbox component with icon-based visual representation and basic toggle functionality.

**When Called**

This panel is called when:
- Simple checkbox controls are needed
- Icon-based checkbox representation is preferred
- Basic toggle functionality is sufficient

**Parameters**

* `text` (*string*): Optional text label for the checkbox.
* `defaultState` (*boolean*): Initial checked state.
* `iconChecked` (*string*): Icon path for checked state.
* `iconUnchecked` (*string*): Icon path for unchecked state.

**Returns**

* `panel` (*Panel*): The created simple checkbox panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create simple checkbox with text
local simpleCheck = vgui.Create("liaSimpleCheckbox")
simpleCheck:setText("Enable feature")
simpleCheck:setChecked(true)
simpleCheck.onChange = function(checked)
    print("Feature " .. (checked and "enabled" or "disabled"))
end

-- Create icon-only checkbox
local iconCheck = vgui.Create("liaSimpleCheckbox")
iconCheck:setSize(24, 24)
iconCheck:setText("") -- No text label
iconCheck:setChecked(false)
```

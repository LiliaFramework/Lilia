# Menu and UI Panels Library

A comprehensive collection of panels for managing main menu interfaces, navigation, and user interface components within the Lilia framework.

---

## Overview

The menu and UI panel library provides the primary interface components for Lilia's user interaction system. These panels handle main menu navigation, tab management, class selection, character information display, and quick settings interfaces. They integrate seamlessly with Lilia's GUI system to provide consistent navigation and user experience.

---

### liaMenu

**Purpose**

Main F1 menu housing tabs like Character, Help and Settings. It controls switching between tabs and can be opened on demand.

**When Called**

This panel is called when:
- Player presses the F1 key to open the main menu
- Menu system needs to be displayed or updated
- Tab navigation between different menu sections
- Framework initialization of the main interface

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Open the main F1 menu
lia.menu.toggle()

-- Check if menu is open
if lia.menu.isOpen() then
    print("Menu is currently open")
end

-- Programmatically create and show the menu
local menu = vgui.Create("liaMenu")
menu:SetSize(ScrW() * 0.8, ScrH() * 0.8)
menu:Center()
menu:MakePopup()
menu:SetupTabs()

-- Close the menu
if IsValid(menu) then
    menu:Remove()
end
```

---

### liaClasses

**Purpose**

Lists available classes in the F1 menu and shows requirements for each. Players may click a button to join a class when eligible.

**When Called**

This panel is called when:
- Player accesses the Classes tab in the F1 menu
- Viewing available character classes and their requirements
- Attempting to join or change character classes
- During character management and progression

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a classes panel
local panel = vgui.Create("liaClasses")
panel:SetSize(400, 300)
panel:Center()
panel:MakePopup()

-- Access the classes panel from the main menu
if lia.menu.isOpen() then
    -- Switch to the classes tab programmatically
    lia.gui.menu:SwitchToTab("Classes")
end

-- Create a standalone classes interface
local frame = vgui.Create("DFrame")
frame:SetTitle("Available Classes")
frame:SetSize(500, 400)
frame:Center()
frame:MakePopup()

local classesPanel = vgui.Create("liaClasses", frame)
classesPanel:Dock(FILL)
```

---

### liaCharInfo

**Purpose**

Displays the current character's stats and fields in the F1 menu. The panel updates periodically and can show plugin-defined information.

**When Called**

This panel is called when:
- The F1 menu is opened to display character information
- Character data needs to be shown in the main interface
- Player requests to view their current character's details
- During menu navigation and character management

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Character info is automatically created in the F1 menu
-- No manual creation needed - it's part of the main menu system

-- Access the character info panel programmatically
local charInfo = lia.gui.charInfo
if IsValid(charInfo) then
    -- Force an update of the character information
    charInfo:UpdateCharacterInfo()
end

-- Create a custom character info panel for specific use
local customCharInfo = vgui.Create("liaCharInfo")
customCharInfo:SetSize(300, 400)
customCharInfo:Dock(FILL)
```

---

### liaQuick

**Purpose**

Quick settings menu that lists options flagged with `isQuick`.

**When Called**

This panel is called when:
- Accessing quick configuration options
- Managing frequently used settings
- Providing rapid access to common controls
- Creating compact settings interfaces

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `addCategory(text)` – inserts a non-interactive section label.
- `addButton(text, cb)` – adds a clickable button that triggers `cb` when pressed.
- `addSpacer()` – draws a thin divider line.
- `addSlider(text, cb, val, min, max, dec)` – slider control that calls `cb(panel, value)`; default range `0–100`.
- `addCheck(text, cb, checked)` – checkbox row; invokes `cb(panel, state)` when toggled.
- `setIcon(char)` – sets the icon character displayed on the expand button.
- `populateOptions()` – fills the panel using registered quick options.

**Example Usage**

```lua
-- Create a quick settings panel
local quickPanel = vgui.Create("liaQuick")
quickPanel:SetSize(200, 100)

-- Add various UI elements
quickPanel:addCategory("Audio Settings")
quickPanel:addSlider("Volume", function(panel, value) print("Volume:", value) end, 50, 0, 100)
quickPanel:addCheck("Enable Sound", function(panel, state) print("Sound enabled:", state) end, true)
quickPanel:addButton("Reset", function() print("Reset clicked") end)

-- Or automatically populate with registered quick options
local autoQuick = vgui.Create("liaQuick")
autoQuick:populateOptions()
```

---

### liaTabs

**Purpose**

Tabbed interface system that organizes content into multiple tabs with smooth animations and modern styling options. Supports both horizontal and vertical tab layouts.

**When Called**

This panel is called when:
- Creating tabbed user interfaces
- Organizing content into multiple sections
- Managing complex UI layouts with multiple views
- Providing navigation between different content areas

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `AddTab(name, pan, icon)` – adds a new tab with name, content panel, and optional icon.
- `SetTabStyle(style)` – sets the tab style ("modern" or "classic").
- `SetTabHeight(height)` – sets the height of the tab bar.
- `SetIndicatorHeight(height)` – sets the height of the active tab indicator.

**Example Usage**

```lua
-- Create a tabbed interface
local tabs = vgui.Create("liaTabs")
tabs:SetSize(500, 400)

-- Add tabs with content panels
local tab1 = vgui.Create("DPanel")
tab1:SetBackgroundColor(Color(255, 0, 0))
tabs:AddTab("Tab 1", tab1)

local tab2 = vgui.Create("DPanel")
tab2:SetBackgroundColor(Color(0, 255, 0))
tabs:AddTab("Tab 2", tab2, "icon16/user.png")

local tab3 = vgui.Create("DPanel")
tab3:SetBackgroundColor(Color(0, 0, 255))
tabs:AddTab("Tab 3", tab3)
```

---

### liaCategory

**Purpose**

Category panel for organizing content into collapsible sections with headers and optional icons.

**When Called**

This panel is called when:
- Creating collapsible content sections
- Organizing UI elements into categories
- Managing hierarchical content displays
- Providing expandable interface sections

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a category panel
local category = vgui.Create("liaCategory")
category:SetSize(300, 200)

-- Set category header
category:SetHeader("Settings Category")
category:SetIcon("icon16/cog.png")

-- Add content to the category
local content = vgui.Create("DPanel", category)
content:Dock(FILL)
content:SetBackgroundColor(Color(240, 240, 240))
```

---

### liaComboBox

**Purpose**

Dropdown selection panel that displays a list of options in an animated popup menu. Supports placeholder text and custom selection callbacks.

**When Called**

This panel is called when:
- Creating dropdown selection interfaces
- Managing option lists with limited space
- Providing searchable selection controls
- Implementing compact choice interfaces

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `AddChoice(text, data)` – adds a new option to the dropdown list.
- `SetValue(val)` – sets the currently selected value.
- `GetValue()` – returns the currently selected value.
- `SetPlaceholder(text)` – sets the placeholder text shown when no option is selected.

**Example Usage**

```lua
-- Create a combo box
local comboBox = vgui.Create("liaComboBox")
comboBox:SetSize(200, 26)
comboBox:SetPlaceholder("Select an option")

-- Add choices
comboBox:AddChoice("Option 1", {id = 1})
comboBox:AddChoice("Option 2", {id = 2})
comboBox:AddChoice("Option 3", {id = 3})

-- Set selection callback
comboBox.OnSelect = function(index, text, data)
    print("Selected:", text, "with data:", data)
end
```

---

### liaDermaMenu

**Purpose**

Context menu system that displays a list of options with support for submenus, icons, and custom data. Features smooth animations and proper menu positioning.

**When Called**

This panel is called when:
- Creating context menus
- Managing right-click interfaces
- Providing nested menu options
- Implementing popup selection menus

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `AddOption(text, func, icon, optData)` – adds a menu option with text, callback function, icon, and optional data.
- `AddSubMenu()` – creates and returns a submenu panel that can be attached to an option.
- `AddSpacer()` – adds a visual separator line between menu sections.
- `UpdateSize()` – recalculates the menu size based on its contents.

**Example Usage**

```lua
-- Create a context menu
local menu = vgui.Create("liaDermaMenu")

-- Add menu options
menu:AddOption("Option 1", function() print("Option 1 selected") end, "icon16/application.png")
menu:AddSpacer()
menu:AddOption("Option 2", function() print("Option 2 selected") end)

-- Create submenu
local submenu = menu:AddOption("Submenu", nil, "icon16/folder.png")
submenu:AddSubMenu():AddOption("Sub-option 1", function() print("Sub-option 1") end)
submenu:AddSubMenu():AddOption("Sub-option 2", function() print("Sub-option 2") end)
```

---

### liaPlayerSelector

**Purpose**

Player selection interface that displays all players with their avatars, names, and status information. Supports custom validation and selection callbacks.

**When Called**

This panel is called when:
- Selecting players from the server
- Creating player management interfaces
- Providing player selection dialogs
- Managing multiplayer interactions

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetTitle(title)` – sets the selector title.
- `SetCheckFunc(func)` – sets a validation function for player selection.
- `GetSelectedPlayer()` – returns the currently selected player.
- `RefreshPlayers()` – refreshes the player list.

**Example Usage**

```lua
-- Create a player selector
local selector = vgui.Create("liaPlayerSelector")
selector:SetSize(340, 398)
selector:Center()
selector:MakePopup()

-- Set validation function
selector:SetCheckFunc(function(player)
    return player ~= LocalPlayer() -- Can't select self
end)

-- Set selection callback
selector.OnAction = function(player)
    print("Selected player:", player:Name())
end
```

---

### liaRadialPanel

**Purpose**

Circular radial menu system that displays options in a wheel pattern around a center point. Supports keyboard shortcuts, submenus, and smooth animations.

**When Called**

This panel is called when:
- Creating radial selection interfaces
- Managing quick action menus
- Providing circular navigation options
- Implementing wheel-based selection systems

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `AddOption(text, func, icon, desc, submenu)` – adds a radial menu option.
- `AddSubMenuOption(text, submenu, icon, desc)` – adds an option with a submenu.
- `CreateSubMenu(title, desc)` – creates a new submenu.
- `SetCenterText(title, desc)` – sets the center text and description.

**Example Usage**

```lua
-- Create a radial menu
local radialMenu = vgui.Create("liaRadialPanel")

-- Add options
radialMenu:AddOption("Option 1", function() print("Option 1") end, "icon16/star.png", "First option")
radialMenu:AddOption("Option 2", function() print("Option 2") end, "icon16/heart.png", "Second option")

-- Add submenu option
local submenu = radialMenu:CreateSubMenu("Actions", "Choose an action")
submenu:AddOption("Attack", function() print("Attack") end)
submenu:AddOption("Defend", function() print("Defend") end)
radialMenu:AddSubMenuOption("Actions", submenu, "icon16/folder.png", "Action submenu")
```

---

### liaSlideBox

**Purpose**

Dual-purpose panel that can function as either a numeric slider with range controls or a slide container for displaying multiple content panels with navigation.

**When Called**

This panel is called when:
- Creating numeric slider controls
- Managing slide-based content displays
- Providing value selection interfaces
- Implementing multi-slide presentations

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetRange(min_value, max_value, decimals)` – configures the slider range and decimal precision.
- `SetConvar(convar)` – binds the slider to a console variable.
- `SetText(text)` – sets the slider label text.
- `SetValue(val, fromConVar)` – sets the slider value.
- `GetValue()` – returns the current slider value.
- `AddSlide(panel)` – adds a slide panel to the container.
- `NextSlide()` – advances to the next slide.
- `PreviousSlide()` – goes to the previous slide.

**Example Usage**

```lua
-- Create a slider
local slider = vgui.Create("liaSlideBox")
slider:SetSize(300, 60)
slider:SetText("Volume")
slider:SetRange(0, 100, 0)

-- Set slider callback
slider.OnValueChanged = function(value)
    print("Volume changed to:", value)
end

-- Or create a slide container
local slideBox = vgui.Create("liaSlideBox")
slideBox:SetSize(400, 300)

-- Add slides
local slide1 = vgui.Create("DPanel")
slide1:SetBackgroundColor(Color(255, 0, 0))
slideBox:AddSlide(slide1)

local slide2 = vgui.Create("DPanel")
slide2:SetBackgroundColor(Color(0, 255, 0))
slideBox:AddSlide(slide2)
```

---

### liaColorPicker

**Purpose**

Interactive color picker that allows users to select colors using HSV (Hue, Saturation, Value) color model. Features a color field, hue slider, and preview panel with real-time updates.

**When Called**

This panel is called when:
- Selecting colors for UI customization
- Choosing colors for character creation
- Managing color-based configuration options
- Providing interactive color selection interfaces

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetColor(color)` – sets the initial color to display and edit.
- `GetColor()` – returns the currently selected color.
- `OnCallback(callback)` – sets a callback function that is called when a color is selected.

**Example Usage**

```lua
-- Create a color picker
local colorPicker = vgui.Create("liaColorPicker")
colorPicker:SetSize(400, 300)
colorPicker:Center()
colorPicker:MakePopup()

-- Set initial color
colorPicker:SetColor(Color(255, 100, 50))

-- Set callback for when color is selected
colorPicker:OnCallback(function(color)
    print("Selected color:", color.r, color.g, color.b)
end)
```

---

### liaTextBox

**Purpose**

Enhanced text input panel with multiline support, formatting options, and custom styling. Built on `liaFrame` for consistent theming.

**When Called**

This panel is called when:
- Creating multiline text input interfaces
- Managing formatted text entry
- Providing rich text editing capabilities
- Implementing comment or description fields

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a text box
local textBox = vgui.Create("liaTextBox")
textBox:SetSize(400, 200)
textBox:Center()
textBox:MakePopup()

-- Set initial text
textBox:SetText("Enter your description here...")

-- Get text content
local content = textBox:GetText()
print("Text content:", content)
```

---

### liaEntry

**Purpose**

Enhanced text entry field with validation, formatting, and styling options. Supports placeholder text and input restrictions.

**When Called**

This panel is called when:
- Creating single-line text input fields
- Managing validated user input
- Providing formatted input controls
- Implementing search or filter inputs

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create an entry field
local entry = vgui.Create("liaEntry")
entry:SetSize(300, 30)
entry:SetPlaceholder("Enter your name...")

-- Set validation
entry.OnValidate = function(text)
    return string.len(text) >= 3, "Name must be at least 3 characters"
end

-- Handle text changes
entry.OnChange = function(text)
    print("Text changed to:", text)
end
```

---

### liaSimpleCheckbox

**Purpose**

Checkbox that paints the same checkmark icons used in the configuration menu.

**When Called**

This panel is called when:
- Creating boolean selection controls
- Managing option toggles
- Providing simple on/off interfaces
- Implementing configuration checkboxes

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetChecked(state)` – toggles the checkmark and fires `OnChange`.
- `GetChecked()` – returns whether the box is checked.
- `DoClick()` – default click handler that flips the checked state.

**Example Usage**

```lua
-- Create a simple checkbox
local checkbox = vgui.Create("liaSimpleCheckbox")
checkbox:SetSize(200, 30)
checkbox:SetPos(10, 10)

-- Set initial state
checkbox:SetChecked(true)

-- Listen for changes
checkbox.OnChange = function(panel, state)
    print("Checkbox state changed to:", state)
end

-- Manual click handling
checkbox.DoClick = function()
    print("Checkbox was clicked!")
    checkbox:SetChecked(not checkbox:GetChecked())
end
```

---

### liaCheckBox

**Purpose**

Advanced checkbox panel with custom styling and grouping support for complex selection interfaces.

**When Called**

This panel is called when:
- Creating grouped checkbox controls
- Managing complex selection interfaces
- Providing advanced boolean input options
- Implementing multi-option selection systems

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a checkbox
local checkbox = vgui.Create("liaCheckBox")
checkbox:SetSize(200, 30)
checkbox:SetText("Enable Feature")

-- Set up grouping
checkbox:SetGroup("feature_group")
checkbox.OnToggled = function(checked)
    print("Feature toggled:", checked)
end
```

---

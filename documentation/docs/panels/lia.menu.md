# Menu and Navigation Panel Library

This page documents the menu and navigation panel components for the Lilia framework.

---

## Overview

The menu and navigation panel library provides a comprehensive set of UI components for creating menus, tabbed interfaces, navigation systems, and interactive dialogs. These panels handle menu creation, tab management, sheet organization, and navigation controls.

---

### liaMenu

**Purpose**

Main menu panel that provides navigation and organization for game menus and interfaces.

**When Called**

This panel is called when:
- Main game menus need to be displayed
- Navigation interfaces are required
- Menu organization and management is needed

**Parameters**

* `title` (*string*): Menu title text.
* `width` (*number*): Menu width in pixels.
* `height` (*number*): Menu height in pixels.

**Returns**

* `panel` (*Panel*): The created menu panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create main game menu
local menu = vgui.Create("liaMenu")
menu:setTitle("Game Menu")
menu:setSize(800, 600)

-- Add menu sections
menu:addSection("Settings")
menu:addSection("Controls")
```

---

### liaTabButton

**Purpose**

Individual tab button component with hover effects and click handling for tabbed interfaces.

**When Called**

This panel is called when:
- Tab navigation buttons are needed
- Custom tab interfaces are being built
- Tab selection controls are required

**Parameters**

* `text` (*string*): Button text label.
* `icon` (*string|IMaterial*): Optional icon for the button.
* `callback` (*function*): Function to call when clicked.

**Returns**

* `panel` (*Panel*): The created tab button panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create tab button
local tabBtn = vgui.Create("liaTabButton")
tabBtn:setText("Settings")
tabBtn:setDoClick(function()
    print("Settings tab clicked!")
end)

-- Create tab button with icon
local iconTab = vgui.Create("liaTabButton")
iconTab:setText("Inventory")
iconTab:setIcon("icon16/package.png")
```

---

### liaTabs

**Purpose**

Tabbed interface panel that manages multiple content panels with tab navigation.

**When Called**

This panel is called when:
- Multi-tabbed interfaces are needed
- Content organization by tabs is required
- Tab-based navigation is implemented

**Parameters**

* `tabHeight` (*number*): Height of tab buttons.
* `indicatorHeight` (*number*): Height of active tab indicator.
* `animationSpeed` (*number*): Tab switching animation speed.

**Returns**

* `panel` (*Panel*): The created tabs panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create tabbed interface
local tabs = vgui.Create("liaTabs")
tabs:setTabHeight(40)
tabs:setIndicatorHeight(3)

-- Add tabs with content
tabs:addTab("General", generalPanel)
tabs:addTab("Advanced", advancedPanel)
tabs:addTab("About", aboutPanel)

-- Set active tab
tabs:setActiveTab(2)
```

---

### liaSheet

**Purpose**

Sheet panel for organizing content in a structured, document-like layout.

**When Called**

This panel is called when:
- Document-like interfaces are needed
- Content needs to be organized in sheets
- Structured content presentation is required

**Parameters**

* `title` (*string*): Sheet title.
* `content` (*table*): Content sections for the sheet.
* `collapsible` (*boolean*): Whether sections can be collapsed.

**Returns**

* `panel` (*Panel*): The created sheet panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create content sheet
local sheet = vgui.Create("liaSheet")
sheet:setTitle("Character Information")

-- Add sections
sheet:addSection("Basic Info", basicInfoPanel)
sheet:addSection("Attributes", attributesPanel)
sheet:addSection("Inventory", inventoryPanel)
```

---

### liaDermaMenu

**Purpose**

Context menu panel with submenu support and keyboard navigation.

**When Called**

This panel is called when:
- Context menus need to be displayed
- Right-click menus are required
- Hierarchical menu structures are needed

**Parameters**

* `x` (*number*): X position for menu display.
* `y` (*number*): Y position for menu display.
* `deleteOnClose` (*boolean*): Whether to delete menu when closed.

**Returns**

* `panel` (*Panel*): The created derma menu panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create context menu
local menu = vgui.Create("liaDermaMenu")

-- Add menu options
menu:addOption("Copy", function() print("Copy selected") end)
menu:addOption("Paste", function() print("Paste selected") end)
menu:addSeparator()
menu:addOption("Delete", function() print("Delete selected") end)

-- Show menu at mouse position
menu:Open()
```

---

### liaHorizontalScroll

**Purpose**

Horizontal scrolling panel for content that exceeds container width.

**When Called**

This panel is called when:
- Horizontal scrolling content is needed
- Wide content needs to be contained
- Scrollable horizontal layouts are required

**Parameters**

* `contentWidth` (*number*): Width of scrollable content.
* `showScrollbar` (*boolean*): Whether to show horizontal scrollbar.

**Returns**

* `panel` (*Panel*): The created horizontal scroll panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create horizontal scrolling panel
local hScroll = vgui.Create("liaHorizontalScroll")
hScroll:setContentWidth(1200)

-- Add wide content
for i = 1, 20 do
    local item = hScroll:addItem("Item " .. i)
    item:setSize(100, 50)
end
```

---

### liaHorizontalScrollBar

**Purpose**

Horizontal scrollbar component for custom scrollable interfaces.

**When Called**

This panel is called when:
- Custom horizontal scrolling controls are needed
- Manual scrollbar control is required
- Horizontal scroll indicators are needed

**Parameters**

* `orientation` (*string*): Scrollbar orientation ("horizontal").
* `visible` (*boolean*): Whether scrollbar is visible.

**Returns**

* `panel` (*Panel*): The created horizontal scrollbar panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create horizontal scrollbar
local hScrollbar = vgui.Create("liaHorizontalScrollBar")
hScrollbar:setOrientation("horizontal")
hScrollbar:setVisible(true)

-- Connect to scroll panel
hScrollbar:setScrollPanel(scrollPanel)
```

---

### liaRadialPanel

**Purpose**

Circular panel layout for radial menus and circular interface elements.

**When Called**

This panel is called when:
- Radial menu interfaces are needed
- Circular layout arrangements are required
- Radial selection interfaces are implemented

**Parameters**

* `radius` (*number*): Radius of the radial layout.
* `centerX` (*number*): Center X position.
* `centerY` (*number*): Center Y position.

**Returns**

* `panel` (*Panel*): The created radial panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create radial menu
local radial = vgui.Create("liaRadialPanel")
radial:setRadius(150)
radial:setCenter(ScrW() / 2, ScrH() / 2)

-- Add radial items
radial:addRadialItem("Option 1", 0)
radial:addRadialItem("Option 2", 90)
radial:addRadialItem("Option 3", 180)
radial:addRadialItem("Option 4", 270)
```

---

### liaSlideBox

**Purpose**

Sliding panel interface for smooth transitions between content panels.

**When Called**

This panel is called when:
- Sliding content transitions are needed
- Smooth panel animations are required
- Slide-based navigation is implemented

**Parameters**

* `slideDirection` (*string*): Direction of slide animation.
* `slideSpeed` (*number*): Speed of slide animation.
* `panels` (*table*): Array of panels to slide between.

**Returns**

* `panel` (*Panel*): The created slide box panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create sliding interface
local slideBox = vgui.Create("liaSlideBox")
slideBox:setSlideDirection("horizontal")
slideBox:setSlideSpeed(10)

-- Add panels to slide between
slideBox:addPanel(panel1)
slideBox:addPanel(panel2)
slideBox:addPanel(panel3)

-- Navigate between panels
slideBox:slideToPanel(2)
```

---

### liaQuick

**Purpose**

Quick settings panel for rapid configuration and option management.

**When Called**

This panel is called when:
- Quick settings access is needed
- Rapid configuration changes are required
- Quick access to common options is needed

**Parameters**

* `options` (*table*): Quick settings options to display.
* `categories` (*table*): Option categories for organization.

**Returns**

* `panel` (*Panel*): The created quick settings panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create quick settings panel
local quick = vgui.Create("liaQuick")
quick:addCategory("Display")
quick:addCategory("Audio")
quick:addCategory("Controls")

-- Populate with options
quick:addSlider("Volume", 0, 100, 50)
quick:addCheckbox("Show FPS", true)
quick:addButton("Reset Settings", function() end)
```

---

### liaSpawnIcon

**Purpose**

Icon panel for spawnable entities and items with visual representation.

**When Called**

This panel is called when:
- Spawn menu icons are needed
- Entity spawn interfaces are created
- Visual spawn selection is required

**Parameters**

* `model` (*string*): Model path for the spawn icon.
* `size` (*number*): Icon size in pixels.
* `spawnFunction` (*function*): Function to call when spawned.

**Returns**

* `panel` (*Panel*): The created spawn icon panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create spawn icon for model
local spawnIcon = vgui.Create("liaSpawnIcon")
spawnIcon:setModel("models/props/cs_office/chair_office.mdl")
spawnIcon:setSize(64, 64)

-- Handle spawn action
spawnIcon:setSpawnFunction(function()
    RunConsoleCommand("gm_spawn", "models/props/cs_office/chair_office.mdl")
end)
```

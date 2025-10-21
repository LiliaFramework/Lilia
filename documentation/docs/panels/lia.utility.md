# Utility and Helper Panel Library

This page documents the utility and helper panel components for the Lilia framework.

---

## Overview

The utility and helper panel library provides essential UI components for data display, scrolling, numerical input, and various interface utilities. These panels handle list views, tables, scrollable content, and numerical controls.

---

### liaDListView

**Purpose**

Advanced list view panel with search functionality, sorting, and data management capabilities.

**When Called**

This panel is called when:
- Tabular data needs to be displayed with search and sort
- Administrative interfaces need data browsing
- Complex list management is required

**Parameters**

* `columns` (*table*): Column definitions for the list.
* `data` (*table*): Data rows to display.
* `searchable` (*boolean*): Whether search functionality is enabled.
* `sortable` (*boolean*): Whether columns are sortable.

**Returns**

* `panel` (*Panel*): The created list view panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create searchable list view
local listView = vgui.Create("liaDListView")
listView:setTitle("Player List")
listView:setColumns({"Name", "SteamID", "Playtime"})

-- Add data rows
listView:addRow("John Doe", "STEAM_0:1:12345", "2h 30m")
listView:addRow("Jane Smith", "STEAM_0:1:67890", "1h 15m")

-- Enable search
listView:setSearchable(true)

-- Handle row selection
listView.onRowSelected = function(rowIndex, rowData)
    print("Selected: " .. rowData[1])
end
```

---

### liaTable

**Purpose**

Customizable table panel with sorting, selection, and advanced data display features.

**When Called**

This panel is called when:
- Custom table layouts are needed
- Sortable tabular data display is required
- Advanced table interactions are needed

**Parameters**

* `columns` (*table*): Column configuration with names, widths, and alignment.
* `data` (*table*): Table data as array of arrays.
* `sortable` (*boolean*): Whether table supports column sorting.
* `multiSelect` (*boolean*): Whether multiple row selection is allowed.

**Returns**

* `panel` (*Panel*): The created table panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create sortable table
local table = vgui.Create("liaTable")
table:addColumn("Name", 200, TEXT_ALIGN_LEFT, true)
table:addColumn("Score", 100, TEXT_ALIGN_CENTER, true)
table:addColumn("Status", 120, TEXT_ALIGN_RIGHT, false)

-- Add data rows
table:addRow("Player 1", "1500", "Online")
table:addRow("Player 2", "1200", "Away")
table:addRow("Player 3", "1800", "Online")

-- Handle row selection
table.onRowSelected = function(rowIndex, rowData)
    print("Selected row " .. rowIndex .. ": " .. rowData[1])
end

-- Sort by score column
table:sortByColumn(2, true) -- Column 2 (Score), descending
```

---

### liaScrollPanel

**Purpose**

Custom scrollable panel with styled scrollbars and smooth scrolling behavior.

**When Called**

This panel is called when:
- Content needs to be scrollable with custom styling
- Smooth scrolling behavior is required
- Custom scrollbar appearance is needed

**Parameters**

* `contentWidth` (*number*): Width of scrollable content.
* `contentHeight` (*number*): Height of scrollable content.
* `autoHideBars` (*boolean*): Whether scrollbars auto-hide when not needed.

**Returns**

* `panel` (*Panel*): The created scroll panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create scrollable content area
local scrollPanel = vgui.Create("liaScrollPanel")
scrollPanel:setSize(400, 300)

-- Add content that exceeds panel size
for i = 1, 20 do
    local item = scrollPanel:add("DLabel")
    item:setText("Item " .. i)
    item:setTall(30)
    item:dock(TOP)
end

-- Customize scrollbar appearance
local vbar = scrollPanel:getVBar()
vbar:setWide(8)
vbar:setHideButtons(true)
```

---

### liaNumSlider

**Purpose**

Numerical slider control with visual feedback, hover effects, and precise value control.

**When Called**

This panel is called when:
- Numerical value input with visual slider is needed
- Precise value adjustment is required
- Interactive numerical controls are needed

**Parameters**

* `min` (*number*): Minimum slider value.
* `max` (*number*): Maximum slider value.
* `default` (*number*): Default/initial value.
* `decimals` (*number*): Number of decimal places for display.

**Returns**

* `panel` (*Panel*): The created number slider panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create volume slider
local volumeSlider = vgui.Create("liaNumSlider")
volumeSlider:setMin(0)
volumeSlider:setMax(100)
volumeSlider:setValue(50)
volumeSlider:setDecimals(0)
volumeSlider:setText("Volume")

-- Handle value changes
volumeSlider.onValueChanged = function(value)
    print("Volume set to: " .. value)
    -- Apply volume change
    LocalPlayer():SetVolume(value / 100)
end

-- Create precision slider for settings
local precisionSlider = vgui.Create("liaNumSlider")
precisionSlider:setMin(0.1)
precisionSlider:setMax(5.0)
precisionSlider:setValue(1.5)
precisionSlider:setDecimals(2)
precisionSlider:setText("Mouse Sensitivity")
```

---

### liaCategory

**Purpose**

Category panel for organizing content into collapsible sections.

**When Called**

This panel is called when:
- Content needs to be organized into categories
- Collapsible sections are required
- Hierarchical content organization is needed

**Parameters**

* `title` (*string*): Category title text.
* `expanded` (*boolean*): Whether category starts expanded.
* `content` (*table*): Content panels for the category.

**Returns**

* `panel` (*Panel*): The created category panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create collapsible category
local category = vgui.Create("liaCategory")
category:setTitle("Player Settings")
category:setExpanded(true)

-- Add content to category
category:addContent(playerNamePanel)
category:addContent(playerAvatarPanel)
category:addContent(playerStatsPanel)

-- Handle category toggle
category.onToggle = function(expanded)
    print("Category " .. (expanded and "expanded" or "collapsed"))
end
```

---

### liaDoorMenu

**Purpose**

Specialized interface for door management and door-related interactions.

**When Called**

This panel is called when:
- Door ownership and permissions need to be managed
- Door purchasing/selling interfaces are required
- Door access control is needed

**Parameters**

* `doorEntity` (*Entity*): Door entity to manage.
* `doorData` (*table*): Door configuration and ownership data.
* `playerPermissions` (*table*): Player's door permissions.

**Returns**

* `panel` (*Panel*): The created door menu panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create door management interface
local doorMenu = vgui.Create("liaDoorMenu")
doorMenu:setDoor(doorEntity)
doorMenu:setDoorData(doorInfo)

-- Add door owner
doorMenu:addOwner(player)
doorMenu:addOwner(player2)

-- Set door title
doorMenu:setTitle("Main Entrance")

-- Handle door purchase
doorMenu.onPurchase = function(price)
    print("Door purchased for $" .. price)
end
```

---

### liaComboBox

**Purpose**

Dropdown selection control with multiple options and customizable appearance.

**When Called**

This panel is called when:
- Multiple choice selection is needed
- Dropdown menus are required
- Option selection with visual feedback is needed

**Parameters**

* `options` (*table*): Array of available options.
* `default` (*string|number*): Default selected option.
* `placeholder` (*string*): Placeholder text when nothing selected.

**Returns**

* `panel` (*Panel*): The created combo box panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create dropdown selection
local comboBox = vgui.Create("liaComboBox")
comboBox:addOption("Option 1", "opt1")
comboBox:addOption("Option 2", "opt2")
comboBox:addOption("Option 3", "opt3")
comboBox:setValue("opt2") -- Select option 2

-- Handle selection changes
comboBox.onSelect = function(selected, data)
    print("Selected: " .. selected .. " (data: " .. (data or "none") .. ")")
end

-- Create faction selection dropdown
local factionBox = vgui.Create("liaComboBox")
for factionID, faction in pairs(lia.faction.indices) do
    factionBox:addOption(faction.name, factionID)
end
```

---

### liaMarkupPanel

**Purpose**

Rich text display panel with markup parsing and advanced text formatting.

**When Called**

This panel is called when:
- Rich text content needs to be displayed
- Markup formatting and parsing is required
- Advanced text rendering with colors and styles is needed

**Parameters**

* `text` (*string*): Markup text content to display.
* `maxWidth` (*number*): Maximum display width for text wrapping.
* `font` (*string*): Font to use for text rendering.

**Returns**

* `panel` (*Panel*): The created markup panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create rich text display
local markup = vgui.Create("liaMarkupPanel")
markup:setText("[color=red]Error:[/color] This is an error message")
markup:setMaxWidth(400)
markup:setFont("liaMediumFont")

-- Update markup content
markup:setMarkup("[b]Bold text[/b] and [i]italic text[/i] with [color=blue]colors[/color]")

-- Handle markup links
markup.onLinkClick = function(url)
    gui.OpenURL(url)
end
```

---

### liaPrivilegeRow

**Purpose**

Row component for displaying and managing user privileges in administrative interfaces.

**When Called**

This panel is called when:
- Individual privilege management is needed
- Administrative privilege assignment is required
- Privilege display in user management interfaces

**Parameters**

* `privilege` (*string*): Privilege identifier.
* `privilegeData` (*table*): Privilege configuration and description.
* `userGroups` (*table*): User groups that have this privilege.

**Returns**

* `panel` (*Panel*): The created privilege row panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create privilege management row
local privilegeRow = vgui.Create("liaPrivilegeRow")
privilegeRow:setPrivilege("manage_users")
privilegeRow:setPrivilegeData({
    name = "Manage Users",
    desc = "Can manage user accounts and permissions"
})

-- Set user groups with this privilege
privilegeRow:setUserGroups({"admin", "moderator"})

-- Handle privilege changes
privilegeRow.onToggle = function(enabled, userGroup)
    print("Privilege " .. (enabled and "enabled" or "disabled") .. " for " .. userGroup)
end
```

---

### liaUserGroupButton

**Purpose**

Button component for user group management and assignment interfaces.

**When Called**

This panel is called when:
- User group selection buttons are needed
- Group management interfaces are created
- User group assignment controls are required

**Parameters**

* `groupID` (*string*): User group identifier.
* `groupData` (*table*): User group configuration and permissions.
* `isSelected` (*boolean*): Whether this group is currently selected.

**Returns**

* `panel` (*Panel*): The created user group button panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create user group selection button
local groupButton = vgui.Create("liaUserGroupButton")
groupButton:setGroup("admin")
groupButton:setGroupData({
    name = "Administrator",
    color = Color(255, 100, 100),
    permissions = {"kick", "ban", "manage_users"}
})

-- Handle group selection
groupButton.onSelect = function(groupID)
    print("Selected group: " .. groupID)
end
```

---

### liaUserGroupList

**Purpose**

List panel for displaying and managing multiple user groups and their members.

**When Called**

This panel is called when:
- User group overview is needed
- Group member management is required
- Administrative group management interfaces are needed

**Parameters**

* `groups` (*table*): Array of user groups to display.
* `showMembers` (*boolean*): Whether to show group members.
* `editable` (*boolean*): Whether groups can be edited.

**Returns**

* `panel` (*Panel*): The created user group list panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create user group management list
local groupList = vgui.Create("liaUserGroupList")
groupList:setGroups(allUserGroups)
groupList:setShowMembers(true)
groupList:setEditable(true)

-- Handle group editing
groupList.onGroupEdit = function(groupID, groupData)
    -- Open group editor
    local editor = vgui.Create("liaUserGroupEditor")
    editor:setGroup(groupID, groupData)
end

-- Handle member management
groupList.onMemberManage = function(groupID, member)
    print("Managing member " .. member .. " in group " .. groupID)
end
```

---

### liaSemiTransparentDFrame

**Purpose**

Semi-transparent frame panel with background blur for modal dialogs.

**When Called**

This panel is called when:
- Modal dialogs need background transparency
- Background blur effects are desired
- Semi-transparent overlays are needed

**Parameters**

* `title` (*string*): Frame title text.
* `blurAmount` (*number*): Background blur intensity.
* `transparency` (*number*): Frame transparency level (0-255).

**Returns**

* `panel` (*Panel*): The created semi-transparent frame panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create semi-transparent modal dialog
local dialog = vgui.Create("liaSemiTransparentDFrame")
dialog:setTitle("Confirmation")
dialog:setSize(400, 200)
dialog:setBlurAmount(5)
dialog:setTransparency(200)
dialog:center()

-- Add dialog content
local message = dialog:add("DLabel")
message:setText("Are you sure you want to delete this item?")
message:setContentAlignment(5)
message:dock(TOP)

-- Add confirmation buttons
local buttonPanel = dialog:add("DPanel")
buttonPanel:dock(BOTTOM)
buttonPanel:setTall(40)

local yesBtn = buttonPanel:add("liaButton")
yesBtn:setText("Yes")
yesBtn:dock(LEFT)
yesBtn:setWide(100)

local noBtn = buttonPanel:add("liaButton")
noBtn:setText("No")
noBtn:dock(RIGHT)
noBtn:setWide(100)
```

---

### liaSemiTransparentDPanel

**Purpose**

Semi-transparent panel component for overlay elements and backgrounds.

**When Called**

This panel is called when:
- Semi-transparent backgrounds are needed
- Overlay elements require transparency
- Panel backgrounds need blur effects

**Parameters**

* `transparency` (*number*): Panel transparency level (0-255).
* `blurBackground` (*boolean*): Whether to blur background content.

**Returns**

* `panel` (*Panel*): The created semi-transparent panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create semi-transparent overlay
local overlay = vgui.Create("liaSemiTransparentDPanel")
overlay:setSize(ScrW(), ScrH())
overlay:setTransparency(150)
overlay:setBlurBackground(true)

-- Add overlay content
local message = overlay:add("DLabel")
message:setText("Loading...")
message:setFont("liaBigFont")
message:setTextColor(Color(255, 255, 255))
message:center()
```

---

### liaBlurredDFrame

**Purpose**

Frame panel with background blur effect for modal interfaces.

**When Called**

This panel is called when:
- Modal frames need background blur
- Focus isolation with blur effects is required
- Dialog boxes need visual separation from background

**Parameters**

* `title` (*string*): Frame title text.
* `blurPasses` (*number*): Number of blur passes for background.
* `blurAmount` (*number*): Blur intensity level.

**Returns**

* `panel` (*Panel*): The created blurred frame panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create blurred modal frame
local modalFrame = vgui.Create("liaBlurredDFrame")
modalFrame:setTitle("Settings")
modalFrame:setSize(600, 400)
modalFrame:setBlurPasses(3)
modalFrame:setBlurAmount(8)
modalFrame:center()

-- Add modal content
local settingsList = modalFrame:add("liaScrollPanel")
settingsList:dock(FILL)

-- Add various setting controls
settingsList:add("liaNumSlider"):setText("Volume"):setValue(75)
settingsList:add("liaCheckbox"):setText("Show FPS"):setChecked(true)
```

---

### liaVoicePanel

**Purpose**

Voice chat interface panel for displaying speaking players and voice controls.

**When Called**

This panel is called when:
- Voice chat indicators need to be displayed
- Speaking player visualization is required
- Voice chat controls and settings are needed

**Parameters**

* `voiceData` (*table*): Voice chat status and player data.
* `showControls` (*boolean*): Whether to show voice controls.
* `maxPlayers` (*number*): Maximum players to display.

**Returns**

* `panel` (*Panel*): The created voice panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create voice chat panel
local voicePanel = vgui.Create("liaVoicePanel")
voicePanel:setPosition(ScrW() - 200, ScrH() - 300)
voicePanel:setSize(180, 250)

-- Update voice data
voicePanel:updateVoiceData({
    [player1] = {speaking = true, volume = 0.8},
    [player2] = {speaking = false, volume = 0.5}
})

-- Handle voice controls
voicePanel.onMuteToggle = function(player)
    print("Toggled mute for " .. player:Nick())
end
```

---

### liaFacingModelPanel

**Purpose**

3D model display panel with mouse tracking and interactive model viewing.

**When Called**

This panel is called when:
- Interactive 3D model display is needed
- Mouse-look model interaction is required
- Character preview with head tracking is needed

**Parameters**

* `model` (*string*): Model path to display.
* `brightness` (*number*): Model lighting brightness.
* `interactive` (*boolean*): Whether mouse interaction is enabled.

**Returns**

* `panel` (*Panel*): The created facing model panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create interactive model viewer
local modelViewer = vgui.Create("liaFacingModelPanel")
modelViewer:setModel("models/player/group01/male_01.mdl")
modelViewer:setBrightness(1.2)
modelViewer:setInteractive(true)
modelViewer:setSize(300, 400)

-- Handle model interactions
modelViewer.onModelClick = function()
    print("Model clicked!")
end

-- Update model animation
modelViewer:playSequence("idle")
```

---

### liaCategory

**Purpose**

Collapsible category panel for organizing content into expandable sections.

**When Called**

This panel is called when:
- Content organization into categories is needed
- Collapsible sections with headers are required
- Hierarchical content display is needed

**Parameters**

* `title` (*string*): Category title text.
* `icon` (*string*): Optional icon for the category.
* `defaultExpanded` (*boolean*): Whether category starts expanded.

**Returns**

* `panel` (*Panel*): The created category panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create collapsible category
local category = vgui.Create("liaCategory")
category:setTitle("Server Settings")
category:setIcon("icon16/cog.png")
category:setExpanded(true)

-- Add category content
category:addContent(serverNamePanel)
category:addContent(serverPasswordPanel)
category:addContent(serverMaxPlayersPanel)

-- Handle category expansion
category.onToggle = function(expanded)
    print("Category " .. (expanded and "expanded" or "collapsed"))
end
```

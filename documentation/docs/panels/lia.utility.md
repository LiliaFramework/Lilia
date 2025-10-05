# Utility Panels Library

A comprehensive collection of utility panels providing various interface components for the Lilia framework.

---

## Overview

The utility panel library provides a wide range of specialized interface components for various framework functions. These panels handle progress indication, scrolling, item management, communication, data display, and other utility functions essential to the Lilia framework's operation.

---

### DProgressBar

**Purpose**

Simple progress bar panel. Update its fraction each frame to visually represent timed actions.

**When Called**

This panel is called when:
- Displaying loading progress or completion status
- Showing timed action progress (e.g., crafting, hacking)
- Creating progress indicators for user feedback
- Implementing countdown or timer displays

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetFraction(fraction)` – sets the current progress fraction between `0` and `1`.
- `SetProgress(startTime, endTime)` – defines the progress window; defaults to a five second duration when no values are provided.
- `SetText(text)` – text displayed in the centre of the bar.
- `SetBarColor(color)` – overrides the default bar colour.

**Example Usage**

```lua
-- Create a progress bar
local progressBar = vgui.Create("DProgressBar")
progressBar:SetSize(300, 30)
progressBar:Center()
progressBar:SetFraction(0.0) -- Start at 0%
progressBar:SetText("Loading...")
progressBar:SetBarColor(Color(0, 255, 0)) -- Green bar

-- Animate the progress
local startTime = CurTime()
local duration = 5 -- 5 seconds

hook.Add("Think", "UpdateProgress", function()
    local elapsed = CurTime() - startTime
    local fraction = math.Clamp(elapsed / duration, 0, 1)
    progressBar:SetFraction(fraction)

    if fraction >= 1 then
        progressBar:SetText("Complete!")
        hook.Remove("Think", "UpdateProgress")
    end
end)

-- Use with SetProgress for automatic timing
local timedBar = vgui.Create("DProgressBar")
timedBar:SetSize(300, 30)
timedBar:SetText("Processing...")
timedBar:SetProgress(CurTime(), CurTime() + 3) -- 3 second duration
```

---

### liaChatBox

**Purpose**

In-game chat window supporting multiple tabs, command prefix detection and color-coded messages.

**When Called**

This panel is called when:
- Displaying in-game chat interface
- Managing player communication
- Providing command input interface
- Creating multi-channel chat system

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `setActive(state)` – opens or closes the chat entry box.
- `addFilterButton(filter)` – inserts a filter toggle for a chat class.
- `addText(...)` – appends one or more strings or colours to the chat history.
- `setFilter(filter, state)` – enables or disables visibility for a chat class.

**Example Usage**

```lua
-- Chat box is automatically created by the framework
-- Access it through lia.chatbox if needed
if lia.chatbox then
    lia.chatbox.addText("Welcome to the server!")
end

-- Programmatically control chat
lia.chatbox.setActive(true) -- Open chat input
lia.chatbox.addText(Color(255, 0, 0), "Error: ", Color(255, 255, 255), "Something went wrong!")
```

---

### liaSpawnIcon

**Purpose**

Improved spawn icon built on `DModelPanel`. It centers models and applies good lighting for use in inventories or lists.

**When Called**

This panel is called when:
- Displaying spawn menu icons
- Creating model previews in lists
- Managing item or entity icons
- Providing visual representation of models

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `setHidden(hidden)` – toggles lighting and colour to hide or reveal the model.
- `OnMousePressed()` – forwards clicks to `DoClick` when defined.

**Example Usage**

```lua
-- Create a spawn icon
local icon = vgui.Create("liaSpawnIcon")
icon:SetSize(64, 64)
icon:SetModel("models/player.mdl")
icon.DoClick = function()
    print("Icon clicked!")
end

-- Use in spawn menu or inventory
icon:setHidden(false) -- Show the model
icon.DoRightClick = function()
    -- Right-click context menu
end
```

---

### VoicePanel

**Purpose**

HUD element that lists players using voice chat. Each entry fades out after a player stops talking.

**When Called**

This panel is called when:
- Displaying voice chat participants
- Managing voice communication interface
- Creating voice activity indicators
- Providing real-time voice status

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `Setup(client)` – initialises the entry with the speaking player.
- `UpdateIcon()` – refreshes the icon based on voice type.
- `FadeOut(anim, delta)` – animation callback used to fade the panel when speech ends.

**Example Usage**

```lua
-- Voice panel is automatically managed by the framework
-- No manual creation needed - it's part of the HUD system

-- Access for custom voice interfaces
local voicePanel = vgui.Create("VoicePanel")
voicePanel:Setup(player) -- Initialize with player
voicePanel:UpdateIcon() -- Refresh icon display
```

---

### liaHorizontalScroll

**Purpose**

Container that arranges child panels in a single row. Often paired with a custom scrollbar when content overflows.

**When Called**

This panel is called when:
- Creating horizontal scrolling interfaces
- Managing wide content in limited space
- Building horizontal navigation menus
- Providing scrollable content containers

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `AddItem(panel)` – parents `panel` to the internal canvas.
- `ScrollToChild(child)` – animates the scrollbar so `child` becomes centred.
- `GetHBar()` – returns the companion horizontal scrollbar panel.
- `Clear()` – removes all child panels from the canvas.

**Example Usage**

```lua
-- Create a horizontal scroll container
local scroll = vgui.Create("liaHorizontalScroll")
scroll:SetSize(400, 100)

-- Add items to the scroll
local item1 = vgui.Create("DPanel")
item1:SetSize(80, 80)
scroll:AddItem(item1)

-- Scroll to specific item
scroll:ScrollToChild(item1)

-- Get scrollbar for custom control
local scrollbar = scroll:GetHBar()
scrollbar:SetScroll(0.5) -- Scroll to 50% position
```

---

### liaHorizontalScrollBar

**Purpose**

Custom scrollbar paired with `liaHorizontalScroll`. It moves the canvas horizontally when items overflow.

**When Called**

This panel is called when:
- Providing horizontal scroll controls
- Managing horizontal navigation
- Creating custom scrollbar interfaces
- Handling horizontal content overflow

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetScroll(offset)` – manually adjusts the scroll position.

**Example Usage**

```lua
-- Usually created automatically with liaHorizontalScroll
-- Access through scroll:GetHBar() if manual control needed
local scroll = vgui.Create("liaHorizontalScroll")
local scrollbar = scroll:GetHBar()
scrollbar:SetScroll(0.5) -- Scroll to 50% position

-- Custom scrollbar behavior
scrollbar.OnScroll = function(self, offset)
    print("Scrolled to:", offset)
end
```

---

### liaItemMenu

**Purpose**

Panel shown when you interact with an item entity. Displays item info and action buttons.

**When Called**

This panel is called when:
- Interacting with world items
- Displaying item context menus
- Managing item interaction interfaces
- Providing item-specific actions

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `addBtn(text, cb)` – helper to append a button that calls `cb` when pressed.
- `openInspect()` – opens a 3D model viewer for the item.
- `buildButtons()` – populates action buttons based on the item's functions table.
- `SetEntity(ent)` – assigns the world entity and refreshes the panel contents.
- `Think()` – closes the menu if the entity becomes invalid or too far away.

**Example Usage**

```lua
-- Called from GM:ItemShowEntityMenu
if IsValid(liaItemMenuInstance) then liaItemMenuInstance:Remove() end
liaItemMenuInstance = vgui.Create("liaItemMenu")
liaItemMenuInstance:SetEntity(entity)

-- Custom item menu
liaItemMenuInstance:addBtn("Use", function()
    entity:UseBy(LocalPlayer())
    liaItemMenuInstance:Remove()
end)
```

---

### liaAttribBar

**Purpose**

Interactive bar used during character creation to assign starting attribute points.

**When Called**

This panel is called when:
- Managing character attribute allocation
- Providing interactive attribute controls
- Creating point distribution interfaces
- Handling character stat customization

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `getValue()` – returns the current value.
- `setValue(v)` – sets the bar to `v`.
- `setBoost(v)` – displays a temporary boost amount.
- `setMax(m)` – changes the maximum allowed value (default `10`).
- `SetText(text)` – sets the label text.
- `setReadOnly()` – removes the increment and decrement buttons.

**Example Usage**

```lua
-- Create an attribute bar
local attribBar = vgui.Create("liaAttribBar")
attribBar:SetSize(200, 30)
attribBar:SetText("Strength")
attribBar:setMax(10)
attribBar:setValue(5)

-- Interactive controls
attribBar.OnValueChanged = function(value)
    print("Attribute value changed to:", value)
end
```

---

### liaRoster

**Purpose**

Lists players in a faction or class roster and supports context actions such as kicking members.

**When Called**

This panel is called when:
- Displaying faction member lists
- Managing class rosters
- Providing administrative member controls
- Creating organizational interfaces

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetRosterType(type)` – chooses which roster to display. Passing `"faction"` requests faction data from the server.
- `Populate(data, canKick)` – fills the sheet with `data` rows and enables kick options when `canKick` is true.
- `PerformLayout()` – sizes the panel to its children and refreshes the internal sheet layout.

**Example Usage**

```lua
-- Create a roster panel
local roster = vgui.Create("liaRoster")
roster:SetSize(400, 300)
roster:SetRosterType("faction")
roster:Populate(rosterData, true) -- true = can kick members

-- Administrative controls
roster.OnMemberKick = function(member)
    print("Kicked member:", member.name)
end
```

---

### liaScoreboard

**Purpose**

Replacement scoreboard that groups players by team or faction and displays additional stats like ping and play time.

**When Called**

This panel is called when:
- Displaying player scoreboards
- Managing team/faction displays
- Providing player statistics
- Creating competitive interfaces

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `ApplyConfig()` – applies skin and colour configuration before showing the board.
- `updateStaff()` – refreshes the staff list portion based on current players.
- `addPlayer(player, parent)` – inserts a player row into the given category panel.

**Example Usage**

```lua
-- Scoreboard is automatically created by the framework
-- No manual creation needed - it's part of the HUD system

-- Access for customization
if lia.gui.scoreboard and IsValid(lia.gui.scoreboard) then
    lia.gui.scoreboard:ApplyConfig()
    lia.gui.scoreboard:updateStaff()
end
```

---

### liaSheet

**Purpose**

Scrollable sheet used to build filterable lists with rows of arbitrary content.

**When Called**

This panel is called when:
- Creating filterable data lists
- Managing searchable interfaces
- Building organized data displays
- Providing flexible content management

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetPlaceholderText(text)` – sets the search box placeholder.
- `SetSpacing(y)` – vertical spacing between rows (default `8`).
- `SetPadding(p)` – padding around row contents (default `10`).
- `Clear()` – removes all rows.
- `AddRow(builder)` – adds a custom row using `builder(panel, row)`; returns the row table.
- `AddPanelRow(widget, opts)` – inserts an existing panel as a row.
- `AddTextRow(data)` – creates a text row from `title`, `desc`, and `right` fields.
- `AddSubsheetRow(cfg)` – adds a collapsible subsheet for grouped entries.
- `AddPreviewRow(data)` – displays an HTML preview thumbnail.
- `AddListViewRow(cfg)` – embeds a `DListView` into a row.
- `AddIconLayoutRow(cfg)` – embeds a `DIconLayout` into a row.
- `RegisterCustomFilter(row, fn)` – registers an extra filter function for `Refresh`.
- `Refresh()` – re-applies the search filter to all rows.

**Example Usage**

```lua
-- Create a sheet
local sheet = vgui.Create("liaSheet")
sheet:SetSize(400, 300)
sheet:SetPlaceholderText("Search...")

-- Add a text row
sheet:AddTextRow({
    title = "Example Item",
    desc = "This is a description",
    right = "Value"
})

-- Add custom row with builder function
sheet:AddRow(function(panel, row)
    local label = vgui.Create("DLabel", panel)
    label:Dock(FILL)
    label:SetText("Custom Row Content")
    return row -- Return the row for filtering
end)

-- Refresh search
sheet:Refresh()
```

---

### liaDoorMenu

**Purpose**

Interface for property doors showing ownership and faction access. Owners can lock, sell or share the door through this menu.

**When Called**

This panel is called when:
- Managing door permissions
- Setting door ownership
- Configuring faction access
- Providing door control interfaces

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `setDoor(door, accessData, fallback)` – populates the list of players with their access levels for `door`.
- `CheckAccess(minimum)` – returns `true` if the local player meets the required access level.
- `Think()` – automatically closes the menu when the door becomes invalid or inaccessible.

**Example Usage**

```lua
-- Door menu is usually created when interacting with a door
-- No manual creation needed - it's part of the door system

-- Programmatic door management
local doorMenu = vgui.Create("liaDoorMenu")
doorMenu:setDoor(doorEntity, accessData)
doorMenu:SetupPermissionControls()
```

---

### liaLoadingFailure

**Purpose**

Error display panel shown when the server fails to load properly. Displays error messages, failure reasons, and provides options for retry or console access.

**When Called**

This panel is called when:
- Handling server loading failures
- Displaying connection errors
- Providing error recovery options
- Managing failed initialization

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetFailureInfo(reason, details)` – sets the failure reason and detailed information.
- `AddError(errorMessage, line, file)` – adds individual error entries to the display.
- `UpdateErrorDisplay()` – refreshes the error information panel.

**Example Usage**

```lua
-- Loading failure panel is automatically shown by the framework
-- when server initialization fails - no manual creation needed

-- Custom error handling
local failurePanel = vgui.Create("liaLoadingFailure")
failurePanel:SetFailureInfo("Connection Failed", "Unable to connect to server")
failurePanel:AddError("Network timeout", 150, "net.lua")
```

---

### liaTable

**Purpose**

Advanced data table component for displaying structured information with sorting, filtering, and column management capabilities.

**When Called**

This panel is called when:
- Creating data tables with multiple columns
- Managing structured information displays
- Providing sortable and filterable data lists
- Implementing complex data organization interfaces

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a data table
local table = vgui.Create("liaTable")
table:SetSize(600, 400)

-- Add columns
table:AddColumn("Name", 200)
table:AddColumn("Age", 100)
table:AddColumn("Status", 150)

-- Add rows
table:AddRow("John Doe", "25", "Active")
table:AddRow("Jane Smith", "30", "Inactive")

-- Set sorting
table:SortByColumn(1, false) -- Sort by name descending
```

---

### liaText

**Purpose**

Enhanced text display panel with formatting support, alignment options, and styling capabilities for rich text presentation.

**When Called**

This panel is called when:
- Displaying formatted text content
- Creating styled text interfaces
- Managing rich text displays
- Providing formatted information presentation

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a text panel
local textPanel = vgui.Create("liaText")
textPanel:SetSize(400, 200)

-- Set formatted text
textPanel:SetText("Welcome to the **server**!\n\n*Features:*\n• Character creation\n• Inventory system\n• Role-playing tools")

-- Set text alignment
textPanel:SetTextAlign(TEXT_ALIGN_CENTER)
textPanel:SetFont("liaMediumFont")
```

---

### liaMarkupPanel

**Purpose**

Panel that renders text using Garry's Mod markup language and wraps `markup.Parse` so formatted chat messages can be displayed easily.

**When Called**

This panel is called when:
- Displaying formatted text with markup formatting
- Rendering rich text content in UI elements
- Showing formatted messages or descriptions
- Creating text-based interfaces with styling

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a markup panel for displaying formatted text
local markupPanel = vgui.Create("liaMarkupPanel")
markupPanel:SetText("This is **bold** and *italic* text!")
markupPanel:SetSize(200, 100)

-- Use in a larger interface
local frame = vgui.Create("DFrame")
frame:SetSize(400, 300)
frame:Center()
frame:MakePopup()

local textPanel = vgui.Create("liaMarkupPanel", frame)
textPanel:Dock(FILL)
textPanel:SetText("Welcome to the server!\n\n**Features:**\n• Character creation\n• Inventory management\n• Role-playing systems")
```

---

### liaItemList

**Purpose**

Generic list frame for displaying items in a structured format. Supports custom columns, data population, and item management.

**When Called**

This panel is called when:
- Creating structured item lists
- Managing item collections with metadata
- Providing organized item displays
- Implementing item management interfaces

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetTitle(title)` – sets the window title.
- `setData(data)` – populates the list with item data.
- `SetColumns(columns)` – defines the column structure.
- `PopulateItems()` – refreshes the list display.

**Example Usage**

```lua
-- Create an item list
local itemList = vgui.Create("liaItemList")
itemList:SetSize(600, 500)
itemList:Center()
itemList:MakePopup()

-- Set columns
itemList:SetColumns({"Item Name", "Value", "Description"})

-- Set data
itemList:setData({
    {"Sword", "100", "A sharp blade"},
    {"Shield", "50", "Protective gear"},
    {"Potion", "25", "Healing item"}
})
```

---

### liaItemSelector

**Purpose**

Item selection dialog with search functionality and filtering capabilities. Allows users to select from a list of items with confirmation buttons.

**When Called**

This panel is called when:
- Selecting items from a collection
- Providing searchable item interfaces
- Creating item selection dialogs
- Managing item choice workflows

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetTitle(title)` – sets the dialog title.
- `setData(data)` – populates the selector with item data.
- `SetColumns(columns)` – defines the column structure.
- `SetActionText(text)` – sets the text for the action button.

**Example Usage**

```lua
-- Create an item selector
local selector = vgui.Create("liaItemSelector")
selector:SetSize(600, 500)
selector:Center()
selector:MakePopup()

-- Configure selector
selector:SetTitle("Select an Item")
selector:SetActionText("Choose Item")
selector:SetColumns({"Item", "Value", "Quantity"})

-- Set selection callback
selector.OnAction = function(line, selectedIndex)
    print("Selected item:", line:GetColumnText(1))
end

-- Populate with data
selector:setData({
    {"Sword", "100", "5"},
    {"Shield", "50", "10"},
    {"Potion", "25", "20"}
})
```

---

### liaDListView

**Purpose**

Enhanced list view with search, sorting, and context menus. Features a search box, refresh button, and status bar showing total count.

**When Called**

This panel is called when:
- Creating advanced list displays
- Managing searchable data collections
- Providing sortable data interfaces
- Implementing complex data management

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Custom Functions**

- `SetWindowTitle(title)` – sets the window title.
- `SetPlaceholderText(text)` – sets the search box placeholder text.
- `SetColumns(columns)` – defines the list columns.
- `setData(rows)` – populates the list with data rows.
- `SetSort(column, desc)` – sets the sort column and direction.
- `Populate()` – refreshes the list based on current search filter.

**Example Usage**

```lua
-- Create an enhanced list view
local listView = vgui.Create("liaDListView")
listView:SetSize(500, 400)
listView:Center()
listView:MakePopup()

-- Configure the list
listView:SetWindowTitle("Player List")
listView:SetPlaceholderText("Search players...")
listView:SetColumns({"Name", "Score", "Ping"})

-- Set data and sorting
listView:setData(playerData)
listView:SetSort(1, false) -- Sort by name ascending
```

---

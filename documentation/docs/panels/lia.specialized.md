# Specialized Panel Library

This page documents the specialized UI panel components for the Lilia framework.

---

## Overview

The specialized panel library provides a comprehensive set of UI components for specific game functions including chat systems, scoreboards, notifications, vendor interfaces, and various specialized display elements. These panels handle complex interactions and specialized display requirements.

---

### liaChatBox

**Purpose**

Interactive chat interface with command history, autocomplete, and message display.

**When Called**

This panel is called when:
- Players need to send chat messages
- Command input and history is required
- Chat message display and formatting is needed

**Parameters**

* `width` (*number*): Chat box width as percentage of screen.
* `height` (*number*): Chat box height as percentage of screen.
* `commands` (*table*): Available chat commands.
* `history` (*table*): Chat message history.

**Returns**

* `panel` (*Panel*): The created chat box panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create chat interface
local chatBox = vgui.Create("liaChatBox")
chatBox:setSize(0.4, 0.375) -- 40% width, 37.5% height
chatBox:setPosition(32, ScrH() - height - 32)

-- Add chat message
chatBox:addMessage(player, "Hello everyone!", Color(255, 255, 255))

-- Enable chat input
chatBox:activate()
```

---

### liaScoreboard

**Purpose**

Displays player scoreboard with statistics, teams, and player information.

**When Called**

This panel is called when:
- Player scoreboard needs to be displayed
- Player statistics and rankings are shown
- Team-based player organization is required

**Parameters**

* `players` (*table*): Array of players to display.
* `showTeams` (*boolean*): Whether to organize by teams.
* `showStats` (*boolean*): Whether to show player statistics.
* `dockPosition` (*string*): Screen position ("left", "center", "right").

**Returns**

* `panel` (*Panel*): The created scoreboard panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create player scoreboard
local scoreboard = vgui.Create("liaScoreboard")
scoreboard:setPlayers(player.GetAll())
scoreboard:setShowTeams(true)
scoreboard:setDockPosition("center")

-- Add custom columns
scoreboard:addColumn("Kills", 80)
scoreboard:addColumn("Deaths", 80)
scoreboard:addColumn("Score", 100)

-- Refresh scoreboard data
scoreboard:refresh()
```

---

### liaNotice

**Purpose**

Displays temporary notification messages with different types and animations.

**When Called**

This panel is called when:
- Temporary notifications need to be shown
- User feedback messages are required
- Alert or information display is needed

**Parameters**

* `message` (*string*): Notification text content.
* `type` (*string*): Notification type ("info", "error", "success", "warning").
* `duration` (*number*): Display duration in seconds.
* `sound` (*string*): Optional sound to play.

**Returns**

* `panel` (*Panel*): The created notice panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create info notification
local notice = vgui.Create("liaNotice")
notice:setMessage("Server will restart in 5 minutes")
notice:setType("info")
notice:setDuration(10)

-- Create error notification with sound
local errorNotice = vgui.Create("liaNotice")
errorNotice:setMessage("Failed to save character!")
errorNotice:setType("error")
errorNotice:setSound("buttons/button10.wav")
```

---

### liaNoticePanel

**Purpose**

Individual notification panel component for the notification system.

**When Called**

This panel is called when:
- Individual notification items need to be created
- Notification queuing and management is required
- Custom notification layouts are needed

**Parameters**

* `message` (*string*): Notification message text.
* `type` (*string*): Notification type for styling.
* `icon` (*string*): Icon material path.

**Returns**

* `panel` (*Panel*): The created notice panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create individual notification
local notifPanel = vgui.Create("liaNoticePanel")
notifPanel:setMessage("Quest completed!")
notifPanel:setType("success")
notifPanel:setIcon("icon16/accept.png")

-- Add to notification queue
lia.notice.add(notifPanel)
```

---

### liaVendor

**Purpose**

Vendor interface for buying and selling items with inventory management.

**When Called**

This panel is called when:
- Player-vendor interactions are needed
- Item purchasing and selling interfaces are required
- Vendor inventory browsing is needed

**Parameters**

* `vendorEntity` (*Entity*): Vendor entity reference.
* `vendorItems` (*table*): Items available from vendor.
* `playerInventory` (*table*): Player's current inventory.

**Returns**

* `panel` (*Panel*): The created vendor panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create vendor interface
local vendor = vgui.Create("liaVendor")
vendor:setVendorEntity(vendorEnt)
vendor:setVendorItems(availableItems)

-- Handle item purchase
vendor.onItemPurchased = function(item, quantity, price)
    print("Purchased " .. quantity .. "x " .. item.name .. " for " .. price)
end

-- Handle item sale
vendor.onItemSold = function(item, quantity, price)
    print("Sold " .. quantity .. "x " .. item.name .. " for " .. price)
end
```

---

### liaVendorItem

**Purpose**

Individual item display component within vendor interfaces.

**When Called**

This panel is called when:
- Individual vendor items need to be displayed
- Item purchasing/selling controls are needed
- Vendor item information display is required

**Parameters**

* `itemData` (*table*): Item information and data.
* `vendorID` (*number*): Vendor entity ID.
* `price` (*number*): Item price for purchase/sale.

**Returns**

* `panel` (*Panel*): The created vendor item panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create vendor item display
local vendorItem = vgui.Create("liaVendorItem")
vendorItem:setItem(itemData)
vendorItem:setPrice(100)
vendorItem:setStock(50)

-- Handle purchase button
vendorItem.onPurchase = function(quantity)
    net.Start("VendorPurchase")
    net.WriteUInt(itemData.id, 32)
    net.WriteUInt(quantity, 16)
    net.SendToServer()
end
```

---

### liaVendorEditor

**Purpose**

Administrative interface for editing vendor inventories and settings.

**When Called**

This panel is called when:
- Administrators need to edit vendor items
- Vendor inventory management is required
- Vendor settings and configuration is needed

**Parameters**

* `vendorEntity` (*Entity*): Vendor entity to edit.
* `adminMode` (*boolean*): Whether in administrative mode.

**Returns**

* `panel` (*Panel*): The created vendor editor panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create vendor editor for admins
local vendorEditor = vgui.Create("liaVendorEditor")
vendorEditor:setVendorEntity(vendorEnt)
vendorEditor:setAdminMode(true)

-- Add new item to vendor
vendorEditor:addVendorItem(itemID, price, stock)

-- Remove item from vendor
vendorEditor:removeVendorItem(itemID)
```

---

### liaVendorFactionEditor

**Purpose**

Specialized vendor editor for managing faction-specific vendor items.

**When Called**

This panel is called when:
- Faction-specific vendor items need to be managed
- Faction-based item restrictions are required
- Administrative faction vendor management is needed

**Parameters**

* `vendorEntity` (*Entity*): Vendor entity to edit.
* `factionID` (*number*): Faction ID for restrictions.

**Returns**

* `panel` (*Panel*): The created vendor faction editor panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create faction vendor editor
local factionEditor = vgui.Create("liaVendorFactionEditor")
factionEditor:setVendorEntity(vendorEnt)
factionEditor:setFactionID(factionID)

-- Set faction-specific items
factionEditor:setFactionItems(factionItems)

-- Update faction restrictions
factionEditor:updateFactionRestrictions()
```

---

### liaVendorBodygroupEditor

**Purpose**

Editor interface for managing vendor NPC bodygroups and appearance.

**When Called**

This panel is called when:
- Vendor NPC appearance needs to be customized
- Bodygroup management for vendors is required
- Visual vendor customization is needed

**Parameters**

* `vendorEntity` (*Entity*): Vendor entity to edit.
* `bodygroups` (*table*): Available bodygroup options.

**Returns**

* `panel` (*Panel*): The created vendor bodygroup editor panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create vendor bodygroup editor
local bodygroupEditor = vgui.Create("liaVendorBodygroupEditor")
bodygroupEditor:setVendorEntity(vendorEnt)
bodygroupEditor:setBodygroups(availableBodygroups)

-- Apply bodygroup changes
bodygroupEditor:applyBodygroups()

-- Reset to default appearance
bodygroupEditor:resetToDefault()
```

---

### liaLoadingFailure

**Purpose**

Error display panel for server loading failures and critical errors.

**When Called**

This panel is called when:
- Server loading fails with critical errors
- Error information needs to be displayed to users
- Loading failure recovery options are needed

**Parameters**

* `errorMessage` (*string*): Specific error message.
* `errorDetails` (*table*): Detailed error information.
* `canRetry` (*boolean*): Whether retry option should be shown.

**Returns**

* `panel` (*Panel*): The created loading failure panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create loading failure display
local failurePanel = vgui.Create("liaLoadingFailure")
failurePanel:setErrorMessage("Server failed to load")
failurePanel:setErrorDetails(errorDetails)
failurePanel:setCanRetry(true)

-- Handle retry attempt
failurePanel.onRetry = function()
    RunConsoleCommand("retry")
end
```

---

### liaMarkupPanel

**Purpose**

Rich text display panel with markup parsing and formatting capabilities.

**When Called**

This panel is called when:
- Rich text content needs to be displayed
- Markup formatting is required
- Advanced text rendering is needed

**Parameters**

* `text` (*string*): Markup text content to display.
* `maxWidth` (*number*): Maximum display width.
* `font` (*string*): Font to use for rendering.

**Returns**

* `panel` (*Panel*): The created markup panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create markup text display
local markup = vgui.Create("liaMarkupPanel")
markup:setText("[color=red]Error:[/color] This is a test message")
markup:setMaxWidth(400)
markup:setFont("liaMediumFont")

-- Update markup content
markup:setMarkup("[b]Bold text[/b] and [i]italic text[/i]")
```

---

### liaFacingModelPanel

**Purpose**

3D model display panel with mouse-look controls and head tracking.

**When Called**

This panel is called when:
- 3D character models need to be displayed
- Mouse-look model interaction is required
- Character preview with head tracking is needed

**Parameters**

* `model` (*string*): Model path to display.
* `brightness` (*number*): Model lighting brightness.
* `copyPlayer` (*boolean*): Whether to copy player pose.

**Returns**

* `panel` (*Panel*): The created facing model panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create interactive model display
local modelPanel = vgui.Create("liaFacingModelPanel")
modelPanel:setModel("models/player/group01/male_01.mdl")
modelPanel:setBrightness(1.5)
modelPanel:setCopyPlayer(true)

-- Handle model interaction
modelPanel.onModelClick = function()
    print("Model clicked!")
end

-- Update model pose
modelPanel:updatePose()
```

---

### liaModelPanel

**Purpose**

Basic 3D model display panel for simple model preview and display.

**When Called**

This panel is called when:
- Simple 3D model display is needed
- Model preview without advanced controls is required
- Basic model visualization is sufficient

**Parameters**

* `model` (*string*): Model path to display.
* `skin` (*number*): Model skin index.
* `scale` (*number*): Model display scale.

**Returns**

* `panel` (*Panel*): The created model panel object.

**Realm**

Client.

**Example Usage**

```lua
-- Create basic model display
local modelPanel = vgui.Create("liaModelPanel")
modelPanel:setModel("models/props/cs_office/chair_office.mdl")
modelPanel:setSkin(0)
modelPanel:setScale(1.0)

-- Animate model
modelPanel:playAnimation("idle")

-- Set model position and angles
modelPanel:setModelPosition(Vector(0, 0, 0))
modelPanel:setModelAngles(Angle(0, 45, 0))
```

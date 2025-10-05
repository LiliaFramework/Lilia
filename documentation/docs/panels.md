# Panel Reference

This document describes every custom panel bundled with **Lilia**. Each entry lists the base Garry's Mod panel it derives from, a short description of its purpose, and a small code snippet demonstrating typical usage.

---

## Overview

The panel library provides a comprehensive set of custom Derma panels that extend Garry's Mod's native VGUI system with enhanced functionality, consistent styling, and framework-specific features. These panels automatically integrate with Lilia's theming system, localization framework, and core libraries, ensuring a cohesive user experience across all interface components. The system includes specialized panels for character management, inventory systems, vendor interfaces, communication tools, and various UI controls, all designed to work seamlessly within the Lilia framework ecosystem.

---

## Panel Summary

| Panel Name | Base Panel | Description |
|------------|------------|-------------|
| `liaMarkupPanel` | `DPanel` | Renders text using Garry's Mod markup. |
| `liaCharInfo` | `EditablePanel` | Displays character details in the F1 menu. |
| `liaMenu` | `EditablePanel` | Main F1 menu housing multiple tabs. |
| `liaClasses` | `EditablePanel` | Allows players to view and join classes. |
| `liaModelPanel` | `DModelPanel` | Model viewer with custom lighting. |
| `FacingModelPanel` | `DModelPanel` | Model viewer locked to the head angle. |
| `DProgressBar` | `DPanel` | Generic progress bar for timed actions. |
| `liaNotice` | `DLabel` | Small blur-backed notification label. |
| `noticePanel` | `DPanel` | Larger notification with optional buttons. |
| `liaChatBox` | `DPanel` | Custom chat box with commands and tabs. |
| `liaSpawnIcon` | `DModelPanel` | Spawn icon with improved positioning. |
| `VoicePanel` | `DPanel` | HUD element showing players using voice. |
| `liaHorizontalScroll` | `DPanel` | Horizontally scrolling container. |
| `liaHorizontalScrollBar` | `DVScrollBar` | Scrollbar companion for the horizontal container. |
| `liaItemMenu` | `EditablePanel` | Context menu for world items. |
| `liaAttribBar` | `DPanel` | Widget for assigning attribute points. |
| `liaCharacterAttribs` | `liaCharacterCreateStep` | Step for attribute selection. |
| `liaCharacterAttribsRow` | `DPanel` | Displays a single attribute row. |
| `liaItemIcon` | `SpawnIcon` | Icon specialised for Lilia items. |
| `BlurredDFrame` | `DFrame` | Frame with a blurred background. |
| `SemiTransparentDFrame` | `DFrame` | Frame drawn with partial transparency. |
| `SemiTransparentDPanel` | `DPanel` | Panel drawn with partial transparency. |
| `liaDoorMenu` | `DFrame` | Door permissions and ownership menu. |
| `liaRoster` | `EditablePanel` | Lists members of a faction or class. |
| `liaScoreboard` | `EditablePanel` | Replacement scoreboard. |
| `liaSheet` | `DPanel` | Filterable sheet used for building lists. |
| `liaCharacter` | `EditablePanel` | Main screen for character management. |
| `liaCharBGMusic` | `DPanel` | Handles menu background music playback. |
| `liaCharacterCreation` | `EditablePanel` | Multi-step character creation window. |
| `liaCharacterCreateStep` | `DScrollPanel` | Base panel for creation steps. |
| `liaCharacterConfirm` | `SemiTransparentDFrame` | Confirmation dialog used in the menu. |
| `liaCharacterBiography` | `liaCharacterCreateStep` | Step for entering name and description. |
| `liaCharacterFaction` | `liaCharacterCreateStep` | Step for selecting a faction. |
| `liaCharacterModel` | `liaCharacterCreateStep` | Step for choosing a player model. |
| `liaInventory` | `DFrame` | Base inventory window. |
| `liaGridInventory` | `liaInventory` | Inventory arranged in a grid of slots. |
| `liaGridInvItem` | `liaItemIcon` | Item icon used inside grid inventories. |
| `liaGridInventoryPanel` | `DPanel` | Container that manages a grid of item icons. |
| `Vendor` | `EditablePanel` | Vendor shop interface. |
| `VendorItem` | `DPanel` | Single item entry in the vendor menu. |
| `VendorEditor` | `DFrame` | Admin window for configuring vendors. |
| `VendorFactionEditor` | `DFrame` | Editor for vendor faction and class access. |
| `VendorBodygroupEditor` | `DFrame` | Editor for adjusting a vendor's bodygroups and skin. |
| `liaHugeButton` | `DButton` | Large button with prominent styling. |
| `liaBigButton` | `DButton` | Button using a big font size. |
| `liaMediumButton` | `DButton` | Standard medium button. |
| `liaSmallButton` | `DButton` | Compact button for tight layouts. |
| `liaMiniButton` | `DButton` | Very small button variant. |
| `liaNoBGButton` | `DButton` | Text-only button with no background. |
| `liaQuick` | `EditablePanel` | Quick settings panel showing options flagged with `isQuick`. |
| `liaSimpleCheckbox` | `DButton` | Checkbox that draws the config icons. |
| `liaItemSelector` | `DFrame` | Item selection dialog with search and filtering. |
| `liaDListView` | `DFrame` | Enhanced list view with search, sorting, and context menus. |
| `liaColorPicker` | `EditablePanel` | Interactive color picker with HSV color model. |
| `liaComboBox` | `Panel` | Dropdown selection with animated popup menu. |
| `liaDermaMenu` | `DPanel` | Context menu system with submenus and icons. |
| `liaLoadingFailure` | `DFrame` | Error display for server loading failures. |
| `liaPlayerSelector` | `liaFrame` | Player selection interface with avatars. |
| `liaRadialPanel` | `DPanel` | Circular radial menu with keyboard shortcuts. |
| `liaSlideBox` | `Panel` | Dual-purpose slider or slide container. |
| `liaTabs` | `Panel` | Tabbed interface with modern styling options. |
| `liaCategory` | `Panel` | Collapsible category panel for organizing UI elements. |
| `liaEntry` | `EditablePanel` | Enhanced text entry field with placeholder and animations. |
| `liaNumSlider` | `Panel` | Numeric slider control with customizable range and precision. |
| `liaTable` | `Panel` | Advanced table component with sortable columns and selection. |
| `liaScrollPanel` | `DScrollPanel` | Enhanced scroll panel with custom scrollbar styling. |
| `liaItemList` | `DFrame` | Generic list frame for displaying structured item data. |

---

## Panel Details

---

### `liaMarkupPanel`

**Purpose**

Panel that renders text using Garry's Mod markup language and wraps `markup.Parse` so formatted chat messages can be displayed easily.

**Base Panel**

`DPanel`

**Realm**

Client.

**Example Usage**

```lua
-- Create a markup panel for displaying formatted text
local markupPanel = vgui.Create("liaMarkupPanel")
markupPanel:SetText("This is **bold** and *italic* text!")
markupPanel:SetSize(200, 100)
```

---

### `liaCharInfo`

**Purpose**

Displays the current character's stats and fields in the F1 menu. The panel updates periodically and can show plugin-defined information.

**Base Panel**

`EditablePanel`

**Realm**

Client.

**Example Usage**

```lua
-- Character info is automatically created in the F1 menu
-- No manual creation needed - it's part of the main menu system
```

---

### `liaMenu`

**Purpose**

Main F1 menu housing tabs like Character, Help and Settings. It controls switching between tabs and can be opened on demand.

**Base Panel**

`EditablePanel`

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
```

---

### `liaClasses`

**Purpose**

Lists available classes in the F1 menu and shows requirements for each. Players may click a button to join a class when eligible.

**Base Panel**

`EditablePanel`

**Realm**

Client.

**Example Usage**

```lua
-- Create a liaclasses
local panel = vgui.Create("liaClasses")
panel:SetSize(200, 100)
```

---

### `liaModelPanel`

**Purpose**

Displays a model with custom lighting and mouse controls for rotation and zoom. Useful for previewing items or player characters.

**Base Panel**

`DModelPanel`

**Realm**

Client.

**Example Usage**

```lua
-- Create a liamodelpanel
local panel = vgui.Create("liaModelPanel")
panel:SetSize(400, 300)
panel:Center()
panel:MakePopup()
```

---

### `FacingModelPanel`

**Purpose**

Variant of `liaModelPanel` that locks the camera to the model's head bone, ideal for mugshots or scoreboard avatars.

**Base Panel**

`DModelPanel`

**Realm**

Client.

**Example Usage**

```lua
-- Create a facingmodelpanel
local panel = vgui.Create("FacingModelPanel")
panel:SetSize(400, 300)
panel:Center()
panel:MakePopup()
```

---

### `DProgressBar`

**Purpose**

Simple progress bar panel. Update its fraction each frame to visually represent timed actions.

**Base Panel**

`DPanel`

**Realm**

Client.

**Functions**

- `SetFraction(fraction)` – sets the current progress fraction between `0` and `1`.
- `SetProgress(startTime, endTime)` – defines the progress window; defaults to a five second duration when no values are provided.
- `SetText(text)` – text displayed in the centre of the bar.
- `SetBarColor(color)` – overrides the default bar colour.

**Example Usage**

```lua
-- Create a progress bar
local progressBar = vgui.Create("DProgressBar")
progressBar:SetSize(200, 20)
progressBar:SetFraction(0.5) -- 50% complete
progressBar:SetText("Loading...")
progressBar:SetBarColor(Color(0, 255, 0)) -- Green bar
```

---

### `liaNotice`

**Purpose**

Small label for quick notifications. It draws a blurred backdrop and fades away after a short delay. Supports different notification types with icons and colors.

**Base Panel**

`DLabel`

**Realm**

Client.

**Functions**

- `SetText(text)` – sets the notification message text.
- `SetType(type)` – sets the notification type (info, error, success, warning, money, admin, default) to change icon and color.

**Behaviour**

- When `start` and `endTime` fields are populated, a colour bar fills from left to right to indicate progress.
- Automatically positions itself and fades out after a configurable time.

**Example Usage**

```lua
-- Create a notification
local notice = vgui.Create("liaNotice")
notice:SetText("This is a notification!")
notice:SetType("info") -- Sets icon and color

-- Or create with specific positioning
notice:SetPos(10, 10)
notice:SetSize(300, 54)
```

---

### `noticePanel`

**Purpose**

Expanded version of `liaNotice` supporting more text and optional buttons. Often used for yes/no prompts.

**Base Panel**

`DPanel`

**Realm**

Client.

**Functions**

- `CalcWidth(padding)` – recalculates the panel width based on the inner label and supplied padding.

**Example Usage**

```lua
-- Create a notice panel
local notice = vgui.Create("noticePanel")
notice:SetText("Are you sure you want to delete this item?")
notice:SetSize(300, 100)
notice:Center()
```

---

### `liaChatBox`

**Purpose**

In-game chat window supporting multiple tabs, command prefix detection and color-coded messages.

**Base Panel**

`DPanel`

**Realm**

Client.

**Functions**

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
```

---

### `liaSpawnIcon`

**Purpose**

Improved spawn icon built on `DModelPanel`. It centers models and applies good lighting for use in inventories or lists.

**Base Panel**

`DModelPanel`

**Realm**

Client.

**Functions**

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
```

---

### `VoicePanel`

**Purpose**

HUD element that lists players using voice chat. Each entry fades out after a player stops talking.

**Base Panel**

`DPanel`

**Realm**

Client.

**Functions**

- `Setup(client)` – initialises the entry with the speaking player.
- `UpdateIcon()` – refreshes the icon based on voice type.
- `FadeOut(anim, delta)` – animation callback used to fade the panel when speech ends.

**Example Usage**

```lua
-- Voice panel is automatically managed by the framework
-- No manual creation needed - it's part of the HUD system
```

---

### `liaHorizontalScroll`

**Purpose**

Container that arranges child panels in a single row. Often paired with a custom scrollbar when content overflows.

**Base Panel**

`DPanel`

**Realm**

Client.

**Functions**

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
```

---

### `liaHorizontalScrollBar`

**Purpose**

Custom scrollbar paired with `liaHorizontalScroll`. It moves the canvas horizontally when items overflow.

**Base Panel**

`DVScrollBar`

**Realm**

Client.

**Functions**

- `SetScroll(offset)` – manually adjusts the scroll position.

**Example Usage**

```lua
-- Usually created automatically with liaHorizontalScroll
-- Access through scroll:GetHBar() if manual control needed
local scroll = vgui.Create("liaHorizontalScroll")
local scrollbar = scroll:GetHBar()
scrollbar:SetScroll(0.5) -- Scroll to 50% position
```

---

### `liaItemMenu`

**Purpose**

Panel shown when you interact with an item entity. Displays item info and action buttons.

**Base Panel**

`EditablePanel`

**Realm**

Client.

**Functions**

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
```

---

### `liaAttribBar`

**Purpose**

Interactive bar used during character creation to assign starting attribute points.

**Base Panel**

`DPanel`

**Realm**

Client.

**Functions**

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
```

---

### `liaCharacterAttribs`

**Purpose**

Character creation step panel for distributing attribute points across stats.

**Base Panel**

`liaCharacterCreateStep`

**Realm**

Client.

**Functions**

- `updatePointsLeft()` – refreshes the remaining points label.
- `onDisplay()` – loads saved attribute values into the rows.
- `addAttribute(key, info)` – creates a `liaCharacterAttribsRow` for the attribute.
- `onPointChange(key, delta)` – validates and applies a point change request.

**Example Usage**

```lua
-- Usually created as part of character creation flow
-- No manual creation needed - it's part of the character creation system
```

---

### `liaCharacterAttribsRow`

**Purpose**

Represents a single attribute with its description and current points, including buttons for adjustment.

**Base Panel**

`DPanel`

**Realm**

Client.

**Functions**

- `setAttribute(key, info)` – sets which attribute the row represents and updates its tooltip.
- `delta(amount)` – requests a point change of `amount` from the parent panel.
- `addButton(symbol, delta)` – internal helper that creates the increment/decrement buttons.
- `updateQuantity()` – refreshes the displayed point total.

**Example Usage**

```lua
-- Usually created by liaCharacterAttribs panel
-- No manual creation needed - it's part of the attribute system
```

---

### `liaItemIcon`

**Purpose**

Spawn icon specialised for Lilia item tables. Displays custom tooltips and supports right-click menus.

**Base Panel**

`SpawnIcon`

**Realm**

Client.

**Functions**

- `getItem()` – returns the associated item table if available.
- `setItemType(itemTypeOrID)` – assigns an item by unique ID or type string and updates the model and tooltip.
- `openActionMenu()` – builds and shows the context menu for the item.
- `updateTooltip()` – refreshes the tooltip text using the current item data.
- `ItemDataChanged()` – hook that re-runs `updateTooltip` when the item data changes.

**Example Usage**

```lua
-- Create an item icon
local icon = vgui.Create("liaItemIcon")
icon:SetSize(64, 64)
icon:setItemType("weapon_pistol")
icon.DoRightClick = function()
    icon:openActionMenu()
end
```

---

### `BlurredDFrame`

**Purpose**

Frame that draws a screen blur behind its contents. Useful for overlay menus that shouldn't fully obscure the game.

**Base Panel**

`DFrame`

**Realm**

Client.

**Example Usage**

```lua
-- Create a blurred frame
local frame = vgui.Create("BlurredDFrame")
frame:SetSize(400, 300)
frame:Center()
frame:MakePopup()
```

---

### `SemiTransparentDFrame`

**Purpose**

Simplified frame with a semi-transparent background, ideal for pop-up windows where the game should remain partially visible.

**Base Panel**

`DFrame`

**Realm**

Client.

**Example Usage**

```lua
-- Create a semi-transparent frame
local frame = vgui.Create("SemiTransparentDFrame")
frame:SetSize(500, 400)
frame:Center()
frame:MakePopup()
```

---

### `SemiTransparentDPanel`

**Purpose**

Basic panel that paints itself with partial transparency. Often used inside `SemiTransparentDFrame` as an inner container.

**Base Panel**

`DPanel`

**Realm**

Client.

**Example Usage**

```lua
-- Create a semi-transparent panel
local panel = vgui.Create("SemiTransparentDPanel")
panel:SetSize(200, 100)
panel:SetPos(10, 10)
```

---

### `liaDoorMenu`

**Purpose**

Interface for property doors showing ownership and faction access. Owners can lock, sell or share the door through this menu.

**Base Panel**

`DFrame`

**Realm**

Client.

**Functions**

- `setDoor(door, accessData, fallback)` – populates the list of players with their access levels for `door`.
- `CheckAccess(minimum)` – returns `true` if the local player meets the required access level.
- `Think()` – automatically closes the menu when the door becomes invalid or inaccessible.

**Example Usage**

```lua
-- Door menu is usually created when interacting with a door
-- No manual creation needed - it's part of the door system
```

---

### `liaRoster`

**Purpose**

Lists players in a faction or class roster and supports context actions such as kicking members.

**Base Panel**

`EditablePanel`

**Realm**

Client.

**Functions**

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
```

---

### `liaScoreboard`

**Purpose**

Replacement scoreboard that groups players by team or faction and displays additional stats like ping and play time.

**Base Panel**

`EditablePanel`

**Realm**

Client.

**Functions**

- `ApplyConfig()` – applies skin and colour configuration before showing the board.
- `updateStaff()` – refreshes the staff list portion based on current players.
- `addPlayer(player, parent)` – inserts a player row into the given category panel.

**Example Usage**

```lua
-- Scoreboard is automatically created by the framework
-- No manual creation needed - it's part of the HUD system
```

---

### `liaSheet`

**Purpose**

Scrollable sheet used to build filterable lists with rows of arbitrary content.

**Base Panel**

`DPanel`

**Realm**

Client.

**Functions**

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
```

---

### `liaCharacter`

**Purpose**

Main panel of the character selection menu. Lists the player's characters with options to create, delete or load them.

**Base Panel**

`EditablePanel`

**Realm**

Client.

**Example Usage**

```lua
-- Character panel is automatically created by the framework
-- No manual creation needed - it's part of the character system
```

---

### `liaCharBGMusic`

**Purpose**

Small panel that plays ambient music when the main menu is open. It fades the track in and out as the menu is shown or closed.

**Base Panel**

`DPanel`

**Realm**

Client.

**Example Usage**

```lua
-- Background music panel is automatically created by the framework
-- No manual creation needed - it's part of the menu system
```

---

### `liaCharacterCreation`

**Purpose**

Parent panel that hosts each character creation step such as biography, faction and model. It provides navigation buttons and validates input before advancing.

**Base Panel**

`EditablePanel`

**Realm**

Client.

**Example Usage**

```lua
-- liacharactercreation is usually created by the framework
-- No manual creation needed - it's part of the character system
```

---

### `liaCharacterCreateStep`

**Purpose**

Scroll panel used as the foundation for each creation step. Provides helpers for saving user input and moving forward in the flow.

**Base Panel**

`DScrollPanel`

**Realm**

Client.

**Example Usage**

```lua
-- liacharactercreatestep is usually created by the framework
-- No manual creation needed - it's part of the character system
```

---

### `liaCharacterConfirm`

**Purpose**

Confirmation dialog used for dangerous actions like deleting a character. Inherits from `SemiTransparentDFrame` for a consistent overlay look.

**Base Panel**

`SemiTransparentDFrame`

**Realm**

Client.

**Example Usage**

```lua
-- liacharacterconfirm is usually created by the framework
-- No manual creation needed - it's part of the character system
```

---

### `liaCharacterBiography`

**Purpose**

Step where players input their character's name and optional backstory. These values are validated and stored for later steps.

**Base Panel**

`liaCharacterCreateStep`

**Realm**

Client.

**Example Usage**

```lua
-- liacharacterbiography is usually created by the framework
-- No manual creation needed - it's part of the character system
```

---

### `liaCharacterFaction`

**Purpose**

Allows the player to choose from available factions. The selected faction updates the model panel and determines accessible classes.

**Base Panel**

`liaCharacterCreateStep`

**Realm**

Client.

**Example Usage**

```lua
-- liacharacterfaction is usually created by the framework
-- No manual creation needed - it's part of the character system
```

---

### `liaCharacterModel`

**Purpose**

Lets the player browse and select a player model appropriate for the chosen faction. Clicking an icon saves the choice and refreshes the preview.

**Base Panel**

`liaCharacterCreateStep`

**Realm**

Client.

**Example Usage**

```lua
-- liacharactermodel is usually created by the framework
-- No manual creation needed - it's part of the character system
```

---

### `liaInventory`

**Purpose**

Main inventory frame for characters. It listens for network updates and renders items in the layout provided by its subclass.

**Base Panel**

`DFrame`

**Realm**

Client.

**Example Usage**

```lua
-- Create a liainventory
local inventory = vgui.Create("liaInventory")
inventory:SetSize(400, 300)
inventory:Center()
inventory:MakePopup()
```

---

### `liaGridInventory`

**Purpose**

Subclass of `liaInventory` that arranges item icons into a fixed grid. Often used for storage containers or equipment screens.

**Base Panel**

`liaInventory`

**Realm**

Client.

**Example Usage**

```lua
-- Create a liagridinventory
local inventory = vgui.Create("liaGridInventory")
inventory:SetSize(400, 300)
inventory:Center()
inventory:MakePopup()
```

---

### `liaGridInvItem`

**Purpose**

Specialized icon used by `liaGridInventory`. Supports drag-and-drop for moving items between slots.

**Base Panel**

`liaItemIcon`

**Realm**

Client.

**Example Usage**

```lua
-- Create a liagridinvitem
local inventory = vgui.Create("liaGridInvItem")
inventory:SetSize(400, 300)
inventory:Center()
inventory:MakePopup()
```

---

### `liaGridInventoryPanel`

**Purpose**

Container responsible for laying out `liaGridInvItem` icons in rows and columns. Handles drag-and-drop and keeps the grid in sync with item data.

**Base Panel**

`DPanel`

**Realm**

Client.

**Example Usage**

```lua
-- Create a liagridinventorypanel
local panel = vgui.Create("liaGridInventoryPanel")
panel:SetSize(400, 300)
panel:Center()
panel:MakePopup()
```

---

### `Vendor`

**Purpose**

Main vendor window that lists items the NPC will buy or sell. Provides buttons for transactions and updates when the player's inventory changes.

**Base Panel**

`EditablePanel`

**Realm**

Client.

**Example Usage**

```lua
-- Create a vendor
local vendor = vgui.Create("Vendor")
vendor:SetSize(500, 400)
vendor:Center()
vendor:MakePopup()
```

---

### `VendorItem`

**Purpose**

Panel representing an individual item within the vendor list. Shows price information and handles clicks for buying or selling.

**Base Panel**

`DPanel`

**Realm**

Client.

**Example Usage**

```lua
-- Create a vendoritem
local vendor = vgui.Create("VendorItem")
vendor:SetSize(500, 400)
vendor:Center()
vendor:MakePopup()
```

---

### `VendorEditor`

**Purpose**

Administrative window for editing a vendor's inventory and settings, including item prices and faction permissions.

**Base Panel**

`DFrame`

**Realm**

Client.

**Example Usage**

```lua
-- Create a vendoreditor
local vendor = vgui.Create("VendorEditor")
vendor:SetSize(500, 400)
vendor:Center()
vendor:MakePopup()
```

---

### `VendorFactionEditor`

**Purpose**

Secondary editor for selecting which factions and player classes can trade with the vendor.

**Base Panel**

`DFrame`

**Realm**

Client.

**Example Usage**

```lua
-- Create a vendorfactioneditor
local vendor = vgui.Create("VendorFactionEditor")
vendor:SetSize(500, 400)
vendor:Center()
vendor:MakePopup()
```

---

### `VendorBodygroupEditor`

**Purpose**

Window for adjusting a vendor's bodygroups and skin.

**Base Panel**

`DFrame`

**Realm**

Client.

**Example Usage**

```lua
-- Create a vendorbodygroupeditor
local vendor = vgui.Create("VendorBodygroupEditor")
vendor:SetSize(500, 400)
vendor:Center()
vendor:MakePopup()
```

---

### `liaHugeButton`

**Purpose**

Large button styled with `liaHugeFont` and an underline effect on hover. Supports selection state with persistent underline when `SetSelected(true)` is called.

**Base Panel**

`DButton`

**Realm**

Client.

**Functions**

- `SetSelected(state)` – sets the button's selected state, showing persistent underline when true.
- `IsSelected()` – returns whether the button is currently selected.

**Example Usage**

```lua
-- Create a liahugebutton
local button = vgui.Create("liaHugeButton")
button:SetText("Click Me")
button:SetSize(100, 30)
button.DoClick = function()
    print("Button clicked!")
end

-- Set as selected to show persistent underline
button:SetSelected(true)
```

---

### `liaBigButton`

**Purpose**

Big-font button with the same underline hover animation and selection state support.

**Base Panel**

`DButton`

**Realm**

Client.

**Functions**

- `SetSelected(state)` – sets the button's selected state, showing persistent underline when true.
- `IsSelected()` – returns whether the button is currently selected.

**Example Usage**

```lua
-- Create a liabigbutton
local button = vgui.Create("liaBigButton")
button:SetText("Click Me")
button:SetSize(100, 30)
button.DoClick = function()
    print("Button clicked!")
end

-- Set as selected to show persistent underline
button:SetSelected(true)
```

---

### `liaMediumButton`

**Purpose**

Medium-size button using `liaMediumFont` with underline hover animation and selection state support.

**Base Panel**

`DButton`

**Realm**

Client.

**Functions**

- `SetSelected(state)` – sets the button's selected state, showing persistent underline when true.
- `IsSelected()` – returns whether the button is currently selected.

**Example Usage**

```lua
-- Create a liamediumbutton
local button = vgui.Create("liaMediumButton")
button:SetText("Click Me")
button:SetSize(100, 30)
button.DoClick = function()
    print("Button clicked!")
end

-- Set as selected to show persistent underline
button:SetSelected(true)
```

---

### `liaSmallButton`

**Purpose**

Small button sized for compact layouts with underline hover animation and selection state support.

**Base Panel**

`DButton`

**Realm**

Client.

**Functions**

- `SetSelected(state)` – sets the button's selected state, showing persistent underline when true.
- `IsSelected()` – returns whether the button is currently selected.

**Example Usage**

```lua
-- Create a liasmallbutton
local button = vgui.Create("liaSmallButton")
button:SetText("Click Me")
button:SetSize(100, 30)
button.DoClick = function()
    print("Button clicked!")
end

-- Set as selected to show persistent underline
button:SetSelected(true)
```

---

### `liaMiniButton`

**Purpose**

Tiny button using `liaMiniFont` for dense interfaces with underline hover animation and selection state support.

**Base Panel**

`DButton`

**Realm**

Client.

**Functions**

- `SetSelected(state)` – sets the button's selected state, showing persistent underline when true.
- `IsSelected()` – returns whether the button is currently selected.

**Example Usage**

```lua
-- Create a liaminibutton
local button = vgui.Create("liaMiniButton")
button:SetText("Click Me")
button:SetSize(100, 30)
button.DoClick = function()
    print("Button clicked!")
end

-- Set as selected to show persistent underline
button:SetSelected(true)
```

---

### `liaNoBGButton`

**Purpose**

Text-only button with no background that still shows the underline animation and supports selection state.

**Base Panel**

`DButton`

**Realm**

Client.

**Functions**

- `SetSelected(state)` – sets the button's selected state, showing persistent underline when true.
- `IsSelected()` – returns whether the button is currently selected.

**Example Usage**

```lua
-- Create a lianobgbutton
local button = vgui.Create("liaNoBGButton")
button:SetText("Click Me")
button:SetSize(100, 30)
button.DoClick = function()
    print("Button clicked!")
end

-- Set as selected to show persistent underline
button:SetSelected(true)
```

---

### `liaQuick`

**Purpose**

Quick settings menu that lists options flagged with `isQuick`.

**Base Panel**

`EditablePanel`

**Realm**

Client.

**Functions:**

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

### `liaSimpleCheckbox`

**Purpose**

Checkbox that paints the same checkmark icons used in the configuration menu.

**Base Panel**

`DButton`

**Realm**

Client.

**Functions:**

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

### `liaItemSelector`

**Purpose**

Item selection dialog with search and filtering capabilities for choosing items from a list.

**Base Panel**

`DFrame`

**Realm**

Client.

**Example Usage**

```lua
-- Create a liaitemselector
local panel = vgui.Create("liaItemSelector")
panel:SetSize(200, 100)
```

---

### `liaDListView`

**Purpose**

Enhanced list view with search, sorting, and context menus. Features a search box, refresh button, and status bar showing total count.

**Base Panel**

`DFrame`

**Realm**

Client.

**Example Usage**

```lua
-- Create a liadlistview
local panel = vgui.Create("liaDListView")
panel:SetSize(200, 100)
```

**Functions:**

- `SetWindowTitle(title)` – sets the window title.
- `SetPlaceholderText(text)` – sets the search box placeholder text.
- `SetColumns(columns)` – defines the list columns.
- `setData(rows)` – populates the list with data rows.
- `SetSort(column, desc)` – sets the sort column and direction.
- `Populate()` – refreshes the list based on current search filter.

---

### `liaColorPicker`

**Purpose**

Interactive color picker that allows users to select colors using HSV (Hue, Saturation, Value) color model. Features a color field, hue slider, and preview panel with real-time updates.

**Base Panel**

`EditablePanel`

**Realm**

Client.

**Functions:**

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

### `liaComboBox`

**Purpose**

Dropdown selection panel that displays a list of options in an animated popup menu. Supports placeholder text and custom selection callbacks.

**Base Panel**

`Panel`

**Realm**

Client.

**Functions:**

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

### `liaDermaMenu`

**Purpose**

Context menu system that displays a list of options with support for submenus, icons, and custom data. Features smooth animations and proper menu positioning.

**Base Panel**

`DPanel`

**Realm**

Client.

**Functions:**

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

### `liaItemList`

**Purpose**

Generic list frame for displaying items in a structured format. Supports custom columns, data population, and item management.

**Base Panel**

`DFrame`

**Realm**

Client.

**Functions:**

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

### `liaItemSelector`

**Purpose**

Item selection dialog with search functionality and filtering capabilities. Allows users to select from a list of items with confirmation buttons.

**Base Panel**

`DFrame`

**Realm**

Client.

**Functions:**

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

### `liaLoadingFailure`

**Purpose**

Error display panel shown when the server fails to load properly. Displays error messages, failure reasons, and provides options for retry or console access.

**Base Panel**

`DFrame`

**Realm**

Client.

**Functions:**

- `SetFailureInfo(reason, details)` – sets the failure reason and detailed information.
- `AddError(errorMessage, line, file)` – adds individual error entries to the display.
- `UpdateErrorDisplay()` – refreshes the error information panel.

**Example Usage**

```lua
-- Loading failure panel is automatically shown by the framework
-- when server initialization fails - no manual creation needed
```

---

### `liaPlayerSelector`

**Purpose**

Player selection interface that displays all players with their avatars, names, and status information. Supports custom validation and selection callbacks.

**Base Panel**

`liaFrame`

**Realm**

Client.

**Functions:**

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

### `liaRadialPanel`

**Purpose**

Circular radial menu system that displays options in a wheel pattern around a center point. Supports keyboard shortcuts, submenus, and smooth animations.

**Base Panel**

`DPanel`

**Realm**

Client.

**Functions:**

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

### `liaSlideBox`

**Purpose**

Dual-purpose panel that can function as either a numeric slider with range controls or a slide container for displaying multiple content panels with navigation.

**Base Panel**

`Panel`

**Realm**

Client.

**Functions:**

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

### `liaTabs`

**Purpose**

Tabbed interface system that organizes content into multiple tabs with smooth animations and modern styling options. Supports both horizontal and vertical tab layouts.

**Base Panel**

`Panel`

**Realm**

Client.

**Functions:**

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

### `liaCategory`

**Purpose**

Collapsible category panel that can contain other UI elements. When clicked, it expands or collapses to show/hide its contents with smooth animation.

**Base Panel**

`Panel`

**Realm**

Client.

**Functions:**

- `SetText(name)` – sets the category header text.
- `SetCenterText(is_centered)` – centers the header text if true.
- `SetLabel(label)` – alias for SetText.
- `SetContents(panel)` – sets the content panel that will be shown/hidden.
- `SetExpanded(is_active)` – expands or collapses the category.
- `SetActive(is_active)` – alias for SetExpanded.
- `Toggle()` – toggles the expanded state.
- `GetHeader()` – returns the header button panel.
- `AddItem(panel)` – adds a panel to the content area.
- `SetColor(col)` – sets the header color.

**Example Usage**

```lua
-- Create a collapsible category
local category = vgui.Create("liaCategory")
category:SetSize(300, 100)
category:SetText("Settings")

-- Add content panel
local content = vgui.Create("DPanel")
content:SetBackgroundColor(Color(100, 100, 100))
category:SetContents(content)

-- Start expanded
category:SetExpanded(true)
```

---

### `liaEntry`

**Purpose**

Enhanced text entry field with placeholder text, smooth animations, and customizable appearance. Supports title labels and value callbacks.

**Base Panel**

`EditablePanel`

**Realm**

Client.

**Functions:**

- `SetTitle(title)` – sets an optional title label above the entry field.
- `SetPlaceholder(placeholder)` – sets the placeholder text shown when empty.
- `SetPlaceholderText(placeholder)` – alias for SetPlaceholder.
- `SetValue(value)` – sets the current text value.
- `SetText(value)` – alias for SetValue.
- `GetValue()` – returns the current text value.
- `SelectAll()` – selects all text in the entry field.
- `SetFont(font)` – sets the font used for the text.
- `SetNumeric(isNumeric)` – restricts input to numeric characters if true.
- `AllowInput(callback)` – sets a custom input validation function.
- `SetTextColor(color)` – sets the text color.

**Example Usage**

```lua
-- Create a text entry with title
local entry = vgui.Create("liaEntry")
entry:SetSize(300, 60)
entry:SetTitle("Player Name")
entry:SetPlaceholder("Enter your name...")
entry:SetValue("Default Name")

-- Handle value changes
entry.action = function(value)
    print("Entered:", value)
end
```

---

### `liaNumSlider`

**Purpose**

Numeric slider control with customizable range, decimal precision, and smooth animations. Displays current value and supports drag interaction.

**Base Panel**

`Panel`

**Realm**

Client.

**Functions:**

- `SetMin(min)` – sets the minimum value.
- `GetMin()` – returns the minimum value.
- `SetMax(max)` – sets the maximum value.
- `GetMax()` – returns the maximum value.
- `SetDecimals(decimals)` – sets the number of decimal places.
- `GetDecimals()` – returns the number of decimal places.
- `SetValue(value)` – sets the current value.
- `GetValue()` – returns the current value.
- `SetText(text)` – sets the label text prefix.
- `GetText()` – returns the label text prefix.
- `UpdateSliderPosition()` – refreshes the slider position.
- `OnValueChanged()` – callback for value changes (override).
- `OnDragStart()` – callback for drag start (override).
- `OnDragEnd()` – callback for drag end (override).

**Example Usage**

```lua
-- Create a numeric slider
local slider = vgui.Create("liaNumSlider")
slider:SetSize(300, 60)
slider:SetText("Volume: ")
slider:SetMin(0)
slider:SetMax(100)
slider:SetValue(50)
slider:SetDecimals(0)

-- Handle value changes
slider.OnValueChanged = function(value)
    print("Volume changed to:", value)
end
```

---

### `liaTable`

**Purpose**

Advanced table component with sortable columns, selection support, and context menus. Supports custom column definitions and row data management.

**Base Panel**

`Panel`

**Realm**

Client.

**Functions:**

- `AddColumn(name, width, align, sortable)` – adds a column definition.
- `AddItem(...)` – adds a row with the provided data.
- `AddLine(...)` – alias for AddItem.
- `SortByColumn(columnIndex)` – sorts the table by the specified column.
- `CreateHeader()` – creates the table header.
- `CreateRow(rowIndex, rowData)` – creates a row panel.
- `CalculateColumnWidths()` – auto-sizes columns based on content.
- `RebuildRows()` – refreshes all rows.
- `SetAction(func)` – sets the callback for row clicks.
- `SetRightClickAction(func)` – sets the callback for right-clicks.
- `Clear()` – removes all rows.
- `ClearSelection()` – deselects the current row.
- `GetSelectedRow()` – returns the selected row data.
- `RemoveRow(index)` – removes a row by index.
- `OnSizeChanged()` – handles panel resizing.

**Example Usage**

```lua
-- Create a table
local table = vgui.Create("liaTable")
table:SetSize(400, 300)

-- Add columns
table:AddColumn("Name", 150, TEXT_ALIGN_LEFT, true)
table:AddColumn("Value", 100, TEXT_ALIGN_CENTER, true)
table:AddColumn("Description", 150, TEXT_ALIGN_LEFT, false)

-- Add rows
table:AddItem("Sword", "100", "A sharp blade")
table:AddItem("Shield", "50", "Protective gear")

-- Handle row selection
table.OnAction = function(rowData)
    print("Selected:", rowData[1])
end
```

---

### `liaScrollPanel`

**Purpose**

Enhanced scroll panel with custom scrollbar styling and smooth scrolling behavior. Extends DScrollPanel with Lilia theming.

**Base Panel**

`DScrollPanel`

**Realm**

Client.

**Example Usage**

```lua
-- Create a scroll panel
local scrollPanel = vgui.Create("liaScrollPanel")
scrollPanel:SetSize(300, 200)

-- Add content that exceeds the panel size
for i = 1, 20 do
    local panel = vgui.Create("DPanel", scrollPanel)
    panel:Dock(TOP)
    panel:SetTall(50)
    panel:SetBackgroundColor(Color(100 * i % 255, 150, 200))
end
```

---

### `liaItemList`

**Purpose**

Generic list frame for displaying items in a structured format. Supports custom columns and data population for item management.

**Base Panel**

`DFrame`

**Realm**

Client.

**Functions:**

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

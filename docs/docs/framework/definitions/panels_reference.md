# Panel Reference

This document describes every custom panel bundled with **Lilia**. Each entry lists the base Garry's Mod panel it derives from, a short description of its purpose, and a small code snippet demonstrating typical usage.

---
## Overview

Panels provide the building blocks for Lilia's user interface. Most derive from common Source engine panels such as `DFrame` or `DPanel` and extend them with additional behaviour. Use these panels when creating new menus or modifying existing ones.

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
| `liaScoreboard` | `EditablePanel` | Replacement scoreboard. |
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

---
## Panel Details

### `liaMarkupPanel`
**Base Panel:** `DPanel`

**Description:** Panel that renders text using Garry's Mod markup language and wraps `markup.Parse` so formatted chat messages can be displayed easily.

**Example Usage:**
```lua
-- Create a formatted chat line
local chatLine = vgui.Create("liaMarkupPanel", chatScroll)
chatLine:setMarkup("<color=255,255,0>Hello!</color>")
chatLine:Dock(TOP)
```

### `liaCharInfo`
**Base Panel:** `EditablePanel`

**Description:** Displays the current character's stats and fields in the F1 menu. The panel updates periodically and can show plugin-defined information.

**Example Usage:**
```lua
local infoPanel = vgui.Create("liaCharInfo") -- part of the F1 menu
infoPanel:Dock(FILL)
infoPanel:setup() -- populate displayed fields
```

### `liaMenu`
**Base Panel:** `EditablePanel`

**Description:** Main F1 menu housing tabs like Character, Help and Settings. It controls switching between tabs and can be opened on demand.

**Example Usage:**
```lua
local menu = vgui.Create("liaMenu")
menu:MakePopup()
menu:openTab("Character")
```

### `liaClasses`
**Base Panel:** `EditablePanel`

**Description:** Lists available classes in the F1 menu and shows requirements for each. Players may click a button to join a class when eligible.

**Example Usage:**
```lua
local btn = parent:Add("liaMediumButton")
btn:SetText("Medic")
btn.DoClick = function()
    RunConsoleCommand("lia_class", "medic")
end
```

### `liaModelPanel`
**Base Panel:** `DModelPanel`

**Description:** Displays a model with custom lighting and mouse controls for rotation and zoom. Useful for previewing items or player characters.

**Example Usage:**
```lua
local mdl = vgui.Create("liaModelPanel", frame)
mdl:SetModel("models/props_c17/oildrum001.mdl")
mdl:SetCamPos(Vector(35, 0, 55))
```

### `FacingModelPanel`
**Base Panel:** `DModelPanel`

**Description:** Variant of `liaModelPanel` that locks the camera to the model's head bone, ideal for mugshots or scoreboard avatars.

**Example Usage:**
```lua
local avatar = vgui.Create("FacingModelPanel", frame)
avatar:SetModel("models/Humans/Group01/Female_01.mdl")
```

### `DProgressBar`
**Base Panel:** `DPanel`

**Description:** Simple progress bar panel. Update its fraction each frame to visually represent timed actions.

**Example Usage:**
```lua
local progress = vgui.Create("DProgressBar", panel)
progress:SetFraction(0)
timer.Simple(2, function() progress:SetFraction(1) end)
```

### `liaNotice`
**Base Panel:** `DLabel`

**Description:** Small label for quick notifications. It draws a blurred backdrop and fades away after a short delay.

**Example Usage:**
```lua
local notice = vgui.Create("liaNotice")
notice:SetText("Item picked up!")
notice.start = CurTime() + 2
```

### `noticePanel`
**Base Panel:** `DPanel`

**Description:** Expanded version of `liaNotice` supporting more text and optional buttons. Often used for yes/no prompts.

**Example Usage:**
```lua
local prompt = vgui.Create("noticePanel")
prompt.text:SetText("Are you sure?")
prompt.yes.DoClick = function() print("confirmed") end
```

### `liaChatBox`
**Base Panel:** `DPanel`

**Description:** In-game chat window supporting multiple tabs, command prefix detection and color-coded messages.

**Example Usage:**
```lua
local chatBox = vgui.Create("liaChatBox")
chatBox:setActive(true)
```

### `liaSpawnIcon`
**Base Panel:** `DModelPanel`

**Description:** Improved spawn icon built on `DModelPanel`. It centers models and applies good lighting for use in inventories or lists.

**Example Usage:**
```lua
local icon = vgui.Create("liaSpawnIcon", frame)
icon:SetModel("models/props_c17/oildrum001.mdl")
icon:SetSize(64, 64)
icon.DoClick = function() print("clicked") end
```

### `VoicePanel`
**Base Panel:** `DPanel`

**Description:** HUD element that lists players using voice chat. Each entry fades out after a player stops talking.

**Example Usage:**
```lua
local voiceEntry = voiceList:Add("VoicePanel")
voiceEntry:Setup(player)
```

### `liaHorizontalScroll`
**Base Panel:** `DPanel`

**Description:** Container that arranges child panels in a single row. Often paired with a custom scrollbar when content overflows.

**Example Usage:**
```lua
local scroll = vgui.Create("liaHorizontalScroll")
scroll.bar = scroll:Add("liaHorizontalScrollBar")
scroll.bar:Dock(BOTTOM)
```

### `liaHorizontalScrollBar`
**Base Panel:** `DVScrollBar`

**Description:** Custom scrollbar paired with `liaHorizontalScroll`. It moves the canvas horizontally when items overflow.

**Example Usage:**
```lua
local bar = vgui.Create("liaHorizontalScrollBar")
bar.TargetCanvas = scroll.canvas
```

### `liaItemMenu`
**Base Panel:** `EditablePanel`

**Description:** Drop-down menu that appears when interacting with items in the world. Lets players pick up, examine or drop the item.

**Example Usage:**
```lua
local menu = vgui.Create("liaItemMenu")
menu:SetEntity(targetItem)
menu:Open()
menu:Center()
```

### `liaAttribBar`
**Base Panel:** `DPanel`

**Description:** Interactive bar used during character creation to assign starting attribute points.

**Example Usage:**
```lua
local bar = vgui.Create("liaAttribBar", panel)
bar:SetMax(10)
bar:SetValue(0)
```

### `liaCharacterAttribs`
**Base Panel:** `liaCharacterCreateStep`

**Description:** Character creation step panel for distributing attribute points across stats.

**Example Usage:**
```lua
local row = vgui.Create("liaCharacterAttribsRow", attributesPanel)
row:setAttribute("strength", 5)
```

### `liaCharacterAttribsRow`
**Base Panel:** `DPanel`

**Description:** Represents a single attribute with its description and current points, including buttons for adjustment.

**Example Usage:**
```lua
local row = vgui.Create("liaCharacterAttribsRow")
row:setAttribute("agility", 2)
row:updateQuantity()
```

### `liaItemIcon`
**Base Panel:** `SpawnIcon`

**Description:** Spawn icon specialised for Lilia item tables. Displays custom tooltips and supports right-click menus.

**Example Usage:**
```lua
local icon = vgui.Create("liaItemIcon", parent)
icon:setItem(item)
icon:SetTooltip(item:getName())
```

### `BlurredDFrame`
**Base Panel:** `DFrame`

**Description:** Frame that draws a screen blur behind its contents. Useful for overlay menus that shouldn't fully obscure the game.

**Example Usage:**
```lua
local frame = vgui.Create("BlurredDFrame")
frame:SetSize(300, 200)
```

### `SemiTransparentDFrame`
**Base Panel:** `DFrame`

**Description:** Simplified frame with a semi-transparent background, ideal for pop-up windows where the game should remain partially visible.

**Example Usage:**
```lua
local frame = vgui.Create("SemiTransparentDFrame")
frame:SetTitle("Notice")
```

### `SemiTransparentDPanel`
**Base Panel:** `DPanel`

**Description:** Basic panel that paints itself with partial transparency. Often used inside `SemiTransparentDFrame` as an inner container.

**Example Usage:**
```lua
local panel = vgui.Create("SemiTransparentDPanel", frame)
panel:SetSize(200, 100)
```

### `liaDoorMenu`
**Base Panel:** `DFrame`

**Description:** Interface for property doors showing ownership and faction access. Owners can lock, sell or share the door through this menu.

**Example Usage:**
```lua
local doorMenu = vgui.Create("liaDoorMenu")
doorMenu:setDoor(doorEntity, true)
doorMenu:Center()
```

### `liaScoreboard`
**Base Panel:** `EditablePanel`

**Description:** Replacement scoreboard that groups players by team or faction and displays additional stats like ping and play time.

**Example Usage:**
```lua
local board = vgui.Create("liaScoreboard")
board:Show()
```

### `liaCharacter`
**Base Panel:** `EditablePanel`

**Description:** Main panel of the character selection menu. Lists the player's characters with options to create, delete or load them.

**Example Usage:**
```lua
local charMenu = vgui.Create("liaCharacter")
charMenu:Dock(FILL)
charMenu:populateList()
```

### `liaCharBGMusic`
**Base Panel:** `DPanel`

**Description:** Small panel that plays ambient music when the main menu is open. It fades the track in and out as the menu is shown or closed.

**Example Usage:**
```lua
local musicPanel = vgui.Create("liaCharBGMusic")
musicPanel:Play("music/menu_theme.mp3")
```

### `liaCharacterCreation`
**Base Panel:** `EditablePanel`

**Description:** Parent panel that hosts each character creation step such as biography, faction and model. It provides navigation buttons and validates input before advancing.

**Example Usage:**
```lua
local creator = vgui.Create("liaCharacterCreation")
creator:nextStep()
```

### `liaCharacterCreateStep`
**Base Panel:** `DScrollPanel`

**Description:** Scroll panel used as the foundation for each creation step. Provides helpers for saving user input and moving forward in the flow.

**Example Usage:**
```lua
local step = vgui.Create("liaCharacterCreateStep")
step:next()
```

### `liaCharacterConfirm`
**Base Panel:** `SemiTransparentDFrame`

**Description:** Confirmation dialog used for dangerous actions like deleting a character. Inherits from `SemiTransparentDFrame` for a consistent overlay look.

**Example Usage:**
```lua
local confirm = vgui.Create("liaCharacterConfirm")
confirm:setMessage("Are you sure?")
confirm:onConfirm(function() print("confirmed") end)
```

### `liaCharacterBiography`
**Base Panel:** `liaCharacterCreateStep`

**Description:** Step where players input their character's name and optional backstory. These values are validated and stored for later steps.

**Example Usage:**
```lua
step.nameEntry:SetValue("John")
step.descEntry:SetMultiline(true)
```

### `liaCharacterFaction`
**Base Panel:** `liaCharacterCreateStep`

**Description:** Allows the player to choose from available factions. The selected faction updates the model panel and determines accessible classes.

**Example Usage:**
```lua
step:setContext("faction", 1)
step:updateModelPanel()
```

### `liaCharacterModel`
**Base Panel:** `liaCharacterCreateStep`

**Description:** Lets the player browse and select a player model appropriate for the chosen faction. Clicking an icon saves the choice and refreshes the preview.

**Example Usage:**
```lua
function PANEL:onModelSelected(icon)
    self:setContext("model", icon.index or 1)
    self:updateModelPanel()
    icon:SetSelected(true)
end
```

### `liaInventory`
**Base Panel:** `DFrame`

**Description:** Main inventory frame for characters. It listens for network updates and renders items in the layout provided by its subclass.

**Example Usage:**
```lua
local invFrame = vgui.Create("liaInventory")
invFrame:SetTitle("Inventory")
```

### `liaGridInventory`
**Base Panel:** `liaInventory`

**Description:** Subclass of `liaInventory` that arranges item icons into a fixed grid. Often used for storage containers or equipment screens.

**Example Usage:**
```lua
local grid = vgui.Create("liaGridInventory", invFrame)
grid:setGridSize(5, 4, 64)
grid:Dock(FILL)
```

### `liaGridInvItem`
**Base Panel:** `liaItemIcon`

**Description:** Specialized icon used by `liaGridInventory`. Supports drag-and-drop for moving items between slots.

**Example Usage:**
```lua
local icon = vgui.Create("liaGridInvItem", grid)
icon:setItem(item)
icon:SetPos(0, 0)
```

### `liaGridInventoryPanel`
**Base Panel:** `DPanel`

**Description:** Container responsible for laying out `liaGridInvItem` icons in rows and columns. Handles drag-and-drop and keeps the grid in sync with item data.

**Example Usage:**
```lua
function PANEL:populateItems()
    -- Rebuild icons after inventory change
    self:InvalidateLayout()
end
```

### `Vendor`
**Base Panel:** `EditablePanel`

**Description:** Main vendor window that lists items the NPC will buy or sell. Provides buttons for transactions and updates when the player's inventory changes.

**Example Usage:**
```lua
local vendorUI = vgui.Create("Vendor")
vendorUI:PopulateItems()
```

### `VendorItem`
**Base Panel:** `DPanel`

**Description:** Panel representing an individual item within the vendor list. Shows price information and handles clicks for buying or selling.

**Example Usage:**
```lua
local itemRow = vgui.Create("VendorItem", vendorUI.list)
itemRow:setItemType("ammo")
itemRow.DoClick = function() vendorUI:buy("ammo") end
itemRow:SetTall(40)
```

### `VendorEditor`
**Base Panel:** `DFrame`

**Description:** Administrative window for editing a vendor's inventory and settings, including item prices and faction permissions.

**Example Usage:**
```lua
local editor = vgui.Create("VendorEditor")
editor:SetZPos(99)
```

### `VendorFactionEditor`
**Base Panel:** `DFrame`

**Description:** Secondary editor for selecting which factions and player classes can trade with the vendor.

**Example Usage:**
```lua
factionButton.DoClick = function()
    vgui.Create("VendorFactionEditor"):MoveLeftOf(factionButton, 4)
end
```

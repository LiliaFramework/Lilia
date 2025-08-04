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
| `VendorBodygroupEditor` | `DFrame` | Editor for adjusting a vendor's bodygroups. |
| `liaHugeButton` | `DButton` | Large button with prominent styling. |
| `liaBigButton` | `DButton` | Button using a big font size. |
| `liaMediumButton` | `DButton` | Standard medium button. |
| `liaSmallButton` | `DButton` | Compact button for tight layouts. |
| `liaMiniButton` | `DButton` | Very small button variant. |
| `liaNoBGButton` | `DButton` | Text-only button with no background. |
| `liaQuick` | `EditablePanel` | Quick settings panel showing options flagged with `isQuick`. |
| `liaCheckBox` | `DButton` | Checkbox that draws the config icons. |

---

## Panel Details

---

### `liaMarkupPanel`

**Base Panel:**

`DPanel`

**Description:**

Panel that renders text using Garry's Mod markup language and wraps `markup.Parse` so formatted chat messages can be displayed easily.

---

### `liaCharInfo`

**Base Panel:**

`EditablePanel`

**Description:**

Displays the current character's stats and fields in the F1 menu. The panel updates periodically and can show plugin-defined information.

---

### `liaMenu`

**Base Panel:**

`EditablePanel`

**Description:**

Main F1 menu housing tabs like Character, Help and Settings. It controls switching between tabs and can be opened on demand.

---

### `liaClasses`

**Base Panel:**

`EditablePanel`

**Description:**

Lists available classes in the F1 menu and shows requirements for each. Players may click a button to join a class when eligible.

---

### `liaModelPanel`

**Base Panel:**

`DModelPanel`

**Description:**

Displays a model with custom lighting and mouse controls for rotation and zoom. Useful for previewing items or player characters.

---

### `FacingModelPanel`

**Base Panel:**

`DModelPanel`

**Description:**

Variant of `liaModelPanel` that locks the camera to the model's head bone, ideal for mugshots or scoreboard avatars.

---

### `DProgressBar`

**Base Panel:**

`DPanel`

**Description:**

Simple progress bar panel. Update its fraction each frame to visually represent timed actions.

---

### `liaNotice`

**Base Panel:**

`DLabel`

**Description:**

Small label for quick notifications. It draws a blurred backdrop and fades away after a short delay.

---

### `noticePanel`

**Base Panel:**

`DPanel`

**Description:**

Expanded version of `liaNotice` supporting more text and optional buttons. Often used for yes/no prompts.

### `liaChatBox`

**Base Panel:**

`DPanel`

**Description:**

In-game chat window supporting multiple tabs, command prefix detection and color-coded messages.

---

### `liaSpawnIcon`

**Base Panel:**

`DModelPanel`

**Description:**

Improved spawn icon built on `DModelPanel`. It centers models and applies good lighting for use in inventories or lists.

---

### `VoicePanel`

**Base Panel:**

`DPanel`

**Description:**

HUD element that lists players using voice chat. Each entry fades out after a player stops talking.

---

### `liaHorizontalScroll`

**Base Panel:**

`DPanel`

**Description:**

Container that arranges child panels in a single row. Often paired with a custom scrollbar when content overflows.

---

### `liaHorizontalScrollBar`

**Base Panel:**

`DVScrollBar`

**Description:**

Custom scrollbar paired with `liaHorizontalScroll`. It moves the canvas horizontally when items overflow.

---

### `liaItemMenu`

**Base Panel:**

`EditablePanel`

**Description:**

Panel shown when you interact with an item entity. Displays item info and action buttons.

```lua
-- called from GM:ItemShowEntityMenu
if IsValid(liaItemMenuInstance) then liaItemMenuInstance:Remove() end
liaItemMenuInstance = vgui.Create("liaItemMenu")
liaItemMenuInstance:SetEntity(entity)
```

---

### `liaAttribBar`

**Base Panel:**

`DPanel`

**Description:**

Interactive bar used during character creation to assign starting attribute points.

---

### `liaCharacterAttribs`

**Base Panel:**

`liaCharacterCreateStep`

**Description:**

Character creation step panel for distributing attribute points across stats.

---

### `liaCharacterAttribsRow`

**Base Panel:**

`DPanel`

**Description:**

Represents a single attribute with its description and current points, including buttons for adjustment.

---

### `liaItemIcon`

**Base Panel:**

`SpawnIcon`

**Description:**

Spawn icon specialised for Lilia item tables. Displays custom tooltips and supports right-click menus.

---

### `BlurredDFrame`

**Base Panel:**

`DFrame`

**Description:**

Frame that draws a screen blur behind its contents. Useful for overlay menus that shouldn't fully obscure the game.

---

### `SemiTransparentDFrame`

**Base Panel:**

`DFrame`

**Description:**

Simplified frame with a semi-transparent background, ideal for pop-up windows where the game should remain partially visible.

---

### `SemiTransparentDPanel`

**Base Panel:**

`DPanel`

**Description:**

Basic panel that paints itself with partial transparency. Often used inside `SemiTransparentDFrame` as an inner container.

---

### `liaDoorMenu`

**Base Panel:**

`DFrame`

**Description:**

Interface for property doors showing ownership and faction access. Owners can lock, sell or share the door through this menu.

---

### `liaScoreboard`

**Base Panel:**

`EditablePanel`

**Description:**

Replacement scoreboard that groups players by team or faction and displays additional stats like ping and play time.

---

### `liaCharacter`

**Base Panel:**

`EditablePanel`

**Description:**

Main panel of the character selection menu. Lists the player's characters with options to create, delete or load them.

---

### `liaCharBGMusic`

**Base Panel:**

`DPanel`

**Description:**

Small panel that plays ambient music when the main menu is open. It fades the track in and out as the menu is shown or closed.

---

### `liaCharacterCreation`

**Base Panel:**

`EditablePanel`

**Description:**

Parent panel that hosts each character creation step such as biography, faction and model. It provides navigation buttons and validates input before advancing.

---

### `liaCharacterCreateStep`

**Base Panel:**

`DScrollPanel`

**Description:**

Scroll panel used as the foundation for each creation step. Provides helpers for saving user input and moving forward in the flow.

---

### `liaCharacterConfirm`

**Base Panel:**

`SemiTransparentDFrame`

**Description:**

Confirmation dialog used for dangerous actions like deleting a character. Inherits from `SemiTransparentDFrame` for a consistent overlay look.

---

### `liaCharacterBiography`

**Base Panel:**

`liaCharacterCreateStep`

**Description:**

Step where players input their character's name and optional backstory. These values are validated and stored for later steps.

---

### `liaCharacterFaction`

**Base Panel:**

`liaCharacterCreateStep`

**Description:**

Allows the player to choose from available factions. The selected faction updates the model panel and determines accessible classes.

---

### `liaCharacterModel`

**Base Panel:**

`liaCharacterCreateStep`

**Description:**

Lets the player browse and select a player model appropriate for the chosen faction. Clicking an icon saves the choice and refreshes the preview.

---

### `liaInventory`

**Base Panel:**

`DFrame`

**Description:**

Main inventory frame for characters. It listens for network updates and renders items in the layout provided by its subclass.

---

### `liaGridInventory`

**Base Panel:**

`liaInventory`

**Description:**

Subclass of `liaInventory` that arranges item icons into a fixed grid. Often used for storage containers or equipment screens.

---

### `liaGridInvItem`

**Base Panel:**

`liaItemIcon`

**Description:**

Specialized icon used by `liaGridInventory`. Supports drag-and-drop for moving items between slots.

---

### `liaGridInventoryPanel`

**Base Panel:**

`DPanel`

**Description:**

Container responsible for laying out `liaGridInvItem` icons in rows and columns. Handles drag-and-drop and keeps the grid in sync with item data.

---

### `Vendor`

**Base Panel:**

`EditablePanel`

**Description:**

Main vendor window that lists items the NPC will buy or sell. Provides buttons for transactions and updates when the player's inventory changes.

---

### `VendorItem`

**Base Panel:**

`DPanel`

**Description:**

Panel representing an individual item within the vendor list. Shows price information and handles clicks for buying or selling.

---

### `VendorEditor`

**Base Panel:**

`DFrame`

**Description:**

Administrative window for editing a vendor's inventory and settings, including item prices and faction permissions.

---

### `VendorFactionEditor`

**Base Panel:**

`DFrame`

**Description:**

Secondary editor for selecting which factions and player classes can trade with the vendor.

---

### `VendorBodygroupEditor`

**Base Panel:**

`DFrame`

**Description:**

Window for adjusting a vendor's bodygroups and skin.

---

### `liaHugeButton`

**Base Panel:**

`DButton`

**Description:**

Large button styled with `liaHugeFont` and an underline effect on hover.

```lua
local btn = vgui.Create("liaHugeButton")
btn:SetText("Play")
btn:SetSelected(true) -- keep underline visible
```

---

### `liaBigButton`

**Base Panel:**

`DButton`

**Description:**

Big-font button with the same underline hover animation.

---

### `liaMediumButton`

**Base Panel:**

`DButton`

**Description:**

Medium-size button using `liaMediumFont`.

---

### `liaSmallButton`

**Base Panel:**

`DButton`

**Description:**

Small button sized for compact layouts.

---

### `liaMiniButton`

**Base Panel:**

`DButton`

**Description:**

Tiny button using `liaMiniFont` for dense interfaces.

---

### `liaNoBGButton`

**Base Panel:**

`DButton`

**Description:**

Text-only button that still shows the underline animation.

---

### `liaQuick`

**Base Panel:**

`EditablePanel`

**Description:**

Quick settings menu that lists options flagged with `isQuick`.

**Example Usage:**

```lua
vgui.Create("liaQuick")
```

---

### `liaCheckBox`

**Base Panel:**

`DButton`

**Description:**

Checkbox that paints the same checkmark icons used in the configuration menu.

**Example Usage:**

```lua
local cb = vgui.Create("liaCheckBox")
cb:SetChecked(true)
```

---

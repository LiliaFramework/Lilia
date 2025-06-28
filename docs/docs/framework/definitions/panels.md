# Panel Classes

This page lists the custom Panel classes provided by Lilia. Each panel inherits from an existing Garry's Mod base class and implements additional behaviour used throughout the framework.

---

## Panel Summary

| Panel Name | Base Panel | Purpose |
|------------|------------|---------|
| `liaMarkupPanel` | `DPanel` | Renders text using Garry's Mod markup. |
| `liaCharInfo` | `EditablePanel` | Displays character details in the F1 menu. |
| `liaMenu` | `EditablePanel` | Main F1 menu containing various tabs. |
| `liaClasses` | `EditablePanel` | Allows players to view and join classes. |
| `liaModelPanel` | `DModelPanel` | Model viewer with custom lighting. |
| `FacingModelPanel` | `DModelPanel` | Model viewer locked to the head angle. |
| `DProgressBar` | `DPanel` | Generic progress bar used during actions. |
| `liaNotice` | `DLabel` | Small blur-backed notification label. |
| `noticePanel` | `DPanel` | Larger notification with blur. |
| `liaChatBox` | `DPanel` | Custom chat box with filters and commands. |
| `liaSpawnIcon` | `DModelPanel` | Spawn icon with better lighting and FOV. |
| `VoicePanel` | `DPanel` | Shows players currently using voice chat. |
| `liaHorizontalScroll` | `DPanel` | Horizontally scrolling panel container. |
| `liaHorizontalScrollBar` | `DVScrollBar` | Scrollbar companion for the horizontal panel. |
| `liaItemMenu` | `EditablePanel` | Item interaction menu for world items. |
| `liaAttribBar` | `DPanel` | Widget for allocating attribute points. |
| `liaCharacterAttribs` | `liaCharacterCreateStep` | Step panel for attribute selection. |
| `liaCharacterAttribsRow` | `DPanel` | Displays a single attribute row. |
| `liaItemIcon` | `SpawnIcon` | Icon specialised for Lilia items. |
| `BlurredDFrame` | `DFrame` | Frame with a blurred background. |
| `SemiTransparentDFrame` | `DFrame` | Frame with a translucent background. |
| `SemiTransparentDPanel` | `DPanel` | Panel with a translucent background. |
| `liaDoorMenu` | `DFrame` | Door permissions and ownership menu. |
| `liaScoreboard` | `EditablePanel` | Custom scoreboard grouping players. |
| `liaCharacter` | `EditablePanel` | Main screen for character management. |
| `liaCharBGMusic` | `DPanel` | Handles background music playback. |
| `liaCharacterCreation` | `EditablePanel` | Multi-step character creation window. |
| `liaCharacterCreateStep` | `DScrollPanel` | Base panel for creation steps. |
| `liaCharacterConfirm` | `SemiTransparentDFrame` | Confirmation dialog used in the menu. |
| `liaCharacterBiography` | `liaCharacterCreateStep` | Biography entry step. |
| `liaCharacterFaction` | `liaCharacterCreateStep` | Faction selection step. |
| `liaCharacterModel` | `liaCharacterCreateStep` | Model selection step. |
| `liaInventory` | `DFrame` | Base inventory window. |
| `liaGridInventory` | `liaInventory` | Inventory using a grid of slots. |
| `liaGridInvItem` | `liaItemIcon` | Item icon used in grid inventories. |
| `liaGridInventoryPanel` | `DPanel` | Container for arranging grid item icons. |
| `Vendor` | `EditablePanel` | Vendor shop interface. |
| `VendorItem` | `DPanel` | Single item entry in the vendor menu. |
| `VendorEditor` | `DFrame` | Admin window for configuring vendors. |
| `VendorFactionEditor` | `DFrame` | Editor for vendor faction and class access. |

---

## Panel Details

The Lua reference comments under `docs/lua/definitions/panel_fields.lua` provide concise examples of how each panel can be created. Refer to those definitions for inline code snippets and usage notes.

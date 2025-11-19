# Panel Definitions

Comprehensive documentation for all Lilia VGUI panels.

---

Overview

This file contains detailed documentation for every panel in the Lilia framework. Each panel entry includes its purpose, explanation, usage scenarios, and available methods. This serves as a complete reference for developers working with Lilia's UI system, providing comprehensive information about panel functionality and parameters. The panels are organized into logical categories including character panels, attribute panels, basic UI panels, input/form panels, layout/container panels, specialized panels, inventory panels, and vendor panels. Each category groups related functionality together for easier navigation and understanding. Note: All panels documented below are actually implemented in the Lilia framework. A total of 60+ panels are available for use in UI development.

---

### liaCharacterBiography

#### 📋 Purpose
Displays character biography information
A panel that shows and allows editing of character biography text

#### ⏰ When Called
In character creation, character info display, or biography editing interfaces
]]

---

### liaCharacterFaction

#### 📋 Purpose
Displays and manages character faction selection
A panel for selecting and displaying character factions

#### ⏰ When Called
During character creation or faction management interfaces
]]

---

### liaCharacterModel

#### 📋 Purpose
Displays character model with customization options
A model panel specifically designed for character model display and customization

#### ⏰ When Called
In character creation, model selection, or character preview interfaces
]]

---

### liaCharBGMusic

#### 📋 Purpose
Manages character background music selection
A panel for selecting and previewing background music for characters

#### ⏰ When Called
In character creation or settings interfaces
]]

---

### liaCharacter

#### 📋 Purpose
Main character display and management panel
The primary panel for character information display and basic management

#### ⏰ When Called
In character selection, character info screens, or character management interfaces
]]

---

### liaCharacterConfirm

#### 📋 Purpose
Character confirmation dialog
A confirmation panel for character-related actions

#### ⏰ When Called
When confirming character creation, deletion, or other character actions
]]

---

### liaCharacterCreation

#### 📋 Purpose
Character creation interface
The main panel for creating new characters

#### ⏰ When Called
During the character creation process
]]

---

### liaCharacterCreateStep

#### 📋 Purpose
Individual character creation step
A panel representing a single step in character creation

#### ⏰ When Called
As part of the character creation process
]]

---

### liaAttribBar

#### 📋 Purpose
Displays attribute progress bar
A progress bar specifically designed for displaying attribute values

#### ⏰ When Called
In character creation, attribute display, or skill interfaces
]]

---

### liaCharacterAttribs

#### 📋 Purpose
Character attributes management panel
A panel for managing and displaying character attributes

#### ⏰ When Called
In character creation, attribute allocation, or character info screens
]]

---

### liaCharacterAttribsRow

#### 📋 Purpose
Individual attribute row in attributes panel
A single row representing one attribute with controls

#### ⏰ When Called
As part of the character attributes panel
]]

---

### liaButton

#### 📋 Purpose
Styled button with Lilia theming
A custom button panel with Lilia's visual styling and effects

#### ⏰ When Called
Throughout the UI for interactive elements
]]

---

### liaCategory

#### 📋 Purpose
Category header for organizing UI elements
A collapsible category header for grouping related UI elements

#### ⏰ When Called
In settings panels, option menus, or any organized interface
]]

---

### liaChatBox

#### 📋 Purpose
Main chat interface
The primary chat system interface with message display and input

#### ⏰ When Called
For all chat communication in the game
]]

---

### liaCheckbox

#### 📋 Purpose
Custom checkbox with Lilia styling
A toggle checkbox with custom visual design

#### ⏰ When Called
For boolean options, settings, or toggles
]]

---

### liaSimpleCheckbox

#### 📋 Purpose
Simple checkbox variant
A simplified checkbox without complex styling

#### ⏰ When Called
For basic boolean inputs where simple styling is preferred
]]

---

### liaCharInfo

#### 📋 Purpose
Character information display
A panel for displaying detailed character information

#### ⏰ When Called
In character selection, info screens, or character management
]]

---

### liaMenu

#### 📋 Purpose
Menu container panel
A container panel designed for menu layouts

#### ⏰ When Called
For main menus, submenus, or menu-based interfaces
]]

---

### liaClasses

#### 📋 Purpose
Character class selection
A panel for selecting character classes or jobs

#### ⏰ When Called
In character creation or class selection interfaces
]]

---

### liaComboBox

#### 📋 Purpose
Dropdown combo box
A dropdown selection box with custom styling

#### ⏰ When Called
For selecting from multiple options
]]

---

### liaDermaMenu

#### 📋 Purpose
Custom context menu
A styled context menu for right-click actions

#### ⏰ When Called
For context menus, right-click menus, or popup menus
]]

---

### liaDialogMenu

#### 📋 Purpose
NPC dialog interface
A comprehensive dialog system for NPC conversations with conversation history, response options, and server-side callbacks

#### ⏰ When Called
For NPC interactions, quest dialogs, or scripted conversations with non-player characters
]]

---

### liaDListView

#### 📋 Purpose
Custom list view
A styled list view with custom theming

#### ⏰ When Called
For displaying lists of items, data, or options
]]

---

### liaDoorMenu

#### 📋 Purpose
Door interaction menu
A specialized menu for door interactions

#### ⏰ When Called
When interacting with doors or similar entities
]]

---

### liaDProgressBar

#### 📋 Purpose
Progress bar with custom styling
A progress bar with Lilia theming and animations

#### ⏰ When Called
For loading bars, progress indicators, or value displays
]]

---

### liaEntry

#### 📋 Purpose
Text input entry field
A styled text input field with custom theming

#### ⏰ When Called
For text input, forms, or data entry
]]

---

### liaFrame

#### 📋 Purpose
Main frame container
The primary frame panel with title bar, close button, and theming

#### ⏰ When Called
As the main container for most UI windows and dialogs
]]

---

### liaItemList

#### 📋 Purpose
Item list display
A panel for displaying lists of items with icons and information

#### ⏰ When Called
In inventory interfaces, item selection, or item browsing
]]

---

### liaItemSelector

#### 📋 Purpose
Item selection interface
A specialized panel for selecting items from a list

#### ⏰ When Called
In item trading, crafting, or selection interfaces
]]

---

### liaHorizontalScroll

#### 📋 Purpose
Horizontal scroll container
A container that provides horizontal scrolling

#### ⏰ When Called
For horizontal layouts that need scrolling
]]

---

### liaHorizontalScrollBar

#### 📋 Purpose
Horizontal scroll bar
A horizontal scroll bar control

#### ⏰ When Called
With horizontal scroll panels
]]

---

### liaItemIcon

#### 📋 Purpose
Item icon display
A panel for displaying item icons with tooltips

#### ⏰ When Called
In inventory, item lists, or item displays
]]

---

### liaTabButton

#### 📋 Purpose
Tab button for tabbed interfaces
A button designed for tab navigation

#### ⏰ When Called
In tabbed interfaces or tab navigation
]]

---

### liaLoadingFailure

#### 📋 Purpose
Loading failure display
A panel shown when loading fails

#### ⏰ When Called
When content fails to load
]]

---

### liaModelPanel

#### 📋 Purpose
3D model display panel
A panel for displaying 3D models with camera controls

#### ⏰ When Called
For model previews, character display, or 3D content
]]

---

### liaFacingModelPanel

#### 📋 Purpose
Facing model panel for character display
A specialized model panel that faces the camera

#### ⏰ When Called
For character portraits or facing displays
]]

---

### liaNotice

#### 📋 Purpose
Notification display
A panel for displaying notifications or alerts

#### ⏰ When Called
For system notifications, alerts, or messages
]]

---

### liaNoticePanel

#### 📋 Purpose
Notice panel container
A container for multiple notice panels

#### ⏰ When Called
For managing multiple notifications
]]

---

### liaNumSlider

#### 📋 Purpose
Numeric slider control
A slider for numeric value input

#### ⏰ When Called
For numeric input with visual feedback
]]

---

### liaBlurredDFrame

#### 📋 Purpose
Blurred frame background
A frame with blurred background effect

#### ⏰ When Called
For modal dialogs or overlay frames
]]

---

### liaSemiTransparentDFrame

#### 📋 Purpose
Semi-transparent frame
A frame with semi-transparent background

#### ⏰ When Called
For overlay panels or semi-transparent windows
]]

---

### liaSemiTransparentDPanel

#### 📋 Purpose
Semi-transparent panel
A panel with semi-transparent background

#### ⏰ When Called
For overlay elements or semi-transparent containers
]]

---

### liaQuick

#### 📋 Purpose
Quick settings panel
A panel for quick access to settings and options

#### ⏰ When Called
For quick settings access or option panels
]]

---

### liaPrivilegeRow

#### 📋 Purpose
Privilege row display
A row displaying privilege information

#### ⏰ When Called
In admin panels or privilege management
]]

---

### liaRadialPanel

#### 📋 Purpose
Radial panel for circular layouts
A panel that arranges children in a radial pattern

#### ⏰ When Called
For radial menus, circular layouts, or radial interfaces
]]

---

### liaScoreboard

#### 📋 Purpose
Player scoreboard
A panel displaying player scores and information

#### ⏰ When Called
For displaying player rankings, scores, or statistics
]]

---

### liaScrollPanel

#### 📋 Purpose
Scrollable panel container
A panel that provides vertical scrolling for content

#### ⏰ When Called
For content that exceeds panel size
]]

---

### liaSheet

#### 📋 Purpose
Tabbed sheet container
A container that manages multiple tabbed panels

#### ⏰ When Called
For organizing content into tabs
]]

---

### liaSlideBox

#### 📋 Purpose
Sliding box container
A container that slides content in and out

#### ⏰ When Called
For sliding panels or animated content
]]

---

### liaSpawnIcon

#### 📋 Purpose
Spawn icon display
A panel for displaying spawn icons with tooltips

#### ⏰ When Called
For entity spawning, model selection, or icon displays
]]

---

### liaTable

#### 📋 Purpose
Data table display
A panel for displaying tabular data

#### ⏰ When Called
For data tables, lists, or structured information
]]

---

### liaTabs

#### 📋 Purpose
Tab navigation container
A container that manages tab navigation

#### ⏰ When Called
For tabbed interfaces or navigation
]]

---

### liaUserGroupButton

#### 📋 Purpose
User group button
A button representing a user group

#### ⏰ When Called
In admin panels or user management
]]

---

### liaUserGroupList

#### 📋 Purpose
User group list
A list displaying user groups

#### ⏰ When Called
In admin panels or user management interfaces
]]

---

### liaVoicePanel

#### 📋 Purpose
Voice panel for voice chat
A panel for voice chat controls and indicators

#### ⏰ When Called
For voice chat interfaces or voice controls
]]

---

### liaMarkupPanel

#### 📋 Purpose
Markup text display panel
A panel for displaying formatted markup text

#### ⏰ When Called
For rich text display, formatted content, or styled text
]]

---

### liaGridInvItem

#### 📋 Purpose
Grid inventory item
A single item in a grid-based inventory

#### ⏰ When Called
In grid inventory displays
]]

---

### liaGridInventoryPanel

#### 📋 Purpose
Grid inventory panel
A panel displaying inventory in grid format

#### ⏰ When Called
For grid-based inventory systems
]]

---

### liaInventory

#### 📋 Purpose
Main inventory interface
The primary inventory management interface

#### ⏰ When Called
For inventory management and item handling
]]

---

### liaGridInventory

#### 📋 Purpose
Grid inventory container
A container for grid-based inventory systems

#### ⏰ When Called
As the main container for grid inventories
]]

---

### liaVendor

#### 📋 Purpose
Vendor interface
A panel for vendor interactions and trading

#### ⏰ When Called
For NPC vendors, trading interfaces, or shops
]]

---

### liaVendorItem

#### 📋 Purpose
Vendor item display
A panel for displaying individual vendor items

#### ⏰ When Called
In vendor interfaces for item display
]]

---

### liaVendorEditor

#### 📋 Purpose
Vendor editor interface
A panel for editing vendor settings and items

#### ⏰ When Called
In admin panels for vendor management
]]

---

### liaVendorFactionEditor

#### 📋 Purpose
Vendor faction editor
A panel for editing vendor faction restrictions

#### ⏰ When Called
In admin panels for vendor faction management
]]

---

### liaVendorBodygroupEditor

#### 📋 Purpose
Vendor bodygroup editor
A panel for editing vendor bodygroup settings

#### ⏰ When Called
In admin panels for vendor appearance management
]]

---


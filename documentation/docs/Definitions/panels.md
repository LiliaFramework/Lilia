# Panel Definitions

Comprehensive documentation for all Lilia VGUI panels.

---

Overview

This file contains detailed documentation for every panel in the Lilia framework. Each panel entry includes its purpose, explanation, usage scenarios, and available methods. This serves as a complete reference for developers working with Lilia's UI system, providing comprehensive information about panel functionality and parameters. The panels are organized into logical categories including character panels, attribute panels, basic UI panels, input/form panels, layout/container panels, specialized panels, inventory panels, and vendor panels. Each category groups related functionality together for easier navigation and understanding. Note: All panels documented below are actually implemented in the Lilia framework. A total of 71 panels are available for use in UI development.

---

### liaCharacterBiography

#### 📋 Purpose
Displays character biography information
A panel that shows and allows editing of character biography text

#### ⏰ When Called
In character creation, character info display, or biography editing interfaces
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

### liaButton

#### 📋 Purpose
Styled button with Lilia theming and effects
A custom button panel with Lilia's visual styling, hover animations, ripple effects, and sound feedback

#### ⏰ When Called
Throughout the UI for interactive elements requiring prominent clickable areas
]]

---

### liaBigButton

#### 📋 Purpose
Large styled button with Lilia theming
A large button variant with Lilia's visual styling and effects

#### ⏰ When Called
For prominent UI elements requiring larger clickable areas
]]

---

### liaCustomFontButton

#### 📋 Purpose
Custom font styled button
A button variant that allows custom font specification

#### ⏰ When Called
When specific font styling is needed for buttons
]]

---

### liaHugeButton

#### 📋 Purpose
Huge styled button with Lilia theming
The largest button variant with Lilia's visual styling and effects

#### ⏰ When Called
For very prominent UI elements or main actions
]]

---

### liaLockCircle

#### 📋 Purpose
Lock circle progress indicator
A circular progress indicator with lock/unlock visual feedback

#### ⏰ When Called
For displaying lockpicking progress, loading states, or timed actions
]]

---

### liaMediumButton

#### 📋 Purpose
Medium styled button with Lilia theming
A medium-sized button variant with Lilia's visual styling and effects

#### ⏰ When Called
For standard UI buttons that need moderate prominence
]]

---

### liaMiniButton

#### 📋 Purpose
Miniature styled button with Lilia theming
A small button variant with Lilia's visual styling and effects

#### ⏰ When Called
For compact UI elements or secondary actions
]]

---

### liaNoBGButton

#### 📋 Purpose
No background styled button
A button variant without background styling for transparent effects

#### ⏰ When Called
When button text/icons need to appear without background panels
]]

---

### liaCategory

#### 📋 Purpose
Collapsible category header with Lilia styling
A styled category header that can expand/collapse to show/hide grouped content with smooth animations

#### ⏰ When Called
In settings panels, configuration menus, inventory categories, or any interface requiring organized content sections
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
Styled dropdown selection box
A customizable dropdown combo box with Lilia theming, smooth animations, and enhanced selection interface

#### ⏰ When Called
For character class/job selection, faction selection, or any multi-option choice requiring dropdown interface
]]

---

### liaDermaMenu

#### 📋 Purpose
Enhanced context menu with Lilia styling
A fully customizable context menu with Lilia theming, icons, submenus, and smooth animations for right-click interactions

#### ⏰ When Called
For entity interaction menus, admin tools, inventory actions, or any context-sensitive popup menu
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

### DialogMenu

#### 📋 Purpose
NPC dialog interface panel
The main dialog menu panel for NPC conversations with conversation history tracking, response display, and interactive dialog options

#### ⏰ When Called
When initiating NPC dialog interactions, quest conversations, or scripted dialogue sequences with non-player characters
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

### liaProgressBar

#### 📋 Purpose
Progress bar with custom styling
A progress bar with Lilia theming and animations

#### ⏰ When Called
For loading bars, progress indicators, or value displays
]]

---

### liaEntry

#### 📋 Purpose
Styled text input field with validation
A customizable text entry field with Lilia theming, placeholder text, character limits, and input validation

#### ⏰ When Called
For character names, descriptions, search fields, or any text input requiring enhanced styling and validation
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
Interactive 3D model viewer with controls
A 3D model display panel with mouse controls, zoom, rotation, and lighting for comprehensive model inspection

#### ⏰ When Called
For character model previews, item model displays, weapon showcases, or any 3D content visualization
]]

---

### liaFacingModelPanel

#### 📋 Purpose
Portrait-style facing model display
A specialized model panel that automatically rotates models to face the camera for consistent portrait views

#### ⏰ When Called
For character selection screens, profile displays, or any interface requiring standardized model presentation
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

### liaPaintedNotification

#### 📋 Purpose
Painted notification display
A custom notification panel with colored labels and styled text display

#### ⏰ When Called
For displaying server messages, system notifications, or custom alerts with colored labels
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

### liaSlider

#### 📋 Purpose
Custom slider control with smooth animations
A styled slider panel for numeric value input with smooth animations, convar synchronization support, and custom Lilia theming

#### ⏰ When Called
For settings panels, configuration interfaces, or any UI that requires smooth numeric value selection with visual feedback
]]

---

### liaSmallButton

#### 📋 Purpose
Small styled button with Lilia theming
A small button variant with Lilia's visual styling and effects

#### ⏰ When Called
For compact UI elements or secondary actions requiring standard styling
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
Interactive data table with sorting and filtering
A fully featured data table with column sorting, row selection, custom cell rendering, and Lilia theming

#### ⏰ When Called
For displaying structured data like player lists, item catalogs, server statistics, or admin management interfaces
]]

---

### liaTabs

#### 📋 Purpose
Tabbed interface container with smooth transitions
A container that manages multiple tabbed panels with smooth animations, custom styling, and organized content navigation

#### ⏰ When Called
For multi-section interfaces like character creation steps, settings panels, or complex UI with multiple views
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
Interactive grid inventory item with drag-and-drop
A single item slot in a grid inventory with drag-and-drop functionality, tooltips, and visual feedback

#### ⏰ When Called
As individual cells in grid-based inventory systems for item management and interaction
]]

---

### liaGridInventoryPanel

#### 📋 Purpose
Grid-based inventory display with pagination
A scrollable grid panel for displaying items in organized rows and columns with pagination support

#### ⏰ When Called
For comprehensive inventory management interfaces requiring organized item display and navigation
]]

---

### liaInventory

#### 📋 Purpose
Main inventory management interface
The primary inventory interface with drag-and-drop, item tooltips, quick actions, and comprehensive item management

#### ⏰ When Called
As the main player inventory interface for item storage, organization, and interaction
]]

---

### liaGridInventory

#### 📋 Purpose
Grid inventory container with advanced features
A feature-rich container for grid-based inventory systems with item filtering, search, and customization options

#### ⏰ When Called
As the main container for complex grid-based inventory systems requiring advanced functionality
]]

---

### liaVendor

#### 📋 Purpose
NPC vendor trading interface
A comprehensive vendor interface for buying and selling items with NPC merchants, including faction restrictions and pricing

#### ⏰ When Called
For NPC vendor interactions, marketplace systems, and economic trading interfaces
]]

---

### liaVendorItem

#### 📋 Purpose
Individual vendor item with pricing and actions
A single vendor item display showing price, stock, purchase options, and item details

#### ⏰ When Called
Within vendor interfaces to display individual items available for purchase or sale
]]

---

### liaVendorEditor

#### 📋 Purpose
Comprehensive vendor configuration editor
An administrative interface for creating and editing vendor NPCs, managing inventory, pricing, and vendor properties

#### ⏰ When Called
In admin panels for creating and configuring NPC vendors with full control over items and settings
]]

---

### liaVendorFactionEditor

#### 📋 Purpose
Vendor faction restriction manager
A specialized editor for configuring which factions can access specific vendors and their trading restrictions

#### ⏰ When Called
In admin panels to set up faction-based access controls for vendor interactions
]]

---

### liaVendorBodygroupEditor

#### 📋 Purpose
Vendor appearance customization editor
An interface for customizing vendor NPC bodygroups, skins, and visual appearance options

#### ⏰ When Called
In admin panels for fine-tuning vendor NPC visual presentation and customization options
]]

---


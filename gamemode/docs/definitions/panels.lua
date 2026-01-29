--[[
    Folder: Definitions
    File:  panels.md
]]

--[[
    Panel Definitions

    Comprehensive documentation for all Lilia VGUI panels.

    PLACEMENT INSTRUCTIONS:

    SCHEMA LOCATION:
    - Path: garrysmod/gamemodes/<SchemaName>/schema/panels/
    - File naming: Use descriptive names like "custom_panel.lua", "inventory_panel.lua"
    - Registration: Each file should define a PANEL table and register it using lia.panel.register()
    - Example: lia.panel.register("custom_panel", PANEL)

    MODULE LOCATION:
    - Path: garrysmod/gamemodes/<SchemaName>/modules/<ModuleName>/panels/
    - File naming: Use descriptive names like "sh_custom_panel.lua", "cl_custom_panel.lua"
    - Registration: Each file should define a PANEL table and register it using lia.panel.register()
    - Example: lia.panel.register("module_panel", PANEL)

    FILE STRUCTURE EXAMPLES:
    Schema: garrysmod/gamemodes/myschema/schema/panels/custom_panel.lua
    Module: garrysmod/gamemodes/myschema/modules/custommodule/panels/sh_custom_panel.lua

    NOTE: Panels are VGUI elements that provide user interface functionality. They can be used
    for character creation, inventory management, settings, and other UI interactions. All panels
    documented below are actually implemented in the Lilia framework and available for use.
]]
--[[
    Overview:
    This file contains detailed documentation for every panel in the Lilia framework. Each panel entry includes its purpose, explanation, usage scenarios, and available methods. This serves as a complete reference for developers working with Lilia's UI system, providing comprehensive information about panel functionality and parameters. The panels are organized into logical categories including character panels, attribute panels, basic UI panels, input/form panels, layout/container panels, specialized panels, inventory panels, and vendor panels. Each category groups related functionality together for easier navigation and understanding. Note: All panels documented below are actually implemented in the Lilia framework. A total of 71 panels are available for use in UI development.
]]
--[[
    Purpose:
        Displays character biography information
        A panel that shows and allows editing of character biography text
    When Used:
        In character creation, character info display, or biography editing interfaces
]]
liaCharacterBiography
--[[
    Purpose:
        Displays character model with customization options
        A model panel specifically designed for character model display and customization
    When Used:
        In character creation, model selection, or character preview interfaces
]]
liaCharacterModel
--[[
    Purpose:
        Manages character background music selection
        A panel for selecting and previewing background music for characters
    When Used:
        In character creation or settings interfaces
]]
liaCharBGMusic
--[[
    Purpose:
        Main character display and management panel
        The primary panel for character information display and basic management
    When Used:
        In character selection, character info screens, or character management interfaces
]]
liaCharacter
--[[
    Purpose:
        Character confirmation dialog
        A confirmation panel for character-related actions
    When Used:
        When confirming character creation, deletion, or other character actions
]]
liaCharacterConfirm
--[[
    Purpose:
        Character creation interface
        The main panel for creating new characters
    When Used:
        During the character creation process
]]
liaCharacterCreation
--[[
    Purpose:
        Individual character creation step
        A panel representing a single step in character creation
    When Used:
        As part of the character creation process
]]
liaCharacterCreateStep
--[[
    Purpose:
        Interactive attribute value bar with increment/decrement controls
        A progress bar panel with add/subtract buttons for adjusting numeric values, featuring smooth animations, boost value visualization, and customizable maximum limits
    When Used:
        For attribute point allocation, skill point distribution, or any numeric value adjustment interface requiring visual feedback
]]
liaAttribBar
--[[
    Purpose:
        Character attribute allocation interface
        A comprehensive panel for managing character attribute point distribution during character creation, displaying available points and individual attribute controls
    When Used:
        In character creation interfaces for allocating starting attribute points, managing attribute bonuses, or configuring character statistics
]]
liaCharacterAttribs
--[[
    Purpose:
        Individual attribute row with point controls
        A single row panel displaying an attribute name, current point value, and increment/decrement buttons for adjusting attribute allocation
    When Used:
        Within character attribute interfaces to display and manage individual attribute point allocation with visual feedback and sound cues
]]
liaCharacterAttribsRow
--[[
    Purpose:
        Styled button with Lilia theming and effects
        A custom button panel with Lilia's visual styling, hover animations, ripple effects, and sound feedback
    When Used:
        Throughout the UI for interactive elements requiring prominent clickable areas
]]
liaButton
--[[
    Purpose:
        Large styled button with Lilia theming
        A large button variant with Lilia's visual styling and effects
    When Used:
        For prominent UI elements requiring larger clickable areas
]]
liaBigButton
--[[
    Purpose:
        Custom font styled button
        A button variant that allows custom font specification
    When Used:
        When specific font styling is needed for buttons
]]
liaCustomFontButton
--[[
    Purpose:
        Huge styled button with Lilia theming
        The largest button variant with Lilia's visual styling and effects
    When Used:
        For very prominent UI elements or main actions
]]
liaHugeButton
--[[
    Purpose:
        Lock circle progress indicator
        A circular progress indicator with lock/unlock visual feedback
    When Used:
        For displaying lockpicking progress, loading states, or timed actions
]]
liaLockCircle
--[[
    Purpose:
        Medium styled button with Lilia theming
        A medium-sized button variant with Lilia's visual styling and effects
    When Used:
        For standard UI buttons that need moderate prominence
]]
liaMediumButton
--[[
    Purpose:
        Miniature styled button with Lilia theming
        A small button variant with Lilia's visual styling and effects
    When Used:
        For compact UI elements or secondary actions
]]
liaMiniButton
--[[
    Purpose:
        No background styled button
        A button variant without background styling for transparent effects
    When Used:
        When button text/icons need to appear without background panels
]]
liaNoBGButton
--[[
    Purpose:
        Collapsible category header with Lilia styling
        A styled category header that can expand/collapse to show/hide grouped content with smooth animations
    When Used:
        In settings panels, configuration menus, inventory categories, or any interface requiring organized content sections
]]
liaCategory
--[[
    Purpose:
        Main chat interface
        The primary chat system interface with message display and input
    When Used:
        For all chat communication in the game
]]
liaChatBox
--[[
    Purpose:
        Custom checkbox with Lilia styling
        A toggle checkbox with custom visual design
    When Used:
        For boolean options, settings, or toggles
]]
liaCheckbox
--[[
    Purpose:
        Simple checkbox variant
        A simplified checkbox without complex styling
    When Used:
        For basic boolean inputs where simple styling is preferred
]]
liaSimpleCheckbox
--[[
    Purpose:
        Character information display
        A panel for displaying detailed character information
    When Used:
        In character selection, info screens, or character management
]]
liaCharInfo
--[[
    Purpose:
        Menu container panel
        A container panel designed for menu layouts
    When Used:
        For main menus, submenus, or menu-based interfaces
]]
liaMenu
--[[
    Purpose:
        Character class selection
        A panel for selecting character classes or jobs
    When Used:
        In character creation or class selection interfaces
]]
liaClasses
--[[
    Purpose:
        Styled dropdown selection box
        A customizable dropdown combo box with Lilia theming, smooth animations, and enhanced selection interface
    When Used:
        For character class/job selection, faction selection, or any multi-option choice requiring dropdown interface
]]
liaComboBox
--[[
    Purpose:
        Enhanced context menu with Lilia styling
        A fully customizable context menu with Lilia theming, icons, submenus, and smooth animations for right-click interactions
    When Used:
        For entity interaction menus, admin tools, inventory actions, or any context-sensitive popup menu
]]
liaDermaMenu
--[[
    Purpose:
        NPC dialog interface panel
        The main dialog menu panel for NPC conversations with conversation history tracking, response display, and interactive dialog options
    When Used:
        When initiating NPC dialog interactions, quest conversations, or scripted dialogue sequences with non-player characters
]]
DialogMenu
--[[
    Purpose:
        Custom list view
        A styled list view with custom theming
    When Used:
        For displaying lists of items, data, or options
]]
liaDListView
--[[
    Purpose:
        Door interaction menu
        A specialized menu for door interactions
    When Used:
        When interacting with doors or similar entities
]]
liaDoorMenu
--[[
    Purpose:
        Progress bar with custom styling
        A progress bar with Lilia theming and animations
    When Used:
        For loading bars, progress indicators, or value displays
]]
liaProgressBar
--[[
    Purpose:
        Styled text input field with validation
        A customizable text entry field with Lilia theming, placeholder text, character limits, and input validation
    When Used:
        For character names, descriptions, search fields, or any text input requiring enhanced styling and validation
]]
liaEntry
--[[
    Purpose:
        Main frame container
        The primary frame panel with title bar, close button, and theming
    When Used:
        As the main container for most UI windows and dialogs
]]
liaFrame
--[[
    Purpose:
        Item list display
        A panel for displaying lists of items with icons and information
    When Used:
        In inventory interfaces, item selection, or item browsing
]]
liaItemList
--[[
    Purpose:
        Item selection interface
        A specialized panel for selecting items from a list
    When Used:
        In item trading, crafting, or selection interfaces
]]
liaItemSelector
--[[
    Purpose:
        Horizontal scroll container
        A container that provides horizontal scrolling
    When Used:
        For horizontal layouts that need scrolling
]]
liaHorizontalScroll
--[[
    Purpose:
        Horizontal scroll bar
        A horizontal scroll bar control
    When Used:
        With horizontal scroll panels
]]
liaHorizontalScrollBar
--[[
    Purpose:
        Item icon display
        A panel for displaying item icons with tooltips
    When Used:
        In inventory, item lists, or item displays
]]
liaItemIcon
--[[
    Purpose:
        Tab button for tabbed interfaces
        A button designed for tab navigation
    When Used:
        In tabbed interfaces or tab navigation
]]
liaTabButton
--[[
    Purpose:
        Interactive 3D model viewer with controls
        A 3D model display panel with mouse controls, zoom, rotation, and lighting for comprehensive model inspection
    When Used:
        For character model previews, item model displays, weapon showcases, or any 3D content visualization
]]
liaModelPanel
--[[
    Purpose:
        Notification display
        A panel for displaying notifications or alerts
    When Used:
        For system notifications, alerts, or messages
]]
liaNotice
--[[
    Purpose:
        Notice panel container
        A container for multiple notice panels
    When Used:
        For managing multiple notifications
]]
liaNoticePanel
--[[
    Purpose:
        Painted notification display
        A custom notification panel with colored labels and styled text display
    When Used:
        For displaying server messages, system notifications, or custom alerts with colored labels
]]
liaPaintedNotification
--[[
    Purpose:
        Blurred frame background
        A frame with blurred background effect
    When Used:
        For modal dialogs or overlay frames
]]
liaBlurredDFrame
--[[
    Purpose:
        Semi-transparent frame
        A frame with semi-transparent background
    When Used:
        For overlay panels or semi-transparent windows
]]
liaSemiTransparentDFrame
--[[
    Purpose:
        Semi-transparent panel
        A panel with semi-transparent background
    When Used:
        For overlay elements or semi-transparent containers
]]
liaSemiTransparentDPanel
--[[
    Purpose:
        Quick settings panel
        A panel for quick access to settings and options
    When Used:
        For quick settings access or option panels
]]
liaQuick
--[[
    Purpose:
        Privilege row display
        A row displaying privilege information
    When Used:
        In admin panels or privilege management
]]
liaPrivilegeRow
--[[
    Purpose:
        Radial panel for circular layouts
        A panel that arranges children in a radial pattern
    When Used:
        For radial menus, circular layouts, or radial interfaces
]]
liaRadialPanel
--[[
    Purpose:
        Player scoreboard
        A panel displaying player scores and information
    When Used:
        For displaying player rankings, scores, or statistics
]]
liaScoreboard
--[[
    Purpose:
        Scrollable panel container
        A panel that provides vertical scrolling for content
    When Used:
        For content that exceeds panel size
]]
liaScrollPanel
--[[
    Purpose:
        Tabbed sheet container
        A container that manages multiple tabbed panels
    When Used:
        For organizing content into tabs
]]
liaSheet
--[[
    Purpose:
        Sliding box container
        A container that slides content in and out
    When Used:
        For sliding panels or animated content
]]
liaSlideBox
--[[
    Purpose:
        Custom slider control with smooth animations
        A styled slider panel for numeric value input with smooth animations, convar synchronization support, and custom Lilia theming
    When Used:
        For settings panels, configuration interfaces, or any UI that requires smooth numeric value selection with visual feedback
]]
liaSlider
--[[
    Purpose:
        Small styled button with Lilia theming
        A small button variant with Lilia's visual styling and effects
    When Used:
        For compact UI elements or secondary actions requiring standard styling
]]
liaSmallButton
--[[
    Purpose:
        Spawn icon display
        A panel for displaying spawn icons with tooltips
    When Used:
        For entity spawning, model selection, or icon displays
]]
liaSpawnIcon
--[[
    Purpose:
        Interactive data table with sorting and filtering
        A fully featured data table with column sorting, row selection, custom cell rendering, and Lilia theming
    When Used:
        For displaying structured data like player lists, item catalogs, server statistics, or admin management interfaces
]]
liaTable
--[[
    Purpose:
        Tabbed interface container with smooth transitions
        A container that manages multiple tabbed panels with smooth animations, custom styling, and organized content navigation
    When Used:
        For multi-section interfaces like character creation steps, settings panels, or complex UI with multiple views
]]
liaTabs
--[[
    Purpose:
        User group button
        A button representing a user group
    When Used:
        In admin panels or user management
]]
liaUserGroupButton
--[[
    Purpose:
        User group list
        A list displaying user groups
    When Used:
        In admin panels or user management interfaces
]]
liaUserGroupList
--[[
    Purpose:
        Voice panel for voice chat
        A panel for voice chat controls and indicators
    When Used:
        For voice chat interfaces or voice controls
]]
liaVoicePanel
--[[
    Purpose:
        Markup text display panel
        A panel for displaying formatted markup text
    When Used:
        For rich text display, formatted content, or styled text
]]
liaMarkupPanel
--[[
    Purpose:
        Interactive grid inventory item with drag-and-drop
        A single item slot in a grid inventory with drag-and-drop functionality, tooltips, and visual feedback
    When Used:
        As individual cells in grid-based inventory systems for item management and interaction
]]
liaGridInvItem
--[[
    Purpose:
        Grid-based inventory display with pagination
        A scrollable grid panel for displaying items in organized rows and columns with pagination support
    When Used:
        For comprehensive inventory management interfaces requiring organized item display and navigation
]]
liaGridInventoryPanel
--[[
    Purpose:
        Main inventory management interface
        The primary inventory interface with drag-and-drop, item tooltips, quick actions, and comprehensive item management
    When Used:
        As the main player inventory interface for item storage, organization, and interaction
]]
liaInventory
--[[
    Purpose:
        Grid inventory container with advanced features
        A feature-rich container for grid-based inventory systems with item filtering, search, and customization options
    When Used:
        As the main container for complex grid-based inventory systems requiring advanced functionality
]]
liaGridInventory
--[[
    Purpose:
        NPC vendor trading interface
        A comprehensive vendor interface for buying and selling items with NPC merchants, including faction restrictions and pricing
    When Used:
        For NPC vendor interactions, marketplace systems, and economic trading interfaces
]]
liaVendor
--[[
    Purpose:
        Individual vendor item with pricing and actions
        A single vendor item display showing price, stock, purchase options, and item details
    When Used:
        Within vendor interfaces to display individual items available for purchase or sale
]]
liaVendorItem
--[[
    Purpose:
        Comprehensive vendor configuration editor
        An administrative interface for creating and editing vendor NPCs, managing inventory, pricing, and vendor properties
    When Used:
        In admin panels for creating and configuring NPC vendors with full control over items and settings
]]
liaVendorEditor
--[[
    Purpose:
        Vendor faction restriction manager
        A specialized editor for configuring which factions can access specific vendors and their trading restrictions
    When Used:
        In admin panels to set up faction-based access controls for vendor interactions
]]
liaVendorFactionEditor
--[[
    Purpose:
        Vendor appearance customization editor
        An interface for customizing vendor NPC bodygroups, skins, and visual appearance options
    When Used:
        In admin panels for fine-tuning vendor NPC visual presentation and customization options
]]
liaVendorBodygroupEditor
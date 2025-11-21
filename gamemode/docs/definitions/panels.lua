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
    This file contains detailed documentation for every panel in the Lilia framework. Each panel entry includes its purpose, explanation, usage scenarios, and available methods. This serves as a complete reference for developers working with Lilia's UI system, providing comprehensive information about panel functionality and parameters. The panels are organized into logical categories including character panels, attribute panels, basic UI panels, input/form panels, layout/container panels, specialized panels, inventory panels, and vendor panels. Each category groups related functionality together for easier navigation and understanding. Note: All panels documented below are actually implemented in the Lilia framework. A total of 60+ panels are available for use in UI development.
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
        Displays and manages character faction selection
        A panel for selecting and displaying character factions
    When Used:
        During character creation or faction management interfaces
]]
liaCharacterFaction
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
        Displays attribute progress bar
        A progress bar specifically designed for displaying attribute values
    When Used:
        In character creation, attribute display, or skill interfaces
]]
liaAttribBar
--[[
    Purpose:
        Character attributes management panel
        A panel for managing and displaying character attributes
    When Used:
        In character creation, attribute allocation, or character info screens
]]
liaCharacterAttribs
--[[
    Purpose:
        Individual attribute row in attributes panel
        A single row representing one attribute with controls
    When Used:
        As part of the character attributes panel
]]
liaCharacterAttribsRow
--[[
    Purpose:
        Styled button with Lilia theming
        A custom button panel with Lilia's visual styling and effects
    When Used:
        Throughout the UI for interactive elements
]]
liaButton
--[[
    Purpose:
        Category header for organizing UI elements
        A collapsible category header for grouping related UI elements
    When Used:
        In settings panels, option menus, or any organized interface
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
        Dropdown combo box
        A dropdown selection box with custom styling
    When Used:
        For selecting from multiple options
]]
liaComboBox
--[[
    Purpose:
        Custom context menu
        A styled context menu for right-click actions
    When Used:
        For context menus, right-click menus, or popup menus
]]
liaDermaMenu
--[[
    Purpose:
        NPC dialog interface
        A comprehensive dialog system for NPC conversations with conversation history, response options, and server-side callbacks
    When Used:
        For NPC interactions, quest dialogs, or scripted conversations with non-player characters
]]
liaDialogMenu
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
        Text input entry field
        A styled text input field with custom theming
    When Used:
        For text input, forms, or data entry
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
        Loading failure display
        A panel shown when loading fails
    When Used:
        When content fails to load
]]
liaLoadingFailure
--[[
    Purpose:
        3D model display panel
        A panel for displaying 3D models with camera controls
    When Used:
        For model previews, character display, or 3D content
]]
liaModelPanel
--[[
    Purpose:
        Facing model panel for character display
        A specialized model panel that faces the camera
    When Used:
        For character portraits or facing displays
]]
liaFacingModelPanel
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
        Numeric slider control
        A slider for numeric value input
    When Used:
        For numeric input with visual feedback
]]
liaNumSlider
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
liaSlider
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
        Data table display
        A panel for displaying tabular data
    When Used:
        For data tables, lists, or structured information
]]
liaTable
--[[
    Purpose:
        Tab navigation container
        A container that manages tab navigation
    When Used:
        For tabbed interfaces or navigation
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
        Grid inventory item
        A single item in a grid-based inventory
    When Used:
        In grid inventory displays
]]
liaGridInvItem
--[[
    Purpose:
        Grid inventory panel
        A panel displaying inventory in grid format
    When Used:
        For grid-based inventory systems
]]
liaGridInventoryPanel
--[[
    Purpose:
        Main inventory interface
        The primary inventory management interface
    When Used:
        For inventory management and item handling
]]
liaInventory
--[[
    Purpose:
        Grid inventory container
        A container for grid-based inventory systems
    When Used:
        As the main container for grid inventories
]]
liaGridInventory
--[[
    Purpose:
        Vendor interface
        A panel for vendor interactions and trading
    When Used:
        For NPC vendors, trading interfaces, or shops
]]
liaVendor
--[[
    Purpose:
        Vendor item display
        A panel for displaying individual vendor items
    When Used:
        In vendor interfaces for item display
]]
liaVendorItem
--[[
    Purpose:
        Vendor editor interface
        A panel for editing vendor settings and items
    When Used:
        In admin panels for vendor management
]]
liaVendorEditor
--[[
    Purpose:
        Vendor faction editor
        A panel for editing vendor faction restrictions
    When Used:
        In admin panels for vendor faction management
]]
liaVendorFactionEditor
--[[
    Purpose:
        Vendor bodygroup editor
        A panel for editing vendor bodygroup settings
    When Used:
        In admin panels for vendor appearance management
]]
liaVendorBodygroupEditor
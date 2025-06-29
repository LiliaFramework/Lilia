# Feature List

---

This page provides an extensive overview of the core modules and libraries included with Lilia. Use it as a quick reference for the capabilities baked into the framework.

### Grid Inventory
- Drag-and-drop item placement using a grid layout
- Supports backpacks, lockers, vehicle trunks and other containers
- Weight limits and configurable width/height
- Virtual inventories for vendors and temporary storage
- Admin commands to resize or wipe inventories

### Recognition
- Manually recognize other players within whisper, talk or yell range
- Optional faction auto-recognition and global faction recognition
- Fake name support for disguises
- Hooks to check recognition and trigger events when recognized

### Attributes
- Character-bound statistics that affect gameplay
- Load attributes from schema folders at runtime
- Hooks for modifying attribute values on events
- Bonuses and penalties applied to relevant actions

### F1 Menu
- Staff tools for teleporting to entities and viewing lists
- Access character sub-menus and module management
- Default tab can be configured
- Admin options integrated with the scoreboard

### Scoreboard
- Roleplay-themed scoreboard with recognition integration
- Context menu for admin actions like kick or mute
- Width, height and background color can be configured
- Optionally show class logos and group headers

### Chatbox
- Customizable chat colors and message length limits
- OOC/LOOC delay timers and chat range controls
- Optional custom chat sounds
- Listen color highlighting when directly addressed

### Main Menu
- Character selection and creation interface
- Supports custom background image and music
- Links to Discord and Workshop pages
- Optional centered logo and background input toggle

### Weapon Selector
- Radial weapon menu with smooth fade animations
- Obeys hooks to decide when it appears
- Works with weapon categories from the Easy Weapons system

### Spawns
- Manage player spawn points per faction or class
- Loss of marked items on death by NPCs, players or the world
- Death popup explaining cause of death
- Staff on duty can spawn with god mode

### Teams
- Faction and class management helpers
- Permanent classes saved on characters
- Optionally display class information above players
- Hooks for custom team loadouts and spawns

### Interaction Menu
- Quick-access radial menu for common actions
- Give money or change voice type directly from the menu
- Recognize characters from whisper/talk/yell range
- Extensible via `AddAction` and `AddInteraction`

### Administration Utilities
- Central logging, warning history and ticket system
- Item spawner GUI for events and testing
- Permission management integrated with CAMI

### Performance
- Libraries focused on optimizing heavy operations
- Useful for tracking tick rate and network performance

### Protection
- Anti-exploitation features such as alting notifications
- Cooldowns on character switching after taking damage
- Delays for equipping, dropping and giving items
- Ragdoll options for explosions and vehicles
- Cleanup timers for dropped weapons
- Option to disable potentially dangerous console commands

### Admin Stick
- Staff-only SWEP for quick moderation actions
- Teleport, freeze and noclip functions

### Item Spawner
- GUI interface to spawn any item
- Respects privilege checks before spawning
- Search and filter through items

### Tickets
- Players can submit tickets that staff can claim
- Notifies staff members and records ticket history

### Warns
- Issue warnings with reasons and durations
- Stores warning history for each player

### Permissions
- CAMI-based framework for defining privileges
- ESP tools and spawn menu restrictions configurable

### Logging
- Log server events with category filtering
- Configurable retention time and line limits

### Easy Weapons
- Automatically generates items from installed weapons
- Hold-type mapping defines item size and category
- Weapon overrides for custom names or models
- Blacklist unwanted weapons from registration

### Doors
- Ownable doors with selling and price settings
- Faction or class based access control
- Lock and unlock using the key SWEP
- Configurable lock times and sell ratio
- Supports linked child doors

### Third Person
- Toggleable third-person view with camera options
- Adjustable distance, height and horizontal offset
- Wall-peek prevention and max view distance limits
- Classic mode option for old-school behaviour

### Storage Containers
- Crates, lockers, fridges and more with predefined sizes
- Vehicle trunk storage supported
- Optional open/close animations for certain models
- Uses grid inventories internally

### NPC Vendors
- NPCs that buy and sell items using the inventory system
- Default money amount configurable
- Admin editing privileges for vendor stock
- Dialogue and camera view support

### Attributes Library
- Manage character attribute values and levels
- Provides hooks for attribute setup and change events
- Automatically network attribute progress to clients

### Bars
- Draw health, armor and custom HUD bars
- Smooth animations and customizable colors
- Register new bar types through a simple API

### Character Library
- Helper functions for accessing character data
- Transfer characters between players
- Save and load variables seamlessly

### Chatbox Library
- Building blocks for custom chat classes
- Utilities for sending formatted messages
- Overridable parsing for unique chat effects

### Classes Library
- Register player classes with spawn data and loadouts
- Integrates class logos into the scoreboard
- Handles class whitelisting and restrictions

### Color Utilities
- Helper functions for color math and interpolation
- Convert between HSV and RGB color spaces
- Ease color transitions with preset curves

### Commands Library
- Register chat commands with syntax parsing
- Built-in access checks and argument extraction
- Hook support for custom command types

### Config Library
- Register server configs with categories and callbacks
- In-game menu for adjusting values
- Automatically network configs to clients

### Currency Library
- Format amounts with currency symbols
- Spawn money entities in the world
- Hooks for payments and transactions

### DarkRP Compatibility
- Hooks for integrating with DarkRP wallets and systems
- Optionally sync lia.money with DarkRP balance
- Convert existing DarkRP jobs to Lilia factions

### Data Library
- Key/value storage wrappers with automatic serialization
- Supports default values and lazy loading
- Synchronous and asynchronous access helpers

### Database Library
- Interface for saving characters and items asynchronously
- Abstraction layer for MySQL or SQLite backends
- Queues database actions to avoid blocking

### Factions Library
- Create factions with colors, models and global recognition
- Manage faction whitelists and default classes
- Provide cross-faction communication hooks

### Flags Library
- Permission flags assignable to players
- Simple hasFlag helper for checks
- Combine with commands for fine-grained access

### Fonts Library
- Register custom fonts for the UI
- Scale fonts for different resolutions
- Preload fonts to avoid runtime hitches

### Inventory Library
- Shared logic for inventories including networking
- Supports weight limits and stack sizes
- Parent and child inventory relationships

### Item Library
- Framework for defining items with metadata and hooks
- Supports consumables, weapons and clothing types
- Easy creation of networked item instances

### Keybind Library
- Add custom client keybinds and save them per player
- Rebind keys through a menu interface
- Hook into press and release events

### Languages Library
- Multi-language phrase system with fallback support
- Merge phrases from schemas and plugins
- String interpolation with variables

### Logger Library
- Simplified logging functions for modules
- Write formatted logs to disk with timestamps
- Configurable log levels and filters

### Markup Library
- Parse and render markup or BBCode text
- Supports images, icons and custom fonts
- Word wrap and measurement helpers

### Menu Helper
- Utility functions for building Derma menus
- Predefined button, slider and text entry helpers
- Layout features for tool panels

### Modularity
- Dynamic loading and disabling of modules and plugins
- Hot-reload plugins without restarting the server
- Ordered search for schema-specific modules

### Networking
- Netstream utilities for efficient communication
- Automatic compression for larger payloads
- Request/response pattern for RPC-style calls

### Notice System
- On-screen notifications with queueing
- Custom icons and sound effects
- Fade animations and stacking behaviour

### Option Library
- Store player preferences using sliders and checkboxes
- Categorize options per module or plugin
- Network options to and from the server

### Salary System
- Periodic salary payouts for characters
- Configurable intervals and amounts
- Commands to set starting wages

### Time Library
- Scheduler helpers and shared timers
- Real time to game time conversions
- Delay utilities for repeating tasks

### Util Library
- Miscellaneous helper functions used across modules
- String and table utilities for common patterns
- Math helpers for clamping and rounding

### Web Image
- Download and cache web images for the UI
- Verify image URLs before requesting them
- Save local copies to reduce bandwidth

### Workshop
- Manage Steam Workshop downloads for clients
- Add resource packs from the configuration
- Update notifications for outdated addons

### Configuration Options

The `config` library exposes numerous settings allowing you to control walk and run speeds, voice chat, crosshair usage, salary intervals, theme colors, workshop downloads, and much more. These options can be tweaked in game via the configuration menu.

---